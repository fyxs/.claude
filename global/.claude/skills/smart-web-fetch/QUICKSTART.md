# Smart Web Fetch - 快速参考

## 安装位置
`/Users/kim/.claude/skills/smart-web-fetch/smart-web-fetch`

## 核心功能
- 智能网页抓取，输出干净 Markdown
- 支持 Jina Reader / markdown.new / defuddle.md 清洗服务
- 多级降级策略，自动切换服务
- 降低 Token 消耗

## 快速使用

```bash
# 基础抓取
/Users/kim/.claude/skills/smart-web-fetch/smart-web-fetch <URL>

# 保存到文件
/Users/kim/.claude/skills/smart-web-fetch/smart-web-fetch <URL> -o output.md

# 指定服务
/Users/kim/.claude/skills/smart-web-fetch/smart-web-fetch <URL> -s jina

# 详细日志
/Users/kim/.claude/skills/smart-web-fetch/smart-web-fetch <URL> -v
```

## 快捷别名
```bash
# 添加到 ~/.zshrc
echo 'alias swf="/Users/kim/.claude/skills/smart-web-fetch/smart-web-fetch"' >> ~/.zshrc
source ~/.zshrc

# 使用
swf https://example.com
```

## 服务优先级（自动降级）
1. Jina Reader (r.jina.ai) - 最稳定，推荐
2. markdown.new API
3. defuddle.md
4. 基础抓取 (curl + html2text)

## 示例

```bash
# 抓取技术文档
swf https://docs.python.org/3/tutorial/

# 抓取博客文章
swf https://example.com/blog/post -o article.md

# 使用 Jina Reader 抓取（跳过自动降级）
swf https://news.ycombinator.com -s jina
```

## 注意事项
- GitHub 等防护较强的网站可能无法通过清洗服务获取，会回退到基础抓取
- 基础抓取返回原始 HTML，Token 消耗较多
- 建议优先使用 `-s jina` 选项获取干净内容
