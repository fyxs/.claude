# Claude 配置集中备份系统使用说明

> 版本: 1.0.0
> 创建日期: 2026-03-23
> 备份目录: D:\10Backups\Claude-Config

---

## 概述

本备份系统用于集中管理 Claude 四层配置架构的备份，采用 **manifest 驱动 + 单向同步** 的策略，确保配置安全可恢复。

### 核心特性

- 📋 **Manifest 驱动**：通过 sources.json 统一管理备份配置
- 🔄 **单向同步**：源 → 备份，避免双向同步的复杂性
- 🎯 **智能排除**：自动排除缓存、临时文件等运行态数据
- 🔍 **变更检测**：记录并报告新增/删除/修改的文件
- ⚡ **增量备份**：只复制修改过的文件，节省时间
- 📊 **详细日志**：彩色输出，清晰展示备份进度和结果

---

## 架构说明

### 四层配置架构

```
全局层 (C:\Users\admin\.claude)
    ↓ 继承
领域层 (D:\2Work\Claude\.claude)
    ↓ 继承
应用层 (应用场景/.claude)
    ↓ 继承
项目层 (具体项目/.claude)
```

### 当前备份范围

**全局层**：
- `.claude` 目录（排除 14 项运行态数据）
- 辅助资产：`.mcp.json`、`.claude.json`

**软件工程领域层**：
- `.claude` 目录（排除 skills 软链接、cache、context、metrics）
- 辅助资产：`CLAUDE.md`、`auto-js`、`configs`、`edge-cli.bat`、`package.json`

---

## 快速开始

### 1. 基础备份

```powershell
cd C:\Users\admin\.claude\plans
.\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config"
```

### 2. 启用变更检测

```powershell
.\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config" -DetectChanges
```

### 3. 增量备份（推荐日常使用）

```powershell
.\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config" -IncrementalBackup
```

### 4. 完整功能（推荐）

```powershell
.\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config" -DetectChanges -IncrementalBackup
```

---

## 备份目录结构

```
D:\10Backups\Claude-Config/
├── global\.claude/                      # 全局层 .claude 目录
│   ├── rules/                           # 规则文件
│   ├── memory/                          # 记忆文件
│   ├── plans/                           # 计划文档
│   ├── templates/                       # 模板文件
│   ├── skills/                          # 技能文件
│   ├── settings.json                    # 全局设置
│   ├── settings.local.json              # 本地设置
│   ├── config.json                      # 配置文件
│   ├── project-config.json              # 项目配置
│   ├── mcp.json                         # MCP 配置
│   └── architecture.md                  # 架构说明
│
├── global-aux\.mcp.json                 # 全局层辅助资产
├── global-aux\.claude.json              # Claude 客户端状态
│
├── domains\software-engineering\.claude/  # 领域层 .claude 目录
│   ├── rules/                           # 领域规则
│   ├── memory/                          # 领域记忆
│   ├── templates/                       # 领域模板
│   ├── settings.json                    # 领域设置
│   └── settings.local.json              # 领域本地设置
│
└── domains\software-engineering-aux\    # 领域层辅助资产
    ├── CLAUDE.md                        # 工作区说明
    ├── auto-js/                         # 自动化脚本
    ├── configs/                         # 配置模板
    ├── edge-cli.bat                     # Edge CLI 启动脚本
    └── package.json                     # Node.js 依赖配置
```

---

## 配置维护

### 添加新的辅助资产

编辑 `C:\Users\admin\.claude\plans\sources.json`，在对应层的 `auxiliaryAssets` 数组中添加：

```json
{
  "source": "D:\\2Work\\Claude\\new-script.ps1",
  "target": "domains\\software-engineering-aux\\new-script.ps1",
  "notes": "新脚本说明"
}
```

### 添加新的排除项

编辑 `sources.json`，在对应层的 `exclude` 数组中添加：

```json
"exclude": [
  "cache",
  "new-temp-dir",
  "logs"
]
```

### 添加新的领域层

编辑 `sources.json`，在 `layers.domains` 对象中添加：

```json
"data-science": {
  "claudeDirBackup": {
    "source": "E:\\DataScience\\.claude",
    "target": "domains\\data-science\\.claude",
    "mode": "exclude",
    "exclude": ["skills", "cache", "context", "metrics"],
    "notes": "数据科学领域层配置"
  },
  "auxiliaryAssets": [
    {
      "source": "E:\\DataScience\\README.md",
      "target": "domains\\data-science-aux\\README.md",
      "notes": "领域说明文档"
    }
  ]
}
```

---

## Git 版本控制

### 初始化 Git 仓库

```powershell
cd D:\10Backups\Claude-Config
git init
git add .
git commit -m "Initial backup: Claude configuration"
```

### 创建 .gitignore

```powershell
# 在备份目录创建 .gitignore
@"
# 变更检测清单（不需要版本控制）
.backup-manifest.json

# 临时文件
*.tmp
*.log
"@ | Out-File -FilePath "D:\10Backups\Claude-Config\.gitignore" -Encoding UTF8
```

### 添加远程仓库（可选）

```powershell
# 添加私有远程仓库
git remote add origin <your-private-repo-url>
git branch -M main
git push -u origin main
```

### 定期提交

每次备份后提交到 Git：

```powershell
cd D:\10Backups\Claude-Config
git add .
git commit -m "Backup $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
```

### 推送到远程（可选）

```powershell
git push origin main
```

---

## 自动化建议

### 方案 1：Windows 任务计划程序

1. 打开"任务计划程序"（taskschd.msc）
2. 创建基本任务
3. 配置触发器：
   - 每天
   - 时间：凌晨 2:00（或其他空闲时间）
4. 配置操作：
   - 程序：`powershell.exe`
   - 参数：`-File "C:\Users\admin\.claude\plans\sync-backup.ps1" -BackupRoot "D:\10Backups\Claude-Config" -DetectChanges -IncrementalBackup`
   - 起始位置：`C:\Users\admin\.claude\plans`

### 方案 2：创建快捷方式

创建桌面快捷方式，方便手动备份：

1. 右键桌面 → 新建 → 快捷方式
2. 位置：
   ```
   powershell.exe -NoExit -Command "cd 'C:\Users\admin\.claude\plans'; .\sync-backup.ps1 -BackupRoot 'D:\10Backups\Claude-Config' -DetectChanges"
   ```
3. 名称：`Claude 配置备份`

### 方案 3：创建批处理脚本

创建 `backup-claude.bat`：

```batch
@echo off
cd /d C:\Users\admin\.claude\plans
powershell.exe -ExecutionPolicy Bypass -File ".\sync-backup.ps1" -BackupRoot "D:\10Backups\Claude-Config" -DetectChanges -IncrementalBackup
pause
```

---

## 恢复指南

### 恢复全局层

```powershell
# 1. 备份当前配置（以防万一）
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Move-Item "C:\Users\admin\.claude" "C:\Users\admin\.claude.backup-$timestamp"

# 2. 恢复 .claude 目录
Copy-Item "D:\10Backups\Claude-Config\global\.claude" "C:\Users\admin\.claude" -Recurse -Force

# 3. 恢复辅助资产
Copy-Item "D:\10Backups\Claude-Config\global-aux\.mcp.json" "C:\Users\admin\.mcp.json" -Force
Copy-Item "D:\10Backups\Claude-Config\global-aux\.claude.json" "C:\Users\admin\.claude.json" -Force

Write-Host "✅ 全局层恢复完成" -ForegroundColor Green
```

### 恢复领域层

```powershell
# 1. 备份当前配置
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Move-Item "D:\2Work\Claude\.claude" "D:\2Work\Claude\.claude.backup-$timestamp"

# 2. 恢复 .claude 目录
Copy-Item "D:\10Backups\Claude-Config\domains\software-engineering\.claude" "D:\2Work\Claude\.claude" -Recurse -Force

# 3. 恢复辅助资产
Copy-Item "D:\10Backups\Claude-Config\domains\software-engineering-aux\CLAUDE.md" "D:\2Work\Claude\CLAUDE.md" -Force
Copy-Item "D:\10Backups\Claude-Config\domains\software-engineering-aux\auto-js" "D:\2Work\Claude\auto-js" -Recurse -Force
Copy-Item "D:\10Backups\Claude-Config\domains\software-engineering-aux\configs" "D:\2Work\Claude\configs" -Recurse -Force
Copy-Item "D:\10Backups\Claude-Config\domains\software-engineering-aux\edge-cli.bat" "D:\2Work\Claude\edge-cli.bat" -Force
Copy-Item "D:\10Backups\Claude-Config\domains\software-engineering-aux\package.json" "D:\2Work\Claude\package.json" -Force

Write-Host "✅ 领域层恢复完成" -ForegroundColor Green
```

### 从 Git 历史恢复特定版本

```powershell
# 1. 查看提交历史
cd D:\10Backups\Claude-Config
git log --oneline

# 2. 恢复到特定提交
git checkout <commit-hash>

# 3. 复制需要的文件到源位置
# （使用上面的恢复命令）

# 4. 返回最新版本
git checkout main
```

---

## 故障排除

### 问题 1：源目录不存在

**现象**：脚本显示 "⚠️ 源目录不存在，跳过"

**原因**：sources.json 中配置的路径不正确

**解决**：
1. 检查 sources.json 中的路径是否正确
2. 确认源目录确实存在
3. 注意路径中的反斜杠需要转义（`\\`）

### 问题 2：权限不足

**现象**：复制文件时提示 "Access Denied" 或权限错误

**解决**：
1. 以管理员身份运行 PowerShell
2. 检查源目录和目标目录的权限
3. 确保没有文件被其他程序占用

### 问题 3：变更检测不工作

**现象**：每次都显示 "ℹ️ 首次备份，无历史清单"

**原因**：`.backup-manifest.json` 文件被删除或损坏

**解决**：
1. 检查备份目录中是否存在 `.backup-manifest.json`
2. 如果文件损坏，删除它并重新运行备份
3. 确保 `.backup-manifest.json` 没有被 .gitignore 排除

### 问题 4：备份速度慢

**现象**：备份耗时很长

**解决**：
1. 使用 `-IncrementalBackup` 参数（只复制修改过的文件）
2. 检查是否有大文件或大量小文件
3. 考虑添加更多排除项到 sources.json
4. 检查磁盘性能和网络连接（如果备份到网络驱动器）

### 问题 5：脚本执行策略限制

**现象**：提示 "无法加载文件，因为在此系统上禁止运行脚本"

**解决**：
```powershell
# 临时允许（当前会话）
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 或永久允许（需要管理员权限）
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 最佳实践

### 1. 定期备份

- **推荐频率**：每天至少备份一次
- **最佳时间**：凌晨或系统空闲时间
- **自动化**：使用 Windows 任务计划程序

### 2. 使用增量备份

- **日常使用**：启用 `-IncrementalBackup` 节省时间
- **完整备份**：每周至少一次完整备份（不使用 -IncrementalBackup）

### 3. 启用变更检测

- **监控变化**：使用 `-DetectChanges` 了解配置变化
- **审查新增文件**：定期检查变更报告，确认新增文件是否需要备份

### 4. Git 版本控制

- **每次备份后提交**：保持 Git 历史完整
- **有意义的提交消息**：描述主要变更内容
- **定期推送远程**：每周推送到远程仓库（如果有）

### 5. 定期测试恢复

- **每月测试**：至少每月测试一次恢复流程
- **验证完整性**：确认恢复后的配置可用
- **记录问题**：记录恢复过程中遇到的问题

### 6. 维护 sources.json

- **及时更新**：添加新文件或目录时更新配置
- **清理无效项**：删除不再需要的配置项
- **添加注释**：在 notes 字段中说明每项的用途

### 7. 监控备份大小

- **定期检查**：每月检查备份大小
- **清理冗余**：删除不必要的文件
- **优化排除列表**：添加更多运行态数据到排除列表

### 8. 文档维护

- **更新文档**：配置变更时更新相关文档
- **记录决策**：在 plans 目录记录重要决策
- **保持同步**：确保文档与实际配置一致

---

## 安全建议

### 1. 私有仓库

- 如果使用远程 Git 仓库，**必须使用私有仓库**
- 不要将配置推送到公共仓库
- 使用 SSH 密钥而非密码认证

### 2. 敏感信息检查

- 定期检查备份中是否包含 API 密钥、密码等敏感信息
- 使用 `.gitignore` 排除包含敏感信息的文件
- 考虑使用环境变量或密钥管理工具

### 3. 访问控制

- 限制备份目录的访问权限
- 只允许必要的用户访问
- 定期审查权限设置

### 4. 加密

- 考虑对备份目录进行加密（如使用 BitLocker）
- 如果备份到外部驱动器，必须加密
- 使用强密码保护加密密钥

### 5. 备份的备份

- 考虑创建备份的备份（如压缩快照）
- 存储到不同的物理位置
- 定期验证备份的完整性

---

## 参考文档

- **配置清单**：`C:\Users\admin\.claude\plans\sources.json`
- **备份计划**：`C:\Users\admin\.claude\plans\centralized-claude-backup-plan.md`
- **内容清单**：`C:\Users\admin\.claude\plans\claude-backup-inventory.md`
- **同步脚本**：`C:\Users\admin\.claude\plans\sync-backup.ps1`

---

## 常见使用场景

### 场景 1：日常备份

```powershell
# 快速增量备份（推荐日常使用）
.\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config" -IncrementalBackup
```

### 场景 2：完整备份 + 变更检测

```powershell
# 每周一次完整备份，查看变更
.\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config" -DetectChanges
```

### 场景 3：首次备份

```powershell
# 首次备份，建立基线
.\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config" -DetectChanges

# 初始化 Git 仓库
cd D:\10Backups\Claude-Config
git init
git add .
git commit -m "Initial backup"
```

### 场景 4：灾难恢复

```powershell
# 1. 从 Git 获取最新备份
cd D:\10Backups\Claude-Config
git pull origin main

# 2. 恢复全局层和领域层
# （使用上面的恢复命令）
```

---

## 更新日志

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0.0 | 2026-03-23 | 初始版本，包含完整的使用说明和最佳实践 |

---

## 支持与反馈

如有问题或建议，请：
1. 检查本文档的"故障排除"部分
2. 查看相关参考文档
3. 记录问题到 `.claude/plans/` 目录
