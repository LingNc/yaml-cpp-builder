#include <iostream>

int get_value1();
int get_value2();

int main() {
    int v1 = get_value1();
    int v2 = get_value2();
    std::cout << "get_value1() = " << v1 << ", get_value2() = " << v2 << std::endl;
    return (v1 == 10 && v2 == 20) ? 0 : 1;
}