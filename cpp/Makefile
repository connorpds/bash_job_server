# Variables
CXX = clang++ 
CXXFLAGS = -Wall -Wextra -std=c++17 
SRC = *.cpp 
OBJ = $(SRC:.cpp=.o)
LDFLAGS = -lstdc++
TARGET = testprog

# Default target
all: $(TARGET)

# Link the object files to create the executable
$(TARGET): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^ $(LDFLAGS)

# Compile the source files to object files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up generated files
clean:
	rm -f $(OBJ) $(TARGET)

# Phony targets
.PHONY: all clean
