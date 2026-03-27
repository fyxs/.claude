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
| **build-error-resolver** | 修复构建/编译错误 | 构建失败 | 中 |
| **refactor-cleaner** | 清理死代码、简化逻辑 | 代码维护 | 中 |
| **e2e-runner** | 端到端测试 | 关键流程验证、发布前 | 中 |
| **doc-updater** | 文档同步更新 | API 变更后、新功能发布 | 低 |

---

## 二、Agent 使用策略

### 2.1 主动触发原则

根据任务类型**自动选择 Agent**，不等待用户明确要求：

| 场景 | 自动启动 |
|------|---------|
| 用户请求复杂功能 / 重构 | **planner** agent |
| 需要技术选型或架构设计 | **architect** agent |
| 代码编写或修改完成 | **code-reviewer** agent |
| 涉及认证、权限、用户输入 | **security-reviewer** agent |
| 构建失败 | **build-error-resolver** agent |

**与 SDD 的衔接：**
- `/specify` → 可启动 **planner** 辅助拆解用户故事
- `/plan` → 可启动 **architect** 辅助技术方案设计
- 实现阶段完成 → 自动启动 **code-reviewer** + **security-reviewer**

### 2.2 并行执行原则

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

### 2.3 多视角分析

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

## 三、Hooks 系统

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

## 四、TodoWrite 任务管理

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

## 五、最佳实践总结

1. **主动编排**：检测到复杂任务时自动启动对应 Agent，不等用户要求
2. **并行优先**：独立任务一律并行执行，节省时间
3. **SDD 衔接**：Agent 选择与 SDD 三阶段对齐（规格→计划→任务→实现）
4. **Hooks 自动化**：通过 PostToolUse 实现格式化、lint 等重复操作的自动化
5. **TodoWrite 透明**：多步骤任务必须用 TodoWrite 跟踪，保持执行透明

---

## 相关规则

- **global-sdd-workflow.md** — 主工作流，Agent 编排为其实现层支撑
- **global-development-workflow.md** — 实现层工作流（Annotation Cycle、验证、Git）
- **global-tools-environment.md** — 工具配置（浏览器、网页抓取等）

---

## 变更历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0.0 | 2026-03-09 | 初始版本（领域层） |
| 2.0.0 | 2026-03-27 | 移至全局层；聚焦软件开发场景；移除 TDD 强制相关内容；精简测试用例；与 SDD 工作流对齐 |
