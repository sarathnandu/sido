class Solution {
public:
    string longestPalindrome(string s) {
        string sub_palindrome;
        for (std::string::size_type i = 0; i < s.size(); i++) {
            for (std::string::size_type rev_i = s.size(); rev_i!= i; --rev_i) {
             bool check = checkPalindrome(s, i, (rev_i - 1));
             if(check) {
                 std::string tmp_pal(s, i, (rev_i - i));
                 if (tmp_pal.size() > sub_palindrome.size())
                    sub_palindrome = tmp_pal;
             }
            }
        }
        return sub_palindrome;
    }
private:
   bool checkPalindrome(string& s, int i, int j) {
       while (i<j) {
           if(s[i] != s[j]) {
              return false;
           }
           i++;
           j--;
       }
       return true;
   }
};