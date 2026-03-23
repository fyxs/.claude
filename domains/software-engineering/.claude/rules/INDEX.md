# 规则索引

> 规则 ID: DOMAIN-INDEX-001
> 版本: 1.1.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-10
> 状态: 发布
> 总规则数：16 个（Edge 浏览器自动化规则已移至全局层；domain-development-workflow.md 已提升至全局层；新增 global-sdd-workflow.md）

## 目录

1. [按层级分类](#按层级分类)
2. [按主题分类](#按主题分类)
3. [规则依赖关系](#规则依赖关系)
4. [规则统计](#规则统计)

---

## 按层级分类

### 全局层 (C:\Users\admin\.claude\rules)

**common/ 目录**：

| 规则文件 | 主题 | 大小 | 状态 |
|---------|------|------|------|
| [meta-rule-creation-guide.md](C:\Users\admin\.claude\rules\common\meta-rule-creation-guide.md) | 元规则：规则创建指南 | 9.9K | ✅ 可缓存 |
| [global-notebooklm-usage.md](C:\Users\admin\.claude\rules\common\global-notebooklm-usage.md) | NotebookLM 使用规则 | 11K | ✅ 可缓存 |
| [global-token-optimization.md](C:\Users\admin\.claude\rules\common\global-token-optimization.md) | Token 与性能优化策略（已合并 PERF-002） | 14K | ✅ 可缓存 |
| [global-tools-environment.md](C:\Users\admin\.claude\rules\common\global-tools-environment.md) | 工具与环境配置 | 4.9K | ✅ 可缓存 |
| [global-development-workflow.md](C:\Users\admin\.claude\rules\common\global-development-workflow.md) | 开发工作流与验证（原 domain-development-workflow.md，已提升至全局层） | 9.8K | ✅ 可缓存 |
| [global-sdd-workflow.md](C:\Users\admin\.claude\rules\common\global-sdd-workflow.md) | Spec-Driven Development 工作流（GLOBAL-WORKFLOW-002） | ~6K | ✅ 可缓存 |

**总计**：7 个规则文件，~69.6K

---

### 领域层 (D:\2Work\Claude\.claude\rules)

**根目录**：

| 规则文件 | 主题 | 大小 | 状态 |
|---------|------|------|------|
| [architecture.md](D:\2Work\Claude\.claude\rules\architecture.md) | Claude 配置架构说明 | 6.0K | ✅ 可缓存 |

**common/ 目录**：

| 规则文件 | 主题 | 大小 | 状态 |
|---------|------|------|------|
| [workspace.md](D:\2Work\Claude\.claude\rules\common\workspace.md) | 工作区持久化指令 | 690 bytes | ❌ 太小 |

**domain-* 文件**：

| 规则文件 | 主题 | 大小 | 状态 |
|---------|------|------|------|
| [domain-agent-orchestration.md](D:\2Work\Claude\.claude\rules\domain-agent-orchestration.md) | Agent 编排与自动化 | 13K | ✅ 可缓存 |
| [domain-code-analysis-best-practices.md](D:\2Work\Claude\.claude\rules\domain-code-analysis-best-practices.md) | 代码分析最佳实践 | 5.8K | ✅ 可缓存 |
| [domain-comprehensive-replacement-workflow.md](D:\2Work\Claude\.claude\rules\domain-comprehensive-replacement-workflow.md) | 全面替换工作流规则 | 5.3K | ✅ 可缓存 |
| [domain-development-workflow.md](D:\2Work\Claude\.claude\rules\domain-development-workflow.md) | 开发工作流与验证 ⚠️ 已提升至全局层，此文件可删除 | 9.8K | ✅ 可缓存 |
| [domain-mcp-configuration-guide.md](D:\2Work\Claude\.claude\rules\domain-mcp-configuration-guide.md) | MCP 配置分层指南 | 4.5K | ✅ 可缓存 |
| [domain-project-initialization.md](D:\2Work\Claude\.claude\rules\domain-project-initialization.md) | 项目初始化规则 | 1.9K | ⚠️ 接近阈值 |
| [domain-standards-security.md](D:\2Work\Claude\.claude\rules\domain-standards-security.md) | 代码标准与安全 | 5.5K | ✅ 可缓存 |

**总计**：9 个规则文件，45.8K

---

## 按主题分类

### 工作流规则

| 规则 | 层级 | 文件 |
|------|------|------|
| SDD 工作流（规格层） | 全局 | global-sdd-workflow.md |
| 开发工作流与验证（实现层） | 全局 | global-development-workflow.md |
| 全面替换工作流 | 领域 | domain-comprehensive-replacement-workflow.md |

### 工具使用规则

| 规则 | 层级 | 文件 |
|------|------|------|
| NotebookLM 使用 | 全局 | global-notebooklm-usage.md |
| 工具与环境配置 | 全局 | global-tools-environment.md |
| Edge 浏览器自动化 | 全局 | global-edge-browser-automation.md |

### Agent 编排规则

| 规则 | 层级 | 文件 |
|------|------|------|
| Agent 编排与自动化 | 领域 | domain-agent-orchestration.md |

### 标准与质量规则

| 规则 | 层级 | 文件 |
|------|------|------|
| 代码标准与安全 | 领域 | domain-standards-security.md |
| 代码分析最佳实践 | 领域 | domain-code-analysis-best-practices.md |

### 性能优化规则

| 规则 | 层级 | 文件 |
|------|------|------|
| Token 与性能优化策略 | 全局 | global-token-optimization.md |

### 配置管理规则

| 规则 | 层级 | 文件 |
|------|------|------|
| Claude 配置架构说明 | 领域 | architecture.md |
| MCP 配置分层指南 | 领域 | domain-mcp-configuration-guide.md |
| 工作区持久化指令 | 领域 | workspace.md |
| 项目初始化规则 | 领域 | domain-project-initialization.md |

### 元规则

| 规则 | 层级 | 文件 |
|------|------|------|
| 规则创建指南 | 全局 | meta-rule-creation-guide.md |

---

## 规则依赖关系

### 核心依赖链

```
meta-rule-creation-guide.md (元规则)
    ↓ 指导创建
所有其他规则文件
```

### 工作流依赖

```
global-development-workflow.md (开发工作流)
    ↓ 依赖
global-agent-orchestration.md (Agent 编排)
    ↓ 依赖
global-standards-performance-security.md (代码标准)
```

### 工具使用依赖

```
global-tools-environment.md (工具配置)
    ↓ 依赖
global-notebooklm-usage.md (NotebookLM)
global-edge-browser-automation.md (Edge 自动化)
```

### 配置架构依赖

```
architecture.md (架构说明)
    ↓ 指导
domain-mcp-configuration-guide.md (MCP 配置)
workspace.md (工作区配置)
domain-project-initialization.md (项目初始化)
```

---

## 规则统计

### 按层级统计

| 层级 | 规则数 | 总大小 | 平均大小 |
|------|--------|--------|---------|
| 全局层 | 5 | 53.8K | 10.8K |
| 领域层 | 9 | 45.8K | 5.1K |
| **总计** | **14** | **99.6K** | **7.1K** |

### 按缓存状态统计

| 状态 | 数量 | 占比 |
|------|------|------|
| ✅ 可缓存 (≥ 1024 tokens) | 12 | 86% |
| ⚠️ 接近阈值 (1024-1500 tokens) | 1 | 7% |
| ❌ 太小 (< 1024 tokens) | 1 | 7% |

### 按主题统计

| 主题 | 数量 |
|------|------|
| 工作流规则 | 2 |
| 工具使用规则 | 3 |
| Agent 编排规则 | 1 |
| 标准与质量规则 | 2 |
| 性能优化规则 | 1 |
| 配置管理规则 | 4 |
| 元规则 | 1 |

### 质量状态

| 指标 | 状态 |
|------|------|
| 包含元数据 | 15/15 (100%) |
| 包含测试用例 | 6/15 (40%) |
| 命名符合规范 | 13/15 (87%) |

---

## 待改进项

### 高优先级

1. **测试用例覆盖** - 9 个规则仍缺少测试用例（当前 6/15，40%）

### 中优先级

1. **示例完善** - 已为 2 个规则添加错误示例（domain-mcp-configuration-guide.md, architecture.md）
2. **规则关系** - 已为 3 个核心规则添加关系说明（global-notebooklm-usage.md, global-development-workflow.md, global-agent-orchestration.md）

### 低优先级

无

---

## 使用指南

### 查找规则

1. **按层级查找** - 根据作用域选择全局层或领域层
2. **按主题查找** - 根据需求类型选择对应主题
3. **按依赖查找** - 查看规则依赖关系图

### 添加新规则

1. 确定规则层级（全局/领域/应用/项目）
2. 选择合适的主题分类
3. 遵循 meta-rule-creation-guide.md 创建
4. 更新本索引文件

### 修改现有规则

1. 查看规则依赖关系
2. 评估影响范围
3. 更新变更历史
4. 更新本索引文件

---

**维护说明**：
- 本索引文件应在每次规则变更后更新
- 定期审查规则质量状态
- 及时处理待改进项
