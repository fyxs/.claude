# Claude 全局配置

> 本文件由 Claude Code 在所有会话中自动加载。
> 作用：核心指令入口，详细规则见 `~/.claude/rules/` 目录。

---

## 配置架构

采用四层架构，详见 `~/.claude/rules/architecture.md`：

```
全局层 (~/.claude)        ← 本文件所在层
    ↓ 软连接共享
领域层 / 应用层 / 项目层
```

---

## 全局规则索引

| 规则文件 | 核心内容 |
|---------|---------|
| `rules/common/global-sdd-workflow.md` | **主工作流**：SDD /specify /plan /tasks |
| `rules/common/global-development-workflow.md` | 实现层：研究→Annotation Cycle→验证→Git |
| `rules/common/global-development-agent-orchestration.md` | Agent 编排：planner/reviewer/并行执行/TodoWrite |
| `rules/common/global-tools-environment.md` | 工具选择策略、Obsidian 集成、任务监控 |
| `rules/common/global-edge-browser-automation.md` | 浏览器自动化（agent-browser 唯一工具） |
| `rules/common/global-notebooklm-usage.md` | NotebookLM 使用规则（前缀触发） |
| `rules/common/global-token-optimization.md` | Token 优化、上下文压缩策略 |
| `rules/common/meta-rule-creation-guide.md` | 规则创建与维护指南 |

---

## 最高优先级规则

### 工具使用（浏览器自动化）

**agent-browser 是唯一的浏览器自动化工具**，覆盖所有场景：

```bash
agent-browser --cdp 9222 <命令>   # 连接日常 Edge（端口 9222）
agent-browser --auto-connect <命令>  # 自动发现已运行浏览器
agent-browser open <url>           # 新浏览器会话
```

Skill 位置：`C:\Users\admin\.claude\skills\agent-browser\`

### 网页内容抓取优先级

```
本地简单内容  → curl
本地需要清洗  → Smart Web Fetch
云端/无代理   → WebFetch
JS渲染/交互   → agent-browser
```

### 前缀规则（最高优先级，覆盖其他判断）

| 前缀 | 执行 |
|------|------|
| `notebooklm <内容>` | 完整 NotebookLM 工作流 |
| `obsidian <内容>` | 直接保存到 Obsidian（主题从上下文判断） |
| `/specify` | SDD 阶段1：生成规格说明 |
| `/plan` | SDD 阶段2：生成实现计划 |
| `/tasks` | SDD 阶段3：生成任务列表 |

### 开发工作流（SDD 优先）

**主工作流（SDD）**：`/specify → /plan → /tasks → 实现`，每阶段产出后必须等待用户确认。

**实现层规则：**
- **研究结果**必须持久化到 `research.md`（SDD 已有则复用，不重复）
- **计划**必须写入 `plan.md`，经 Annotation Cycle 确认后才能实现
- **TDD 可选**：视项目情况决定，不再强制
- **提交前**必须运行完整验证循环（构建→类型→Lint→安全）

---

## 关键路径

| 资源 | 路径 |
|------|------|
| 全局 Skills | `C:\Users\admin\.claude\skills\` |
| Obsidian Vault | `D:\8Documents\Obsidian\` |
| 截图目录 | `D:\2Work\Claude\imgs\` |
| agent-browser 源码 | `D:\2Work\Claude\tools\agent-browser\` |
| Smart Web Fetch | `D:\2Work\Claude\tools\smart-web-fetch\` |
