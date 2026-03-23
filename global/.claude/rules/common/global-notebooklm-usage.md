# NotebookLM 使用规则

> 规则 ID: GLOBAL-TOOL-001
> 版本: 1.2.0
> 创建日期: 2026-03-09
> 最后更新: 2026-03-11
> 状态: 发布

> 本规则定义了何时以及如何使用 NotebookLM 进行研究和内容生成。

## 使用场景判断

### 🔴 强制执行规则（最高优先级）

**前缀规则优先级说明：**
- 前缀规则是**最高优先级**，覆盖所有其他判断标准
- 有前缀时，**只执行前缀对应的流程**，忽略其他关键词

---

**1. NotebookLM 前缀规则**

当用户消息以 "notebooklm" 前缀开头时，必须执行完整的 NotebookLM → Obsidian 流程。

**示例：**
```
notebooklm https://github.com/vercel-labs/skills
notebooklm 探索 XXX 项目
notebooklm 深度研究 XXX
```

**执行要求：**
- 忽略其他判断标准
- 创建笔记本 → 添加源 → 生成内容 → 保存到 Obsidian
- 完整执行整个工作流

---

**2. Obsidian 前缀规则**

当用户消息以 "obsidian" 前缀开头时，**直接**将内容记录到 Obsidian 中。

**CRITICAL：前缀 vs 主题的区分**

⚠️ **"obsidian" 是工具前缀，不是主题关键词**

**错误理解**：
```
用户："obsidian 深入探讨，总结输出"
错误：认为主题是 Obsidian 本身
```

**正确理解**：
```
用户："obsidian 深入探讨，总结输出"
正确：
  - "obsidian" = 工具（用 Obsidian 记录）
  - "深入探讨" = 动作
  - 主题 = 结合上下文判断（当前对话的主题）
```

**判断流程**：
1. **检测前缀** → 确定使用 Obsidian 工具
2. **分析上下文** → 确定主题是什么（回顾对话历史）
3. **执行操作** → 用 Obsidian 记录该主题的内容

**CRITICAL：**
- ❌ **不使用 NotebookLM**
- ✅ **直接分析和整理内容**
- ✅ **保存到 Obsidian**
- ✅ **必须结合对话上下文判断主题**

**示例：**
```
场景 1：
  对话上下文：正在讨论 .claude 目录
  用户："obsidian 深入探讨，总结输出"
  主题：.claude 目录（不是 Obsidian）

场景 2：
  对话上下文：正在讨论 Vue 3
  用户："obsidian 记录今天学到的内容"
  主题：Vue 3 相关内容（不是 Obsidian）

场景 3：
  用户："obsidian 总结 XXX 项目的核心要点"
  主题：XXX 项目（明确指定）
```

**执行流程：**
1. 自己分析和整理内容（不使用 NotebookLM）
2. 创建结构化的 Markdown 文档
3. 根据内容类型选择合适的 Obsidian 目录：
   - 学习笔记 → `D:/8Documents/Obsidian/Knowledge/`
   - 项目总结 → `D:/8Documents/Obsidian/Projects/`
   - 研究记录 → `D:/8Documents/Obsidian/Research/`
   - 日常记录 → `D:/8Documents/Obsidian/Daily/`
4. 使用清晰的文件命名（包含日期和主题）
5. 直接创建文件，无需用户确认

### ✅ 应该使用 NotebookLM 的场景

**仅在以下情况使用 NotebookLM**：
1. **用户明确要求使用 NotebookLM**
   - 用户直接说"使用 NotebookLM"
   - 用户说"用 NotebookLM 研究 XXX"

2. **用户使用 notebooklm 前缀**
   - `notebooklm https://github.com/xxx`
   - `notebooklm 研究 XXX`

**CRITICAL：不要根据关键词自动触发**
- ❌ 看到"深度研究"、"探索"、"调研"等词汇不自动使用
- ❌ 看到"生成学习指南"、"生成播客"等不自动使用
- ✅ 只有用户明确要求或使用前缀时才使用

### ❌ 不应该使用 NotebookLM 的场景

**默认不使用 NotebookLM**：
- 用户没有明确要求使用 NotebookLM
- 用户没有使用 notebooklm 前缀
- 即使用户使用了"深度研究"、"探索"、"调研"等词汇

**替代方案**：
- 使用 curl 直接获取 GitHub README
- 使用 WebFetch 获取在线文档
- 直接搜索和分析
- 使用其他更高效的工具

### 判断标准

**使用 NotebookLM 的唯一标准**：
1. 用户明确说"使用 NotebookLM"或"用 NotebookLM"
2. 用户使用 `notebooklm` 前缀

**不使用 NotebookLM**：
- 所有其他情况，包括但不限于：
  - 用户说"深度研究"、"系统研究"
  - 用户说"探索"、"调研"、"分析"
  - 用户说"生成学习指南"、"生成报告"
  - 任何没有明确提到 NotebookLM 的请求

## 自动触发场景

**CRITICAL：不自动触发 NotebookLM**

NotebookLM 只在以下情况使用：
1. 用户明确要求："使用 NotebookLM"、"用 NotebookLM 研究 XXX"
2. 用户使用前缀：`notebooklm XXX`

**禁止自动触发**：
- ❌ 不要根据"深度研究"、"探索"等关键词自动使用
- ❌ 不要根据任务复杂度自动判断
- ❌ 不要自作主张使用 NotebookLM
- ✅ 只有用户明确要求时才使用

## 使用流程

### 标准工作流

```
1. 创建笔记本 → notebooklm create "Title"
2. 添加源文件 → 优先使用 GitHub URL
3. 批量生成内容 → 学习指南、FAQ、简报、播客、思维导图
4. 检查状态 → 使用 --json 避免编码问题
5. 提供访问链接 → https://notebooklm.google.com
```

### 源文件选择优先级

1. **GitHub 仓库 URL**（最优）
   - 直接获取最新内容
   - 自动生成中文内容
   - 避免本地文件编码问题

2. **在线文档 URL**
   - 技术文档、博客、论文

3. **本地文件**（最后选择）
   - 可能遇到编码问题
   - 需要确保文件完整性

## 认证问题处理

**遇到登录/认证问题时**：
- ❌ 不要自行尝试解决复杂的认证问题
- ✅ 立即告知用户遇到认证问题
- ✅ 说明具体错误信息
- ✅ 请用户自行运行 `notebooklm login` 处理
- ✅ 等待用户确认后继续

## 编码问题处理

**Windows 终端编码问题**：
- 问题：GBK 编码无法显示 emoji 和中文
- 解决：始终使用 `--json` 参数获取输出
- 示例：`notebooklm artifact list --notebook ID --json`

## 权限配置

**问题**：NotebookLM 命令需要用户手动确认才能执行

**原因**：系统的权限机制独立于规则文件，需要单独配置

**解决方案**：在 `~/.claude/settings.json` 中配置 permissions.allow

```json
{
  "permissions": {
    "allow": [
      "Bash(prompt:run notebooklm commands)"
    ]
  }
}
```

**说明**：
- `permissions.allow` 是字符串数组，包含允许自动执行的操作
- `Bash(prompt:run notebooklm commands)` 表示允许运行 NotebookLM 相关的 bash 命令
- 配置后，NotebookLM 命令将自动执行，不需要用户确认

## 数据保护规则

**CRITICAL：以下操作必须获得用户明确授权：**

1. **禁止自动删除 NotebookLM 笔记本**
   - ❌ 不允许使用 `notebooklm notebook delete` 命令
   - ✅ 除非用户明确要求删除

2. **禁止自动删除 Obsidian 文档**
   - ❌ 不允许删除 `D:/8Documents/Obsidian/` 中的任何文件
   - ✅ 除非用户明确要求删除

3. **数据操作原则**
   - 只能创建和修改，不能删除
   - 删除操作必须获得明确授权
   - 保护用户的知识资产

## 不适用场景

**默认不使用 NotebookLM**

除非用户明确要求或使用 `notebooklm` 前缀，否则不使用 NotebookLM。

**常见场景的替代方案**：

1. **研究和探索**
   - 场景：用户说"研究 XXX"、"探索 XXX"、"深度分析 XXX"
   - 替代：直接使用 curl 获取 README，或使用 WebFetch
   - 示例：`curl -s https://raw.githubusercontent.com/owner/repo/main/README.md`

2. **信息查询**
   - 场景：用户说"了解 XXX"、"查看 XXX"
   - 替代：直接搜索或查询

3. **代码开发任务**
   - 场景：代码编写、调试、文件操作
   - 替代：使用代码工具直接处理

4. **实时交互任务**
   - 场景：需要实时反馈的任务
   - 替代：直接交互式处理

**判断原则**：默认不使用 NotebookLM，除非用户明确要求。

## 实践经验与教训

### 命令格式规范

**正确的命令格式：**

1. **添加源文件**
   ```bash
   # ✅ 正确
   notebooklm source add <url>
   notebooklm source add <file_path>
   
   # ❌ 错误
   notebooklm source add --url <url>
   ```

2. **生成内容**
   ```bash
   # ✅ 正确
   notebooklm generate audio "instructions"
   notebooklm generate report --format briefing-doc
   
   # ❌ 错误
   notebooklm artifact generate audio
   ```

### 操作流程规范

**CRITICAL：执行 NotebookLM 操作时必须遵循以下流程：**

1. **自动执行，无需用户介入**
   - 简短说明将要执行的操作
   - 直接执行，不等待确认
   - 高效完成整个工作流

2. **默认生成内容**
   - 简报报告（briefing-doc）
   - 思维导图（mind-map）
   - ❌ 默认不生成音频播客（除非用户明确要求）

3. **音频播客处理**
   - 仅在用户明确要求时生成
   - 生成后无需等待完成（耗时 10-20 分钟）
   - 继续执行后续任务

**示例：**
```markdown
✅ 正确做法：
1. 创建笔记本
2. 添加源
3. 生成简报报告
4. 生成思维导图
5. 下载并保存到 Obsidian
6. 报告最终结果

❌ 错误做法：
- 逐步询问用户是否继续
- 等待用户确认每个步骤
- 默认生成音频播客
```

### 与 Obsidian 集成

**标准工作流：**
1. 使用 NotebookLM 生成内容
2. 使用 `download` 命令保存到临时文件
3. 移动文件到 Obsidian vault 的对应目录
4. 根据内容类型选择目录：
   - 调研报告 → `D:/8Documents/Obsidian/Research/`
   - 学习笔记 → `D:/8Documents/Obsidian/Knowledge/`
   - 项目文档 → `D:/8Documents/Obsidian/Projects/`

**示例：**
```bash
# 1. 生成报告
notebooklm generate report --format briefing-doc

# 2. 下载到临时文件
notebooklm download report report.md

# 3. 移动到 Obsidian
mv report.md "D:/8Documents/Obsidian/Research/项目名-评估报告.md"
```

### 常见错误与解决方案

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `No such option: --url` | 命令格式错误 | 使用 `notebooklm source add <url>` |
| `No such command 'generate'` | 命令层级错误 | 使用 `notebooklm generate <type>` 而非 `artifact generate` |
| GBK 编码错误 | Windows 终端编码限制 | 使用 `download` 命令保存到文件 |
| 文件不可见 | 文件已创建但需刷新 | 提醒用户刷新文件浏览器 |

---

## 相关规则

### 依赖规则
- **global-tools-environment.md** - 工具与环境配置（网络访问、Obsidian 集成）
- **architecture.md** - 配置架构说明（目录结构）

### 冲突规则
- 无直接冲突

### 优先级说明
- **前缀规则优先级：最高**
  - "notebooklm" 前缀 → 强制执行 NotebookLM 工作流
  - "obsidian" 前缀 → 强制直接使用 Obsidian
  - 前缀规则覆盖所有关键词判断

### 相关规则
- **global-development-workflow.md** - 开发工作流（研究与复用阶段可能使用 NotebookLM）

---

## 测试用例

### 测试用例 1：NotebookLM 前缀规则（正常场景）

**规则**：NotebookLM 前缀规则

**输入**：
- 用户消息：`notebooklm https://github.com/vercel-labs/skills`
- 对话上下文：无特定上下文

**期望行为**：
1. 检测到 "notebooklm" 前缀
2. 自动执行完整的 NotebookLM 工作流
3. 创建笔记本
4. 添加 GitHub URL 作为源
5. 生成简报报告和思维导图
6. 下载并保存到 Obsidian
7. 报告最终结果

**实际行为**：
[待测试]

**状态**：⏳ 待测试

---

### 测试用例 2：Obsidian 前缀规则（边界场景）

**规则**：Obsidian 前缀规则 - 前缀 vs 主题区分

**输入**：
- 用户消息：`obsidian 深入探讨，总结输出`
- 对话上下文：正在讨论 .claude 目录配置系统

**期望行为**：
1. 检测到 "obsidian" 前缀 → 确定工具是 Obsidian
2. 分析上下文 → 确定主题是 .claude 目录（不是 Obsidian 本身）
3. 自己分析和整理 .claude 目录的内容
4. 创建关于 .claude 的文档
5. 保存到 `D:/8Documents/Obsidian/Knowledge/` 目录
6. 文件名包含日期和主题（如：2026-03-09-Claude配置系统.md）

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ❌ 不应该创建关于 Obsidian 集成的文档
- ✅ 应该创建关于 .claude 目录的文档
- ✅ 主题应该从上下文判断，不是从前缀判断

---

### 测试用例 3：深度研究关键词（正常场景）

**规则**：不自动触发 NotebookLM

**输入**：
- 用户消息：`深度研究 Vue 3 Composition API`
- 对话上下文：无特定上下文

**期望行为**：
1. **不自动触发 NotebookLM**
   - 即使用户说"深度研究"，也不自动使用 NotebookLM
   - 因为用户没有明确要求使用 NotebookLM
2. **使用替代方案**
   - 使用 curl、WebFetch 或其他工具
   - 直接搜索和分析相关文档
3. **不创建 NotebookLM 笔记本**
   - 除非用户明确要求

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ❌ 不应该自动触发 NotebookLM
- ✅ 应该使用替代方案（curl、WebFetch 等）
- ❌ 不应该创建 NotebookLM 笔记本

---

### 测试用例 4：简单探索（正常场景）

**规则**：不自动触发 NotebookLM

**输入**：
- 用户消息：`探索 https://github.com/owner/repo`
- 对话上下文：无特定上下文

**期望行为**：
1. **不使用 NotebookLM**
   - 用户没有明确要求使用 NotebookLM
   - 用户没有使用 notebooklm 前缀
2. **使用高效替代方案**
   - 使用 curl 直接获取 README
   - 分析并总结基本信息
3. **快速返回结果**
   - 不创建 NotebookLM 笔记本
   - 直接提供分析结果

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ❌ 不应该创建 NotebookLM 笔记本
- ✅ 应该使用更高效的替代方案（curl）
- ✅ 快速返回基本信息
