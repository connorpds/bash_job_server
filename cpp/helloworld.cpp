#include <stdio.h>
#include <iostream>

int main(int argc, char* argv[]){
  if (argc <= 1)
    std::cout << "Hello, world!\n";
  else {
    std::cout << argv[1] << "\n";
  }
  int* shrek[5];
  int donkey = *shrek[5];
  std::cout << donkey;
  return 0;
}
