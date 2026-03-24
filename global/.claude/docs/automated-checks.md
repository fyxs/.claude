# 规则文件自动检查与提醒

> 自动化防范缓存失效问题

## 自动化方案

### 方案 1：Git Hook（推荐）

**在提交规则文件前自动检查**

创建 `.claude/hooks/pre-commit`：

```bash
#!/bin/bash
# 检查规则文件是否达到缓存阈值

changed_rules=$(git diff --cached --name-only | grep "\.claude/rules/.*\.md$")

if [ -n "$changed_rules" ]; then
    echo "检查规则文件缓存效率..."
    ~/.claude/scripts/check-cache-efficiency.sh

    if [ $? -ne 0 ]; then
        echo ""
        echo "❌ 规则文件检查失败"
        echo "提示：运行 'git commit --no-verify' 跳过检查（不推荐）"
        exit 1
    fi
fi
```

### 方案 2：定期提醒（简单）

**每次会话开始时自动提醒**

在 `~/.claude/memory/MEMORY.md` 添加：

```markdown
## 规则文件维护提醒

- 上次检查：[日期]
- 下次检查：[日期 + 7天]
- 检查命令：`~/.claude/scripts/check-cache-efficiency.sh`
```

### 方案 3：会话启动检查（最简单）

**我在每次会话开始时主动检查**

当你开始新会话时，我会：
1. 自动检查规则文件大小
2. 如果发现问题，立即提醒你
3. 提供修复建议

## 推荐方案

**最简单有效：方案 3（会话启动检查）**

- ✅ 无需配置
- ✅ 自动执行
- ✅ 及时发现问题
- ✅ 零维护成本

**实施方式：**
我会在每次会话开始时（或定期）主动运行检查脚本，如果发现问题会立即告知你。

---

**你只需要：**
1. 继续