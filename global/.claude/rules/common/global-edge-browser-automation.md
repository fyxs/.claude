# 浏览器自动化规则

> 规则 ID: GLOBAL-TOOL-003
> 版本: 2.0.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-27
> 状态: 发布

> 本规则定义了浏览器自动化操作的唯一工具标准。
> **2.0.0 重大更新**：全面迁移至 agent-browser，废弃 Playwright CLI、Puppeteer、edge-cli。

## 唯一工具：agent-browser

**所有浏览器自动化任务，统一使用 agent-browser。无例外。**

- 版本：0.22.3（已全局安装）
- 源码：`D:\2Work\Claude\tools\agent-browser`
- Skill 实际位置：`C:\Users\admin\.claude\skills\agent-browser\`（全局，软连接共享）
- 技术：Rust 原生 CLI，直接通过 CDP 驱动 Chrome

**废弃工具（不再使用）：**
- ~~Playwright CLI~~ → 已移除 skill
- ~~Puppeteer / edge-cli~~ → 所有场景由 agent-browser 覆盖

---

## 核心工作流

每次浏览器自动化任务的标准模式：

```bash
# 1. 导航（新浏览器 或 连接日常 Edge）
agent-browser open https://example.com          # 新会话
agent-browser --cdp 9222 open https://example.com  # 连接日常 Edge

# 2. 获取快照（取得元素引用 @eN）
agent-browser snapshot -i

# 3. 交互（用 @ref 操作，无需 CSS 选择器）
agent-browser click @e1
agent-browser fill @e2 "text"

# 4. 页面变化后必须重新 snapshot
agent-browser snapshot -i
```

---

## 两种连接模式

### 模式一：连接日常使用的 Edge（CDP 模式）

适用场景：操作用户正在使用的浏览器，用户可见所有操作。

**前提**：Edge 已以调试模式启动（端口 9222）

```bash
# 连接并操作（用户能看到所有操作）
agent-browser connect 9222       # 连接一次，后续命令无需再指定
agent-browser snapshot -i
agent-browser click @e3
agent-browser close

# 或每次命令都带 --cdp
agent-browser --cdp 9222 snapshot -i

# 零配置自动发现（无需知道端口）
agent-browser --auto-connect snapshot -i
```

**启动 Edge 调试模式**（如果还未启动）：
```bash
cd "D:\2Work\Claude" && cmd /c auto-js\browser\start-edge-debug.bat
```

### 模式二：新浏览器会话（独立自动化）

适用场景：独立自动化任务、测试、数据采集，不干扰用户的日常浏览。

```bash
# 直接使用，自动启动 Chrome（无需手动操作）
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser screenshot D:\2Work\Claude\imgs\result.png
agent-browser close
```

---

## 截图保存

所有截图统一保存到 `D:\2Work\Claude\imgs\`：

```bash
agent-browser screenshot D:\2Work\Claude\imgs\screenshot.png
agent-browser screenshot D:\2Work\Claude\imgs\screenshot.png --full      # 全页截图
agent-browser screenshot D:\2Work\Claude\imgs\screenshot.png --annotate  # 含元素标注
```

---

## 代理配置

agent-browser 自动读取系统代理环境变量，**无需额外配置**：

```bash
# 如果已设置 HTTP_PROXY/HTTPS_PROXY，agent-browser 自动走代理
# 也可显式指定
agent-browser --proxy "http://127.0.0.1:7890" open https://example.com
```

---

## 常用场景快速参考

### 查看当前标签页（原 edge-cli tabs）

```bash
agent-browser --cdp 9222 snapshot -i
# 或 获取当前页标题和URL
agent-browser --cdp 9222 get title
agent-browser --cdp 9222 get url
```

### 页面截图（原 edge-cli screenshot）

```bash
agent-browser --cdp 9222 screenshot D:\2Work\Claude\imgs\edge-screenshot.png
```

### 填写表单并提交

```bash
agent-browser open https://example.com/form
agent-browser snapshot -i
agent-browser fill @e1 "用户名"
agent-browser fill @e2 "密码"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser diff snapshot    # 验证操作生效
```

### 登录后保存状态（下次免登录）

```bash
# 从日常 Edge 导入认证状态
agent-browser --auto-connect state save D:\2Work\Claude\auth.json
# 后续使用
agent-browser --state D:\2Work\Claude\auth.json open https://app.example.com/dashboard
```

### 数据提取

```bash
agent-browser open https://example.com
agent-browser get text body > output.txt
agent-browser snapshot -i --json   # JSON 格式输出
```

### 网络请求调试

```bash
agent-browser open https://example.com
agent-browser network requests --type xhr,fetch --method POST
agent-browser network har start
# ... 执行操作 ...
agent-browser network har stop D:\2Work\Claude\capture.har
```

---

## 触发条件

当用户消息包含以下关键词时，自动使用 agent-browser：

**连接日常 Edge 模式**（`--cdp 9222`）：
- "edge 访问"、"edge 打开"、"edge 截图"、"edge 查看"
- "通过 edge 浏览器"、"用 edge"、"在 edge 中"

**新浏览器模式**（默认）：
- "浏览器访问"、"打开网页"、"访问网站"
- "截图"、"抓取页面"、"自动化"、"测试网页"

**CRITICAL 执行要求**：
- ✅ 自动判断使用哪种连接模式
- ✅ 直接执行，不询问用户是否需要操作
- ✅ 操作完成后保持浏览器状态，不随意关闭
- ❌ 不再使用 Puppeteer、edge-cli、Playwright CLI

---

## 快速参考命令

```bash
# 连接日常 Edge
agent-browser connect 9222 / agent-browser --auto-connect

# 导航
agent-browser open <url>
agent-browser --cdp 9222 open <url>

# 快照与交互
agent-browser snapshot -i           # 获取元素引用
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser scroll down 500

# 截图
agent-browser screenshot D:\2Work\Claude\imgs\out.png
agent-browser screenshot D:\2Work\Claude\imgs\out.png --annotate

# 验证
agent-browser diff snapshot         # 操作前后对比
agent-browser get url / get title

# 会话
agent-browser session list
agent-browser close --all

# Dashboard（实时监控所有 session）
agent-browser dashboard start       # 端口 4848
```

**完整文档**：`C:\Users\admin\.claude\skills\agent-browser\SKILL.md`

---

## 变更历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0.0 | 2026-03-09 | 初始版本（Playwright CLI + Puppeteer + edge-cli） |
| 2.0.0 | 2026-03-27 | **全面迁移至 agent-browser**，废弃所有旧工具 |
