# MCP 配置分层指南

> 规则 ID: DOMAIN-CONFIG-001
> 版本: 1.0.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-09
> 状态: 发布

## MCP 配置层级

根据四层配置架构，MCP 服务器配置也应分层管理。

---

## 各层 MCP 配置

### 1. 全局层 MCP

**位置**：`C:\Users\admin\.claude\settings\mcp.json`

**用途**：通用 MCP 服务器，所有项目共享

**推荐服务器**：
- **filesystem** - 文件系统操作
- **git** - Git 版本控制
- **brave-search** - 网络搜索
- **fetch** - HTTP 请求

**配置示例**：
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git"]
    }
  }
}
```

---

### 2. 领域层 MCP

**位置**：`D:\2Work\Claude\.claude\settings\mcp.json`

**用途**：软件工程领域特定的 MCP 服务器

**推荐服务器**：
- **github** - GitHub 集成
- **playwright** - 浏览器自动化
- **figma** - 设计工具集成
- **notebooklm** - 知识管理

**配置示例**：
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<your-token>"
      }
    }
  }
}
```

---

### 3. 应用层 MCP

**位置**：
- `D:\2Work\Claude\ts-projects\.claude\settings\mcp.json`
- `D:\2Work\Claude\personal-projects\.claude\settings\mcp.json`

**用途**：应用场景特定的 MCP 服务器

**企业开发 (ts-projects)**：
- 企业内部工具集成
- 项目管理工具（Jira、Confluence 等）
- CI/CD 工具集成

**个人开发 (personal-projects)**：
- 实验性 MCP 服务器
- 个人工具集成

---

### 4. 项目层 MCP

**位置**：`项目目录/.claude/settings/mcp.json`

**用途**：项目特定的 MCP 服务器

**示例场景**：
- 项目特定的 API 服务器
- 项目数据库连接
- 项目特定的外部服务

---

## 配置优先级

MCP 配置的合并规则：

```
全局层（基础）
    ↓ 合并
领域层（添加/覆盖）
    ↓ 合并
应用层（添加/覆盖）
    ↓ 合并
项目层（最终配置）
```

**注意**：
- 同名服务器会被下层覆盖
- 不同名服务器会合并
- 最终生效的是所有层级合并后的配置

---

## 配置最佳实践

### 1. 避免重复配置

- 通用服务器放在全局层
- 不要在多个层级重复配置相同服务器

### 2. 环境变量管理

- 敏感信息使用环境变量
- 不要在配置文件中硬编码 token

### 3. 禁用不需要的服务器

```json
{
  "mcpServers": {
    "some-server": {
      "disabled": true
    }
  }
}
```

### 4. 自动批准工具

```json
{
  "mcpServers": {
    "github": {
      "autoApprove": ["search_repositories", "get_file_contents"]
    }
  }
}
```

---

## 常用 MCP 服务器

### 开发工具

| 服务器 | 用途 | 推荐层级 |
|--------|------|---------|
| filesystem | 文件操作 | 全局层 |
| git | Git 操作 | 全局层 |
| github | GitHub 集成 | 领域层 |
| gitlab | GitLab 集成 | 领域层 |

### 浏览器和测试

| 服务器 | 用途 | 推荐层级 |
|--------|------|---------|
| playwright | 浏览器自动化 | 领域层 |
| puppeteer | 浏览器控制 | 领域层 |

### 设计和文档

| 服务器 | 用途 | 推荐层级 |
|--------|------|---------|
| figma | Figma 集成 | 领域层 |
| notebooklm | 知识管理 | 全局层 |

### 数据和 API

| 服务器 | 用途 | 推荐层级 |
|--------|------|---------|
| postgres | PostgreSQL | 项目层 |
| sqlite | SQLite | 项目层 |
| fetch | HTTP 请求 | 全局层 |

---

## 故障排查

### 检查 MCP 配置

1. 查看当前生效的配置
2. 检查服务器是否启动
3. 查看日志输出

### 常见问题

**问题 1**：MCP 服务器未启动
- 检查命令路径是否正确
- 检查依赖是否安装

**问题 2**：权限问题
- 检查 autoApprove 配置
- 手动批准工具调用

**问题 3**：配置冲突
- 检查多层级配置
- 确认优先级规则

---

## 常见配置错误

### 错误 1：在多个层级重复配置

**❌ 错误做法**：
```json
// 全局层 mcp.json
{
  "mcpServers": {
    "github": { "command": "npx", "args": [...] }
  }
}

// 领域层 mcp.json（重复配置）
{
  "mcpServers": {
    "github": { "command": "npx", "args": [...] }
  }
}
```

**✅ 正确做法**：
```json
// 全局层 mcp.json（只在一个层级配置）
{
  "mcpServers": {
    "github": { "command": "npx", "args": [...] }
  }
}

// 领域层 mcp.json（不重复）
{
  "mcpServers": {
    "playwright": { "command": "npx", "args": [...] }
  }
}
```

---

### 错误 2：硬编码敏感信息

**❌ 错误做法**：
```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxxxxxxxxxx"
      }
    }
  }
}
```

**✅ 正确做法**：
```json
// 使用环境变量
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

---

### 错误 3：项目特定服务器放在全局层

**❌ 错误做法**：
```json
// 全局层 mcp.json
{
  "mcpServers": {
    "project-api": {
      "command": "node",
      "args": ["./api-server.js"]
    }
  }
}
```

**✅ 正确做法**：
```json
// 项目层 .claude/settings/mcp.json
{
  "mcpServers": {
    "project-api": {
      "command": "node",
      "args": ["./api-server.js"]
    }
  }
}
```

---

## 快速参考

**查看 MCP 服务器状态**：
- 使用 MCP Server 视图
- 或使用命令面板搜索 "MCP"

**重新连接 MCP 服务器**：
- 修改配置后自动重连
- 或手动从 MCP Server 视图重连

**调试 MCP 问题**：
- 查看服务器日志
- 检查环境变量
- 验证命令可执行性
