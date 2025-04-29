# YAML-CPP 构建工具

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows-lightgrey)]()

本项目提供了从 yaml-cpp 源码生成不同形式的单文件版 YAML 库的工具。
由于 yaml-cpp 的仓库配置说明不清楚，而且不方便使用和安装，故诞生此工具库。

我们已经发布了一些预构建的文件到release，可以直接使用，无需自行构建。

#### 单头文件版本
适用于快速集成和简单项目

  - **yaml-cpp.hpp** - 合并所有依赖的单头文件版本，使用时只需包含此文件，采用 stb 风格设计


#### 静态库版本（也可以使用动态库）
适用于需要高性能和更小二进制体积的项目

  - **yaml.hpp** - 静态库使用的头文件
  - **libyaml.a** - 针对生产环境优化的静态库（Release版本）
  - **libyaml-debug.a** - 包含调试信息的静态库（Debug版本）


## 功能特点

- 生成全合并版单头文件 - 只需包含一个文件，无需链接库（STB风格）
- 生成纯头文件版 + 静态库 - 更灵活的使用方式，可单独更新库文件
- 提供发布版和调试版静态库
- 简单易用的构建系统
- 详细的测试用例

## 前置条件

1. 克隆 yaml-cpp 仓库到项目根目录：
   ```bash
   git clone https://github.com/jbeder/yaml-cpp.git
   ```

2. 确保已安装 CMake 和 C++ 编译器：
   ```bash
   sudo apt install cmake build-essential  # Ubuntu/Debian
   brew install cmake                      # macOS
   ```

## 使用方法

本工具提供了多种方式来构建和使用 yaml-cpp 库：

### 使用 Makefile (推荐)

项目提供了完整的 Makefile，可以轻松构建所有版本的库：

```bash
# 查看帮助信息
make help

# 构建合并单头文件版本
make merged-header

# 构建静态库版本（发布版）
make static-lib

# 构建静态库版本（调试版）
make static-lib-debug

# 构建所有版本
make all

# 运行测试
make test-all

# 清理构建内容
make clean
```

### 直接使用脚本

也可以直接使用 scripts 目录下的脚本：

#### 1. make_yaml_header.sh

**功能：** 生成纯头文件版 yaml-cpp 及其静态库

**生成文件：**
- `include/yaml.hpp` - 合并后的单头文件（只包含声明）
- `lib/libyaml.a` - 编译好的静态库
- `lib/libyaml-debug.a` - 编译好的调试版静态库

**使用方法：**
```bash
chmod +x scripts/make_yaml_header.sh
./scripts/make_yaml_header.sh
```

**在项目中使用：**
```cpp
#include "yaml.hpp"  // 在 include 目录中

// 编译时需链接静态库
// g++ your_file.cpp -o your_program -Iinclude -Llib -lyaml
```

**适用场景：**
- 希望保持库与代码分离
- 需要使用完整的 yaml-cpp 功能
- 代码体积和编译速度敏感

#### 2. make_yaml_all.sh

**功能：** 生成全合并版 yaml-cpp 单头文件（采用 stb 风格设计，一次定义多处包含）

**生成文件：**
- `include/yaml-cpp.hpp` - 最终合并文件（包含所有声明和实现）

**使用方法：**
```bash
chmod +x scripts/make_yaml_all.sh
./scripts/make_yaml_all.sh
```

**在项目中使用：**
```cpp
// 在所有需要使用 YAML-CPP 的文件中：
#include "yaml-cpp.hpp"  // 在 include 目录中

// 在且仅在一个源文件中添加：
#define YAML_CPP_IMPLEMENTATION
#include "yaml-cpp.hpp"

// 编译时无需链接额外的库
// g++ your_file.cpp -o your_program -Iinclude
```

**适用场景：**
- 希望简化依赖，只需一个文件
- 项目移植、分发方便
- 多文件项目中使用统一的 YAML 处理功能

## 安装

您可以使用以下两种方式之一将构建好的文件安装到系统目录：

### 使用 make install（推荐）

使用 Makefile 中的 install 目标可以轻松安装到系统或自定义目录：

```bash
# 构建所有版本并安装到默认位置（/usr/local）
# 需要管理员权限
sudo make install

# 或安装到自定义目录
make install PREFIX=/path/to/custom/dir
```

### 使用安装脚本

您也可以使用提供的安装脚本：

```bash
# 构建所有版本
make all

# 安装到系统目录 (需要管理员权限)
sudo ./install.sh

# 或安装到自定义目录
./install.sh --prefix=/path/to/custom/dir
```

## 自定义配置

两个脚本开头都有配置部分，可根据需要修改：
- 源码目录、输出目录和文件名
- 搜索路径和其他编译选项

## 注意事项

1. 脚本执行时会自动创建所需目录
2. 对于 `make_yaml_header.sh`：
   - 头文件 `yaml.hpp` 存放在 `include` 目录
   - 静态库 `libyaml.a` 存放在 `lib` 目录
   - 使用时需要同时包含头文件并链接静态库
3. 对于 `make_yaml_all.sh`：
   - 合并后的头文件 `yaml-cpp.hpp` 存放在 `include` 目录
   - 使用 stb 风格设计，在所有文件中包含头文件，但只在一个源文件中定义 `YAML_CPP_IMPLEMENTATION`
   - 使用时只需包含该头文件，无需链接任何库
4. 如果使用 CMake，可以在 CMakeLists.txt 中配置：
   ```cmake
   # 使用 yaml.hpp + 静态库
   include_directories(include)
   link_directories(lib)
   target_link_libraries(your_target yaml)

   # 或使用全合并版
   include_directories(include)
   # 在一个源文件中定义 YAML_CPP_IMPLEMENTATION
   # 无需链接库
   ```

## 测试

项目提供了简单的测试程序，可以验证生成的库是否正常工作：

```bash
# 测试合并单头文件版本
make test-merged

# 测试合并单头文件版本的多文件编译
make test-multi

# 测试静态库版本（发布版）
make test-static

# 测试静态库版本（调试版）
make test-static-debug

# 测试所有版本
make test-all
```

## 性能比较

| 版本 | 编译时间 | 二进制大小 | 运行时性能 | 适用场景 |
|------|----------|------------|------------|----------|
| 合并单头文件 | 较慢 | 较大 | 相同 | 简单项目，快速集成 |
| 静态库 | 较快 | 较小 | 相同 | 大型项目，注重编译速度 |

## 贡献

欢迎通过 PR 和 Issue 为项目做出贡献！请参阅 [CONTRIBUTING.md](CONTRIBUTING.md) 了解更多信息。

## 许可证

本项目遵循 MIT 许可证。请参阅 [LICENSE](LICENSE) 文件了解详情。