#define USE_MERGED_HEADER
#include "../include/yaml-cpp.hpp"

int get_value1() {
    YAML::Node node = YAML::Load("val: 10");
    return node["val"].as<int>();
}
