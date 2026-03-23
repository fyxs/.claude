# Claude 配置架构说明

> 规则 ID: DOMAIN-ARCH-001
> 版本: 1.1.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-09
> 状态: 发布

## 规则文件索引

### 领域层规则
- `architecture.md` - 本文档，配置架构说明（包含工作区配置）
- `domain-project-initialization.md` - 项目初始化规则
- `domain-edge-browser-automation.md` - Edge 浏览器自动化
- `domain-mcp-configuration-guide.md` - MCP 配置分层指南

### 应用层规则
- `ts-projects/.claude/rules/common/app-enterprise-standards.md` - 企业开发规范
- `personal-projects/.claude/rules/common/app-personal-workflow.md` - 个人开发规范

---

## 四层配置架构

本工作区采用四层配置架构，从全局到项目逐级细化：

```
全局层 (C:\Users\admin\.claude)
    ↓ 继承
领域层 (D:\2Work\Claude\.claude)
    ↓ 继承
应用层 (ts-projects / personal-projects)
    ↓ 继承
项目层 (具体项目目录)
```

---

## 各层职责

### 1. 全局层 (`C:\Users\admin\.claude`)

**作用域**：所有领域和项目

**存放内容**：
- 跨领域的通用规则
- 全局 skills
- 基础工具配置
- 全局 MCP 服务器配置
- 全局记忆

**示例**：
- 基础沟通偏好
- 通用工具使用规则
- 跨领域的最佳实践

---

### 2. 领域层 (`D:\2Work\Claude\.claude`)

**作用域**：专业软件工程师领域

**存放内容**：
- 软件工程专业规则
- 开发工作流（TDD、代码审查、Git 工作流）
- Agent 编排策略
- 性能和安全规范
- Token 优化策略
- 领域特定工具配置

**示例**：
- TDD 强制规则
- 代码审查标准
- 安全检查清单
- 测试覆盖率要求

---

### 3. 应用层

**作用域**：特定工作场景

#### 3.1 企业开发 (`ts-projects`)

**特点**：
- 更严格的代码审查流程
- 强制的提交规范和 PR 模板
- 团队协作规范
- 完善的文档要求
- 企业级安全标准

**技术栈**：Vue 前端项目

#### 3.2 个人开发 (`personal-projects`)

**特点**：
- 灵活的实验性规则
- 快速迭代优先
- 可选的文档要求
- 允许更激进的技术尝试
- 个人风格优先

---

### 4. 项目层 (具体项目目录)

**作用域**：单个项目

**存放内容**：
- 项目特定的技术栈配置
- 项目级的构建、测试规则
- 项目文档和约定
- 项目特定的 MCP 配置

**示例**：
- `hlms-portal-front/.claude/` - 具体项目配置
- `isms-web/.claude/` - 具体项目配置

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

## 规则文件命名规范

使用前缀标识层级和类型：

| 前缀 | 层级 | 示例 |
|------|------|------|
| `global-` | 全局层 | `global-preferences.md` |
| `domain-` | 领域层 | `domain-development-workflow.md` |
| `app-enterprise-` | 应用层（企业） | `app-enterprise-standards.md` |
| `app-personal-` | 应用层（个人） | `app-personal-workflow.md` |
| `project-` | 项目层 | `project-build-config.md` |

**特殊规则文件**：
- `architecture.md` - 架构说明（领域层）
- `workspace.md` - 工作区配置（各层通用）

---

## MCP 配置分层

### 全局层 MCP
- 通用 MCP 服务器（filesystem、git 等）
- 跨领域工具

### 领域层 MCP
- 软件工程相关（GitHub、测试工具）
- 开发辅助工具

### 应用层 MCP
- 企业开发：内部工具集成
- 个人开发：实验性工具

### 项目层 MCP
- 项目特定的 API 或服务
- 项目依赖的外部服务

---

## 记忆系统分层

### 全局记忆
- 位置：`C:\Users\admin\.claude\memory/`
- 内容：跨领域的通用知识

### 领域记忆
- 位置：`D:\2Work\Claude\.claude\memory/`
- 内容：软件工程领域的知识沉淀

### 应用记忆
- 位置：`ts-projects/.claude/memory/` 或 `personal-projects/.claude/memory/`
- 内容：特定应用场景的经验

### 项目记忆
- 位置：`项目目录/.claude/memory/`
- 内容：项目特定的知识和决策

---

## 配置示例

### 示例 1：规则应该放在哪一层？

**场景**：创建 TDD 工作流规则

**❌ 错误**：放在项目层
```
my-project/.claude/rules/tdd-workflow.md
```
**原因**：TDD 是通用开发规范，不是项目特定的

**✅ 正确**：放在全局层或领域层
```
C:\Users\admin\.claude\rules\common\global-development-workflow.md
```

---

### 示例 2：MCP 服务器配置层级

**场景**：配置 GitHub MCP 服务器

**❌ 错误**：在每个项目都配置
```
project-a/.claude/settings/mcp.json
project-b/.claude/settings/mcp.json
project-c/.claude/settings/mcp.json
```

**✅ 正确**：在领域层配置一次
```
D:\2Work\Claude\.claude\settings\mcp.json
```

---

### 示例 3：项目特定配置

**场景**：项目使用特定的 API 端点

**❌ 错误**：放在全局层
```
C:\Users\admin\.claude\rules\project-api-config.md
```

**✅ 正确**：放在项目层
```
my-project/.claude/rules/project-api-config.md
```

---

## 最佳实践

1. **规则复用**：通用规则放在上层，避免重复
2. **职责清晰**：每层只定义自己职责范围内的规则
3. **适度覆盖**：只在必要时覆盖上层配置
4. **文档完善**：每层都应有清晰的说明文档
5. **定期审查**：定期检查规则的有效性和合理性

---

## 维护指南

### 添加新规则
1. 确定规则的作用域（全局/领域/应用/项目）
2. 选择合适的层级
3. 使用规范的文件命名
4. 更新相关文档

### 修改现有规则
1. 确认修改的影响范围
2. 考虑是否需要在多个层级同步修改
3. 更新变更日志

### 删除过时规则
1. 确认规则不再被使用
2. 检查是否有其他规则依赖
3. 归档而非直接删除（移至 archive/）

---

## 快速参考

### 当前工作区配置

**配置位置**：
- 全局：`C:\Users\admin\.claude/`
- 领域：`D:\2Work\Claude\.claude/`
- 企业开发：`D:\2Work\Claude\ts-projects\.claude/`
- 个人开发：`D:\2Work\Claude\personal-projects\.claude/`

**主工作目录**：`D:\2Work\Claude`

**目录结构**：
- `auto-js/` — 自动化脚本
- `documents/` — 文档资源
- `projects/` — 开发项目
- `resources/` — 参考资源 & 第三方仓库
- `tools/` — 工具和实用程序
- `configs/` — 配置文件集合

**文件归类规则**：
- 自动化脚本 → `auto-js/`
- 文档/指南/总结 → `documents/`
- 新开发项目 → `projects/`
- 第三方参考资源 → `resources/`
- 独立小工具 → `tools/`
- 配置模板 → `configs/`

### 沟通偏好

- **语言**：中文优先
- **风格**：简洁实用
- **代码注释**：中文

### 规则加载

所有层级的规则都会被加载，按优先级应用。
