#include <iostream>

bool is_paliandrome(const std::string& ip_str) {
    for (auto fwd_iter = ip_str.cbegin(); fwd_iter != ip_str.cend(); fwd_iter++) {
        std::cout << *fwd_iter << "\t";
        static auto rev_iter = ip_str.rbegin();
        std::cout << *rev_iter << "\t";
        if (*fwd_iter != *rev_iter) { return false; };
        if (rev_iter != ip_str.rend()) { rev_iter++; };
        std::cout << "\n";
    }
    return true;
}


int main() {
    std::string str = "malayalam";
    bool check_pal = is_paliandrome(str);
    if (check_pal) {
        std::cout << "The string " << str << " is a paliandrome" << std::endl;
    }
    return 0;
}