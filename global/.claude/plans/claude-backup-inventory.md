# Claude 配置备份内容清单

> 文档主题：全局层与软件工程领域层的 Claude 配置备份清单
> 输出目的：为集中仓库备份方案提供明确的纳入/排除边界
> 状态：草案
> 更新日期：2026-03-23

---

## 1. 文档目标

本清单用于明确以下两层配置中，哪些内容属于**必须备份**、哪些属于**建议备份**、哪些属于**默认排除**：

1. 全局层：`C:\Users\admin\.claude`
2. 软件工程领域层：`D:\2Work\Claude\.claude`
3. 软件工程领域工作区中的 Claude 相关辅助资产：`D:\2Work\Claude`

本清单服务于后续集中仓库、`sources.json`、同步脚本和 `.gitignore` 设计。

---

## 2. 分类标准

### 2.1 必须备份

满足以下任一条件的内容，列为必须备份：

- 属于 Claude 配置的真相源（source of truth）
- 定义行为、规则、模板、技能、记忆、计划
- 无法轻易自动再生成
- 丢失后会直接影响 Claude 使用方式或配置体系

### 2.2 建议备份

满足以下任一条件的内容，列为建议备份：

- 属于辅助性配置或工作资产
- 丢失后不会立即破坏体系，但恢复成本较高
- 对知识沉淀、工具工作区、自动化能力有价值

### 2.3 默认排除

满足以下任一条件的内容，列为默认排除：

- 用户明确指定不备份
- 明确属于软链接入口、且真实本体已在其他位置统一备份
- 属于缓存、日志、遥测、快照或明显运行态派生产物

### 2.4 当前脚本策略

当前备份脚本按“**默认整目录备份**”设计：

- 对于被纳入清单的目录，默认整体同步
- 不做复杂的细粒度内容筛选，除非有明确排除要求
- 因此本清单中的“默认排除”只保留少量、明确、稳定的排除项
- 后续如需缩小范围，再单独增加排除规则

---

## 3. 全局层备份清单

**核心根路径：** `C:\Users\admin\.claude`

**辅助能力资产根路径：** `C:\Users\admin`

---

### 3.1 全局层必须备份

#### 核心目录

- `C:\Users\admin\.claude\rules\`
  - 原因：全局规则定义，属于配置体系核心。

- `C:\Users\admin\.claude\memory\`
  - 原因：全局记忆与知识沉淀，无法自动恢复。

- `C:\Users\admin\.claude\plans\`
  - 原因：全局层计划文档与设计文档。

- `C:\Users\admin\.claude\templates\`
  - 原因：Spec / Plan / Tasks / Checklist 模板属于复用资产。

- `C:\Users\admin\.claude\skills\`
  - 原因：自定义技能与工作流能力集合。

#### 核心文件

- `C:\Users\admin\.claude\architecture.md`
  - 原因：全局配置架构说明，是顶层结构文档。

- `C:\Users\admin\.claude\settings.json`
  - 原因：全局配置入口之一。

- `C:\Users\admin\.claude\settings.local.json`
  - 原因：本地层面的全局设置，可能包含运行偏好与权限配置。

- `C:\Users\admin\.claude\config.json`
  - 原因：全局配置文件。

- `C:\Users\admin\.claude\project-config.json`
  - 原因：项目相关的配置入口文件。

- `C:\Users\admin\.claude\mcp.json`
  - 原因：MCP 配置属于核心集成配置。

---

### 3.2 全局层建议备份

#### `.claude` 内的建议备份项

- `C:\Users\admin\.claude\memory\last-session.md`
  - 原因：保留最近会话状态，有助于恢复工作上下文。

- `C:\Users\admin\.claude\memory\projects\`
  - 原因：若其中保存项目相关记忆或沉淀，建议保留。

- `C:\Users\admin\.claude\plans\centralized-claude-backup-plan.md`
  - 原因：当前集中备份方案计划文档。

- `C:\Users\admin\.claude\plans\serialized-honking-newell.md`
  - 原因：已存在的计划文档，应视为知识资产。

#### 全局层辅助能力资产

- `C:\Users\admin\.mcp.json`
  - 原因：位于用户目录根部的 MCP 服务器配置，虽然不在 `.claude` 内，但直接影响 Claude 的外部能力接入，应视为全局层辅助能力资产并纳入备份。

- `C:\Users\admin\.claude.json`
  - 原因：位于用户目录根部的 Claude 客户端状态/配置文件，虽然包含较多运行与使用状态，但对恢复本机 Claude 使用环境有参考价值，按辅助能力资产纳入备份。

---

### 3.3 全局层默认排除

当前全局层采用“整目录备份，少量明确排除”的策略。

保留的明确排除项：

- `C:\Users\admin\.claude\skills\` 以外层级中的软链接目标重复项不重复备份
  - 原因：skills 本体只在全局层保留一次。

如后续实施中发现明显不应进入集中仓库的运行态目录，再补充排除规则。

---

## 4. 软件工程领域层备份清单

**根路径：** `D:\2Work\Claude\.claude`

---

### 4.1 领域层必须备份

#### 核心目录

- `D:\2Work\Claude\.claude\rules\`
  - 原因：领域规则集合，是软件工程领域层的核心定义。

- `D:\2Work\Claude\.claude\memory\`
  - 原因：领域知识与经验沉淀。

- `D:\2Work\Claude\.claude\templates\`
  - 原因：领域规则/测试模板。

#### 核心文件

- `D:\2Work\Claude\.claude\settings.json`
  - 原因：领域层基础设置。

- `D:\2Work\Claude\.claude\settings.local.json`
  - 原因：领域层本地设置与权限允许项。

#### 领域规则重点文件

- `D:\2Work\Claude\.claude\rules\architecture.md`
- `D:\2Work\Claude\.claude\rules\domain-agent-orchestration.md`
- `D:\2Work\Claude\.claude\rules\domain-code-analysis-best-practices.md`
- `D:\2Work\Claude\.claude\rules\domain-comprehensive-replacement-workflow.md`
- `D:\2Work\Claude\.claude\rules\domain-development-workflow.md`
- `D:\2Work\Claude\.claude\rules\domain-mcp-configuration-guide.md`
- `D:\2Work\Claude\.claude\rules\domain-project-initialization.md`
- `D:\2Work\Claude\.claude\rules\domain-standards-security.md`
- `D:\2Work\Claude\.claude\rules\INDEX.md`
- `D:\2Work\Claude\.claude\rules\rule-tests.md`

以上文件的共同原因：它们直接定义软件工程领域的行为边界、流程和标准。

#### 关于 skills 的特殊说明

- `D:\2Work\Claude\.claude\skills\` 当前不纳入领域层备份清单。
- 原因：按当前架构，非全局层下的 `skills` 为软链接，本体由全局层统一维护。
- 备份策略：只保留全局层 `C:\Users\admin\.claude\skills\`，其他层级的 `skills` 仅视为链接入口，不重复备份其链接目标内容。
- 恢复策略：恢复全局层 skills 后，再按架构需要重建各层软链接。

---

### 4.2 领域层建议备份

- `D:\2Work\Claude\.claude\memory\README.md`
  - 原因：说明领域记忆设计原则，虽然可重写，但建议保留。

如未来 `memory/`、`plans/`、`context/` 中出现人工维护的知识文件，应再重新分类。

---

### 4.3 领域层默认排除

当前领域层采用“整目录备份，少量明确排除”的策略。

保留的明确排除项：

- `D:\2Work\Claude\.claude\skills\`
  - 原因：当前架构下该目录为软链接，真实 skills 本体只在全局层保留，不在领域层重复备份。

如后续实施中发现其他目录仅为明显运行态派生产物，再补充排除规则。

---

## 5. 软件工程领域工作区辅助资产清单

**根路径：** `D:\2Work\Claude`

这些内容不完全属于“领域层 `.claude` 核心配置”，但部分属于高价值工作资产。建议将它们作为**扩展备份集**，与核心配置分开管理。

---

### 5.1 建议备份的辅助资产

#### 工作区说明文件

- `D:\2Work\Claude\CLAUDE.md`
  - 原因：领域工作区说明文档，与四层架构使用方式直接相关。

- `D:\2Work\Claude\README.md`
  - 原因：若包含工作区约定、说明或恢复信息，建议保留。

#### 自动化脚本

- `D:\2Work\Claude\auto-js\`
  - 原因：按当前要求，`auto-js` 目录整体纳入备份，作为领域工作区的重要自动化能力资产。

#### 配置集合

- `D:\2Work\Claude\configs\`
  - 原因：若存放手工维护配置模板，应保留。

---

### 5.2 视情况备份

- `D:\2Work\Claude\docs\`
  - 原因：若文档为手工沉淀内容，建议备份；若多为可重建说明，可降级。

- `D:\2Work\Claude\package.json`
- `D:\2Work\Claude\package-lock.json`
  - 原因：若你要恢复整个领域工具工作区环境，建议保留；若只备份 Claude 配置核心，可不纳入主清单。

---

### 5.3 默认排除的辅助资产

- `D:\2Work\Claude\tools\`
  - 原因：按当前要求，不纳入本次备份范围。

- `D:\2Work\Claude\resources\`
  - 原因：按当前要求，不纳入本次备份范围。

- `D:\2Work\Claude\edge_pages.json`
  - 原因：按当前要求，不纳入备份范围。

- `D:\2Work\Claude\node_modules\`
  - 原因：依赖目录，可通过安装恢复，不应纳入集中仓库。

- `D:\2Work\Claude\imgs\`
  - 原因：截图与图片通常体积大、恢复价值低。

---

## 6. 建议的备份分组

为便于后续集中仓库和 `sources.json` 设计，建议将备份内容分为 4 组。

### 6.1 组 A：全局核心配置

- `C:\Users\admin\.claude`

说明：
- 当前脚本策略为：目录一旦纳入，即默认整体备份。
- 全局层暂不预设复杂排除规则，后续如发现明确不应纳入的运行态目录，再补充。

### 6.1A 组 A-aux：全局辅助能力资产

- `C:\Users\admin\.mcp.json`
- `C:\Users\admin\.claude.json`

说明：
- 这两项不放在 `.claude` 根目录内，但都位于用户主目录下并与 Claude 运行能力有关。
- 建议在集中仓库中单独归类为“global auxiliary assets”，避免与 `.claude` 核心配置混淆。

### 6.2 组 B：领域核心配置

- `D:\2Work\Claude\.claude`

排除：
- `skills/`（软链接，仅保留全局层 skills 本体）

说明：
- 除 `skills/` 外，当前不对领域层 `.claude` 预设复杂排除规则。
- `cache/`、`context/`、`metrics/` 目前按“整目录默认备份”策略纳入，后续如确认应排除，再单独收紧。

### 6.3 组 C：领域工作区辅助资产

- `D:\2Work\Claude\CLAUDE.md`
- `D:\2Work\Claude\README.md`
- `D:\2Work\Claude\auto-js`
- `D:\2Work\Claude\configs`

### 6.4 组 D：可选扩展资产

- `D:\2Work\Claude\docs`
- `D:\2Work\Claude\package.json`
- `D:\2Work\Claude\package-lock.json`

---

## 7. 后续落地建议

基于本清单，后续建议按以下顺序推进：

1. 先将“组 A + 组 B”纳入集中备份仓库
2. 再评估是否加入“组 C”
3. 最后再决定“组 D”是否需要作为扩展备份
4. 用 `manifest/sources.json` 明确每组的源路径、目标路径、启用状态
5. 用同步脚本实现单向同步
6. 用 `.gitignore` 与排除规则过滤缓存与生成物

---

## 8. 当前推荐结论

### 最小必要备份范围

- `C:\Users\admin\.claude`
- `D:\2Work\Claude\.claude`（同步时排除 `skills/` 软链接）

### 推荐扩展备份范围

- `C:\Users\admin\.mcp.json`
- `C:\Users\admin\.claude.json`
- `D:\2Work\Claude\CLAUDE.md`
- `D:\2Work\Claude\auto-js`
- `D:\2Work\Claude\configs`

### 默认不进入当前集中仓库范围

- `D:\2Work\Claude\tools`
- `D:\2Work\Claude\resources`
- `D:\2Work\Claude\edge_pages.json`
- 其他后续明确指定排除的辅助资产

### 默认不进入核心集中仓库

- `D:\2Work\Claude\tools`
- `D:\2Work\Claude\resources`
- `D:\2Work\Claude\edge_pages.json`
- `node_modules/`
- 截图和工具输出

---

## 9. 下一步输出建议

在本清单确认后，下一步建议直接产出：

1. `sources.json` 初稿
2. 同步脚本初稿
3. `.gitignore` / 排除规则初稿

这样可以直接进入可执行阶段。
