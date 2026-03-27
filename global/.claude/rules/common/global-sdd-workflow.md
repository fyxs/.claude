# SDD 工作流规则

> 规则 ID: GLOBAL-WORKFLOW-002
> 版本: 1.2.0
> 创建日期: 2026-03-20
> 最后更新: 2026-03-27
> 状态: 发布

> **主工作流**：SDD 是所有功能开发的首选工作流，优先级高于 global-development-workflow。
> 基于 github/spec-kit (78K+ stars) 方法论，适配本地 Claude Code 工作流。

## 核心理念

Spec-Driven Development (SDD) 将规格说明从代码的"仆人"变成代码的"主人"。

- **传统方式**：代码是真相，规格说明是辅助文档，最终被抛弃
- **SDD 方式**：规格说明是真相，代码是规格说明的输出产物

> "Maintaining software means evolving specifications. Debugging means fixing specifications."

维护软件 = 演进规格说明。调试 = 修复生成错误代码的规格说明。

---

## 触发条件

### 强制触发（前缀规则，最高优先级）

当用户消息以以下前缀开头时，必须执行对应的 SDD 阶段：

| 前缀 | 执行阶段 | 示例 |
|------|---------|------|
| `/specify` | 阶段 1：生成规格说明 | `/specify 实时聊天系统` |
| `/plan` | 阶段 2：生成实现计划 | `/plan WebSocket + PostgreSQL` |
| `/tasks` | 阶段 3：生成任务列表 | `/tasks` |
| `/checklist` | 生成检查清单 | `/checklist 部署前检查` |

### 推荐使用 SDD 的场景

- 新功能开发（预计超过 1 天工作量）
- 多人协作项目
- 需要 AI 长期维护的模块
- 用户说"写 spec"、"创建规格说明"、"需求文档"

### 不需要 SDD 的场景

- 快速修 bug（直接修复）
- 一次性脚本（直接实现）
- 探索性实验（直接尝试）

---

## 三阶段工作流

### 阶段 1：/specify [功能描述]

**目的**：将功能描述转化为结构化规格说明

**执行步骤**：
1. 扫描 `specs/` 目录，确定下一个功能编号（001, 002, 003...）
2. 确认分支名（如已知）和任务/功能名称
3. 创建 `specs/[###_分支name_任务或功能name]/` 目录结构（如不能确定分支，则为 `[###_任务或功能name]`）
4. 基于 `~/.claude/templates/spec-template.md` 生成 `spec.md`
5. 用 `[NEEDS CLARIFICATION: xxx]` 标记所有不明确的需求

**输出**：`specs/[###_分支name_任务或功能name]/spec.md`

**关键约束**：
- ✅ 只写 WHAT（用户需要什么）和 WHY（为什么需要）
- ❌ 不写 HOW（不涉及技术栈、API、代码结构）
- ✅ 所有不确定的地方必须用 `[NEEDS CLARIFICATION]` 标记，不猜测
- ✅ 每个用户故事必须可独立测试，可独立交付价值
- ✅ 用户故事按优先级排序（P1 最重要，P1 单独可构成 MVP）

---

### 阶段 2：/plan [技术提示（可选）]

**目的**：将规格说明转化为技术实现计划

**前提**：`specs/[###_分支name_任务或功能name]/spec.md` 必须存在

**执行步骤**：
1. 读取 `spec.md` 中的需求、用户故事、验收标准
2. 执行宪法合规检查（Phase -1 Gates，见下方）
3. 进行技术研究（库选型、性能、安全影响）
4. 生成技术架构和实现细节
5. 创建支撑文档

**输出**：
```
specs/[###_分支name_任务或功能name]/
├── plan.md          # 实现计划（基于 plan-template.md）
├── research.md      # 技术研究结果
├── data-model.md    # 数据模型
├── quickstart.md    # 关键验证场景
└── contracts/       # API 合约定义
```

**重要**：plan.md 保持高层次可读性。代码示例、详细算法等放入 `implementation-details/` 子文件。

---

### 阶段 3：/tasks

**目的**：将实现计划转化为可执行任务列表

**输入**：`plan.md`（必须）+ `data-model.md` + `contracts/` + `research.md`

**执行步骤**：
1. 读取所有设计文档
2. 将合约、实体、场景转化为具体任务
3. 标记可并行任务 `[P]`
4. 按用户故事分组（US1, US2, US3...）
5. 明确阶段依赖关系

**输出**：`specs/[###_分支name_任务或功能name]/tasks.md`

**任务格式**：`[ID] [P?] [Story] 描述（含具体文件路径）`

---

## 宪法原则（Phase -1 Gates）

执行 `/plan` 时，必须通过以下检查门控。
失败项必须在 `plan.md` 的 Complexity Tracking 部分记录原因。

### Article III：Test-First（建议）

- [ ] 是否规划了测试策略？
- [ ] 关键路径是否有验收标准可测试？
- [ ] 用户是否对测试范围有明确要求？

**视项目情况决定，不强制 TDD。**

### Article VII：Simplicity Gate

- [ ] 最多使用 3 个项目？
- [ ] 没有为未来需求过度设计（YAGNI）？
- [ ] 没有投机性功能（每个功能必须追溯到具体用户故事）？

### Article VIII：Anti-Abstraction Gate

- [ ] 直接使用框架，没有无意义封装？
- [ ] 单一模型表示，没有重复抽象？
- [ ] 没有"以防万一"的辅助类或工具函数？

### Article IX：Integration-First Gate

- [ ] API 合约已定义？
- [ ] 合约测试已规划？
- [ ] 优先使用真实环境（真实数据库 > Mock）？

---

## 目录结构规范

```
项目根目录/
└── specs/
    └── [###_分支name_任务或功能name]/   # 如不能确定分支，则为 [###_任务或功能name]
        ├── spec.md                  # /specify 输出
        ├── plan.md                  # /plan 输出
        ├── research.md              # /plan 输出
        ├── data-model.md            # /plan 输出
        ├── quickstart.md            # /plan 输出
        ├── contracts/               # /plan 输出（API 合约）
        │   ├── api.md
        │   └── events.md
        ├── implementation-details/  # 详细技术文档（可选）
        └── tasks.md                 # /tasks 输出
```

---

## 模板位置

| 模板 | 路径 |
|------|------|
| Spec 模板 | `~/.claude/templates/spec-template.md` |
| Plan 模板 | `~/.claude/templates/plan-template.md` |
| Tasks 模板 | `~/.claude/templates/tasks-template.md` |
| Constitution 模板 | `~/.claude/templates/constitution-template.md` |
| Checklist 模板 | `~/.claude/templates/checklist-template.md` |

---

## 与现有工作流集成

### 与 global-development-workflow 的衔接关系

SDD 是**规格层（主工作流）**，`global-development-workflow` 是**实现层（从工作流）**，串联使用：

```
SDD 规格层（主）
  /specify → spec.md（需求）
  /plan    → plan.md + research.md + contracts/（技术方案）
  /tasks   → tasks.md（任务列表）
       ↓ 用户确认后
global-development-workflow 实现层（从）
  Annotation Cycle → 实现 → 验证 → Git 提交
```

**覆盖关系：**
- SDD 已有 `research.md` → 实现层**跳过**研究阶段
- SDD 已有 `plan.md` → 实现层**跳过**计划阶段，直接进入 Annotation Cycle
- SDD 已有 `tasks.md` → 实现层直接以此作为任务输入
- **测试**：Article III 的 Test-First 条款已调整为建议性，不再强制（与 global-development-workflow 2.0 保持一致）

### 阶段暂停规则（MANDATORY）

**每个阶段生成关键文档后，必须停下来等待用户审查确认，不得自动进入下一阶段。**

```
/specify → 生成 spec.md → 停止，等待用户审查 ✋
    ↓ 用户确认后
/plan → 生成 plan.md 等文档 → 停止，等待用户审查 ✋
    ↓ 用户确认后
/tasks → 生成 tasks.md → 停止，等待用户审查 ✋
    ↓ 用户确认后
进入实现阶段
```

**违反此规则没有例外。** 除非用户明确说"继续执行下一阶段"或"全部自动完成"，否则每个阶段结束后必须暂停。

### 与 TodoWrite 集成

- `/specify` 完成后，用 TodoWrite 记录 `/plan` 和 `/tasks` 为待办
- `/tasks` 生成后，可将关键里程碑同步到 TodoWrite

### 与 plans/ 目录集成

- SDD 的 `specs/` 目录是项目层的规格说明
- 重大架构决策可同步到 `.claude/plans/`

### 与 Git 集成

- 每个 spec 对应一个 feature branch
- Spec 文档随代码一起版本控制
- 分支命名：`[###_分支name_任务或功能name]`（如 `003_feature-3.15.0_实时聊天系统`）

---

## 快速参考

```bash
# 完整 SDD 流程示例

/specify 实时聊天系统，支持消息历史和用户在线状态
# → 生成 specs/003_feature-chat_实时聊天系统/spec.md

/plan WebSocket 实时通信，PostgreSQL 存储历史，Redis 管理在线状态
# → 生成 plan.md, research.md, data-model.md, contracts/, quickstart.md

/tasks
# → 生成 tasks.md，可直接交给 AI Agent 执行
```

---

## 相关规则

- 依赖规则：`global-tools-environment.md`（工具配置）
- 相关规则：`architecture.md`（目录结构）
- 参考来源：[github/spec-kit](https://github.com/github/spec-kit)（MIT License）

---

## 变更历史

| 版本 | 日期 | 变更内容 | 原因 |
|------|------|---------|------|
| 1.0.0 | 2026-03-20 | 初始版本 | 集成 github/spec-kit SDD 方法论 |
| 1.1.0 | 2026-03-20 | 新增阶段暂停规则（MANDATORY） | 每阶段产出后必须等待用户审查确认，不得自动推进 |
| 1.2.0 | 2026-03-27 | 明确为主工作流；Article III 由强制改为建议；更新与 global-development-workflow 的覆盖关系 | TDD 不再强制，SDD 优先 |
