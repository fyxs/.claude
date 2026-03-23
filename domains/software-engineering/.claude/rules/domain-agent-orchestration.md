# Agent 编排与自动化

> 规则 ID: GLOBAL-AGENT-001
> 版本: 1.0.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-09
> 状态: 发布

> 本文档描述了如何有效使用 agents、hooks 和自动化工具来提高开发效率和代码质量。

## 目录

1. [可用 Agents](#可用-agents)
2. [Agent 使用策略](#agent-使用策略)
3. [Hooks 系统](#hooks-系统)
4. [TodoWrite 最佳实践](#todowrite-最佳实践)

---

## 可用 Agents

**位置：** `~/.claude/agents/`

### Agent 目录

| Agent | 用途 | 何时使用 | 优先级 |
|-------|------|---------|--------|
| **planner** | 实施规划 | 复杂功能、重构 | 高 |
| **architect** | 系统设计 | 架构决策 | 高 |
| **tdd-guide** | 测试驱动开发 | 新功能、bug 修复 | 必需 |
| **code-reviewer** | 代码审查 | 编写代码后 | 必需 |
| **security-reviewer** | 安全分析 | 提交前 | 必需 |
| **build-error-resolver** | 修复构建错误 | 构建失败时 | 中 |
| **e2e-runner** | E2E 测试 | 关键用户流程 | 中 |
| **refactor-cleaner** | 清理死代码 | 代码维护 | 低 |
| **doc-updater** | 文档更新 | 更新文档 | 低 |

---

### Agent 详细说明

#### 1. Planner Agent

**用途：** 创建详细的实施计划

**何时使用：**
- 实现复杂功能
- 大规模重构
- 多模块变更
- 不确定实施路径时

**输出：**
- PRD（产品需求文档）
- 架构设计
- 系统设计文档
- 技术文档
- 任务列表

**示例：**
```bash
# 使用 planner agent
claude-code --agent planner "实现用户认证系统"
```

---

#### 2. Architect Agent

**用途：** 系统设计和架构决策

**何时使用：**
- 选择技术栈
- 设计系统架构
- 评估架构权衡
- 制定扩展策略

**输出：**
- 架构图
- 技术选型建议
- 权衡分析
- 扩展策略

**示例：**
```bash
# 使用 architect agent
claude-code --agent architect "设计微服务架构"
```

---

#### 3. TDD-Guide Agent

**用途：** 强制执行测试驱动开发

**何时使用：**
- 实现新功能（必需）
- 修复 bug（必需）
- 重构代码
- 提高测试覆盖率

**工作流：**
1. 引导编写测试
2. 验证测试失败（RED）
3. 引导实现
4. 验证测试通过（GREEN）
5. 建议重构（IMPROVE）

**示例：**
```bash
# 使用 tdd-guide agent
claude-code --agent tdd-guide "添加用户登录功能"
```

---

#### 4. Code-Reviewer Agent

**用途：** 自动代码审查

**何时使用：**
- 编写代码后立即使用（必需）
- 提交前
- PR 创建前

**检查项：**
- 代码质量
- 安全漏洞
- 性能问题
- 最佳实践
- 代码风格
- 测试覆盖率

**问题优先级：**
- CRITICAL - 必须修复
- HIGH - 必须修复
- MEDIUM - 应该修复
- LOW - 可选修复

**示例：**
```bash
# 使用 code-reviewer agent
claude-code --agent code-reviewer "审查 src/auth/"
```

---

#### 5. Security-Reviewer Agent

**用途：** 安全漏洞分析

**何时使用：**
- 提交前（必需）
- 处理敏感数据时
- 实现认证/授权
- 处理用户输入

**检查项：**
- SQL 注入
- XSS 漏洞
- CSRF 保护
- 硬编码密钥
- 不安全的依赖
- 权限问题

**示例：**
```bash
# 使用 security-reviewer agent
claude-code --agent security-reviewer "检查安全问题"
```

---

#### 6. Build-Error-Resolver Agent

**用途：** 修复构建错误

**何时使用：**
- 构建失败
- 编译错误
- 依赖问题
- 配置错误

**工作流：**
1. 分析错误消息
2. 识别根本原因
3. 提供修复建议
4. 验证修复

**示例：**
```bash
# 使用 build-error-resolver agent
claude-code --agent build-error-resolver "修复构建错误"
```

---

#### 7. E2E-Runner Agent

**用途：** 运行端到端测试

**何时使用：**
- 测试关键用户流程
- 回归测试
- 发布前验证

**测试场景：**
- 用户注册/登录
- 购物车流程
- 支付流程
- 数据提交

**示例：**
```bash
# 使用 e2e-runner agent
claude-code --agent e2e-runner "运行登录流程测试"
```

---

#### 8. Refactor-Cleaner Agent

**用途：** 清理死代码和重构

**何时使用：**
- 代码维护
- 清理未使用的代码
- 简化复杂逻辑
- 提高代码质量

**清理项：**
- 未使用的导入
- 死代码
- 重复代码
- 过时的注释

**示例：**
```bash
# 使用 refactor-cleaner agent
claude-code --agent refactor-cleaner "清理 src/ 目录"
```

---

#### 9. Doc-Updater Agent

**用途：** 更新文档

**何时使用：**
- API 变更后
- 添加新功能后
- 重构后
- 发布前

**更新内容：**
- README
- API 文档
- 使用指南
- 变更日志

**示例：**
```bash
# 使用 doc-updater agent
claude-code --agent doc-updater "更新 API 文档"
```

---

## Agent 使用策略

### 立即使用 Agent（无需用户提示）

**自动触发场景：**

1. **复杂功能请求** → 使用 **planner** agent
   - 用户请求实现复杂功能
   - 立即启动 planner agent 创建计划

2. **代码刚编写/修改** → 使用 **code-reviewer** agent
   - 完成代码编写后
   - 立即启动 code-reviewer agent 审查

3. **Bug 修复或新功能** → 使用 **tdd-guide** agent
   - 用户报告 bug 或请求新功能
   - 立即启动 tdd-guide agent 强制 TDD

4. **架构决策** → 使用 **architect** agent
   - 需要做技术选型或架构设计
   - 立即启动 architect agent 提供建议

**主动使用原则：**
- 不要等待用户明确要求
- 根据任务类型自动选择合适的 agent
- 提高代码质量和开发效率

---

### 并行任务执行

**核心原则：** ALWAYS 对独立操作使用并行 Task 执行

**好的示例：并行执行**
```markdown
同时启动 3 个 agents：
1. Agent 1: 安全分析 auth 模块
2. Agent 2: 性能审查 cache 系统
3. Agent 3: 类型检查 utilities
```

**差的示例：不必要的顺序执行**
```markdown
先 agent 1，然后 agent 2，然后 agent 3
（当它们可以并行时）
```

**并行执行场景：**

| 场景 | Agents | 原因 |
|------|--------|------|
| 代码审查 | code-reviewer + security-reviewer | 独立检查 |
| 测试 | unit-test + integration-test + e2e-test | 独立测试套件 |
| 分析 | performance + security + quality | 独立分析维度 |
| 文档 | api-docs + readme + changelog | 独立文档 |

**实施步骤：**
1. 识别独立任务
2. 在单个消息中启动多个 Task 调用
3. 等待所有任务完成
4. 汇总结果

---

### 多视角分析

**用途：** 对复杂问题使用分角色子 agents

**角色类型：**

1. **事实审查者（Factual Reviewer）**
   - 验证事实准确性
   - 检查数据正确性
   - 确认技术细节

2. **高级工程师（Senior Engineer）**
   - 评估架构决策
   - 审查代码质量
   - 提供最佳实践建议

3. **安全专家（Security Expert）**
   - 识别安全漏洞
   - 评估风险
   - 提供安全建议

4. **一致性审查者（Consistency Reviewer）**
   - 检查代码风格一致性
   - 验证命名约定
   - 确保模式一致

5. **冗余检查者（Redundancy Checker）**
   - 识别重复代码
   - 发现可复用的模式
   - 建议抽象

**使用场景：**
- 复杂架构决策
- 大规模重构
- 安全关键功能
- 性能优化

**工作流：**
```markdown
1. 定义问题
2. 启动多个角色 agents（并行）
3. 收集各角色的分析
4. 综合所有视角
5. 做出明智决策
```

**示例：**
```bash
# 多视角分析认证系统
claude-code --agents "security-expert,senior-engineer,consistency-reviewer" \
  "分析认证系统设计"
```

---

## Hooks 系统

### Hook 类型

#### 1. PreToolUse Hook

**触发时机：** 工具执行前

**用途：**
- 验证参数
- 修改参数
- 阻止执行
- 记录日志

**示例：**
```javascript
// 验证文件路径
function preToolUse(tool, params) {
  if (tool === 'Write' && params.file_path.includes('node_modules')) {
    throw new Error('不允许修改 node_modules');
  }
  return params;
}
```

---

#### 2. PostToolUse Hook

**触发时机：** 工具执行后

**用途：**
- 自动格式化
- 运行检查
- 更新缓存
- 触发后续操作

**示例：**
```javascript
// 自动格式化代码
function postToolUse(tool, result) {
  if (tool === 'Write' && result.file_path.endsWith('.js')) {
    exec(`prettier --write ${result.file_path}`);
  }
  return result;
}
```

---

#### 3. Stop Hook

**触发时机：** 会话结束时

**用途：**
- 最终验证
- 清理资源
- 生成报告
- 提交代码

**示例：**
```javascript
// 会话结束时运行测试
function onStop() {
  exec('npm test');
  exec('npm run lint');
  console.log('会话结束，测试已运行');
}
```

---

### Auto-Accept Permissions（自动接受权限）

**谨慎使用：**

**何时启用：**
- ✅ 受信任的、定义明确的计划
- ✅ 重复性任务
- ✅ 已验证的工作流

**何时禁用：**
- ❌ 探索性工作
- ❌ 不熟悉的代码库
- ❌ 高风险操作

**配置：**
```json
// ~/.claude.json
{
  "allowedTools": [
    "Read",
    "Grep",
    "Glob"
  ],
  "autoAccept": true
}
```

**安全原则：**
- 永远不要使用 `dangerously-skip-permissions` 标志
- 在 `~/.claude.json` 中配置 `allowedTools`
- 定期审查自动接受的权限
- 对破坏性操作保持手动确认

---

## TodoWrite 最佳实践

### 使用 TodoWrite 工具

**用途：**

1. **跟踪多步骤任务的进度**
   - 将大任务分解为小步骤
   - 实时更新状态
   - 提供进度可见性

2. **验证对指令的理解**
   - 列出计划的步骤
   - 让用户确认理解正确
   - 避免误解

3. **启用实时引导**
   - 用户可以看到当前步骤
   - 可以在执行前纠正方向
   - 提供反馈机会

4. **显示细粒度实施步骤**
   - 展示详细的执行计划
   - 提高透明度
   - 建立信任

---

### Todo List 揭示的问题

**Todo list 可以揭示：**

1. **步骤顺序错误**
   ```markdown
   ❌ 错误顺序：
   1. 运行测试
   2. 编写代码
   3. 编写测试

   ✅ 正确顺序：
   1. 编写测试
   2. 编写代码
   3. 运行测试
   ```

2. **缺失项目**
   ```markdown
   ❌ 缺失步骤：
   1. 编写代码
   2. 提交代码

   ✅ 完整步骤：
   1. 编写测试
   2. 编写代码
   3. 运行测试
   4. 代码审查
   5. 提交代码
   ```

3. **额外的不必要项目**
   ```markdown
   ❌ 不必要的步骤：
   1. 编写代码
   2. 重写整个模块
   3. 重构所有相关文件

   ✅ 必要步骤：
   1. 编写代码
   2. 运行测试
   ```

4. **错误的粒度**
   ```markdown
   ❌ 粒度太粗：
   1. 实现功能

   ✅ 适当粒度：
   1. 编写测试
   2. 实现核心逻辑
   3. 添加错误处理
   4. 运行测试
   5. 代码审查
   ```

5. **误解需求**
   ```markdown
   ❌ 误解：
   1. 添加用户删除功能
   2. 删除所有用户数据

   ✅ 正确理解：
   1. 添加单个用户删除功能
   2. 软删除（标记为已删除）
   3. 保留审计日志
   ```

---

### TodoWrite 工作流

**最佳实践：**

1. **任务开始时创建 todo list**
   ```markdown
   收到任务 → 立即创建 todo list → 开始执行
   ```

2. **实时更新状态**
   ```markdown
   - pending → in_progress → completed
   - 一次只有一个任务 in_progress
   ```

3. **完成后立即标记**
   ```markdown
   完成任务 → 立即标记为 completed → 开始下一个
   ```

4. **发现新任务时添加**
   ```markdown
   发现额外工作 → 添加到 todo list → 继续执行
   ```

5. **任务不再相关时移除**
   ```markdown
   任务过时 → 从 todo list 移除 → 更新计划
   ```

---

## 最佳实践总结

### Agent 使用
1. **主动使用** - 不要等待用户明确要求
2. **并行执行** - 对独立任务使用并行 agents
3. **多视角分析** - 对复杂问题使用多角色 agents
4. **选择合适的 agent** - 根据任务类型选择

### Hooks 配置
1. **PreToolUse** - 验证和修改参数
2. **PostToolUse** - 自动格式化和检查
3. **Stop** - 最终验证和清理
4. **谨慎使用自动接受** - 仅对受信任的操作

### TodoWrite 管理
1. **任务开始时创建** - 提供清晰的路线图
2. **实时更新** - 保持状态同步
3. **细粒度步骤** - 提高透明度
4. **揭示问题** - 及早发现误解

**记住：** Agent 编排和自动化是提高开发效率的关键。合理使用这些工具可以显著提升代码质量和开发速度。

---

## 相关规则

### 依赖规则
- 无（本规则定义 Agent 使用策略，被其他规则依赖）

### 冲突规则
- 无直接冲突

### 优先级说明
- **主动使用原则**：检测到适用场景时自动触发，无需等待用户明确要求
- **并行执行优先**：独立任务必须并行执行，不可顺序执行
- **TodoWrite 强制使用**：多步骤任务必须使用 TodoWrite 跟踪

### 被依赖规则
- **global-development-workflow.md** - 开发工作流（使用 planner、tdd-guide、code-reviewer）
- **domain-comprehensive-replacement-workflow.md** - 全面替换工作流（使用 TodoWrite）

---

## 测试用例

### 测试用例 1：复杂功能自动触发 planner agent（正常场景）

**规则**：Agent 使用策略 - 立即使用 Agent

**输入**：
- 用户消息：`实现用户认证系统`
- 对话上下文：新项目，需要从零开始设计认证系统

**期望行为**：
1. **自动识别复杂功能**
   - 识别"实现用户认证系统"是复杂功能
   - 不需要用户明确要求使用 planner agent
2. **自动启动 planner agent**
   - 立即启动 planner agent
   - 简短说明正在创建实施计划
3. **生成完整计划**
   - PRD（产品需求文档）
   - 架构设计
   - 系统设计文档
   - 技术文档
   - 任务列表
4. **后续自动触发其他 agents**
   - 实现阶段自动启动 tdd-guide agent
   - 代码完成后自动启动 code-reviewer agent
   - 提交前自动启动 security-reviewer agent

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ✅ / ❌ 自动识别为复杂功能（无需用户明确要求）
- ✅ / ❌ 自动启动了 planner agent
- ✅ / ❌ 生成了完整的规划文档
- ✅ / ❌ 后续阶段自动触发了相应的 agents

---

### 测试用例 2：并行执行多个独立 agents（边界场景）

**规则**：Agent 使用策略 - 并行任务执行

**输入**：
- 用户消息：`审查 auth 模块的代码质量、安全性和性能`
- 对话上下文：auth 模块代码已完成，需要全面审查

**期望行为**：
1. **识别独立任务**
   - 代码质量审查（code-reviewer）
   - 安全性审查（security-reviewer）
   - 性能审查（performance-analyzer）
   - 三个任务相互独立
2. **并行启动 agents**
   - 在单个消息中启动 3 个 agents
   - 不是顺序执行（先 agent 1，再 agent 2，再 agent 3）
3. **等待所有任务完成**
   - 同时等待 3 个 agents 的结果
   - 不阻塞其他操作
4. **汇总结果**
   - 收集所有 agents 的分析结果
   - 综合报告问题和建议
   - 按优先级排序（CRITICAL > HIGH > MEDIUM > LOW）

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ✅ / ❌ 识别了 3 个独立任务
- ✅ / ❌ 并行启动了 3 个 agents（不是顺序执行）
- ✅ / ❌ 同时等待所有任务完成
- ✅ / ❌ 汇总了所有结果并按优先级排序

---

### 测试用例 3：TodoWrite 揭示步骤顺序错误（异常场景）

**规则**：TodoWrite 最佳实践 - Todo List 揭示的问题

**输入**：
- 用户消息：`实现购物车功能`
- 对话上下文：用户请求新功能

**期望行为**：
1. **创建 todo list**
   - 使用 TodoWrite 工具创建任务列表
   - 列出实施步骤
2. **识别步骤顺序错误**
   - 假设初始 todo list 顺序错误：
     1. 运行测试
     2. 编写代码
     3. 编写测试
   - 识别这是错误的顺序（违反 TDD）
3. **纠正步骤顺序**
   - 正确顺序应该是：
     1. 编写测试（RED）
     2. 编写代码（GREEN）
     3. 运行测试（VERIFY）
     4. 代码审查
     5. 提交代码
4. **更新 todo list**
   - 使用 TodoWrite 更新为正确的顺序
   - 开始执行正确的工作流

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ✅ / ❌ 创建了 todo list
- ✅ / ❌ 识别了步骤顺序错误
- ✅ / ❌ 纠正为正确的 TDD 顺序
- ✅ / ❌ 更新了 todo list
- ✅ / ❌ 按正确顺序执行任务
