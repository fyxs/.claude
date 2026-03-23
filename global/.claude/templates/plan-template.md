# 实现计划：[功能名称]

**分支**：`[###_分支name_任务或功能name]` | **日期**：[日期] | **规格说明**：[链接]
**输入**：来自 `/specs/[###_分支name_任务或功能name]/spec.md` 的功能规格说明

## 摘要

[从功能规格中提取：核心需求 + 研究得出的技术方案]

## 技术背景

<!--
  需要处理：将本节内容替换为项目的实际技术细节。
  以下结构仅供参考，指导迭代过程。
-->

**语言/版本**：[例如 Python 3.11、TypeScript 5.x，或 NEEDS CLARIFICATION]
**主要依赖**：[例如 FastAPI、Vue 3、Element Plus，或 NEEDS CLARIFICATION]
**存储**：[如适用，例如 PostgreSQL、Redis、文件系统，或 N/A]
**测试**：[例如 Vitest、pytest、Jest，或 NEEDS CLARIFICATION]
**目标平台**：[例如 Web 浏览器、Linux 服务器、iOS 15+，或 NEEDS CLARIFICATION]
**项目类型**：[例如 库/CLI/Web 服务/移动应用/桌面应用，或 NEEDS CLARIFICATION]
**性能目标**：[领域相关，例如 1000 req/s、60fps，或 NEEDS CLARIFICATION]
**约束条件**：[领域相关，例如 p95 < 200ms、内存 < 100MB，或 NEEDS CLARIFICATION]
**规模/范围**：[领域相关，例如 1 万用户、50 个页面，或 NEEDS CLARIFICATION]

## 宪法检查

*门控：必须在阶段 0 研究前通过。阶段 1 设计后重新检查。*

[根据宪法文件确定检查项]

## 项目结构

### 文档（本功能）

```text
specs/[###_分支name_任务或功能name]/
├── plan.md              # 本文件（/plan 命令输出）
├── research.md          # 阶段 0 输出（/plan 命令）
├── data-model.md        # 阶段 1 输出（/plan 命令）
├── quickstart.md        # 阶段 1 输出（/plan 命令）
├── contracts/           # 阶段 1 输出（/plan 命令）
└── tasks.md             # 阶段 2 输出（/tasks 命令——不由 /plan 创建）
```

### 源代码（仓库根目录）

<!--
  需要处理：将下方占位符目录树替换为本功能的实际布局。
  删除未使用的选项，用真实路径展开所选结构。
  最终计划中不应保留"选项"标签。
-->

```text
# [如不适用请删除] 选项 1：单项目（默认）
src/
├── components/
├── views/
├── services/
└── utils/

tests/
├── unit/
└── integration/

# [如不适用请删除] 选项 2：Web 应用（前端 + 后端）
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── views/
│   └── services/
└── tests/
```

**结构决策**：[说明所选结构，并引用上方实际目录]

## 复杂度追踪

> **仅在宪法检查存在需要说明的违规项时填写**

| 违规项 | 必要原因 | 拒绝更简方案的理由 |
|--------|---------|-----------------|
| [例如：第 4 个项目] | [当前需求] | [为何 3 个项目不够] |
| [例如：Repository 模式] | [具体问题] | [为何直接访问 DB 不够] |
