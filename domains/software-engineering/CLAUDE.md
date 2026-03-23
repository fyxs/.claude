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

### 开发工作流
- **TDD 强制执行**：先写测试，再写代码
- **代码审查必需**：完成代码后立即审查
- **测试覆盖率**：最低 80%

### 文件归类
- 自动化脚本 → `auto-js/`
- 文档/指南 → `docs/`
- 第三方资源 → `resources/`
- 独立工具 → `tools/`
- 配置模板 → `configs/`
- **Plan 文档** → 各层 `.claude/plans/`
  - 全局层 plan → `~/.claude/plans/`
  - 领域层 plan → `D:\2Work\Claude\.claude/plans/`
  - 应用层 plan → `ts-projects/.claude/plans/` 或 `personal-projects/.claude/plans/`
  - 项目层 plan → `项目目录/.claude/plans/`
  - **原则**：每层的 plan 归到该层，不跨层存放

### 工具使用
- **NotebookLM**：仅在明确要求或使用 `notebooklm` 前缀时使用
- **Obsidian**：知识记录（前缀：`obsidian`）
- **Edge 自动化**：浏览器操作（关键词：`edge 访问`）

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
- `architecture.md` — 配置架构说明
- `INDEX.md` — 规则索引
- `domain-development-workflow.md` — 开发工作流
- `domain-agent-orchestration.md` — Agent 编排
- 更多规则请查看 INDEX.md

---

## 沟通偏好

- **语言**：中文优先
- **风格**：简洁实用
- **代码注释**：中文
