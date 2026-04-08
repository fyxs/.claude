# 项目探索计划 - nts-eam-front

> 状态：已完成初步探索

## 项目基本信息

| 项目 | 详情 |
|------|------|
| **项目名** | `eam-web`（设备管理 Web） |
| **版本** | `3.15.0-SNAPSHOT` |
| **技术栈** | Vue 3.3.4 + TypeScript 5.3.3 + Vite 4.5.1 |
| **UI 框架** | `@tiansu/ts-web-package@1.2.26-beta.18` + Element Plus |
| **状态管理** | Pinia + pinia-plugin-persistedstate |
| **HTTP** | Axios 1.5.1 |
| **微前端** | Qiankun（vite-plugin-qiankun） |
| **路由** | Vue Router 4.2.5 |
| **图表** | ECharts 5.4.3 |

## 目录结构

```
src/
├── apis/                      # API 接口（按业务模块）
├── components/                # 公共组件（28+ 个子目录）
│   ├── people-select/         # 人员选择封装（包含 te-department/employee/job/label/title）
│   ├── te-tree-edit-v2/       # 可编辑树形组件
│   ├── te-immediate-transfer/ # 即时转派组件
│   └── ...
├── hooks/                     # 组合式函数
├── router/                    # 路由配置
├── store/                     # Pinia 状态管理
├── styles/                    # 全局样式
├── types/                     # TypeScript 类型
├── utils/                     # 工具函数
├── views/                     # 页面视图
└── constant/                  # 常量定义
```

## 关键发现 - te- 组件实际情况

### V2 组件不存在

**重要偏差**：项目中**不存在** `TeDepartmentV2`、`TeEmployeeV2`、`TeJobV2`、`TeLabelV2`、`TeTitleV2` 等 V2 后缀组件。

### 实际使用的 te- 组件

项目中使用的是**不带 V2 后缀**的组件：

| 组件 | 用途 | 使用位置 |
|------|------|---------|
| `te-department` | 部门选择 | `src/components/people-select/components/people-item.vue` |
| `te-employee` | 人员选择 | 同上 |
| `te-label` | 标签选择 | 同上 |
| `te-job` | 岗位选择 | 同上 |
| `te-title` | 职务选择 | 同上 |

### 组件来源

- **来源包**: `@tiansu/ts-web-package`（天肃 UI 组件库）
- **注册方式**: `main.ts` 中通过 `TSUI` 全局注册
- **项目本地封装**: `src/components/people-select/` 对这 5 个底层选择器进行了二次封装

### people-select 封装模式

```
src/components/people-select/
├── index.vue                    # 主入口组件
├── components/
│   └── people-item.vue         # 人员选择项（使用 te-department/employee/job/label/title）
├── hooks/useConfigRule.ts
├── api/
└── constant.ts                  # SELECT_FIELD_CONFIGS 定义 5 种选择类型
```

底层选择器使用方式（弹窗选择器）：
```vue
<te-department
  v-model:visible="depVisible"
  v-model:selected="internalSelectedValue"
  :axios-instance="request"
  :tenant-id="tenantId"
  multiple
/>
```

## 其他 te- 前缀组件

项目还使用了来自 `@tiansu/ts-web-package` 和 `@tiansu/element-plus` 的其他 te- 组件：

| 组件 | 类别 |
|------|------|
| `te-tree-select` | 树形选择 |
| `te-space-select` | 空间选择 |
| `te-tree-v2` | 树形组件 v2 |
| `te-button`, `te-input`, `te-select` | 基础组件 |
| `te-form`, `te-form-item` | 表单组件 |
| `te-tabs`, `te-tab-pane` | 标签页 |
| `te-search`, `te-module-table` | 业务组件 |
| `te-icon`, `te-tooltip`, `te-popover` | 展示组件 |

## 待确认事项

**需要与用户确认**：
1. 用户提到的 `TeJobV2`、`TeLabelV2`、`TeTitleV2` 组件是从哪里得知的？（文档、需求、还是其他来源？）
2. 是否有其他参考文档或需求说明提到了这些 V2 组件？
3. 是否有内部 npm 包的变更日志说明了 V2 组件的存在？
4. 接下来具体想对项目做什么？（因为原来提到的"全面替换 V2 组件"任务需要先澄清需求）
