#define USE_MERGED_HEADER
#include "../include/yaml-cpp.hpp"

int get_value2() {
    YAML::Node node = YAML::Load("val: 20");
    return node["val"].as<int>();
}
