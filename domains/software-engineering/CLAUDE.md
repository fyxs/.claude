# Claude 工作区

软件工程领域工作区，采用四层配置架构。

## 快速参考

**主工作目录**：`D:\2Work\Claude`

**目录结构**：
- `auto-js/` — 自动化脚本
- `docs/` — 文档资源
- `resources/` — 参考资源 & 第三方仓库
- `tools/` — 工具和实用程序
- `configs/` — 配置文件集合
- `imgs/` — 截图和图片
- `ts-projects/` — 企业项目
- `personal-projects/` — 个人开发项目

**应用层**：
- `ts-projects/.claude/` — 企业开发配置
- `personal-projects/.claude/` — 个人开发配置

---

## 核心规则

### 开发工作流（SDD 优先）

**主工作流**：`/specify → /plan → /tasks → 实现`，每阶段产出后必须等待用户确认。

- `/specify` — 生成规格说明（spec.md）
- `/plan` — 生成实现计划（plan.md + research.md + contracts/）
- `/tasks` — 生成任务列表（tasks.md）

**实现层**：有 SDD 产物时直接从 tasks.md 实现；无产物时研究→计划→实现。

**TDD**：视项目情况决定，不强制。

### 文件归类
- 自动化脚本 → `auto-js/`
- 文档/指南 → `docs/`
- 第三方资源 → `resources/`
- 独立工具 → `tools/`
- 配置模板 → `configs/`
- **Plan 文档** → 各层 `.claude/plans/`
  - 全局层 plan → `~/.claude/plans/`
  - 领域层 plan → `D:\2Work\Claude\.claude\plans\`
  - 应用层 plan → `ts-projects/.claude/plans/` 或 `personal-projects/.claude/plans/`
  - 项目层 plan → `项目目录/.claude/plans/`

### 工具使用
- **NotebookLM**：仅在明确要求或使用 `notebooklm` 前缀时使用
- **Obsidian**：知识记录（前缀：`obsidian`）
- **浏览器自动化**：统一使用 `agent-browser`（`--cdp 9222` 连接日常 Edge）

### Obsidian 存放目录
路径：`D:\8Documents\Obsidian`

| 内容类型 | 目录 |
|---------|------|
| 知识总结、学习笔记 | `Knowledge/` |
| 项目文档 | `Projects/` |
| 调研报告 | `Research/` |
| 日常记录 | `Daily/` |
| 配置说明 | `Config/` |
| 归档 | `Archive/` |

---

## 详细规则

完整规则体系位于 `.claude/rules/`：
- `architecture.md` — 领域配置架构说明
- `INDEX.md` — 规则索引（含全局层 + 领域层完整列表）
- `domain-code-analysis-best-practices.md` — 代码分析最佳实践
- `domain-comprehensive-replacement-workflow.md` — 全面替换工作流
- `domain-project-initialization.md` — 项目初始化规则
- `domain-standards-security.md` — 代码标准与安全

全局规则位于 `~/.claude/rules/common/`，详见全局 CLAUDE.md。

---

## 沟通偏好

- **语言**：中文优先
- **风格**：简洁实用
- **代码注释**：中文
