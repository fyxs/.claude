# 开发实施工作流

> 规则 ID: GLOBAL-WORKFLOW-001
> 版本: 2.0.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-27
> 状态: 发布

> **2.0.0 重大更新**：工作流以 SDD 为主（见 global-sdd-workflow.md）。
> 本文档聚焦实现层：研究复用、Annotation Cycle、验证、Git。
> TDD 降级为可选，不再强制。

---

## 整体流程

```
SDD 规格层（global-sdd-workflow.md）
  /specify → spec.md
  /plan    → plan.md + research.md + contracts/
  /tasks   → tasks.md
       ↓ 用户确认后进入实现层
实现层（本文档）
  研究复用 → Annotation Cycle → 实现 → 验证 → Git
```

**有 SDD 产物时**：直接从 tasks.md 开始实现，跳过研究和规划步骤。
**无 SDD 产物时**：按本文档完整流程执行。

---

## 一、研究与复用

> 仅在没有 SDD research.md 时执行

**优先级顺序：**

1. GitHub 代码搜索（`gh search repos` / `gh search code`）
2. 包注册表检查（npm、PyPI、crates.io 等）
3. Exa MCP 或 curl/Smart Web Fetch 研究

**研究产物持久化（MANDATORY）：**

- 结果写入 `research-<主题>.md`，不能只在聊天中口头总结
- 人审查后才能进入下一步
- SDD 中已有 `research.md` 时，直接复用，不重复研究

---

## 二、计划与 Annotation Cycle

> 仅在没有 SDD plan.md 时执行

**计划文件**：写入 `plan-<主题>.md`（SDD 已有 plan.md 时直接使用）

**Annotation Cycle：**

```
Claude 写 plan.md → 人审查并批注 → Claude 处理批注更新计划 → 满意？
                                                              ├─ 否 → 继续批注
                                                              └─ 是 → 进入实现
```

**MANDATORY**：计划未经人确认，不得开始写代码（"don't implement yet" 防护）

**标准化实现启动指令：**

```
全部实现。每完成一个任务，在 tasks.md 中标记为已完成。
不要在所有任务完成前停下来。不要添加不必要的注释。
不要使用 any 或 unknown 类型。持续运行类型检查。
```

---

## 三、测试（可选，视项目情况）

> TDD 不再强制。根据项目类型和团队规范决定是否采用。

**有测试需求时的建议顺序：**

1. 先写测试用例（定义预期行为）
2. 实现使测试通过
3. 重构优化

**测试类型**（按需选用）：
- 单元测试：隔离测试单个函数/组件
- 集成测试：测试 API 端点、数据库操作
- E2E 测试：测试关键用户流程

---

## 四、验证工作流

**触发条件**：功能完成后、PR 前、重构后。文档修改可跳过。

### 阶段 1：构建验证

```bash
npm run build 2>&1 | tail -20
```
失败 → 立即停止修复，不继续后续阶段。

### 阶段 2：类型检查

```bash
npx tsc --noEmit 2>&1 | head -30
```

### 阶段 3：代码检查

```bash
npm run lint 2>&1 | head -30
```

### 阶段 4：测试套件（有测试时执行）

```bash
npm run test -- --coverage 2>&1 | tail -50
```

### 阶段 5：安全扫描

```bash
# 检查硬编码密钥
grep -rn "sk-\|api_key\|password\|secret" --include="*.ts" --include="*.js" src/ 2>/dev/null | head -10
```
发现硬编码密钥 → 立即修复。

### 验证报告格式

```
验证报告
构建：    [通过/失败]
类型：    [通过/失败]
代码检查：[通过/失败]
测试：    [通过/失败]（有测试时）
安全：    [通过/失败]
总体：    [准备就绪/需要修复]
```

---

## 五、Git 工作流

### 提交消息格式

```
<type>: <description>

<optional body>
```

**类型：** `feat` / `fix` / `refactor` / `docs` / `test` / `chore` / `perf` / `ci`

**示例：**
```
feat: add user authentication

Implement JWT-based authentication with refresh tokens.
```

注意：Attribution 已通过 `~/.claude/settings.json` 全局禁用。

### PR 工作流

1. 分析完整提交历史（`git log` + `git diff [base]...HEAD`）
2. 起草 PR 标题（< 70 字）和描述
3. 推送并创建 PR

**PR 描述模板：**
```markdown
## 变更摘要
[简要描述]

## 主要变更
- 变更 1
- 变更 2

## 测试
- [ ] 已完成的测试项

## 待办事项
- [ ] 待办项
```

---

## 变更历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0.0 | 2026-03-09 | 初始版本 |
| 1.1.0 | 2026-03-10 | 新增研究产物持久化、Annotation Cycle、标准化实现指令 |
| 2.0.0 | 2026-03-27 | 以 SDD 为主工作流，TDD 降级为可选，大幅精简文档 |
