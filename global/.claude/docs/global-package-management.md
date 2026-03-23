# 全局包管理策略

> 解决 Volta 多版本 Node.js 环境下的全局包安装和 native 模块编译问题

## 问题背景

使用 Volta 管理多个 Node.js 版本时，会遇到以下问题：

1. **版本切换不透明**：不同 shell 或上下文可能使用不同的 Node.js 版本
2. **Native 模块编译问题**：需要针对实际运行的 Node.js 版本编译
3. **全局包管理复杂**：Volta 会在多个版本目录下安装全局包

## 解决方案

### 策略概述

1. **Volta 继续管理项目级 Node.js 版本**（保持灵活性）
2. **全局包统一安装在 `C:\npm-global`**（避免 Volta 管理）
3. **根据实际运行环境自动编译 native 模块**

### Node.js 版本分类

| 版本 | 用途 | 说明 |
|------|------|------|
| 18.20.4 (LTS) | 稳定工具 | 大多数全局工具的默认版本 |
| 25.8.0 (Latest) | 新特性 | 需要最新特性的工具 |
| 其他版本 | 特定项目 | 按需保留 |

---

## 使用指南

### 1. 安装新的全局包

**基本用法：**
```bash
# 使用默认版本（18.20.4）
~/.claude/scripts/install-global-package.sh <package-name>

# 指定 Node.js 版本
~/.claude/scripts/install-global-package.sh <package-name> <node-version>
```

**示例：**
```bash
# 安装 claude-code-ui（使用默认 18.20.4）
~/.claude/scripts/install-global-package.sh @siteboon/claude-code-ui

# 安装需要最新 Node.js 的包
~/.claude/scripts/install-global-package.sh some-package 25.8.0
```

**脚本功能：**
- ✅ 使用指定 Node.js 版本安装包
- ✅ 自动检测 native 模块（better-sqlite3, sqlite3, bcrypt, sharp 等）
- ✅ 自动编译 native 模块
- ✅ 提供安装验证命令

---

### 2. 修复已安装包的 native 模块

**使用场景：**
- 在不同 shell（bash vs PowerShell）中遇到版本不匹配错误
- 切换到新的 Node.js 版本后
- 出现 `NODE_MODULE_VERSION` 不匹配错误

**用法：**
```bash
~/.claude/scripts/fix-native-modules.sh <package-name> <target-node-version>
```

**示例：**
```bash
# 为 PowerShell 环境（使用 Node.js 25.8.0）修复
~/.claude/scripts/fix-native-modules.sh @siteboon/claude-code-ui 25.8.0

# 为 bash 环境（使用 Node.js 18.20.4）修复
~/.claude/scripts/fix-native-modules.sh @siteboon/claude-code-ui 18.20.4
```

**脚本功能：**
- ✅ 自动检测包中的所有 native 模块
- ✅ 使用指定 Node.js 版本重新编译
- ✅ 支持常见 native 模块（better-sqlite3, sqlite3, bcrypt, sharp, canvas 等）

---

## 常见问题处理

### 问题 1：不同 shell 中版本不一致

**症状：**
- bash 中显示版本 A
- PowerShell 中显示版本 B

**原因：**
- Volta 在不同 shell 中可能使用不同的 Node.js 版本
- PATH 优先级不同

**解决：**
```bash
# 1. 检查实际使用的 Node.js 版本
# bash:
node -v

# PowerShell:
powershell -Command "node -v"

# 2. 针对每个环境修复 native 模块
~/.claude/scripts/fix-native-modules.sh <package> <bash-node-version>
~/.claude/scripts/fix-native-modules.sh <package> <powershell-node-version>
```

---

### 问题 2：NODE_MODULE_VERSION 不匹配

**错误示例：**
```
Error: The module was compiled against a different Node.js version using
NODE_MODULE_VERSION 108. This version of Node.js requires
NODE_MODULE_VERSION 141.
```

**版本对应关系：**
- NODE_MODULE_VERSION 108 = Node.js 18.x
- NODE_MODULE_VERSION 127 = Node.js 22.x
- NODE_MODULE_VERSION 141 = Node.js 25.x

**解决：**
```bash
# 使用目标版本重新编译
~/.claude/scripts/fix-native-modules.sh <package> <target-version>

# 例如：错误说需要 141，则使用 25.x
~/.claude/scripts/fix-native-modules.sh @siteboon/claude-code-ui 25.8.0
```

---

### 问题 3：Volta 旧版本残留

**症状：**
- 删除了旧版本，但仍然能运行
- 版本号显示不正确

**原因：**
- Volta 在多个 Node.js 版本目录下都安装了包
- Volta bin 目录下有 shim 文件

**解决：**
```bash
# 1. 查找所有安装位置
where.exe <command-name>

# 2. 删除 Volta 目录下的所有版本
rm -rf "C:/Users/admin/AppData/Local/Volta/tools/image/node/*/node_modules/<package>"
rm -rf "C:/Users/admin/AppData/Local/Volta/tools/image/node/*/<command-name>"*

# 3. 删除 Volta bin 目录下的 shim
rm "C:/Users/admin/AppData/Local/Volta/bin/<command-name>"*

# 4. 重新安装
~/.claude/scripts/install-global-package.sh <package>
```

---

## 最佳实践

### 1. 安装全局包时

```bash
# ✅ 好的做法：使用安装脚本
~/.claude/scripts/install-global-package.sh <package> [version]

# ❌ 避免：直接使用 npm install -g
npm install -g <package>  # 可能导致 Volta 管理，版本混乱
```

### 2. 遇到版本问题时

```bash
# 步骤 1：检查当前环境的 Node.js 版本
node -v

# 步骤 2：检查包的实际位置
where.exe <command-name>

# 步骤 3：使用修复脚本
~/.claude/scripts/fix-native-modules.sh <package> <node-version>
```

### 3. 清理不需要的 Node.js 版本

```bash
# 定期清理不再使用的版本
ls "C:/Users/admin/AppData/Local/Volta/tools/image/node/"

# 删除不需要的版本
rm -rf "C:/Users/admin/AppData/Local/Volta/tools/image/node/<version>"
```

---

## 工作流示例

### 场景 1：安装新工具

```bash
# 1. 安装（使用默认 LTS 版本）
~/.claude/scripts/install-global-package.sh @siteboon/claude-code-ui

# 2. 验证
claude-code-ui -v

# 3. 如果在 PowerShell 中遇到问题
~/.claude/scripts/fix-native-modules.sh @siteboon/claude-code-ui 25.8.0
```

### 场景 2：需要最新 Node.js 特性的工具

```bash
# 1. 安装（指定最新版本）
~/.claude/scripts/install-global-package.sh some-new-tool 25.8.0

# 2. 验证
some-new-tool --version
```

### 场景 3：多环境支持

```bash
# 1. 安装（使用主要环境的版本）
~/.claude/scripts/install-global-package.sh my-tool 18.20.4

# 2. 为 PowerShell 环境修复
~/.claude/scripts/fix-native-modules.sh my-tool 25.8.0

# 3. 现在两个环境都可以使用
```

---

## 脚本维护

### 添加新的 native 模块检测

编辑 `fix-native-modules.sh`，在 `COMMON_NATIVE_MODULES` 数组中添加：

```bash
COMMON_NATIVE_MODULES=(
    "better-sqlite3"
    "sqlite3"
    "bcrypt"
    "sharp"
    "node-sass"
    "canvas"
    "fsevents"
    "node-gyp"
    # 添加新的模块
    "your-native-module"
)
```

### 自定义默认 Node.js 版本

编辑 `install-global-package.sh`，修改默认版本：

```bash
NODE_VERSION="${2:-18.20.4}"  # 改为你想要的默认版本
```

---

## 总结

**优势：**
- ✅ 支持多版本 Node.js 环境
- ✅ 自动处理 native 模块编译
- ✅ 避免 Volta 全局包管理的复杂性
- ✅ 灵活应对不同场景的需求

**注意事项：**
- ⚠️ 不同 shell 可能需要分别修复 native 模块
- ⚠️ 定期清理不需要的 Node.js 版本
- ⚠️ 使用脚本安装，避免直接 `npm install -g`

**记住：**
遇到版本问题时，先检查 Node.js 版本，然后使用 `fix-native-modules.sh` 修复。
