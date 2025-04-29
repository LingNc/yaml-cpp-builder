// #define USE_MERGED_HEADER
#define YAML_CPP_IMPLEMENTATION  // 添加此宏以包含实现部分
#include "../include/yaml-cpp.hpp"

int get_value1() {
    YAML::Node node = YAML::Load("val: 10");
    return node["val"].as<int>();
}
