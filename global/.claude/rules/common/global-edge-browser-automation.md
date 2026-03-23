# Edge 浏览器自动化规则

> 规则 ID: GLOBAL-TOOL-003
> 版本: 1.0.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-18
> 状态: 发布

> 本规则定义了 Edge 浏览器自动化操作的触发条件和执行流程。

## 触发条件

当用户消息包含以下关键词组合时，自动执行 Edge 浏览器操作：

- "通过 edge 浏览器访问"
- "edge 访问"
- "edge 查看"
- "edge 打开"
- "用 edge 浏览器"
- "通过 edge 浏览器"
- "在 edge 中"
- "edge 浏览器中"

## 自动化流程

### 1. 检查 Edge 是否已启动

**检查方法：** 尝试连接到 `http://localhost:9222`

```javascript
// 检查代码示例
const { chromium } = require('playwright');

async function checkEdgeRunning() {
  try {
    const browser = await chromium.connectOverCDP('http://localhost:9222');
    await browser.close();
    return true;
  } catch (error) {
    return false;
  }
}
```

### 2. 如果未启动，自动启动 Edge

**启动脚本位置：** `D:\2Work\Claude\auto-js\browser\start-edge-debug.bat`

**执行命令：**
```bash
cd "D:\2Work\Claude" && cmd /c auto-js\browser\start-edge-debug.bat
```

**等待时间：** 启动后等待 3-5 秒，让浏览器完全启动

### 3. 连接到 Edge 浏览器

**连接脚本：** `D:\2Work\Claude\auto-js\browser\connect-edge.js` 或 `D:\2Work\Claude\auto-js\browser\explore-edge.js`

**连接代码：**
```javascript
const browser = await chromium.connectOverCDP('http://localhost:9222');
const contexts = browser.contexts();
const context = contexts[0];
```

### 4. 执行用户请求的操作

根据用户的具体需求执行相应操作：

- **访问网站：** 创建新标签页或使用现有标签页，导航到指定 URL
- **查看内容：** 获取页面标题、URL、内容
- **探索标签页：** 遍历所有打开的标签页，获取信息
- **截图：** 对指定页面进行截图
- **执行脚本：** 在页面中执行 JavaScript

## 脚本位置

所有浏览器相关脚本位于 `D:\2Work\Claude\auto-js\browser` 目录：

| 脚本 | 用途 |
|------|------|
| `start-edge-debug.bat` | 以调试模式启动 Edge（端口 9222） |
| `connect-edge.js` | 连接到 Edge 并执行示例操作 |
| `explore-edge.js` | 探索 Edge 中所有打开的标签页 |
| `get-page-content.js` | 获取指定页面的内容 |
| `test-puppeteer-simple.js` | Puppeteer 测试脚本 |
| `edge-cli.js` | Edge 统一控制工具 |
| `playwright-*.sh` | Playwright CLI 示例脚本 |

**工具位置：**
- Puppeteer：`D:\2Work\Claude\node_modules\@puppeteer`
- Playwright Skill：`D:\2Work\Claude\.claude\skills\playwright-cli\`
- Edge CLI：`D:\2Work\Claude\edge-cli.bat`

## 执行示例

### 示例 1：用户说"通过 edge 浏览器访问 example.com"

**自动执行流程：**

1. 检查 Edge 是否运行
   ```bash
   # 尝试连接 localhost:9222
   ```

2. 如果未运行，启动 Edge
   ```bash
   cd "D:\2Work\Claude" && cmd /c auto-js\browser\start-edge-debug.bat
   # 等待 3 秒
   ```

3. 连接并访问网站
   ```javascript
   const browser = await chromium.connectOverCDP('http://localhost:9222');
   const context = browser.contexts()[0];
   const page = await context.newPage();
   await page.goto('https://example.com');
   ```

4. 报告结果
   ```
   已通过 Edge 浏览器访问 example.com
   页面标题：Example Domain
   ```

### 示例 2：用户说"edge 查看当前打开的页面"

**自动执行流程：**

1. 检查 Edge 是否运行（同上）

2. 如果未运行，启动 Edge（同上）

3. 探索所有标签页
   ```bash
   cd "D:\2Work\Claude" && node auto-js/browser/explore-edge.js
   ```

4. 报告结果
   ```
   当前 Edge 浏览器中有 8 个标签页：
   1. [标题] - [URL]
   2. [标题] - [URL]
   ...
   ```

## 注意事项

1. **不要重复询问：** 用户不需要每次都说"先启动 Edge"，自动检查并启动
2. **保持连接：** 操作完成后不要关闭浏览器，保持用户的工作状态
3. **错误处理：** 如果连接失败，提供清晰的错误信息和解决建议
4. **等待时间：** 启动 Edge 后需要等待足够时间（3-5 秒）
5. **端口占用：** 如果 9222 端口被占用，提示用户检查

## 实施要求

**CRITICAL：** 当检测到触发条件时，必须：

1. ✅ 自动检查 Edge 状态
2. ✅ 自动启动 Edge（如果需要）
3. ✅ 自动连接并执行操作
4. ❌ 不要询问用户是否需要启动
5. ❌ 不要让用户手动执行步骤

**目标：** 让用户只需说"edge 访问 xxx"，所有准备工作自动完成。

## 快速参考

**启动 Edge：**
```bash
cd "D:\2Work\Claude" && cmd /c auto-js\browser\start-edge-debug.bat
```

**探索标签页：**
```bash
cd "D:\2Work\Claude" && node auto-js/browser/explore-edge.js
```

**连接代码模板：**
```javascript
const { chromium } = require('playwright');
const browser = await chromium.connectOverCDP('http://localhost:9222');
const context = browser.contexts()[0];
const pages = context.pages();
```

---

## Playwright CLI 集成（首选）

### 简介

**Playwright CLI** 是微软在 2026 年 2 月推出的独立命令行工具，是浏览器自动化的首选方案。

**当前状态：** ✅ 已安装

**安装信息：**
- 版本：`1.59.0-alpha-1771104257000`
- 全局安装：`@playwright/cli`
- ✅ 测试通过：打开页面、导航、快照功能正常

**为什么是首选：**
- **Token 节省 75%**：元素引用系统（e1, e2, e3）比传统选择器节省大量 Token
- **命令行工具**：更适合 AI 助手使用，无需编写 JavaScript 代码
- **自动快照**：每次操作后自动提供页面状态，便于理解和调试
- **功能丰富**：支持表单、键盘、鼠标、导航、网络调试等完整功能
- **测试稳定**：实际测试表现良好，无卡顿问题

### 核心优势

- **Token 节省 4 倍**：比 MCP 版本节省约 75% 的 Token 成本
- **元素引用简单**：使用 e1, e2, e3 等编号，无需写 CSS 选择器
- **完整浏览器控制**：支持表单、键盘、鼠标、导航、网络调试等
- **自动快照机制**：每个命令后自动提供页面快照

### 核心功能

**1. 元素引用系统**
```bash
playwright-cli snapshot              # 获取页面快照，显示元素编号
playwright-cli click e15             # 点击编号为 e15 的元素
playwright-cli fill e5 "text"        # 填写编号为 e5 的输入框
```

**2. 基础操作**
```bash
playwright-cli open https://example.com    # 打开页面
playwright-cli goto https://other.com      # 导航到新页面
playwright-cli screenshot                  # 截图
playwright-cli close                       # 关闭浏览器
```

**3. 调试工具**
```bash
playwright-cli console                     # 查看控制台日志
playwright-cli network                     # 查看网络请求
playwright-cli tracing-start               # 开始追踪
playwright-cli tracing-stop                # 停止追踪
```

### 可用脚本

位于 `D:\2Work\Claude\auto-js\browser\` 目录：

| 脚本 | 用途 | 使用场景 |
|------|------|---------|
| `playwright-visit.sh` | 基础访问和截图 | 快速查看页面状态 |
| `playwright-form-test.sh` | 表单测试模板 | 测试表单功能 |
| `playwright-inspect.sh` | 页面巡检 | 检查页面健康状况 |
| `playwright-debug.sh` | 调试助手 | 完整调试信息收集 |

**使用示例：**
```bash
# 访问页面并截图
bash D:\2Work\Claude\auto-js\browser\playwright-visit.sh https://example.com

# 页面巡检
bash D:\2Work\Claude\auto-js\browser\playwright-inspect.sh https://example.com

# 调试模式
bash D:\2Work\Claude\auto-js\browser\playwright-debug.sh https://example.com
```

### 使用场景

**1. 前端开发调试**
- AI 改完代码后自己打开浏览器验证
- 自动截图对比前后效果
- 查看控制台错误和网络请求

**2. 自动化测试**
- 表单功能测试
- 用户流程测试
- 回归测试

**3. 页面巡检**
- 检查线上页面状态
- 监控控制台错误
- 验证关键功能

**4. 问题诊断**
- 录制操作追踪
- 收集调试信息
- 分析网络请求

### Token 优化

**为什么 Playwright CLI 省 Token？**

| 方式 | Token 消耗 | 原因 |
|------|-----------|------|
| MCP | ~114,000 | 每次操作都把完整页面结构塞进上下文 |
| CLI | ~27,000 | 快照保存到文件，按需读取 |

**节省策略：**
1. 快照保存为 YAML 文件，不占用上下文
2. 截图保存为 PNG 文件，不以字节形式进入上下文
3. 工具描述只有 ~68 token（MCP 需 ~3,600 token）

### 与现有工作流集成

**自动化触发：**

当用户说以下关键词时，优先考虑使用 Playwright CLI：
- "playwright 访问"
- "playwright 测试"
- "playwright 检查"
- "使用 playwright"

**与 Edge 自动化配合：**
- Edge CDP 连接：适合连接已打开的浏览器
- Playwright CLI：适合自动化测试和调试

**选择建议：**
- 需要连接现有浏览器 → 使用 CDP 连接
- 需要自动化测试 → 使用 Playwright CLI
- 需要调试信息 → 使用 Playwright CLI
- 需要快照和元素编号 → 使用 Playwright CLI

### 快速参考

**基础命令：**
```bash
playwright-cli open https://example.com
playwright-cli snapshot
playwright-cli click e5
playwright-cli screenshot
playwright-cli close
```

**调试命令：**
```bash
playwright-cli console
playwright-cli network
playwright-cli tracing-start
playwright-cli tracing-stop
```

**会话管理：**
```bash
playwright-cli list                    # 列出所有会话
playwright-cli -s=mysession open       # 创建命名会话
playwright-cli close-all               # 关闭所有会话
```

**完整文档：**
- Skill 文件：`D:\2Work\Claude\.claude\skills\playwright-cli\SKILL.md`
- 示例脚本：`D:\2Work\Claude\auto-js\browser\playwright-*.sh`

---

## Puppeteer 浏览器自动化（备选方案）

### 简介

**Puppeteer** 是浏览器自动化的备选方案，适合需要复杂编程逻辑的场景。

**安装状态：**
- ✅ 已安装：`puppeteer-core@^24.38.0`
- 位置：`D:\2Work\Claude\node_modules\@puppeteer`
- ✅ 测试通过：连接、导航、截图等功能正常

### 何时使用 Puppeteer

**适用场景：**
1. 需要复杂编程逻辑（循环、条件判断、数据处理）
2. Playwright CLI 无法满足的特殊需求
3. 需要更精细的 API 控制
4. CDP 协议的高级功能

### 基本使用

**连接到 Edge（CDP）：**
```javascript
const puppeteer = require('puppeteer-core');

// 连接到已运行的 Edge
const browser = await puppeteer.connect({
  browserURL: 'http://localhost:9222',
  defaultViewport: null
});

// 创建新页面
const page = await browser.newPage();

// 导航到页面
await page.goto('https://example.com', {
  waitUntil: 'domcontentloaded',
  timeout: 10000
});

// 获取页面标题
const title = await page.title();

// 截图
await page.screenshot({ path: 'D:\\2Work\\Claude\\imgs\\screenshot.png' });

// 关闭页面
await page.close();

// 断开连接（不关闭浏览器）
await browser.disconnect();
```

### 测试脚本

**位置：** `D:\2Work\Claude\auto-js\browser\test-puppeteer-simple.js`

**运行测试：**
```bash
cd "D:/2Work/Claude" && node auto-js/browser/test-puppeteer-simple.js
```

### 与 Playwright CLI 的对比

| 特性 | Playwright CLI | Puppeteer |
|------|---------------|-----------|
| 使用方式 | 命令行工具 | JavaScript 编程 |
| Token 效率 | ✅ 节省 75% | ⚠️ 标准消耗 |
| 元素引用 | ✅ e1, e2, e3 | ⚠️ CSS 选择器 |
| 自动快照 | ✅ 内置 | ❌ 需手动实现 |
| 适合 AI | ✅ 非常适合 | ⚠️ 需要编程 |
| 复杂逻辑 | ⚠️ 受限 | ✅ 完全支持 |
| **连接已打开浏览器** | ❌ 不支持 | ✅ 完全支持 |
| 使用场景 | 自动化任务（新浏览器） | 连接现有浏览器 + 复杂逻辑 |

### 工具选择策略

```
浏览器自动化任务
    ↓
需要连接已打开的浏览器？
    ↓ 是
    → Puppeteer（唯一选择）✅
    ↓ 否
创建新浏览器进行自动化？
    ↓ 是
    → Playwright CLI（首选）✅
    ↓ 需要复杂编程逻辑？
    → Puppeteer（备选）
```

**选择原则：**
- **连接已打开浏览器**：必须使用 Puppeteer（Playwright CLI 不支持）
- **自动化任务（新浏览器）**：优先使用 Playwright CLI（Token 效率高）
- **复杂编程逻辑**：使用 Puppeteer（完整 JavaScript API）

**重要说明：**
- Playwright CLI 只能创建新的浏览器会话，无法连接到已打开的浏览器
- Playwright 库虽然有 `connectOverCDP()` API，但实测连接不稳定
- Puppeteer 是连接已打开浏览器的最佳选择（CDP 协议稳定可靠）

---

## edge-cli 统一控制工具

### 简介

**edge-cli** 是专门为连接和操作已运行的 Edge 浏览器而设计的统一命令行工具，实现真正的"共享浏览器"体验。

**核心特点：**
- **共享浏览器**：连接到你已打开的 Edge，我看到的即你能看到的
- **统一接口**：类似 Playwright CLI 的命令行体验
- **自动管理**：自动检测和启动 Edge
- **完整控制**：支持打开页面、截图、查看标签页等操作
- **文件管理**：所有截图自动保存到 imgs 目录

### 安装状态

✅ edge-cli 已创建并可用：
- 主脚本：`D:\2Work\Claude\auto-js\browser\edge-cli.js`
- Windows 启动脚本：`D:\2Work\Claude\edge-cli.bat`
- 依赖：Playwright（已安装）

### 可用命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `start` | 启动 Edge（如果未运行） | `edge-cli start` |
| `check` | 检查 Edge 是否运行 | `edge-cli check` |
| `open` | 打开 URL（新标签页） | `edge-cli open https://example.com` |
| `goto` | 在当前标签页导航 | `edge-cli goto https://example.com` |
| `snapshot` | 获取页面快照 | `edge-cli snapshot` |
| `screenshot` | 截图当前页面 | `edge-cli screenshot` |
| `tabs` | 列出所有标签页 | `edge-cli tabs` |
| `console` | 查看控制台日志 | `edge-cli console` |
| `close` | 关闭 Edge | `edge-cli close` |
| `help` | 显示帮助信息 | `edge-cli help` |

### 使用方式

**在 Windows cmd/PowerShell 中：**
```bash
edge-cli check
edge-cli open https://example.com
edge-cli tabs
edge-cli screenshot
```

**在 bash/Git Bash 中：**
```bash
node D:\2Work\Claude\auto-js\browser\edge-cli.js check
node D:\2Work\Claude\auto-js\browser\edge-cli.js open https://example.com
```

**在 Claude Code 中：**
直接说"edge 访问 xxx"，我会自动使用 edge-cli。

### 工作原理

1. **自动检测**：edge-cli 会自动检测 Edge 是否运行
2. **自动启动**：如果 Edge 未运行，自动调用 start-edge-debug.bat 启动
3. **CDP 连接**：通过 CDP 协议连接到 Edge（端口 9222）
4. **共享控制**：操作你已打开的 Edge 浏览器

### 与 Playwright CLI 的区别

| 特性 | edge-cli | Playwright CLI |
|------|----------|----------------|
| 浏览器 | 连接到已运行的 Edge | 启动新的浏览器实例 |
| 使用场景 | 共享浏览器，协同工作 | 独立测试，自动化 |
| 标签页 | 看到用户所有标签页 | 只看到自己创建的 |
| 适合 | 日常开发调试 | 自动化测试 |

### 自动化触发

当你说以下关键词时，我会自动使用 edge-cli：
- "edge 访问 xxx"
- "edge 打开 xxx"
- "edge 截图"
- "edge 标签页"
- "查看 edge"

### 文件管理

**截图保存位置：**
- 所有截图自动保存到 `D:\2Work\Claude\imgs\` 目录
- 默认文件名：`edge-screenshot-{timestamp}.png`
- 自定义文件名：`edge-cli screenshot myfile.png` → `D:\2Work\Claude\imgs\myfile.png`

**目录结构：**
```
D:\2Work\Claude/
├── imgs/                    # 截图目录
│   └── edge-screenshot-*.png
├── auto-js/browser/
│   ├── edge-cli.js         # 主脚本
│   └── start-edge-debug.bat
└── edge-cli.bat            # Windows 启动脚本
```

### 快速参考

**基础操作：**
```bash
edge-cli check              # 检查状态
edge-cli start              # 启动 Edge
edge-cli open <url>         # 打开页面
edge-cli tabs               # 列出标签页
edge-cli screenshot         # 截图（保存到 D:\2Work\Claude\imgs\）
```

**调试操作：**
```bash
edge-cli console            # 查看控制台
edge-cli snapshot           # 获取快照
```

**管理操作：**
```bash
edge-cli close              # 关闭 Edge
```
