#!/bin/bash
# Stop Hook - 保存会话摘要 + 提示记录 Instinct（按项目分离）

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
INSTINCT_DIR="D:/8Documents/Obsidian/Instincts"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 确保项目内存目录存在
mkdir -p "$MEMORY_DIR"

# 创建会话摘要模板
cat > "$LAST_SESSION" << 'EOF'
**上次会话时间**: TIMESTAMP_PLACEHOLDER

**完成的任务**:
- [待填写]

**当前状态**:
- [待填写]

**下一步计划**:
- [待填写]

**重要决策**:
- [待填写]
EOF

# 替换时间戳
sed -i "s/TIMESTAMP_PLACEHOLDER/$TIMESTAMP/g" "$LAST_SESSION"

echo "会话摘要已保存到: $LAST_SESSION"
echo "项目: $PROJECT_NAME"
echo "请手动编辑该文件，添加本次会话的关键信息。"
echo ""
echo "💡 发现可复用的模式了吗？"
echo "   考虑记录到 Instinct 系统："
echo "   $INSTINCT_DIR/patterns/"
echo "   模板: $INSTINCT_DIR/template.md"
