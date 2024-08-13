#include <iostream>

struct Node {
    int key;
    Node* left;
    Node* right;
    Node(int item) {
        key = item;
        left = right = NULL;
    }
};

Node* search(Node*root, int key) {
// Base case
   if (NULL == root || root->key == key) {return root;}
   if (key < root->key) {
       //search left
       return search(root->left, key);
   }
   // else search right
   return search(root->right, key);
}


int main() {
    // Creating a hard coded tree for keeping 
    // the length of the code small. We need 
    // to make sure that BST properties are 
    // maintained if we try some other cases.
    Node* root = new Node(50);
    root->left = new Node(30);
    root->right = new Node(70);
    root->left->left = new Node(20);
    root->left->right = new Node(40);
    root->right->left = new Node(60);
    root->right->right = new Node(80);
    (search(root,19) != NULL) ? std::cout << "Found 19 \n" : 
        std::cout << "Didn't found 19 \n";
    (search(root,80) != NULL) ? std::cout << "Found 80 \n" : 
        std::cout << "Didn't found 80 \n";

}