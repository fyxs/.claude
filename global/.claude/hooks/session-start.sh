#!/bin/bash
# SessionStart Hook - 加载上一次会话的上下文 + Instinct（按项目分离）

# 错误处理：任何命令失败时继续执行
set +e

# 获取项目名称（最后两级目录名）
PARENT_DIR=$(basename "$(dirname "$PWD")")
CURRENT_DIR=$(basename "$PWD")
if [ "$PARENT_DIR" = "." ] || [ "$PARENT_DIR" = "/" ]; then
    PROJECT_NAME="$CURRENT_DIR"
else
    PROJECT_NAME="${PARENT_DIR}_${CURRENT_DIR}"
fi
MEMORY_DIR="/c/Users/admin/.claude/memory/projects/$PROJECT_NAME"
LAST_SESSION="$MEMORY_DIR/last-session.md"
INSTINCT_FILE="D:/8Documents/Obsidian/Instincts/active/current.md"

# 确保项目内存目录存在
mkdir -p "$MEMORY_DIR"

# 如果存在上次会话摘要，输出到上下文
if [ -f "$LAST_SESSION" ]; then
    echo "=== 上次会话摘要 (项目: $PROJECT_NAME) ==="
    cat "$LAST_SESSION"
    echo ""
fi

# 如果存在活跃的 Instinct，输出到上下文
if [ -f "$INSTINCT_FILE" ]; then
    echo "=== 活跃的 Instinct ==="
    cat "$INSTINCT_FILE"
    echo ""
fi

echo "=== 继续工作 ==="
