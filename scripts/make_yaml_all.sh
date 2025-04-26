#!/bin/bash
set -e

#====== 配置部分 ======
# 版本信息
VERSION="1.0.0"                   # 版本号

# 目录配置
YAML_SRC="yaml-cpp"               # YAML-CPP 源码目录
TEMP_DIR="temp"                   # 临时文件目录
EXT_DIR="ext"                     # 扩展库目录（存放头文件）

# 文件名配置
ALL_HEADER="yaml-cpp.hpp"         # 含实现的合并头文件名

# 获取构建信息
BUILD_DATE=$(date "+%Y-%m-%d %H:%M:%S")
BUILD_OS=$(uname -a)
if [ -f "${YAML_SRC}/CMakeLists.txt" ]; then
    YAML_VERSION=$(grep -oP 'project\(YAML_CPP VERSION \K[0-9\.]+' "${YAML_SRC}/CMakeLists.txt" || echo "unknown")
else
    YAML_VERSION="unknown"
fi

# 搜索路径配置
SEARCH_PATHS=(
    "${TEMP_DIR}"
    "${TEMP_DIR}/yaml-cpp"
    "${TEMP_DIR}/yaml-cpp/contrib"
    "${TEMP_DIR}/yaml-cpp/node"
    "${YAML_SRC}/include"
    "${YAML_SRC}/include/yaml-cpp"
    "${YAML_SRC}/include/yaml-cpp/contrib"
    "${YAML_SRC}/include/yaml-cpp/node"
    "${YAML_SRC}/src"
    "${YAML_SRC}/src/contrib"
)

# 输出文件路径
OUT="${TEMP_DIR}/${ALL_HEADER}"
#====== 配置结束 ======

echo "===== 开始生成 yaml-cpp 全合并单头文件 ====="
echo "源码目录: ${YAML_SRC}"
echo "临时输出: ${OUT}"
echo "最终输出: ${EXT_DIR}/${ALL_HEADER}"
echo "版本: ${VERSION} (原版 YAML-CPP: ${YAML_VERSION})"
echo "构建日期: ${BUILD_DATE}"
echo "构建系统: ${BUILD_OS}"

# 确保目录存在
mkdir -p "${TEMP_DIR}"
mkdir -p "${EXT_DIR}"

# 初始化输出文件
> "$OUT"
echo "// Auto-generated amalgamated yaml-cpp single header (含实现)" >> "$OUT"
echo "// 版本: ${VERSION} (原版 YAML-CPP: ${YAML_VERSION})" >> "$OUT"
echo "// 构建日期: ${BUILD_DATE}" >> "$OUT"
echo "// 构建系统: ${BUILD_OS}" >> "$OUT"
echo "// 此文件包含所有 yaml-cpp 头文件和实现，可独立使用无需链接静态库" >> "$OUT"
echo "#pragma once" >> "$OUT"

# 记录已处理文件，避免重复递归
declare -A included

# 查找头文件的函数
find_include() {
    local inc="$1"

    # 直接路径
    if [[ -f "$inc" ]]; then
        echo "$inc"
        return 0
    fi

    # 遍历所有搜索路径
    for path in "${SEARCH_PATHS[@]}"; do
        if [[ -f "$path/$inc" ]]; then
            echo "$path/$inc"
            return 0
        fi
    done

    # 特殊处理 yaml-cpp/ 开头的
    if [[ "$inc" == yaml-cpp/* ]]; then
        local subinc="${inc#yaml-cpp/}"
        for path in "${SEARCH_PATHS[@]}"; do
            if [[ -f "$path/$subinc" ]]; then
                echo "$path/$subinc"
                return 0
            fi
        done
    fi

    # 未找到
    echo ""
    return 1
}

# 递归展开 include 的函数
expand_file() {
    local file="$1"
    # 绝对路径去重
    local absfile="$(readlink -f "$file")"
    if [[ -n "${included[$absfile]}" ]]; then
        return
    fi
    included[$absfile]=1

    echo -e "\n// ====== BEGIN $file ======" >> "$OUT"

    while IFS= read -r line; do
        # 匹配 #include "xxx.h" 的各种形式
        if [[ "$line" =~ ^#include\ \"([^\"]+)\" ]]; then
            local incfile="${BASH_REMATCH[1]}"
            local fullpath=$(find_include "$incfile")

            if [[ -n "$fullpath" ]]; then
                echo "// Expanding include: $incfile" >> "$OUT"
                expand_file "$fullpath"
            else
                # 如果找不到，保留原始 include
                echo "// [WARN] Cannot find include: $incfile" >> "$OUT"
                echo "$line" >> "$OUT"
            fi
        # 跳过标准库和系统头文件
        elif [[ "$line" =~ ^#include\ \<.*\> ]]; then
            echo "$line" >> "$OUT"
        else
            echo "$line" >> "$OUT"
        fi
    done < "$file"

    echo -e "// ====== END $file ======\n" >> "$OUT"
}

echo -e "\n// ====== HEADERS ======" >> "$OUT"
# 先展开 yaml.h（作为入口头文件）
if [[ -f "${TEMP_DIR}/yaml.h" ]]; then
    echo "使用 ${TEMP_DIR}/yaml.h 作为入口..."
    expand_file "${TEMP_DIR}/yaml.h"
elif [[ -f "${YAML_SRC}/include/yaml-cpp/yaml.h" ]]; then
    echo "使用 ${YAML_SRC}/include/yaml-cpp/yaml.h 作为入口..."
    expand_file "${YAML_SRC}/include/yaml-cpp/yaml.h"
else
    echo "错误: 找不到 yaml.h 入口文件!"
    exit 1
fi

# 再展开源码实现文件
echo -e "\n// ====== IMPLEMENTATION ======" >> "$OUT"
echo "正在加入源码实现..."
find ${YAML_SRC}/src -type f -name "*.cpp" | sort | while read f; do
    # 跳过测试和 main 函数文件
    if grep -qE 'int[[:space:]]+main[[:space:]]*\(' "$f"; then
        echo "跳过 main 文件: $f"
        continue
    fi
    echo "处理源文件: $f"
    expand_file "$f"
done

echo "已生成单头文件: $OUT"
echo "检查是否仍有未能展开的 include:"
# 使用 || true 避免 grep 返回非零导致脚本退出
grep -n "Cannot find include" "$OUT" || echo "全部 include 展开成功!"

# 复制到目标目录
echo "正在复制到目标位置..."
cp "${OUT}" "${EXT_DIR}/${ALL_HEADER}"

echo "===== 生成完成 ====="
echo "全合并头文件: ${EXT_DIR}/${ALL_HEADER}"
echo "使用方法: #include \"${ALL_HEADER}\" (无需链接静态库)"