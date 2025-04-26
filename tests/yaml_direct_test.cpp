#include <iostream>
#include <string>

// 根据构建方式选择正确的头文件
#ifdef USE_MERGED_HEADER
// 使用合并单头文件版本
#   include "../include/yaml-cpp.hpp"
#else
// 使用静态库版本
#   include "../include/yaml.hpp"
#endif

int main() {
    try {
        std::cout << "=== 直接使用YAML-CPP库测试 ===" << std::endl;
#   ifdef USE_MERGED_HEADER
        std::cout << "使用模式: 合并单头文件版本" << std::endl;
#   else
        std::cout << "使用模式: 静态库版本" << std::endl;
#   endif

        // 非常简单的YAML字符串
        std::string yaml_str = "test: 123";

        std::cout << "测试YAML字符串: " << yaml_str << std::endl;

        // 直接使用YAML-CPP解析
        std::cout << "尝试解析..." << std::endl;

        YAML::Node node = YAML::Load(yaml_str);
        std::cout << "解析成功!" << std::endl;

        // 访问节点
        if (node["test"]) {
            std::cout << "成功读取'test'键: " << node["test"].as<int>() << std::endl;
        } else {
            std::cout << "找不到'test'键" << std::endl;
        }

        return 0;
    } catch (const YAML::Exception& e) {
        std::cerr << "YAML错误: " << e.what() << std::endl;
        return 1;
    } catch (const std::exception& e) {
        std::cerr << "标准错误: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "未知错误" << std::endl;
        return 1;
    }
}
