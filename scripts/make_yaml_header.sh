#!/bin/bash
set -e

#====== 配置部分 ======
# 版本信息
VERSION="1.0.0"                   # 版本号

# 目录配置
YAML_SRC="yaml-cpp"               # YAML-CPP 源码目录
TEMP_DIR="temp"                   # 临时文件目录
INCLUDE_DIR="include"             # 头文件输出目录（更改为统一使用include目录）
LIB_DIR="lib"                     # 库文件目录（存放静态库）

# 文件名配置
HEADER_FILE="yaml.hpp"           # 合并后的头文件名
LIB_FILE="libyaml.a"             # 静态库文件名
DEBUG_LIB_FILE="libyaml-debug.a" # 调试版静态库文件名
SHARED_LIB_FILE="libyaml.so"     # 动态库文件名
SHARED_DEBUG_LIB_FILE="libyaml-debug.so" # 调试版动态库文件名

# 构建配置
YAML_BUILD="${YAML_SRC}/build"    # 构建目录
YAML_DEBUG_BUILD="${YAML_SRC}/build-debug" # 调试版构建目录
YAML_SHARED_BUILD="${YAML_SRC}/build-shared" # 动态库构建目录
YAML_SHARED_DEBUG_BUILD="${YAML_SRC}/build-shared-debug" # 动态库调试版构建目录
YAML_LIB="libyaml-cpp.a"          # 构建生成的原始静态库名
YAML_DEBUG_LIB="libyaml-cppd.a"   # 构建生成的原始调试版静态库名
YAML_SHARED_LIB="libyaml-cpp.so"  # 构建生成的原始动态库名
YAML_SHARED_DEBUG_LIB="libyaml-cppd.so" # 构建生成的原始调试版动态库名

# 构建选项配置
BUILD_RELEASE=true    # 是否构建发布版
BUILD_DEBUG=true      # 是否构建调试版
BUILD_STATIC=true     # 是否构建静态库
BUILD_SHARED=false    # 是否构建动态库

# 处理命令行参数
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no-debug|--only-release)
            BUILD_DEBUG=false
            BUILD_RELEASE=true
            ;;
        --only-debug)
            BUILD_DEBUG=true
            BUILD_RELEASE=false
            ;;
        --all)
            BUILD_DEBUG=true
            BUILD_RELEASE=true
            ;;
        --shared)
            BUILD_SHARED=true
            ;;
        --static)
            BUILD_STATIC=true
            ;;
        --only-shared)
            BUILD_SHARED=true
            BUILD_STATIC=false
            ;;
        --only-static)
            BUILD_SHARED=false
            BUILD_STATIC=true
            ;;
        --all-types)
            BUILD_SHARED=true
            BUILD_STATIC=true
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  --no-debug      不构建调试版本，只构建发布版"
            echo "  --only-release  同 --no-debug"
            echo "  --only-debug    只构建调试版本，不构建发布版"
            echo "  --all           构建发布版和调试版（默认行为）"
            echo "  --shared        构建动态库（与静态库一起）"
            echo "  --static        构建静态库（默认行为）"
            echo "  --only-shared   只构建动态库，不构建静态库"
            echo "  --only-static   只构建静态库，不构建动态库（默认行为）"
            echo "  --all-types     构建静态库和动态库"
            echo "  -h, --help      显示此帮助信息"
            exit 0
            ;;
        *)
            echo "错误: 未知参数 $1"
            echo "使用 $0 --help 查看帮助"
            exit 1
            ;;
    esac
    shift
done

# 验证构建选项
if [[ "$BUILD_RELEASE" == "false" && "$BUILD_DEBUG" == "false" ]]; then
    echo "错误: 至少需要构建一个版本（发布版或调试版）"
    exit 1
fi

if [[ "$BUILD_STATIC" == "false" && "$BUILD_SHARED" == "false" ]]; then
    echo "错误: 至少需要构建一种类型（静态库或动态库）"
    exit 1
fi

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
    "${YAML_SRC}/include"
    "${YAML_SRC}/include/yaml-cpp"
    "${YAML_SRC}/include/yaml-cpp/contrib"
    "${YAML_SRC}/include/yaml-cpp/node"
    "${YAML_SRC}/include/yaml-cpp/node/detail"
    "${TEMP_DIR}/yaml-cpp"
    "${TEMP_DIR}/yaml-cpp/contrib"
    "${TEMP_DIR}/yaml-cpp/node"
    "${TEMP_DIR}/yaml-cpp/node/detail"
)

# 输出文件路径
OUT="${INCLUDE_DIR}/${HEADER_FILE}"
#====== 配置结束 ======

echo "===== 开始构建 yaml-cpp 头文件和静态库 ====="
echo "源码目录: ${YAML_SRC}"
echo "头文件输出: ${INCLUDE_DIR}/${HEADER_FILE}"
if [ "$BUILD_RELEASE" = true ]; then
    echo "发布版静态库输出: ${LIB_DIR}/${LIB_FILE}"
fi
if [ "$BUILD_DEBUG" = true ]; then
    echo "调试版静态库输出: ${LIB_DIR}/${DEBUG_LIB_FILE}"
fi
echo "版本: ${VERSION} (原版 YAML-CPP: ${YAML_VERSION})"
echo "构建日期: ${BUILD_DATE}"
echo "构建系统: ${BUILD_OS}"

# 确保目录存在
mkdir -p "${INCLUDE_DIR}"
mkdir -p "${LIB_DIR}"

# 第1步：生成合并的头文件
echo "正在生成合并头文件 ${OUT}..."
> "$OUT"
echo "// Auto-generated amalgamated yaml-cpp header-only file" >> "$OUT"
echo "// 版本: ${VERSION} (原版 YAML-CPP: ${YAML_VERSION})" >> "$OUT"
echo "// 构建日期: ${BUILD_DATE}" >> "$OUT"
echo "// 构建系统: ${BUILD_OS}" >> "$OUT"
echo "// 注意: 此文件只包含头文件，需要配合 ${LIB_FILE} 静态库使用" >> "$OUT"
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

            # 跳过源码中的内部引用
            if [[ "$incfile" == *graphbuilderadapter.h || \
                  "$incfile" == *ptr_vector.h || \
                  "$incfile" == *collectionstack.h || \
                  "$incfile" == *directives.h || \
                  "$incfile" == *emitterstate.h || \
                  "$incfile" == *emitterutils.h || \
                  "$incfile" == *exp.h || \
                  "$incfile" == *indentation.h || \
                  "$incfile" == *nodebuilder.h || \
                  "$incfile" == *nodeevents.h || \
                  "$incfile" == *regex_yaml.h || \
                  "$incfile" == *regeximpl.h || \
                  "$incfile" == *scanner.h || \
                  "$incfile" == *scanscalar.h || \
                  "$incfile" == *scantag.h || \
                  "$incfile" == *setting.h || \
                  "$incfile" == *singledocparser.h || \
                  "$incfile" == *stream.h || \
                  "$incfile" == *streamcharsource.h || \
                  "$incfile" == *stringsource.h || \
                  "$incfile" == *tag.h || \
                  "$incfile" == *token.h ]]; then
                echo "// 跳过内部头文件: $incfile" >> "$OUT"
                continue
            fi

            local fullpath=$(find_include "$incfile")

            if [[ -n "$fullpath" ]]; then
                echo "// 展开 include: $incfile" >> "$OUT"
                expand_file "$fullpath"
            else
                # 如果找不到，保留原始 include
                echo "// [警告] 未找到: $incfile" >> "$OUT"
                echo "$line" >> "$OUT"
            fi
        # 保留标准库和系统头文件
        elif [[ "$line" =~ ^#include\ \<.*\> ]]; then
            echo "$line" >> "$OUT"
        else
            echo "$line" >> "$OUT"
        fi
    done < "$file"

    echo -e "// ====== END $file ======\n" >> "$OUT"
}

echo -e "\n// ====== 头文件开始 ======" >> "$OUT"
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

echo "已生成合并头文件: $OUT"
echo "检查未能展开的 include:"
grep -n "未找到" "$OUT" || echo "全部头文件展开成功!"

# 第2步：如果需要，编译发布版静态库
if [ "$BUILD_RELEASE" = true ] && [ "$BUILD_STATIC" = true ]; then
    echo "===== 开始编译 yaml-cpp 发布版静态库 ====="
    mkdir -p ${YAML_BUILD}
    cd ${YAML_BUILD}

    # 配置构建（只生成静态库，不生成动态库和测试）
    echo "配置 CMake 构建..."
    cmake -DYAML_BUILD_SHARED_LIBS=OFF -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DCMAKE_BUILD_TYPE=Release ..

    # 编译库
    echo "编译 yaml-cpp 静态库..."
    make -j$(nproc)

    # 复制静态库到 lib 目录
    cd ../..
    echo "复制静态库到 ${LIB_DIR}/${LIB_FILE}..."
    cp "${YAML_BUILD}/${YAML_LIB}" "${LIB_DIR}/${LIB_FILE}"
fi

# 第3步：如果需要，编译调试版静态库
if [ "$BUILD_DEBUG" = true ] && [ "$BUILD_STATIC" = true ]; then
    echo "===== 开始编译 yaml-cpp 调试版静态库 ====="
    mkdir -p ${YAML_DEBUG_BUILD}
    cd ${YAML_DEBUG_BUILD}

    # 配置构建（启用调试标志）
    echo "配置 CMake 调试版构建..."
    cmake -DYAML_BUILD_SHARED_LIBS=OFF -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-D_GLIBCXX_DEBUG" ..

    # 编译库
    echo "编译 yaml-cpp 调试版静态库..."
    make -j$(nproc)

    # 复制静态库到 lib 目录
    cd ../..
    echo "复制调试版静态库到 ${LIB_DIR}/${DEBUG_LIB_FILE}..."

    # 检查调试版库文件是哪个名称
    if [ -f "${YAML_DEBUG_BUILD}/${YAML_DEBUG_LIB}" ]; then
        echo "找到调试版库文件: ${YAML_DEBUG_BUILD}/${YAML_DEBUG_LIB}"
        cp "${YAML_DEBUG_BUILD}/${YAML_DEBUG_LIB}" "${LIB_DIR}/${DEBUG_LIB_FILE}"
    elif [ -f "${YAML_DEBUG_BUILD}/${YAML_LIB}" ]; then
        echo "找到调试版库文件: ${YAML_DEBUG_BUILD}/${YAML_LIB}"
        cp "${YAML_DEBUG_BUILD}/${YAML_LIB}" "${LIB_DIR}/${DEBUG_LIB_FILE}"
    else
        echo "错误: 在目录 ${YAML_DEBUG_BUILD} 中找不到调试版库文件"
        echo "尝试查找实际库文件..."
        find "${YAML_DEBUG_BUILD}" -name "libyaml-cpp*.a" -type f
        exit 1
    fi
fi

# 第4步：如果需要，编译发布版动态库
if [ "$BUILD_RELEASE" = true ] && [ "$BUILD_SHARED" = true ]; then
    echo "===== 开始编译 yaml-cpp 发布版动态库 ====="
    mkdir -p ${YAML_SHARED_BUILD}
    cd ${YAML_SHARED_BUILD}

    # 配置构建（生成动态库）
    echo "配置 CMake 构建..."
    cmake -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DCMAKE_BUILD_TYPE=Release ..

    # 编译库
    echo "编译 yaml-cpp 动态库..."
    make -j$(nproc)

    # 复制动态库到 lib 目录
    cd ../..
    echo "复制动态库到 ${LIB_DIR}/${SHARED_LIB_FILE}..."
    # 查找最新的动态库文件（版本可能有差异）
    FOUND_SO=$(find "${YAML_SHARED_BUILD}" -name "libyaml-cpp.so*" -type f | sort | head -1)
    if [ -n "$FOUND_SO" ]; then
        echo "找到动态库文件: $FOUND_SO"
        cp "$FOUND_SO" "${LIB_DIR}/${SHARED_LIB_FILE}"
    else
        echo "错误: 在目录 ${YAML_SHARED_BUILD} 中找不到动态库文件"
        find "${YAML_SHARED_BUILD}" -type f -name "*.so*" || echo "未找到任何.so文件"
        exit 1
    fi
fi

# 第5步：如果需要，编译调试版动态库
if [ "$BUILD_DEBUG" = true ] && [ "$BUILD_SHARED" = true ]; then
    echo "===== 开始编译 yaml-cpp 调试版动态库 ====="
    mkdir -p ${YAML_SHARED_DEBUG_BUILD}
    cd ${YAML_SHARED_DEBUG_BUILD}

    # 配置构建（生成调试版动态库）
    echo "配置 CMake 调试版构建..."
    cmake -DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-D_GLIBCXX_DEBUG" ..

    # 编译库
    echo "编译 yaml-cpp 调试版动态库..."
    make -j$(nproc)

    # 复制调试版动态库到 lib 目录
    cd ../..
    echo "复制调试版动态库到 ${LIB_DIR}/${SHARED_DEBUG_LIB_FILE}..."
    # 查找最新的调试版动态库文件（版本可能有差异）
    FOUND_SO_DEBUG=$(find "${YAML_SHARED_DEBUG_BUILD}" -name "libyaml-cpp*.so*" -type f | sort | head -1)
    if [ -n "$FOUND_SO_DEBUG" ]; then
        echo "找到调试版动态库文件: $FOUND_SO_DEBUG"
        cp "$FOUND_SO_DEBUG" "${LIB_DIR}/${SHARED_DEBUG_LIB_FILE}"
    else
        echo "错误: 在目录 ${YAML_SHARED_DEBUG_BUILD} 中找不到调试版动态库文件"
        find "${YAML_SHARED_DEBUG_BUILD}" -type f -name "*.so*" || echo "未找到任何.so文件"
        exit 1
    fi
fi

echo "===== 构建完成 ====="
echo "头文件: ${INCLUDE_DIR}/${HEADER_FILE}"

# 显示构建信息
if [ "$BUILD_STATIC" = true ]; then
    if [ "$BUILD_RELEASE" = true ]; then
        echo "发布版静态库: ${LIB_DIR}/${LIB_FILE}"
    fi
    if [ "$BUILD_DEBUG" = true ]; then
        echo "调试版静态库: ${LIB_DIR}/${DEBUG_LIB_FILE}"
    fi
fi

if [ "$BUILD_SHARED" = true ]; then
    if [ "$BUILD_RELEASE" = true ]; then
        echo "发布版动态库: ${LIB_DIR}/${SHARED_LIB_FILE}"
    fi
    if [ "$BUILD_DEBUG" = true ]; then
        echo "调试版动态库: ${LIB_DIR}/${SHARED_DEBUG_LIB_FILE}"
    fi
fi

# 使用方法信息
echo -e "\n使用方法:"
echo "#include \"${HEADER_FILE}\""

if [ "$BUILD_STATIC" = true ] && [ "$BUILD_SHARED" = true ]; then
    echo "静态链接: -lyaml (发布版) 或 -lyaml-debug (调试版)"
    echo "动态链接: -lyaml (发布版) 或 -lyaml-debug (调试版) (需设置LD_LIBRARY_PATH)"
elif [ "$BUILD_STATIC" = true ]; then
    echo "链接: -lyaml (发布版) 或 -lyaml-debug (调试版)"
elif [ "$BUILD_SHARED" = true ]; then
    echo "链接: -lyaml (发布版) 或 -lyaml-debug (调试版) (需设置LD_LIBRARY_PATH)"
fi