# ===== YAML-CPP构建工具 Makefile =====

# 目录配置
YAML_SRC = yaml-cpp
YAML_GIT = https://github.com/jbeder/yaml-cpp.git
SCRIPTS_DIR = scripts
INCLUDE_DIR = include
LIB_DIR = lib
BUILD_DIR = build
TEMP_DIR = temp

# 文件名配置
MERGED_HEADER = yaml-cpp.hpp
HEADER_ONLY = yaml.hpp
STATIC_LIB_RELEASE = libyaml.a
STATIC_LIB_DEBUG = libyaml-debug.a

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
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --only-release

# 构建静态库（仅调试版，使用make_yaml_header.sh脚本并传递--only-debug参数）
.PHONY : static-lib-debug
static-lib-debug : check-repo
	@echo "使用脚本生成YAML-CPP头文件和静态库（仅调试版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --only-debug

# 构建所有静态库版本（同时构建发布版和调试版）
.PHONY : static-lib-all
static-lib-all : check-repo
	@echo "使用脚本生成YAML-CPP头文件和静态库（发布版和调试版）..."
	@chmod +x $(SCRIPTS_DIR)/make_yaml_header.sh
	@YAML_SRC=$(YAML_SRC) INCLUDE_DIR=$(INCLUDE_DIR) LIB_DIR=$(LIB_DIR) TEMP_DIR=$(TEMP_DIR) $(SCRIPTS_DIR)/make_yaml_header.sh --all

# ====== 组合目标 ======

# 构建所有类型的库
.PHONY : all
all : merged-header static-lib-all

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
	@if [ -d "$(YAML_SRC)/build" ]; then rm -rf $(YAML_SRC)/build; fi
	@if [ -d "$(YAML_SRC)/build-debug" ]; then rm -rf $(YAML_SRC)/build-debug; fi
	@echo "已清理构建文件和库文件"

# 清理仓库
.PHONY : clean-repo
clean-repo :
	@if [ -d "$(YAML_SRC)" ]; then rm -rf $(YAML_SRC); fi

# 清理所有内容
.PHONY : clean-all
clean-all : clean clean-repo

# ====== 帮助目标 ======

# 显示帮助信息
.PHONY : help
help :
	@echo "YAML-CPP构建工具帮助"
	@echo "===================="
	@echo "构建目标："
	@echo "  make merged-header    - 生成YAML-CPP合并单头文件（只需包含，无需链接库）"
	@echo "  make static-lib       - 构建YAML-CPP头文件和静态库（仅发布版）"
	@echo "  make static-lib-debug - 构建YAML-CPP头文件和静态库（仅调试版）"
	@echo "  make static-lib-all   - 构建YAML-CPP头文件和所有静态库版本"
	@echo "  make all              - 构建所有版本的YAML-CPP库"
	@echo ""
	@echo "测试目标："
	@echo "  make test-merged      - 测试YAML-CPP合并单头文件版本"
	@echo "  make test-static      - 测试YAML-CPP静态库版本（发布版）"
	@echo "  make test-static-debug - 测试YAML-CPP静态库版本（调试版）"
	@echo "  make test-all         - 运行所有测试"
	@echo ""
	@echo "清理目标："
	@echo "  make clean-temp       - 清理临时文件"
	@echo "  make clean            - 清理构建文件"
	@echo "  make clean-repo       - 清理YAML-CPP仓库"
	@echo "  make clean-all        - 清理所有内容"
	@echo ""
	@echo "其他目标："
	@echo "  make help             - 显示此帮助信息"
	@echo ""
	@echo "使用说明："
	@echo "1. 合并单头文件版本："
	@echo "   #include \"yaml-cpp.hpp\""
	@echo ""
	@echo "2. 静态库版本："
	@echo "   #include \"yaml.hpp\""
	@echo "   链接: -lyaml（发布版）或 -lyaml-debug（调试版）"

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

# 运行所有测试
.PHONY : test-all
test-all : test-merged test-static test-static-debug
