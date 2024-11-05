#include <stdio.h>
#include <iostream>

int main(int argc, char* argv[]){
  if (argc <= 1)
    std::cout << "Hello, world!\n";
  else {
    std::cout << argv[1] << "\n";
  }
  return 0;
}
