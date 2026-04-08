---
name: init-project
description: 智能初始化项目层的 `.claude` 目录，基于现有代码库、技术栈和目录结构生成合适的项目级 Claude 配置。只要用户提到 `init-project`、智能初始化项目、为仓库创建 `.claude` 配置、或希望基于项目结构自动生成规则，都应优先使用这个 skill。
---

# Init Project

为项目智能初始化 `.claude` 目录，生成**简洁、实用、符合项目实际情况**的配置。

---

## 核心理念

**项目配置的价值在于精准，而非全面。**

- 机械复制通用模板 = 无用配置
- 只创建项目真正需要的 = 有用配置
- 增量补充，按需演进

---

## 文档层级与分工

### CLAUDE.md（项目入口）

**作用**：Claude 每次进入项目时**自动读取**，是项目的"名片"。

**定位**：让 Claude 在 30 秒内理解项目全貌。

**内容原则（宁少勿多）**：
1. 项目一句话简介
2. 技术栈（关键 3~5 个）
3. 目录结构（只列核心）
4. 常用命令（5~8 条）
5. 指向 `.claude/rules/architecture.md` 的引用

**篇幅控制**：50~80 行以内。

**错误做法**：
- ❌ 把 architecture.md 的内容复制过来
- ❌ 详细罗列所有规范细节
- ❌ 写成项目 README

---

### architecture.md（规则索引）

**作用**：`.claude/rules/` 目录下的**索引文档**，是规则文件的目录页。

**定位**：详细但结构清晰的规则入口。

**内容原则**：
1. 项目作用域与技术栈
2. 规则文件索引（每项一句话说明）
3. 快速参考（命令速查）
4. 继承关系（上层规则优先级）
5. 注意事项（2~5 条）

**与 CLAUDE.md 的关系**：
```
CLAUDE.md（精简入口）
    ↓ 引用
architecture.md（规则索引）
    ↓ 索引
rules/ 下的具体规则文件
```

**篇幅控制**：100~200 行。

---

### memory/（项目记忆）

**作用**：存储会话间持久化的项目上下文，供下次会话快速恢复。

**内容**：
- 项目级记忆文件（架构决策、技术债、特殊约定）
- 按主题拆分的记忆文件（如 `memory/auth记忆.md`、`memory/api-patterns.md`）

**原则**：
- 与全局 memory（`~/.claude/projects/`）分工：全局存通用，项目存专有
- 容量大（可存更多上下文），不压缩

---

### rules/ 下的规则文件

**作用**：具体领域的规范定义，供详细查阅。

**原则**：按需创建，无需求不创建。

---

## 三步执行流程

### 步骤 1：分析项目

读取以下文件，判断项目特征：

| 必读 | 选读 |
|------|------|
| `package.json` | `tsconfig.json` |
| `vite.config.*` | `next.config.*` |
| `README.md` | `Makefile` |
| `.claude/` 现有文件 | `.github/workflows/` |

### 步骤 2：判断需求

根据项目特征，判断需要哪些规则：

| 项目特征 | 必要规则 | 可选规则 |
|----------|----------|----------|
| 有构建脚本 | `project-build-test.md` | - |
| 有 lint/format 配置 | `project-code-standards.md` | - |
| 使用内部组件库 | `project-components.md` | - |
| 有微前端 | - | 微前端注意事项 |
| 有 API 模块划分 | - | API 规范（如果模块多、调用模式统一） |
| 有特定工具链 | - | 工具使用说明 |

**经验法则**：
- 少于 5 个 API 模块 → 不单独创建 API 规范
- 少于 3 个业务组件 → 不创建组件规范
- 构建命令简单（`npm run build`）→ build-test 可合并到 architecture

### 步骤 3：生成配置

**必须创建**：
- `CLAUDE.md`（项目根目录）
- `.claude/rules/architecture.md`
- `.claude/rules/` 下 1~3 个必要规则
- `.claude/memory/`（项目记忆目录，存储会话间持久化的上下文）

**按需创建**：
- `.claude/agents/`（有自定义 agent 时）
- `.claude/plans/`（有进行中计划时）

**不自动创建**：
- `settings/`、`templates/`、`temp/`（除非明确需要）
- `skills/`（禁止）
- `agents/`、`plans/`（有需要时再创建）

---

## 必要规则文件模板

### project-build-test.md（构建与测试）

适用于：有 `package.json` scripts 的项目。

```markdown
# 构建和测试规则

## 开发命令
- `npm run dev` - 开发服务器
- `npm run build` - 生产构建

## 构建流程
- 类型检查 → Vite 构建

## 代码质量
- `npm run ts-check` - 类型检查
- `npm run lint` - ESLint
- `npm run fix` - 自动修复

## Git Hooks
- pre-commit: lint-staged 自动检查
```

### project-code-standards.md（代码规范）

适用于：有 TypeScript / Vue / React 的项目。

```markdown
# 代码规范

## TypeScript
- 避免 any，使用具体类型
- 接口 vs 类型的选择

## 组件规范
- 组件结构约定
- 命名规范

## API 调用
- 请求封装
- 错误处理
```

### project-components.md（组件库规范）

适用于：使用企业内部组件库的项目。

```markdown
# 组件库规范

## 组件分类
- 基础组件
- 表单组件
- 业务组件

## 常用模式
- 组件使用示例
- 样式变量
```

---

## 验证清单

初始化完成后，确认：

- [ ] `CLAUDE.md` 在项目根目录，内容 ≤ 80 行
- [ ] `CLAUDE.md` 能让人 30 秒了解项目
- [ ] `architecture.md` 索引了所有规则文件
- [ ] `.claude/rules/` 目录已创建
- [ ] `.claude/memory/` 目录已创建
- [ ] 只创建了项目真正需要的规则
- [ ] 没有创建空的/占位的规则文件
- [ ] 已有 `.claude` 配置被保留而非覆盖

---

## 常见问题

### CLAUDE.md 写成了 README

**问题**：把项目介绍、技术栈、安装方式都写进去。

**解决**：只写"项目是什么"和"关键入口"，详细规范在 rules/ 下。

### 创建了不需要的规则

**问题**：比如项目只有 2 个 API 文件，却创建了 API 规范。

**解决**：规则按需创建，无需求不创建。

### architecture.md 与 CLAUDE.md 内容重复

**问题**：把 architecture.md 的内容复制到 CLAUDE.md。

**解决**：CLAUDE.md 是入口（一句话），architecture.md 是索引（可详细）。

### 过度结构化

**问题**：创建了 `settings/`、`templates/`、`temp/` 但空着。

**解决**：按需创建，能少则少。

---

## 最佳实践

1. **先分析，后创建** - 不先入为主，根数项目特征
2. **入口精简，索引完整** - CLAUDE.md 轻量，architecture.md 完整
3. **按需创建规则** - 无需求不创建，不造空规则
4. **保留优于覆盖** - 已有配置先读，判断是否真的需要修改
5. **增量演进** - 先建最小集，后续按需补充
