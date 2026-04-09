# 软件开发 Agent 编排与自动化

> 规则 ID: GLOBAL-AGENT-001
> 原始位置: D:\2Work\Claude\.claude\rules\domain-agent-orchestration.md
> 版本: 2.0.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-27
> 状态: 发布

> 本文档聚焦软件开发场景下的 Agent 编排策略、并行执行原则和 TodoWrite 任务管理。

---

## 一、开发场景 Agent 目录

**位置：** `~/.claude/agents/`（或通过内置 Agent 工具调用）

| Agent | 用途 | 触发时机 | 优先级 |
|-------|------|---------|--------|
| **planner** | 实施规划、任务拆解 | 复杂功能、重构、不确定路径 | 高 |
| **architect** | 系统设计、技术选型 | 架构决策、技术栈评估 | 高 |
| **code-reviewer** | 代码质量审查 | 编写/修改代码后 | 高 |
| **security-reviewer** | 安全漏洞分析 | 提交前、敏感功能 | 高 |
| **task-compliance-reviewer** | 任务执行合规审查 | 所有实现 Agent 完成后，merge 前 | 高 |
| **build-error-resolver** | 修复构建/编译错误 | 构建失败 | 中 |
| **refactor-cleaner** | 清理死代码、简化逻辑 | 代码维护 | 中 |
| **e2e-runner** | 端到端测试 | 关键流程验证、发布前 | 中 |
| **doc-updater** | 文档同步更新 | API 变更后、新功能发布 | 低 |

---

## 二、并行 Agent 上下文注入规范

> **核心问题**：子 Agent 自动继承全局规则（`~/.claude/rules/`），但**不继承任务上下文**。
> Orchestrator 必须通过结构化 prompt 显式注入任务上下文，否则 Agent 无法按规则执行。

### 2.1 继承机制说明

| 信息类型 | 是否自动继承 | 说明 |
|---------|------------|------|
| 全局规则（rules/）| ✅ 自动 | SDD 工作流、Figma 规则、工具选择等 |
| 项目层 CLAUDE.md | ✅ 自动 | 项目特定约定 |
| SDD 产物（spec/plan/tasks）| ❌ 不继承 | 需要 orchestrator 传入路径 |
| Figma 节点分配 | ❌ 不继承 | 需要显式列出节点 ID |
| 文件作用域边界 | ❌ 不继承 | 需要明确哪些文件可操作 |
| 并行 Agent 的分工 | ❌ 不继承 | 需要说明其他 Agent 负责什么 |

### 2.2 结构化 Agent Prompt 模板（MANDATORY）

**所有并行 Agent 的 prompt 必须包含以下结构，不得使用随意的自然语言描述：**

```
你是 [角色]，负责实现 [具体任务描述]。

## 上下文文档（实现前必须读取）
- Spec: specs/[###]/spec.md
- 计划: specs/[###]/plan.md
- 任务列表: specs/[###]/tasks.md
[UI 任务追加:]
- Figma 节点映射: specs/[###]/figma-nodes.md

## 你的任务范围
- 任务 ID: T1.1, T1.2（对应 tasks.md 中的条目）
- 允许修改: src/components/ReportCard/
- 禁止修改: src/api/, src/store/（其他 Agent 负责，修改会冲突）

[UI 任务追加:]
## Figma 节点读取顺序
1. get_design_context(1525:25952) → 卡片容器
2. get_design_context(1525:25953) → 标题行
3. get_design_context(I1525:25964;2:441) → 图标

## 完成后必须输出（格式固定，Orchestrator 用于验证）

### 已完成任务
- [x] T1.1 - 实现 ReportCard 容器
- [ ] T1.2 - 未完成（说明原因）

### 已修改文件
- src/components/ReportCard/index.tsx（新建）
- src/components/ReportCard/styles.module.css（新建）

### Figma 节点读取记录（UI 任务必填）
- get_design_context(1525:25952) ✅
- get_design_context(1525:25953) ✅
- get_design_context(I1525:25964;2:441) ✅

### 偏差说明
- 无 / 或：描述偏离 tasks.md 规划的地方及原因
```

### 2.3 Agent Bootstrap 顺序（强制）

每个 Agent 启动后必须按以下顺序操作，**不得跳过读取步骤直接开始实现**：

```
1. 读取 tasks.md → 确认自己负责的任务 ID
2. 读取 plan.md → 了解技术方案和约束
   [UI 任务:]
3. 读取 figma-nodes.md → 确认节点分配
4. 依次调用 get_design_context 获取视觉细节
5. 开始实现，严格限制在文件作用域内
6. 按 §2.2 模板输出结构化完成报告
```

### 2.4 文件作用域隔离（防冲突）

并行 Agent 之间必须有**互不重叠的文件作用域**，由 orchestrator 在启动时明确划分：

```
✅ 正确：作用域互不重叠
  Agent A → src/components/ReportCard/
  Agent B → src/components/ReportList/
  Agent C → src/api/report.ts

❌ 错误：作用域重叠，导致写冲突
  Agent A → src/components/（过于宽泛）
  Agent B → src/components/ReportCard/（被 A 覆盖）
```

**原则：** 作用域粒度与任务粒度一致，组件级任务给组件级目录，API 任务给对应文件。

### 2.5 Orchestrator 内联验证（汇总阶段）

所有并行 Agent 返回结果后，Orchestrator **必须执行内联验证**，不得直接进入下一阶段：

```
收到各 Agent 的结构化完成报告
    ↓
对照 tasks.md 逐项检查：

  检查项 1：任务完成度
    tasks.md 中的任务 ID 是否全部出现在报告的"已完成任务"中？
    → 有未完成项 → 针对性补发指令给对应 Agent

  检查项 2：文件作用域
    "已修改文件"中是否有文件超出分配的作用域边界？
    → 有越界文件 → 记录并要求 Agent 解释或回滚

  检查项 3：Figma 节点（UI 任务）
    figma-nodes.md 中的节点是否全部出现在"节点读取记录"中？
    → 有遗漏节点 → 要求 Agent 补充读取并修正对应实现

  检查项 4：偏差评估
    "偏差说明"中的偏差是否在可接受范围内？
    → 重大偏差 → 进入 task-compliance-reviewer（见 §3.1）
    ↓
全部通过 → 进入 code-reviewer + security-reviewer 阶段
```

**原则：内联验证由 Orchestrator（主 Agent）直接执行，无需启动额外 Agent，零额外开销。**

---

## 三、Agent 使用策略

### 3.1 SDD 阶段触发映射（主要入口）

**规则文件：** `global-sdd-workflow.md`

执行 SDD 流程时，各阶段对应的 Agent 触发时机：

| SDD 阶段 | 触发 Agent | 触发条件 |
|---------|-----------|---------|
| `/specify` | **planner**（可选） | 需求复杂、用户故事不清晰时 |
| `/plan` | **architect**（可选） | 需要技术选型或架构决策时 |
| 用户确认 `tasks.md` 后 | **并行实现 Agent** | tasks.md 中存在标记 `[P]` 的任务组 |
| Orchestrator 内联验证通过后 | **task-compliance-reviewer**（重大偏差时）| 实现报告有重大偏差，或高还原度要求时 |
| 合规核查通过后 | **code-reviewer** + **security-reviewer** | 并行审查，必须执行 |

**`tasks.md` 确认后的完整执行流程：**
```
主 Agent（Orchestrator）读取 tasks.md
    ↓
提取 [P] 任务组 → 按文件作用域边界划分
    ↓
为每个子 Agent 构造结构化 prompt（§2.2 模板）
    ↓
单次消息并行启动所有实现 Agent
    ↓
收到结构化完成报告 → Orchestrator 内联验证（§2.5）
    ↓
    ├─ 有重大偏差 → 启动 task-compliance-reviewer
    │               输入：tasks.md + 完成报告 + git diff
    │               输出：合规报告 + 未完成项 → 补充执行
    │
    └─ 验证通过 → 并行启动 code-reviewer + security-reviewer
```

### 3.2 主动触发原则（非 SDD 场景）

根据任务类型**自动选择 Agent**，不等待用户明确要求：

| 场景 | 自动启动 |
|------|---------|
| 用户请求复杂功能 / 重构 | **planner** agent |
| 需要技术选型或架构设计 | **architect** agent |
| 代码编写或修改完成 | **code-reviewer** agent |
| 涉及认证、权限、用户输入 | **security-reviewer** agent |
| 构建失败 | **build-error-resolver** agent |

### 3.3 并行执行原则

**ALWAYS 对独立任务并行执行，不顺序等待。**

```
✅ 正确：单次消息同时启动多个 Agent
   Agent 1: code-reviewer  → auth 模块
   Agent 2: security-reviewer → auth 模块
   Agent 3: doc-updater → API 文档
   （三者同时运行，互不依赖）

❌ 错误：先等 Agent 1 完成，再启动 Agent 2
```

**常见并行组合：**

| 场景 | 并行 Agents |
|------|------------|
| 代码提交前 | code-reviewer + security-reviewer |
| 发布前验证 | e2e-runner + security-reviewer + build-error-resolver |
| 代码维护 | refactor-cleaner + doc-updater |
| 架构评审 | architect + security-reviewer（多视角） |

### 3.4 多视角分析

对复杂决策启动不同角色的子 Agent 并行分析：

```
问题：设计认证系统架构

并行启动：
├── 高级工程师视角：评估架构合理性、可扩展性
├── 安全专家视角：识别潜在漏洞、合规风险
└── 一致性审查视角：检查与现有代码风格的一致性

汇总三方意见 → 做出决策
```

**适用场景：** 架构决策、安全关键功能、大规模重构、性能优化

---

## 四、Hooks 系统

Claude Code 通过 `~/.claude/settings.json` 配置 hooks，在工具执行前后自动触发脚本。

### Hook 类型与用途

| Hook | 触发时机 | 典型用途 |
|------|---------|---------|
| `PreToolUse` | 工具执行前 | 参数校验、阻止危险操作、日志记录 |
| `PostToolUse` | 工具执行后 | 自动格式化、lint 检查、触发后续操作 |
| `Stop` | 会话结束时 | 最终验证、生成报告、清理资源 |
| `Notification` | 需要通知时 | 推送提醒、状态同步 |

### 开发场景常用 Hook 配置

```json
// ~/.claude/settings.json 中的 hooks 配置示例
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          { "type": "command", "command": "prettier --write {{file_path}}" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "npm run lint" }
        ]
      }
    ]
  }
}
```

### 权限配置原则

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run build)",
      "Bash(git status)"
    ]
  }
}
```

**原则：**
- ✅ 对受信任、重复性的操作配置 allow
- ✅ 定期审查已配置的权限
- ❌ 不对破坏性操作（如 `git push --force`、`rm -rf`）配置自动允许
- ❌ 不在不熟悉的代码库中开启大范围自动接受

---

## 五、TodoWrite 任务管理

### 何时使用

- 任务有 **3 个或以上步骤**时
- 任务预计执行时间超过 **5 分钟**时
- 涉及**多文件修改**时
- 需要**用户中途确认**某些决策时

不适用：单步骤操作、快速 bug 修复、文档小修改。

### 工作流

```
收到任务
  → 创建 TodoList（pending 状态）
  → 开始第一个任务（设为 in_progress）
  → 完成后立即标记 completed
  → 继续下一个（一次只有一个 in_progress）
  → 发现新子任务 → 随时追加
  → 所有完成 → 汇报结果
```

### 任务粒度建议

```
❌ 粒度太粗：
  1. 实现认证功能

✅ 适当粒度：
  1. 读取 spec.md 确认需求范围
  2. 设计数据模型（User、Session 表）
  3. 实现登录 API（POST /auth/login）
  4. 实现登出 API（POST /auth/logout）
  5. 代码审查（code-reviewer）
  6. 安全扫描（security-reviewer）
  7. 提交代码
```

### 与 SDD tasks.md 的关系

- SDD `/tasks` 生成的 `tasks.md` 是**宏观任务列表**（面向功能交付）
- TodoWrite 是**执行层追踪**（面向当前会话的实时进度）
- 两者互补：`tasks.md` 确定做什么，TodoWrite 追踪怎么做

---

## 六、最佳实践总结

1. **主动编排**：检测到复杂任务时自动启动对应 Agent，不等用户要求
2. **并行优先**：独立任务一律并行执行，节省时间
3. **结构化注入**：并行 Agent 的 prompt 必须包含 SDD 文档路径、Figma 节点、文件作用域边界
4. **Bootstrap 顺序**：Agent 启动后先读文档再实现，不得跳过 tasks.md / figma-nodes.md
5. **作用域隔离**：并行 Agent 的文件作用域必须互不重叠，由 Orchestrator 明确划分
6. **结构化完成报告**：每个 Agent 必须按固定格式输出完成报告，供 Orchestrator 验证
7. **Orchestrator 内联验证**：���总阶段对照 tasks.md 检查完成度、作用域、Figma 节点覆盖
8. **task-compliance-reviewer 兜底**：内联验证发现重大偏差时启动，作为 merge 前 QA 门控
9. **SDD 衔接**：Agent 触发时机与 SDD 三阶段严格对齐（§3.1）
10. **Hooks 自动化**：通过 PostToolUse 实现格式化、lint 等重复操作的自动化
11. **TodoWrite 透明**：多步骤任务必须用 TodoWrite 跟踪，保持执行透明

---

## 相关规则

- **global-sdd-workflow.md** — 主工作流；`/tasks` 确认后触发本文件的 §二、§三 执行并行编排
- **global-development-workflow.md** — 实现层工作流（Annotation Cycle、验证、Git）
- **global-tools-environment.md** — 工具配置（浏览器、网页抓取等）

---

## 变更历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0.0 | 2026-03-09 | 初始版本（领域层） |
| 2.0.0 | 2026-03-27 | 移至全局层；聚焦软件开发场景；移除 TDD 强制相关内容；精简测试用例；与 SDD 工作流对齐 |
| 2.1.0 | 2026-04-09 | 新增"二、并行 Agent 上下文注入规范"：继承机制说明、结构化 prompt 模板、Bootstrap 顺序、文件作用域隔离原则；更新最佳实践总结 |
| 2.2.0 | 2026-04-09 | 重构"三、Agent 使用策略"：新增 §3.1 SDD 阶段触发映射，明确 tasks.md 确认后的并行分发流程；修正子章节编号；更新相关规则引用 |
| 2.3.0 | 2026-04-09 | 新增 task-compliance-reviewer（§一）；§2.2 prompt 模板强制结构化完成报告输出；新增 §2.5 Orchestrator 内联验证；更新 §3.1 完整执行流程含 QA 门控；修正章节编号（Hooks→四、TodoWrite→五、最佳实践→六）|
