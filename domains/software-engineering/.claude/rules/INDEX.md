# 规则索引

> 规则 ID: DOMAIN-INDEX-001
> 版本: 2.0.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-27
> 状态: 发布

---

## 全局层规则 (`C:\Users\admin\.claude\rules\common\`)

| 规则文件 | 主题 | 规则 ID |
|---------|------|---------|
| `global-sdd-workflow.md` | **主工作流**：SDD /specify /plan /tasks | GLOBAL-WORKFLOW-002 |
| `global-development-workflow.md` | 实现层工作流：研究复用、Annotation Cycle、验证、Git | GLOBAL-WORKFLOW-001 |
| `global-development-agent-orchestration.md` | Agent 编排：planner/reviewer/并行执行/TodoWrite | GLOBAL-AGENT-001 |
| `global-tools-environment.md` | 工具选择策略、Obsidian 集成、长时间任务监控 | GLOBAL-TOOL-002 |
| `global-edge-browser-automation.md` | 浏览器自动化（agent-browser 唯一工具） | GLOBAL-TOOL-003 |
| `global-notebooklm-usage.md` | NotebookLM 使用规则（前缀触发） | GLOBAL-TOOL-001 |
| `global-token-optimization.md` | Token 优化、上下文压缩策略 | GLOBAL-PERF-001 |
| `meta-rule-creation-guide.md` | 规则创建与维护指南 | META-001 |

---

## 领域层规则 (`D:\2Work\Claude\.claude\rules\`)

| 规则文件 | 主题 | 规则 ID |
|---------|------|---------|
| `architecture.md` | 领域配置架构、工作区目录结构说明 | DOMAIN-ARCH-001 |
| `domain-code-analysis-best-practices.md` | 代码分析：以代码为真相、主动验证、命名推理、全面搜索 | DOMAIN-STANDARD-001 |
| `domain-comprehensive-replacement-workflow.md` | 全面替换工作流：搜索→替换→验证→检查 | DOMAIN-WORKFLOW-001 |
| `domain-project-initialization.md` | 常规 .claude 初始化 vs init-project skill 的判断规则 | DOMAIN-INIT-001 |
| `domain-standards-security.md` | 代码标准（不可变性、文件组织、注释）与安全最佳实践 | DOMAIN-STANDARD-002 |

---

## 按主题分类

### 工作流规则

| 规则 | 层级 | 文件 |
|------|------|------|
| SDD 工作流（规格层，主工作流） | 全局 | global-sdd-workflow.md |
| 开发工作流（实现层） | 全局 | global-development-workflow.md |
| 全面替换工作流 | 领域 | domain-comprehensive-replacement-workflow.md |

### 工具使用规则

| 规则 | 层级 | 文件 |
|------|------|------|
| 工具与环境配置 | 全局 | global-tools-environment.md |
| 浏览器自动化（agent-browser） | 全局 | global-edge-browser-automation.md |
| NotebookLM 使用 | 全局 | global-notebooklm-usage.md |

### Agent 编排规则

| 规则 | 层级 | 文件 |
|------|------|------|
| Agent 编排与自动化 | 全局 | global-development-agent-orchestration.md |

### 代码质量规则

| 规则 | 层级 | 文件 |
|------|------|------|
| 代码分析最佳实践 | 领域 | domain-code-analysis-best-practices.md |
| 代码标准与安全 | 领域 | domain-standards-security.md |

### 性能与优化规则

| 规则 | 层级 | 文件 |
|------|------|------|
| Token 与上下文优化 | 全局 | global-token-optimization.md |

### 配置与初始化规则

| 规则 | 层级 | 文件 |
|------|------|------|
| 领域配置架构 | 领域 | architecture.md |
| 项目初始化规则 | 领域 | domain-project-initialization.md |

### 元规则

| 规则 | 层级 | 文件 |
|------|------|------|
| 规则创建指南 | 全局 | meta-rule-creation-guide.md |

---

## 规则统计

| 层级 | 文件数 |
|------|--------|
| 全局层 | 8 |
| 领域层 | 5（含 architecture.md + INDEX.md） |
| **总计** | **13** |

---

## 变更历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0.0 | 2026-03-09 | 初始版本 |
| 1.1.0 | 2026-03-10 | 新增缓存状态、规则依赖关系 |
| 2.0.0 | 2026-03-27 | 全面重写：反映当前实际文件状态；删除过时条目（domain-agent-orchestration、domain-mcp-configuration-guide、domain-development-workflow、rule-tests）；补充新全局层规则（global-development-agent-orchestration、global-edge-browser-automation、global-sdd-workflow） |
