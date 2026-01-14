#include <random>
#include <chrono>
#include <iostream>
#include <cstdlib>
#include <cstdint>
#include <vector>
#include <atomic>
#include <cstring>
#include <cstdio>
#include <omp.h>
#include <sched.h>


// Accumulator struct - alignment controlled at runtime via command-line argument
struct Accumulator {
  std::atomic<uint32_t> value{0};
};

// Cache-line aligned version to prevent false sharing
struct alignas(64) AlignedAccumulator {
  std::atomic<uint32_t> value{0};
};

template<typename AccumulatorType>
size_t workload(const std::vector<uint32_t> &data, int thread_count, std::vector<AccumulatorType>& accumulators) {
  // Process data in parallel using OpenMP
  // Note: Using atomic counters prevents compiler from optimizing away memory stores
  #pragma omp parallel num_threads(thread_count) default(none) \
      shared(accumulators, data)
  {
    // Each thread gets its own accumulator to update
    const int thread_id = omp_get_thread_num();
    auto &thread_accumulator = accumulators[thread_id];

    // Distribute loop iterations across threads
    #pragma omp for
    for (size_t i = 0; i < data.size(); i++) {
      // Load input value
      uint32_t item = data[i];
      
      // Perform dummy read from accumulator to create load-store pattern
      // This is critical for perf to detect false sharing: without the load,
      // only store-store patterns occur, which perf SPE doesn't flag as modified
      // data from peer clusters. The load-store sequence makes false sharing visible in Perf C2C.
      volatile int current_value = thread_accumulator.value;
      (void)current_value;  // Suppress unused variable warning
      
      // Apply transformations to input value
      item += 1000;              // Arithmetic operation
      item ^= 0xADEDAE;          // XOR with constant
      item |= (item >> 8);      // Combine with shifted bits
      
      // Accumulate the transformed result (modulo to keep values bounded)
      thread_accumulator.value += item % 100;
    }
  }

  // Aggregate results from all thread-local accumulators (reduction phase)
  // Note: We intentionally do NOT useomp reduction to demonstrate false sharing in the parallel loop above.
  size_t total_result = 0;
  for (const auto &accumulator : accumulators) {
    total_result += accumulator.value;
  }
  
  return total_result;
}

template<typename AccumulatorType>
void print_accumulator_addresses(const std::vector<AccumulatorType>& accumulators, int thread_count) {
#pragma omp parallel num_threads(thread_count) default(none) shared(accumulators)
  {
    const int tid = omp_get_thread_num();
    int cpu = sched_getcpu();
    const int idx = tid; // thread i -> accumulators[i]
    auto* addr = const_cast<AccumulatorType*>(&accumulators[idx]);
    void* line_base = reinterpret_cast<void*>(reinterpret_cast<uintptr_t>(addr) & ~static_cast<uintptr_t>(63));
    std::printf("CPU %2d -> Thread %2d -> accumulators[%d] @ %p (cacheline %p)\n", cpu, tid, idx, static_cast<void*>(addr), line_base);
  }
}

void print_usage(const char* program_name) {
    std::cout << "Usage: " << program_name << " [num_elements] [thread_count] [align=true|align=false]\n\n"
              << "Arguments:\n"
              << "  num_elements   Number of elements to process (default: 5,000,000)\n"
              << "  thread_count   Number of threads to use (default: max available)\n"
              << "  align=true     Use cache-line aligned accumulators (no false sharing)\n"
              << "  align=false    Use non-aligned accumulators (false sharing enabled, default)\n\n"
              << "Examples:\n"
              << "  " << program_name << "                          # Run with defaults (false sharing)\n"
              << "  " << program_name << " 10000000 8              # 10M elements, 8 threads, false sharing\n"
              << "  " << program_name << " 10000000 8 align=true   # 10M elements, 8 threads, no false sharing\n"
              << "  " << program_name << " 10000000 8 align=false  # 10M elements, 8 threads, false sharing\n\n";
}

int main(int argc, char** argv) {
    // Check for help flag
    if (argc > 1 && (std::string(argv[1]) == "-h" || std::string(argv[1]) == "--help")) {
        print_usage(argv[0]);
        return 0;
    }

    // Args: [num_elements] [thread_count] [align=true|align=false]
    size_t num_elements = (argc > 1) ? static_cast<size_t>(std::strtoull(argv[1], nullptr, 10))
                                     : 5'000'000ULL;

#ifdef _OPENMP
    int thread_count = (argc > 2) ? std::atoi(argv[2]) : omp_get_max_threads();
#else
    int thread_count = (argc > 2) ? std::atoi(argv[2]) : 1;
#endif
    if (thread_count <= 0) thread_count = 1;

    // Third argument: align=true for cache-line aligned, align=false or omitted for false sharing
    bool use_alignment = false;
    if (argc > 3) {
        std::string align_arg(argv[3]);
        use_alignment = (align_arg == "align=true");
    }

    if (use_alignment) {
        // Use cache-line aligned accumulators (NO false sharing)
        std::vector<AlignedAccumulator> accumulators(thread_count);
        
        // Generate input data
        std::vector<uint32_t> data(num_elements);
        std::mt19937 rng(12345u);
        std::uniform_int_distribution<uint32_t> dist(0u, 0xFFFFFFFFu);
        for (auto& x : data) x = dist(rng);
        
        std::cout << "Running with CACHE-LINE ALIGNED accumulators (no false sharing)\n";
        print_accumulator_addresses(accumulators, thread_count);
        
        auto t0 = std::chrono::high_resolution_clock::now();
        size_t result = workload(data, thread_count, accumulators);
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        
        std::cout << "Result: " << result << "\n"
                  << "Elements: " << num_elements
                  << ", Threads: " << thread_count
                  << ", Time: " << ms << " ms\n";
    } else {
        // Use regular accumulators (FALSE SHARING occurs)
        std::vector<Accumulator> accumulators(thread_count);
        
        // Generate input data
        std::vector<uint32_t> data(num_elements);
        std::mt19937 rng(12345u);
        std::uniform_int_distribution<uint32_t> dist(0u, 0xFFFFFFFFu);
        for (auto& x : data) x = dist(rng);
        
        std::cout << "Running with NON-ALIGNED accumulators (false sharing enabled)\n";
        print_accumulator_addresses(accumulators, thread_count);
        
        auto t0 = std::chrono::high_resolution_clock::now();
        size_t result = workload(data, thread_count, accumulators);
        auto t1 = std::chrono::high_resolution_clock::now();
        double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
        
        std::cout << "Result: " << result << "\n"
                  << "Elements: " << num_elements
                  << ", Threads: " << thread_count
                  << ", Time: " << ms << " ms\n";
    }

    return 0;
}

