#include <iostream>
#include <ctime>
#include <future>
#include <queue>
#include "tbb/tbb.h"
#include <tbb/scalable_allocator.h>
#include <tbb/tick_count.h>
#include <tbb/concurrent_priority_queue.h>

const int array_size = (1<<27);
int myArray[array_size] = { 0 };

int array_cpy[array_size] = { 0 };

using namespace tbb;

int foo(int byte)
{
	std::cout << "calling Foo Tbb malloc with : " << byte << std::endl;
	void* ptr = scalable_malloc(byte);
	return 0;
}


void bar(int byte)
{
	std::cout << "calling bar Tbb malloc with : " << byte << std::endl;
}

template<typename T> void print_queue(T& q) {
	while (!q.empty()) {
		std::cout << q.top() << " ";
		q.pop();
	}
	std::cout << '\n';
}

template<typename T>
void merge_pq(std::priority_queue<T>& src, std::priority_queue<T>& dst) {

	if (dst.size() < src.size()) {
		std::swap(dst, src);
	}
	while (!src.empty()) {
		dst.push(src.top());
		src.pop();
		dst.pop();
	}
}

void findKLargestSeq(int arr[], int k, int length) {
	std::priority_queue<int, std::vector<int>, std::greater<int> > q2(arr, arr + k);
	for (int index = k; index < (length); index++) {
		if (q2.top() < arr[index]) {
			q2.pop();
			q2.push(arr[index]);
		}
	}
	print_queue(q2);
}

void findKLargestPar(int arr[], int k, int length) {

	std::size_t num_threads = 8U;                         // Number of workers
	std::cout << "The TBB library is being used \n";
	tbb::task_scheduler_init init(num_threads);

	std::priority_queue<int, std::vector<int>, std::greater<int> > myPq(arr, arr + k);
	std::mutex g_queue_mutex;
	tbb::parallel_for(
		tbb::blocked_range<int*>(arr + k, arr + length, length / 4), /* Range */
		[&](const tbb::blocked_range<int*>&r) {
		std::priority_queue<int, std::vector<int>, std::greater<int>> q(r.begin(), r.begin() + k);
		for (int*a = r.begin() + k; a != r.end(); a++) {
			if (q.top() < *a) {
				q.pop();
				q.push(*a);
			}
		} /* End of Lambda : Parallel part */
		while (!q.empty()) {
			g_queue_mutex.lock();
			myPq.push(q.top());
			myPq.pop();
			g_queue_mutex.unlock();
			q.pop();
		}
	},
		tbb::simple_partitioner()
		);
	print_queue(myPq);
}

void findKLargestParRed(int arr[], int k, int length) {
	std::priority_queue<int, std::vector<int>, std::greater<int>> resQ = 
		tbb::parallel_reduce(
		tbb::blocked_range<int*>(myArray, myArray + array_size), /* Range */
		std::priority_queue<int, std::vector<int>, std::greater<int>>(), /* Identity */
		[&](const tbb::blocked_range<int*>&r, std::priority_queue<int, std::vector<int>, std::greater<int>> inQ)->
			                                  std::priority_queue<int, std::vector<int>, std::greater<int>> {
		int* a = r.begin();
		while (inQ.size() < k) {
			inQ.push(*a);
			a++;
		}

		while (a != r.end()) {
			if (inQ.top() < *a) {
				inQ.pop();
				inQ.push(*a);
			}
			a++;
		} /* End of Lambda */

		return inQ;
	},
		[](std::priority_queue<int, std::vector<int>, std::greater<int>> src, std::priority_queue<int, std::vector<int>, std::greater<int>> dst)->
		                                                                      std::priority_queue<int, std::vector<int>, std::greater<int>> {
		if (dst.size() < src.size()) {
			std::swap(dst, src);
		}
		while (!src.empty()) {
			dst.push(src.top());
			src.pop();
			dst.pop();
		}
		return dst;
	},
		tbb::static_partitioner()
		);
	print_queue(resQ);
}

int main(int argc, char * argv[])
{

	auto a1 = std::async(std::launch::async, foo, 8);
	int ret = a1.get();
	std::cout << time(NULL) << std::endl;
	srand(time(NULL));

	for (int i = 1; i < array_size; i++) {
		//myArray[i] = (rand() % array_size) + 1;
		myArray[i] = (i);
		array_cpy[i] = myArray[i];
	}
	unsigned int k_elements_to_find = 10;
	findKLargestSeq(myArray, k_elements_to_find, array_size);
	findKLargestPar(myArray, k_elements_to_find, array_size);
	findKLargestParRed(myArray, k_elements_to_find, array_size);


	return 0;
}