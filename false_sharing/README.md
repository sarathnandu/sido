# False Sharing Benchmark

A simple OpenMP benchmark demonstrating the performance impact of **false sharing** on multi-core systems.

## What is False Sharing?

False sharing occurs when threads on different CPU cores modify variables that reside on the same cache line (typically 64 bytes). Even though the threads access different variables, the cache coherency protocol forces expensive cache line transfers between cores, significantly degrading performance.

## Building

### Requirements
- C++17 compiler (GCC 7+ or Clang 5+)
- OpenMP support (for multi-threading)

### Compile

```bash
# Using g++
g++ -std=c++17 -O2 -fopenmp fs.cpp -o fs

# Or using clang++
clang++ -std=c++17 -O2 -fopenmp fs.cpp -o fs

# With debug symbols (for profiling)
g++ -std=c++17 -O2 -g -fopenmp fs.cpp -o fs
```

## Running

### Basic Usage

```bash
./fs [num_elements] [thread_count] [align=true|align=false]
```

### Parameters

- `num_elements` - Number of elements to process (default: 5,000,000)
- `thread_count` - Number of threads (default: max available cores)
- `align=true` - Use cache-line aligned accumulators (prevents false sharing)
- `align=false` - Use non-aligned accumulators (demonstrates false sharing)

### Examples

```bash
# Show help
./fs --help

# Run with defaults (false sharing enabled)
./fs

# Process 10M elements with 8 threads (false sharing)
./fs 10000000 8 align=false

# Same workload with alignment (no false sharing)
./fs 10000000 8 align=true

# Compare performance
echo "=== With False Sharing ==="
time ./fs 10000000 8 align=false

echo -e "\n=== Without False Sharing ==="
time ./fs 10000000 8 align=true
```

## Expected Results

### Non-Aligned (False Sharing)
```
Running with NON-ALIGNED accumulators (false sharing enabled)

```
⚠️ Multiple accumulators share the **same cache line** → cache coherency overhead

### Aligned (No False Sharing)
```
Running with CACHE-LINE ALIGNED accumulators (no false sharing)

```
✅ Each accumulator on a **different cache line** → 3-4× faster!

## Profiling with perf c2c (Linux only)

To see detailed cache-line contention:

```bash
# Record cache-to-cache transfers
sudo perf c2c record -F 60000 -a --all-user -- ./fs 10000000 8 align=false

# Generate report
sudo perf c2c report --stdio

# Interactive TUI
sudo perf c2c report
```
