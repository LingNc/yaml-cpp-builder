#!/bin/bash
# yaml-cpp-builder 安装脚本
# 此脚本帮助用户将生成的yaml-cpp头文件和库安装到系统目录

set -e

# 配置
INSTALL_PREFIX="/usr/local"
INCLUDE_DIR="$INSTALL_PREFIX/include"
LIB_DIR="$INSTALL_PREFIX/lib"

# 生成的文件
YAML_HEADER="include/yaml-cpp.hpp"
YAML_LIB="lib/libyaml.a"
YAML_DEBUG_LIB="lib/libyaml-debug.a"

# 源目录
SRC_INCLUDE_DIR="include"
SRC_LIB_DIR="lib"

# 处理命令行参数
while [ $# -gt 0 ]; do
  case "$1" in
    --prefix=*)
      INSTALL_PREFIX="${1#*=}"
      INCLUDE_DIR="$INSTALL_PREFIX/include"
      LIB_DIR="$INSTALL_PREFIX/lib"
      shift
      ;;
    --help)
      echo "用法: $0 [选项]"
      echo "选项:"
      echo "  --prefix=DIR    安装到指定目录 (默认: /usr/local)"
      echo "  --help          显示此帮助信息"
      exit 0
      ;;
    *)
      echo "未知选项: $1"
      echo "使用 --help 查看帮助"
      exit 1
      ;;
  esac
done

# 检查是否为root用户
if [ "$INSTALL_PREFIX" = "/usr/local" ] && [ "$(id -u)" -ne 0 ]; then
  echo "错误: 安装到 $INSTALL_PREFIX 需要管理员权限"
  echo "请使用 sudo 运行此脚本或使用 --prefix 指定用户可写的目录"
  exit 1
fi

# 确保已构建库文件
if [ ! -f "$YAML_HEADER" ] || [ ! -f "$YAML_LIB" ]; then
  echo "错误: 未找到构建的yaml-cpp文件"
  echo "请先运行 'make all' 构建项目"
  exit 1
fi

# 创建安装目录
echo "创建安装目录..."
mkdir -p "$INCLUDE_DIR"
mkdir -p "$LIB_DIR"

# 安装文件
echo "正在安装头文件..."
cp -v "$YAML_HEADER" "$INCLUDE_DIR/"

echo "正在安装库文件..."
cp -v "$YAML_LIB" "$LIB_DIR/"

if [ -f "$YAML_DEBUG_LIB" ]; then
  cp -v "$YAML_DEBUG_LIB" "$LIB_DIR/"
fi

echo "安装完成！"
echo "头文件安装在: $INCLUDE_DIR"
echo "库文件安装在: $LIB_DIR"
echo ""
echo "使用示例:"
echo "  #include <yaml-cpp.hpp>"
echo "  编译: g++ your_file.cpp -o your_program -lyaml"