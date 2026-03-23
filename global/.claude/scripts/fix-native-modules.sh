#!/bin/bash
# 修复已安装全局包的 native 模块
# 用法: ./fix-native-modules.sh <package-name> <target-node-version>

PACKAGE_NAME="$1"
TARGET_NODE_VERSION="$2"
NPM_PREFIX="C:/npm-global"

if [ -z "$PACKAGE_NAME" ] || [ -z "$TARGET_NODE_VERSION" ]; then
    echo "用法: $0 <package-name> <target-node-version>"
    echo "示例: $0 @siteboon/claude-code-ui 25.8.0"
    exit 1
fi

echo "=========================================="
echo "修复 native 模块"
echo "包: $PACKAGE_NAME"
echo "目标 Node.js 版本: $TARGET_NODE_VERSION"
echo "=========================================="

# 查找包路径
PACKAGE_PATH="$NPM_PREFIX/node_modules/$PACKAGE_NAME"

if [ ! -d "$PACKAGE_PATH" ]; then
    echo "❌ 找不到包: $PACKAGE_PATH"
    exit 1
fi

echo "包路径: $PACKAGE_PATH"
cd "$PACKAGE_PATH" || exit 1

# 检测 native 模块
echo ""
echo "检测 native 模块..."
NATIVE_MODULES=()

# 常见的 native 模块列表
COMMON_NATIVE_MODULES=(
    "better-sqlite3"
    "sqlite3"
    "bcrypt"
    "sharp"
    "node-sass"
    "canvas"
    "fsevents"
    "node-gyp"
)

for module in "${COMMON_NATIVE_MODULES[@]}"; do
    if [ -d "node_modules/$module" ]; then
        NATIVE_MODULES+=("$module")
    fi
done

if [ ${#NATIVE_MODULES[@]} -eq 0 ]; then
    echo "✅ 没有检测到 native 模块"
    exit 0
fi

echo "检测到 native 模块: ${NATIVE_MODULES[*]}"

# 编译 native 模块
echo ""
echo "使用 Node.js $TARGET_NODE_VERSION 重新编译..."
for module in "${NATIVE_MODULES[@]}"; do
    echo "编译 $module..."
    volta run --node "$TARGET_NODE_VERSION" npm rebuild "$module"

    if [ $? -ne 0 ]; then
        echo "⚠️  $module 编译失败"
    else
        echo "✅ $module 编译成功"
    fi
done

echo ""
echo "=========================================="
echo "✅ 修复完成！"
echo "=========================================="
