# Claude 配置架构总览

> 规则 ID: GLOBAL-ARCH-001
> 版本: 1.2.0
> 创建日期: 2026-03-10
> 最后更新: 2026-03-27
> 状态: 发布

## 全局层规则索引

### common/ 目录
- `meta-rule-creation-guide.md` - 元规则：规则创建指南
- `global-notebooklm-usage.md` - NotebookLM 使用规则
- `global-token-optimization.md` - Token 与性能优化策略（已合并 PERF-002）
- `global-tools-environment.md` - 工具与环境配置
- `global-edge-browser-automation.md` - 浏览器自动化规则（agent-browser 唯一工具）
- `global-sdd-workflow.md` - **主工作流**：SDD /specify /plan /tasks（GLOBAL-WORKFLOW-002）
- `global-development-workflow.md` - 实现层工作流：研究复用、Annotation Cycle、验证、Git（GLOBAL-WORKFLOW-001）
- `global-development-agent-orchestration.md` - Agent 编排：planner/reviewer/并行执行/TodoWrite（GLOBAL-AGENT-001）

---

## 四层配置架构

本配置系统采用四层架构，从全局到项目逐级细化：

```
全局层 (~/.claude)
    ↓ 继承
领域层 (领域工作区/.claude)
    ↓ 继承
应用层 (应用场景/.claude)
    ↓ 继承
项目层 (具体项目/.claude)
```

---

## 各层职责

### 1. 全局层

**作用域**：所有领域和项目

**存放内容**：
- 跨领域的通用规则
- 全局 skills
- 基础工具配置
- 全局 MCP 服务器配置
- 全局记忆

---

### 2. 领域层

**作用域**：特定专业领域

**存放内容**：
- 领域专业规则
- 领域工作流
- 领域特定工具配置
- 领域记忆

---

### 3. 应用层

**作用域**：特定工作场景

**存放内容**：
- 场景特定规则
- 团队协作规范
- 应用级配置
- 应用记忆

---

### 4. 项目层

**作用域**：单个项目

**存放内容**：
- 项目特定配置
- 项目级构建、测试规则
- 项目文档
- 项目特定 MCP

---

## 配置优先级

配置的继承和覆盖规则：

```
全局层（最低优先级）
    ↓ 可被覆盖
领域层
    ↓ 可被覆盖
应用层
    ↓ 可被覆盖
项目层（最高优先级）
```

**规则**：
- 下层配置可以覆盖上层配置
- 如果下层没有定义，则继承上层配置
- 所有层级的规则都会被加载，但优先级不同

---

## 目录结构规范

### 标准 .claude 目录结构

```
.claude/
├── rules/              # 规则文件
│   ├── common/         # 通用规则
│   └── specific/       # 特定规则（可选）
├── plans/              # 计划文档（各层独立存放）
├── temp/               # 临时文件、图片等（不纳入版本控制）
├── settings/           # 配置文件
│   └── mcp.json        # MCP 配置（可选）
├── templates/          # 项目模板（应用层）
├── memory/             # 记忆目录（可选）
└── skills/             # 自定义 skills（可选）
```

---

## 规则文件命名规范

使用前缀标识层级和类型：

| 前缀 | 层级 | 示例 |
|------|------|------|
| `global-` | 全局层 | `global-preferences.md` |
| `domain-` | 领域层 | `domain-development-workflow.md` |
| `app-` | 应用层 | `app-enterprise-standards.md` |
| `project-` | 项目层 | `project-build-config.md` |
| `meta-` | 元规则 | `meta-rule-creation-guide.md` |

**特殊规则文件**：
- `architecture.md` - 架构说明（各层通用）
- `INDEX.md` - 规则索引（各层通用）

---

## 配置最佳实践

1. **规则复用**：通用规则放在上层，避免重复
2. **职责清晰**：每层只定义自己职责范围内的规则
3. **适度覆盖**：只在必要时覆盖上层配置
4. **文档完善**：每层都应有清晰的说明文档
5. **定期审查**：定期检查规则的有效性和合理性
6. **Plan 文档归类**：每层的 plan 文档归到该层的 `.claude/plans/` 目录
   - 全局层 plan → `~/.claude/plans/`
   - 领域层 plan → `领域工作区/.claude/plans/`
   - 应用层 plan → `应用场景/.claude/plans/`
   - 项目层 plan → `项目目录/.claude/plans/`
   - **原则**：每层的 plan 归到该层，不跨层存放

---

## 快速参考

**配置位置**：
- 全局：`~/.claude/`
- 领域：`领域工作区/.claude/`
- 应用：`应用场景/.claude/`
- 项目：`项目目录/.claude/`

**规则加载**：
所有层级的规则都会被加载，按优先级应用。
