# 工具与环境配置

> 规则 ID: GLOBAL-TOOL-002
> 版本: 1.3.0
> 创建日期: 2026-03-09
> 最后更新: 2026-04-08
> 状态: 发布

> 本文档整合了环境配置、工具使用策略和任务监控规则。

## 目录

1. [网络访问配置](#网络访问配置)
2. [Obsidian 知识库集成](#obsidian-知识库集成)
3. [网页抓取工具选择](#网页抓取工具选择)
4. [NotebookLM 使用](#notebooklm-使用)
5. [长时间任务监控](#长时间任务监控)

---

## 网络访问配置

### 重要：本地环境已启用代理

**核心原则：** 访问外网资源时，ALWAYS 使用支持代理的命令行工具。

**推荐工具：**
- `curl` - HTTP/HTTPS 请求（自动使用系统代理）
- `git` - Git 操作（自动使用代理配置）

**不要使用：**
- WebFetch 工具 - 不支持代理配置

**示例：**
```bash
# 访问 GitHub API
curl -s https://api.github.com/repos/owner/repo

# 获取 README 内容
curl -s https://raw.githubusercontent.com/owner/repo/main/README.md
```

---

## Obsidian 知识库集成

### 核心原则

**CRITICAL: 所有知识文档必须统一存储在 Obsidian vault 中。**

**重要提醒：**
- ❌ 禁止使用 `D:\2Work\Claude\documents\` 存储知识文档
- ✅ 必须使用 `D:\8Documents\Obsidian\` 存储所有知识文档

---

### Vault 配置

- **Vault 位置**: `D:\8Documents\Obsidian`
- **CLI 状态**: 已启用

**目录结构：**
- `Knowledge/` - 知识库
- `Projects/` - 项目文档
- `Daily/` - 日记
- `Archive/` - 归档
- `Config/` - 配置文档
- `Instincts/` - 本能记录

**分段输出策略：**
- 先用 Write 创建简单框架（标题 + 基本结构）
- 再用 Edit 逐步添加内容
- 每次添加内容保持简短

---

### 目录结构

```
D:\8Documents\Obsidian/
├── Projects/          # 项目文档
├── Research/          # 调研报告
├── Knowledge/         # 知识沉淀
├── Daily/             # 日常记录
├── Config/            # 配置文档
└── Archive/           # 归档文档
```

---

### 文档创建规则

**根据文档类型自动选择存储位置：**

| 文档类型 | 目录 | 示例 |
|---------|------|------|
| 调研报告 | Research/ | 工具调研、技术调研 |
| 项目文档 | Projects/ | 开发文档、项目规划 |
| 知识总结 | Knowledge/ | 最佳实践、经验总结 |
| 配置说明 | Config/ | 环境配置、工具配置 |
| 日常记录 | Daily/ | 工作日志、临时笔记 |

---

## 网页抓取工具选择

### 核心原则

**根据环境和需求自动选择最合适的工具。**

---

### 可用工具

**1. Smart Web Fetch** ⭐ 本地网页内容抓取首选
- 位置：`D:\2Work\Claude\tools\smart-web-fetch\smart-web-fetch`
- 支持代理（通过 curl），本地环境可用
- 自动内容清洗，输出结构化干净文本
- 多级降级策略（比 curl 更健壮）
- 适合：需要提取干净内容、页面有大量噪声的场景

**2. curl** 备选工具
- 走系统代理，本地环境可用
- 适合：Smart Web Fetch 不可用时的降级方案
- 不做内容清洗

**3. WebFetch** 云端/无代理环境
- 开箱即用，官方维护
- **本地环境通常不通**（不走代理），慎用
- 仅在云端或无代理问题时使用

**3. agent-browser** ⭐ 浏览器自动化唯一工具（2026-03-27 全量替换）
- 版本：`0.22.3`（已全局安装）
- Skill 实际位置：`C:\Users\admin\.claude\skills\agent-browser\`（全局，软连接共享）
- 源码：`D:\2Work\Claude\tools\agent-browser\`
- **支持连接日常 Edge**：`--cdp 9222` 或 `--auto-connect`
- **支持新浏览器会话**：默认模式
- **@eN 引用系统**：无需 CSS 选择器
- **代理自动读取**：HTTP_PROXY/HTTPS_PROXY 环境变量
- 完整功能：Diff、HAR、Auth Vault、多 Session、Dashboard
- **详细规则**：见 [global-edge-browser-automation.md](./global-edge-browser-automation.md)（含 CDP 连接异常处理策略）

**废弃工具（不再使用）：**
- ~~Playwright CLI~~ — 已移除 skill（2026-03-27）
- ~~Puppeteer / edge-cli~~ — 所有场景由 agent-browser 覆盖

---

### 自动选择逻辑

```
需要抓取网页内容？
    ↓
本地环境（常态）
    → Smart Web Fetch ✅（默认首选，自带多级降级策略）
    ↓
页面需要 JS 渲染 / 交互？
    → agent-browser ✅

云端 / 无代理问题？
    → WebFetch

浏览器自动化？（无论新浏览器还是日常 Edge）
    → agent-browser ✅
      - 日常 Edge：agent-browser --cdp 9222 ...
      - 新浏览器：agent-browser open ...
```

**curl 仅作为备选**：Smart Web Fetch 不可用时（如工具故障）才降级使用 curl。

---

## NotebookLM 使用

### 核心原则

**优先使用 NotebookLM**：当用户要求使用 NotebookLM 时，应优先使用该工具。

---

### 认证问题处理

**遇到登录/认证问题时：**

1. **不要自行尝试解决复杂的认证问题**
2. **立即交给用户处理**
   - 告知用户遇到了认证问题
   - 说明具体的错误信息
   - 请用户自行处理认证
3. **等待用户确认后继续**

---

## 长时间任务监控

### 适用场景

当执行以下类型的长时间任务时，必须主动定期监控任务进度：
- npm install / npm uninstall
- 编译任务（npm build, webpack, etc.）
- 测试任务（npm test, pytest, etc.）
- 其他预计运行时间超过 30 秒的任务

---

### 监控策略

1. **启动任务后立即开始监控**
   - 使用 `run_in_background=true` 启动长时间任务
   - 记录任务 ID

2. **定期检查任务状态**
   - 第一次检查：1 分钟后
   - 后续检查：每 1 分钟一次
   - 使用 TaskOutput 工具检查任务状态

3. **主动报告进度**
   - 每次检查后，向用户报告当前状态
   - 如果任务仍在运行，说明"任务仍在运行，继续监控"
   - 如果任务完成，报告最终结果

4. **持续监控直到完成**
   - 不要停止监控，直到任务完成或失败
   - 主动、持续地监控任务进度

---

## 最佳实践总结

**网络访问：**
- 本地环境使用 curl（支持代理）
- 避免使用 WebFetch（不支持代理）

**知识管理：**
- 统一使用 Obsidian vault
- 按类型组织文档
- 使用分段输出策略

**工具选择：**
- 本地网页抓取：Smart Web Fetch（默认首选，自带降级策略，覆盖所有场景）
- Smart Web Fetch 不可用时：curl（备选）
- 云端/无代理问题：WebFetch
- JS 渲染 / 浏览器自动化：agent-browser（含日常 Edge 和新浏览器）

**任务监控：**
- 主动监控长时间任务
- 定期报告进度
- 持续直到完成

**记住：** 工具和环境配置是提高效率的基础。合理使用这些工具可以显著提升开发体验。
