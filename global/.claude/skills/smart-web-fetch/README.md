# Smart Web Fetch Pro for Claude Code

专业级智能网页抓取工具，完全替代内置 `web_fetch`。

> **借鉴来源**：本工具功能设计借鉴自 [clawhub.ai/Leochens/smart-web-fetch](https://clawhub.ai/Leochens/smart-web-fetch) 和 OpenClaw web-fetch-pro，感谢原作者的创意和实现思路。

## ✨ 核心特性

- **🔄 四级智能降级**: Jina → markdown.new → defuddle.md → Scrapling
- **🛡️ 反爬支持**: Scrapling 绕过 Cloudflare 等反爬，支持微信公众号
- **💰 Token 节省**: 清洗后内容比原始 HTML 节省 50-80% Token
- **🚀 即插即用**: 零配置，无需 API Key
- **📄 干净输出**: 纯 Markdown，去除广告/导航/页脚等噪音

## 📊 四级降级策略

| 优先级 | 服务 | 速度 | 特点 | 适用场景 |
|--------|------|------|------|----------|
| 1 | **Jina Reader** | ~1-2s | 格式最干净 | 普通博客、新闻、英文网站 |
| 2 | **markdown.new** | ~2s | 无需 API Key | Jina 失败时自动降级 |
| 3 | **defuddle.md** | ~2s | 清洗效果好 | 前两级失败时 |
| 4 | **Scrapling** | ~3-5s | 绕过反爬 | 微信公众号、反爬页面 |

## 🚀 安装

### 1. 基础使用（无需安装）

前三级降级服务（Jina、markdown.new、defuddle）无需任何安装，直接使用。

```bash
chmod +x ~/.claude/skills/smart-web-fetch/smart-web-fetch
```

### 2. 完整功能（可选）

如需支持微信公众号等反爬页面，安装 Scrapling：

```bash
pip3 install scrapling html2text curl_cffi browserforge
```

## 📋 使用方法

### 基础用法

```bash
# 获取网页内容
smart-web-fetch https://example.com

# 保存到文件
smart-web-fetch https://example.com -o output.md

# 指定服务
smart-web-fetch https://example.com -s jina

# 详细日志
smart-web-fetch https://example.com -v

# JSON 输出（包含 source 等元数据）
smart-web-fetch https://example.com --json
```

### 在 Claude Code 中使用

```bash
# 直接调用
/smart-web-fetch https://example.com
```

### 微信公众号示例

```bash
# 自动检测并使用 Scrapling
smart-web-fetch "https://mp.weixin.qq.com/s/xxx" --json
```

## 📋 输出格式

### 普通输出（默认）

```markdown
# 文章标题

正文内容...
```

### JSON 输出 (`--json`)

```json
{
  "success": true,
  "url": "https://example.com",
  "content": "# Article Title\n\nClean markdown content...",
  "source": "jina"
}
```

## 🔧 选项说明

| 选项 | 说明 |
|------|------|
| `-h, --help` | 显示帮助信息 |
| `-o, --output FILE` | 输出到文件 |
| `-s, --service NAME` | 指定清洗服务 (jina\|markdown\|defuddle\|scrapling) |
| `-v, --verbose` | 显示详细日志 |
| `-j, --json` | 输出 JSON 格式 |
| `--no-clean` | 禁用 HTML 清洗 |

## 🧪 测试验证

```bash
# 测试 Jina（普通网站）
smart-web-fetch https://jina.ai -v

# 测试 Scrapling（微信公众号，需要安装依赖）
smart-web-fetch "https://mp.weixin.qq.com/s/EwVItQH4JUsONqv_Fmi4wQ" --json -v
```

## 📁 文件结构

```
smart-web-fetch/
├── smart-web-fetch       # 主脚本（Bash）
├── fetch_scrapling.py    # Scrapling 抓取脚本（Python）
├── skill.json            # Skill 配置文件
├── README.md             # 说明文档
└── LICENSE               # 许可证
```

## 💡 使用建议

1. **普通网页**: 自动使用 Jina，速度最快
2. **微信公众号**: 自动降级到 Scrapling，无需手动干预
3. **大量抓取**: 注意 Jina 有 200 次/天 限制
4. **Token 优化**: 清洗后内容可节省 50-80% Token

## 🔍 故障排查

### Scrapling 未安装

```
[WARN] Scrapling 未安装，请使用以下命令安装:
pip3 install scrapling html2text curl_cffi browserforge
```

### 所有服务均失败

检查网络连接或目标网站是否可访问。

## 依赖

- `curl` - 必需
- `python3` - 必需（用于 Scrapling 和 JSON 处理）
- `jq` - 可选，用于 JSON 解析
- `scrapling` - 可选，用于反爬页面
- `html2text` - 可选，用于基础 HTML 转换

## License

MIT
