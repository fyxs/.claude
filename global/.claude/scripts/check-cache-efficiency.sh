#!/bin/bash

# 规则文件缓存效率检查脚本
# 用途：检查 .claude/rules/ 目录中的规则文件是否达到缓存阈值

RULES_DIR="$HOME/.claude/rules"
MIN_TOKENS=1024
MIN_WORDS=$((MIN_TOKENS * 3 / 4))  # 约 768 words

echo "=== .claude 规则文件缓存效率检查 ==="
echo ""

total_files=0
small_files=0
cacheable_files=0

# 检查所有 .md 文件
while IFS= read -r file; do
    total_files=$((total_files + 1))
    word_count=$(wc -w < "$file")
    estimated_tokens=$((word_count * 4 / 3))

    if [ $word_count -lt $MIN_WORDS ]; then
        small_files=$((small_files + 1))
        echo "⚠️  $(basename "$file"): ${word_count} words (~${estimated_tokens} tokens) - 低于缓存阈值"
    else
        cacheable_files=$((cacheable_files + 1))
        echo "✅ $(basename "$file"): ${word_count} words (~${estimated_tokens} tokens)"
    fi
done < <(find "$RULES_DIR" -name "*.md" -type f)

echo ""
echo "=== 统计 ==="
echo "总文件数: $total_files"
echo "可缓存文件: $cacheable_files"
echo "低于阈值: $small_files"
echo ""

if [ $small_files -gt 0 ]; then
    echo "❌ 发现 $small_files 个文件低于缓存阈值（1024 tokens）"
    echo "建议：合并小文件或扩充内容"
    exit 1
else
    echo "✅ 所有文件都达到缓存阈值"
    exit 0
fi
