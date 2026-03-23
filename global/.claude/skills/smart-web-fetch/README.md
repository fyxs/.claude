# Smart Web Fetch for Claude Code

为 Claude Code 构建的智能网页抓取 Skill。

> **借鉴来源**：本工具功能设计借鉴自 [clawhub.ai/Leochens/smart-web-fetch](https://clawhub.ai/Leochens/smart-web-fetch)，感谢原作者的创意和实现思路。

## 功能特性

- **智能清洗**：自动使用 Jina Reader / markdown.new / defuddle.md 清洗服务
- **多级降级**：当一个服务失败时自动切换到下一个
- **Token 优化**：获取干净的 Markdown 格式，减少 Token 消耗
- **简单易用**：命令行工具，支持多种选项

## 安装

```bash
# 确保脚本有执行权限
chmod +x ~/.claude/skills/smart-web-fetch/smart-web-fetch

# 添加到 PATH（可选）
echo 'export PATH="$HOME/.claude/skills/smart-web-fetch:$PATH"' >> ~/.zshrc
```

## 使用方法

### 基础用法

```bash
# 抓取网页内容
smart-web-fetch https://example.com

# 保存到文件
smart-web-fetch https://example.com -o output.md

# 使用指定服务
smart-web-fetch https://example.com -s jina

# 显示详细日志
smart-web-fetch https://example.com -v
```

### 选项说明

| 选项 | 说明 |
|------|------|
| `-h, --help` | 显示帮助信息 |
| `-o, --output FILE` | 输出到文件 |
| `-s, --service NAME` | 指定清洗服务 (jina\|markdown\|defuddle) |
| `-v, --verbose` | 显示详细日志 |
| `--no-clean` | 禁用 HTML 清洗 |

### 支持的清洗服务

1. **Jina Reader** (`jina`) - 最稳定，推荐
   - 服务地址: `https://r.jina.ai/http://URL`
   - 支持各种网站，包括 JavaScript 渲染的页面

2. **markdown.new** (`markdown`)
   - 服务地址: `https://api.markdown.new/api/v1/convert`
   - 专为 Markdown 转换优化

3. **defuddle.md** (`defuddle`)
   - 服务地址: `https://defuddle.md/api/convert`
   - 去除干扰元素，提取核心内容

## 降级策略

默认自动尝试顺序：
1. Jina Reader（成功率最高）
2. markdown.new
3. defuddle.md
4. 基础抓取（直接 curl + html2text）

## 在 Claude Code 中使用

配置完成后，Claude Code 可以在需要时自动调用此工具。你也可以手动触发：

```
请使用 smart-web-fetch 抓取 https://example.com 的内容
```

## 与原版对比

| 功能 | clawhub skill | 此版本 |
|------|--------------|--------|
| Jina Reader | ✅ | ✅ |
| markdown.new | ✅ | ✅ |
| defuddle.md | ✅ | ✅ |
| 多级降级 | ✅ | ✅ |
| Token 优化 | ✅ | ✅ |
| 命令行工具 | ❌ | ✅ |
| Claude Code 集成 | ❌ | ✅ |

## 依赖

- `curl` - 必需
- `jq` - 可选，用于 JSON 解析
- `html2text` 或 `lynx` - 可选，用于基础 HTML 转换

## License

MIT
