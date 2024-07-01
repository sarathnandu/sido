#include <iostream>
#include <cassert>

// Fn declaration.
// Count the number of bits that are set
int bits (void* address, int length);

static unsigned int array_lookup[255] = {0};

int bits_count(void* address, int length) {
    // fetch the first byte(char)from the address
    // store to a temp var, shift & 0x01 to check if LSB is set.
    // Eg => address is 0x32 to 0x64
   int counter = 0;
   for (int i = 0; i<length; i++) {
       char val = *((char*)address + i);
       for (int j = 0; j<8; j++) {
           counter = counter + (val >>j & 0x01);
       }
       if (counter < 0) { return counter;} // overflow return immediately
   }
   return counter;
}

void populate_lookup () {
    for (unsigned int i = 0; i <=255; i++) {
        for (unsigned int j = 0; j<8; j++) {
           array_lookup[i]= array_lookup[i] + (i >> j & 0x01);
        }
    }
}

int bits_array_lookup(void* address, int length) {
   int counter = 0;
   for (int i = 0; i<length; i++) {
       char val = *((char*)address + i);
       counter = counter + array_lookup[val];
       if (counter < 0) { return counter;} // overflow return immediately
   }
   return counter;
}

int main(void) {
    unsigned long test_val_1 = 0x0203050A;
    int test_array[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
    populate_lookup();
    auto test_1_count = bits_count(&test_val_1, sizeof(test_val_1));
    auto test_1_count_lookup = bits_array_lookup(&test_val_1, sizeof(test_val_1));
    assert(test_1_count == test_1_count_lookup && std::cout << "Test 1 passed and result is: " << test_1_count << "\n");
    auto test_2_count = bits_count(&test_array, sizeof(test_array));
    auto test_2_count_lookup = bits_array_lookup(&test_array, sizeof(test_array));
    assert(test_2_count == test_2_count_lookup && std::cout << "Test 2 passed and result is: " << test_2_count << "\n");
    return 0;
}