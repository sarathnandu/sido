#include <iostream>
#include <thread>
#include <chrono>
#include <atomic>
#include <mutex>

#define BUFFER_SIZE (12u)
static int buffer[BUFFER_SIZE];
static std::atomic <int> space_available = BUFFER_SIZE;
static std::atomic <int> item_available = 0;
std::mutex mtx;

void produce_item_atomically() {
    int in = 0;
    while(true) {
       while (space_available != 0) {
           int item_producer = in /*std::random_generator(0, 25, std::generator) */;
           std::cout << "item_produced : " << item_producer << "\t";
           {
               std::scoped_lock<std::mutex> lock(mtx);
               buffer[in] = item_producer;
           }
           in = (in + 1) % BUFFER_SIZE;
           item_available++;
           std::this_thread::sleep_for(std::chrono::milliseconds(10));
       }
    }
}

void consume_item_atomically() {
    int out = 0;
    int item_consumer;
    while(true) {
        while (item_available != 0) {
            {
                std::scoped_lock<std::mutex> lock(mtx);
                item_consumer = buffer[out];
            }
            std::cout << "item_consumed : " << item_consumer << "\t";
            out = (out + 1) % BUFFER_SIZE;
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            space_available--;
        }
    }
}


int main() {
    std::thread t1(produce_item_atomically);
    std::thread t2(consume_item_atomically);
    t1.join();
    t2.join();
    return 0;
}