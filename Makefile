# ===== YAML-CPP构建工具 Makefile =====

# 目录配置
YAML_SRC = yaml-cpp
YAML_GIT = https://github.com/jbeder/yaml-cpp.git
SCRIPTS_DIR = scripts
INCLUDE_DIR = include
LIB_DIR = lib
BUILD_DIR = build
TEMP_DIR = temp

# 安装配置
PREFIX ?= /usr/local
INSTALL_INCLUDE_DIR ?= $(PREFIX)/include
INSTALL_LIB_DIR ?= $(PREFIX)/lib

# 文件名配置
MERGED_HEADER = yaml-cpp.hpp
HEADER_ONLY = yaml.hpp
STATIC_LIB_RELEASE = libyaml.a
STATIC_LIB_DEBUG = libyaml-debug.a
SHARED_LIB_RELEASE = libyaml.so
SHARED_LIB_DEBUG = libyaml-debug.so

# 创建必要的目录
$(shell mkdir -p $(INCLUDE_DIR) $(LIB_DIR) $(BUILD_DIR) $(TEMP_DIR))

# 默认目标：显示帮助
.PHONY : default
default : help

# ====== YAML-CPP仓库检查 ======

# 检查YAML-CPP仓库是否存在，不存在则下载
.PHONY : check-repo
check-repo :
	@if [ ! -d "$(YAML_SRC)" ]; then \
		echo "YAML-CPP仓库不存在，正在克隆..."; \
		git clone $(YAML_GIT) $(YAML_SRC); \
		echo "YAML-CPP仓库克隆完成！"; \
	else \
		echo "YAML-CPP仓库已存在，跳过克隆"; \
	fi

# ====== 单头文件版构建目标 ======

# 生成合并单头文件（使用make_yaml_all.sh脚本）
.PHONY : merged-header
merged-header : check-repo
	@echo "使用脚本生成全合并版本YAML-CPP单头文件..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_all.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_all.sh

# ====== 静态库版构建目标 ======

# 构建静态库（仅发布版，使用make_yaml_header.sh脚本并传递--only-release参数）
.PHONY : static-lib
static-lib : check-repo
	@echo "使用脚本生成YAML-CPP头文件和静态库（仅发布版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --only-release --only-static

# 构建静态库（仅调试版，使用make_yaml_header.sh脚本并传递--only-debug参数）
.PHONY : static-lib-debug
static-lib-debug : check-repo
	@echo "使用脚本生成YAML-CPP头文件和静态库（仅调试版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --only-debug --only-static

# 构建所有静态库版本（同时构建发布版和调试版）
.PHONY : static-lib-all
static-lib-all : check-repo
	@echo "使用脚本生成YAML-CPP头文件和静态库（发布版和调试版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --all --only-static

# ====== 动态库版构建目标 ======

# 构建动态库（仅发布版）
.PHONY : shared-lib
shared-lib : check-repo
	@echo "使用脚本生成YAML-CPP头文件和动态库（仅发布版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --only-release --only-shared

# 构建动态库（仅调试版）
.PHONY : shared-lib-debug
shared-lib-debug : check-repo
	@echo "使用脚本生成YAML-CPP头文件和动态库（仅调试版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --only-debug --only-shared

# 构建所有动态库版本（同时构建发布版和调试版）
.PHONY : shared-lib-all
shared-lib-all : check-repo
	@echo "使用脚本生成YAML-CPP头文件和动态库（发布版和调试版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --all --only-shared

# ====== 组合目标 ======

# 构建所有静态库和动态库版本
.PHONY : lib-all
lib-all : check-repo
	@echo "使用脚本生成YAML-CPP头文件和所有库（静态和动态，发布版和调试版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --all --all-types

# 构建所有类型的库和头文件
.PHONY : all
all : merged-header lib-all

# ====== 清理目标 ======

# 清理临时文件
.PHONY : clean-temp
clean-temp :
	@rm -rf $(TEMP_DIR)

# 清理构建的文件
.PHONY : clean
clean : clean-temp
	@rm -f $(INCLUDE_DIR)/$(MERGED_HEADER)
	@rm -f $(INCLUDE_DIR)/$(HEADER_ONLY)
	@rm -rf $(INCLUDE_DIR)/yaml-cpp
	@rm -f $(LIB_DIR)/$(STATIC_LIB_RELEASE)
	@rm -f $(LIB_DIR)/$(STATIC_LIB_DEBUG)
	@rm -f $(LIB_DIR)/$(SHARED_LIB_RELEASE)
	@rm -f $(LIB_DIR)/$(SHARED_LIB_DEBUG)
	@if [ -d "$(YAML_SRC)/build" ]; then rm -rf $(YAML_SRC)/build; fi
	@if [ -d "$(YAML_SRC)/build-debug" ]; then rm -rf $(YAML_SRC)/build-debug; fi
	@if [ -d "$(YAML_SRC)/build-shared" ]; then rm -rf $(YAML_SRC)/build-shared; fi
	@if [ -d "$(YAML_SRC)/build-shared-debug" ]; then rm -rf $(YAML_SRC)/build-shared-debug; fi
	@echo "已清理构建文件和库文件"

# 清理仓库
.PHONY : clean-repo
clean-repo :
	@if [ -d "$(YAML_SRC)" ]; then rm -rf $(YAML_SRC); fi

# 清理所有内容
.PHONY : clean-all
clean-all : clean clean-repo

# ====== 安装目标 ======

# 安装到系统目录（默认 /usr/local，可使用 PREFIX 变量更改）
.PHONY : install
install : all
	@echo "正在安装YAML-CPP到 $(PREFIX)..."
	@mkdir -p $(INSTALL_INCLUDE_DIR)
	@mkdir -p $(INSTALL_LIB_DIR)
	@echo "正在安装头文件..."
	cp -v $(INCLUDE_DIR)/$(MERGED_HEADER) $(INSTALL_INCLUDE_DIR)/
	cp -v $(INCLUDE_DIR)/$(HEADER_ONLY) $(INSTALL_INCLUDE_DIR)/
	@echo "正在安装库文件..."
	cp -v $(LIB_DIR)/$(STATIC_LIB_RELEASE) $(INSTALL_LIB_DIR)/
	cp -v $(LIB_DIR)/$(STATIC_LIB_DEBUG) $(INSTALL_LIB_DIR)/
	@if [ -f "$(LIB_DIR)/$(SHARED_LIB_RELEASE)" ]; then \
		cp -v $(LIB_DIR)/$(SHARED_LIB_RELEASE) $(INSTALL_LIB_DIR)/; \
	fi
	@if [ -f "$(LIB_DIR)/$(SHARED_LIB_DEBUG)" ]; then \
		cp -v $(LIB_DIR)/$(SHARED_LIB_DEBUG) $(INSTALL_LIB_DIR)/; \
	fi
	@echo "正在运行ldconfig更新动态库链接..."
	@ldconfig $(INSTALL_LIB_DIR) || echo "警告: ldconfig未能成功运行，您可能需要手动设置LD_LIBRARY_PATH"
	@echo "安装完成！"
	@echo "头文件安装在: $(INSTALL_INCLUDE_DIR)"
	@echo "库文件安装在: $(INSTALL_LIB_DIR)"
	@echo ""
	@echo "使用示例:"
	@echo "  【单头文件版本 (包含实现)】"
	@echo "    #include <yaml-cpp.hpp>"
	@echo "    编译: g++ your_file.cpp -o your_program"
	@echo ""
	@echo "  【静态库版本】"
	@echo "    #include <yaml.hpp>"
	@echo "    编译: g++ your_file.cpp -o your_program -lyaml"
	@echo "    调试版: g++ your_file.cpp -o your_program -lyaml-debug"
	@echo ""
	@echo "  【动态库版本】"
	@echo "    #include <yaml.hpp>"
	@echo "    编译: g++ your_file.cpp -o your_program -lyaml"
	@echo "    调试版: g++ your_file.cpp -o your_program -lyaml-debug"

# ====== 帮助目标 ======

# 显示帮助信息
.PHONY : help
help :
	@echo "YAML-CPP构建工具帮助"
	@echo "===================="
	@echo "构建目标："
	@echo "  make merged-header    - 生成YAML-CPP合并单头文件（只需包含，无需链接库）"
	@echo ""
	@echo "  静态库目标："
	@echo "  make static-lib       - 构建YAML-CPP头文件和静态库（仅发布版）"
	@echo "  make static-lib-debug - 构建YAML-CPP头文件和静态库（仅调试版）"
	@echo "  make static-lib-all   - 构建YAML-CPP头文件和所有静态库版本"
	@echo ""
	@echo "  动态库目标："
	@echo "  make shared-lib       - 构建YAML-CPP头文件和动态库（仅发布版）"
	@echo "  make shared-lib-debug - 构建YAML-CPP头文件和动态库（仅调试版）"
	@echo "  make shared-lib-all   - 构建YAML-CPP头文件和所有动态库版本"
	@echo ""
	@echo "  组合目标："
	@echo "  make lib-all          - 构建所有静态库和动态库版本"
	@echo "  make all              - 构建所有版本的YAML-CPP库和头文件"
	@echo ""
	@echo "安装目标："
	@echo "  make install          - 安装YAML-CPP到系统目录"
	@echo "                          可通过PREFIX变量指定目录："
	@echo "                          例如：make install PREFIX=/usr"
	@echo ""
	@echo "测试目标："
	@echo "  make test-merged      - 测试YAML-CPP合并单头文件版本"
	@echo "  make test-static      - 测试YAML-CPP静态库版本（发布版）"
	@echo "  make test-static-debug - 测试YAML-CPP静态库版本（调试版）"
	@echo "  make test-shared      - 测试YAML-CPP动态库版本（发布版）"
	@echo "  make test-shared-debug - 测试YAML-CPP动态库版本（调试版）"
	@echo "  make test-all         - 运行所有测试"
	@echo ""
	@echo "清理目标："
	@echo "  make clean-temp       - 清理临时文件"
	@echo "  make clean            - 清理构建文件"
	@echo "  make clean-repo       - 清理YAML-CPP仓库"
	@echo "  make clean-all        - 清理所有内容"
	@echo ""
	@echo "使用说明："
	@echo "1. 合并单头文件版本（无需链接库）："
	@echo "   #include \"yaml-cpp.hpp\""
	@echo ""
	@echo "2. 静态库版本："
	@echo "   #include \"yaml.hpp\""
	@echo "   链接: -lyaml（发布版）或 -lyaml-debug（调试版）"
	@echo ""
	@echo "3. 动态库版本："
	@echo "   #include \"yaml.hpp\""
	@echo "   链接: -lyaml（发布版）或 -lyaml-debug（调试版）"
	@echo "   运行时可能需要设置 LD_LIBRARY_PATH 或安装到系统库路径"

# ====== 测试目标 ======

# 测试目录
TESTS_DIR = tests
TEST_BUILD_DIR = $(BUILD_DIR)/tests

# 测试程序
DIRECT_TEST = yaml_direct_test
DIRECT_TEST_SRC = $(TESTS_DIR)/$(DIRECT_TEST).cpp

# 编译器设置
CXX = g++
CXXFLAGS_BASE = -std=c++11 -Wall -I$(INCLUDE_DIR)
CXXFLAGS_RELEASE = $(CXXFLAGS_BASE) -O2 -DNDEBUG  # 发布版编译选项（开启优化，禁用断言）
CXXFLAGS_DEBUG = $(CXXFLAGS_BASE) -g -D_GLIBCXX_DEBUG  # 调试版编译选项（启用调试，启用STL调试）
LDFLAGS = -L$(LIB_DIR)

# 创建测试目录
$(shell mkdir -p $(TEST_BUILD_DIR))

# 测试单头文件版
.PHONY : test-merged
test-merged :
	@if [ ! -f "$(INCLUDE_DIR)/$(MERGED_HEADER)" ]; then \
		echo "合并单头文件不存在，需要先构建..."; \
		$(MAKE) merged-header; \
	else \
		echo "使用已存在的合并单头文件，跳过构建..."; \
	fi
	@echo "编译并运行单头文件测试程序..."
	$(CXX) $(CXXFLAGS_RELEASE) -DUSE_MERGED_HEADER $(DIRECT_TEST_SRC) -o $(TEST_BUILD_DIR)/$(DIRECT_TEST)_merged
	@$(TEST_BUILD_DIR)/$(DIRECT_TEST)_merged

# 测试静态库版（发布版）
.PHONY : test-static
test-static :
	@if [ ! -f "$(LIB_DIR)/$(STATIC_LIB_RELEASE)" ] || [ ! -f "$(INCLUDE_DIR)/$(HEADER_ONLY)" ]; then \
		echo "发布版静态库或头文件不存在，需要先构建..."; \
		$(MAKE) static-lib; \
	else \
		echo "使用已存在的发布版静态库，跳过构建..."; \
	fi
	@echo "使用发布版优化选项编译测试程序并链接发布版静态库..."
	$(CXX) $(CXXFLAGS_RELEASE) $(DIRECT_TEST_SRC) -o $(TEST_BUILD_DIR)/$(DIRECT_TEST)_static $(LDFLAGS) -lyaml
	@$(TEST_BUILD_DIR)/$(DIRECT_TEST)_static

# 测试静态库版（调试版）
.PHONY : test-static-debug
test-static-debug :
	@if [ ! -f "$(LIB_DIR)/$(STATIC_LIB_DEBUG)" ] || [ ! -f "$(INCLUDE_DIR)/$(HEADER_ONLY)" ]; then \
		echo "调试版静态库或头文件不存在，需要先构建..."; \
		$(MAKE) static-lib-debug; \
	else \
		echo "使用已存在的调试版静态库，跳过构建..."; \
	fi
	@echo "使用调试版选项编译测试程序并链接调试版静态库..."
	$(CXX) $(CXXFLAGS_DEBUG) $(DIRECT_TEST_SRC) -o $(TEST_BUILD_DIR)/$(DIRECT_TEST)_static_debug $(LDFLAGS) -lyaml-debug
	@$(TEST_BUILD_DIR)/$(DIRECT_TEST)_static_debug

# 测试动态库版（发布版）
.PHONY : test-shared
test-shared :
	@if [ ! -f "$(LIB_DIR)/$(SHARED_LIB_RELEASE)" ] || [ ! -f "$(INCLUDE_DIR)/$(HEADER_ONLY)" ]; then \
		echo "发布版动态库或头文件不存在，需要先构建..."; \
		$(MAKE) shared-lib; \
	else \
		echo "使用已存在的发布版动态库，跳过构建..."; \
	fi
	@echo "使用发布版优化选项编译测试程序并链接发布版动态库..."
	$(CXX) $(CXXFLAGS_RELEASE) $(DIRECT_TEST_SRC) -o $(TEST_BUILD_DIR)/$(DIRECT_TEST)_shared $(LDFLAGS) -lyaml
	@echo "运行测试程序（设置LD_LIBRARY_PATH）..."
	@LD_LIBRARY_PATH=$(LIB_DIR) $(TEST_BUILD_DIR)/$(DIRECT_TEST)_shared

# 测试动态库版（调试版）
.PHONY : test-shared-debug
test-shared-debug :
	@if [ ! -f "$(LIB_DIR)/$(SHARED_LIB_DEBUG)" ] || [ ! -f "$(INCLUDE_DIR)/$(HEADER_ONLY)" ]; then \
		echo "调试版动态库或头文件不存在，需要先构建..."; \
		$(MAKE) shared-lib-debug; \
	else \
		echo "使用已存在的调试版动态库，跳过构建..."; \
	fi
	@echo "使用调试版选项编译测试程序并链接调试版动态库..."
	$(CXX) $(CXXFLAGS_DEBUG) $(DIRECT_TEST_SRC) -o $(TEST_BUILD_DIR)/$(DIRECT_TEST)_shared_debug $(LDFLAGS) -lyaml-debug
	@echo "运行测试程序（设置LD_LIBRARY_PATH）..."
	@LD_LIBRARY_PATH=$(LIB_DIR) $(TEST_BUILD_DIR)/$(DIRECT_TEST)_shared_debug

# 运行所有测试
.PHONY : test-all
test-all : test-merged test-static test-static-debug test-shared test-shared-debug
