# .claude 配置说明

本目录包含 ISMS-Web 项目的 Claude 配置。

## 目录结构

```
.claude/
├── CLAUDE.md              # 项目入口文档
├── README.md              # 本文件
├── rules/                 # 规则文件
│   └── common/
│       └── project-config.md  # 项目配置
├── settings/              # 配置文件（MCP等）
├── memory/                # 项目记忆
└── plans/                 # 实施计划
```

## 配置继承

本项目配置继承关系：

```
全局层 (~/.claude)
    ↓
领域层 (D:\2Work\Claude\.claude)
    ↓
应用层 (D:\2Work\Claude\ts-projects\.claude)
    ↓
项目层 (本目录)
```

## 使用方式

在项目目录下使用 Claude Code 时，会自动加载所有层级的配置。

## 维护

- 项目特定规则：添加到 `rules/common/`
- 项目记忆：记录到 `memory/`
- 实施计划：保存到 `plans/`
