# ISMS-Web 项目配置

> 规则 ID: PROJECT-ISMS-001
> 版本: 1.0.0
> 创建日期: 2026-03-16
> 状态: 发布

## 项目信息

**项目名称**：isms-web（综合安全管理系统）
**版本**：3.4.0
**技术栈**：Vue 3 + TypeScript + Vite
**状态管理**：Pinia
**微前端**：qiankun

## 技术栈详情

### 核心框架
- Vue 3.3.4
- TypeScript 5.3.3
- Vite 4.5.1
- Vue Router 4.2.5
- Pinia 2.1.7

### 企业内部包
- @tiansu/hlms-portal-web-package
- @tiansu/hlms-workflow-web-package
- @tiansu/ts-web-package
- @tiansu/tools

### 代码质量工具
- ESLint + Prettier
- Stylelint
- Husky + lint-staged
- TypeScript 严格模式

## 项目结构

```
src/
├── api/           # API 接口
├── assets/        # 静态资源
├── components/    # 公共组件
├── router/        # 路由配置
├── stores/        # Pinia 状态管理
├── types/         # TypeScript 类型定义
├── utils/         # 工具函数
├── views/         # 页面组件
└── App.vue
```

## 路径别名

- `@/` → `src/`

## 开发命令

```bash
# 开发
npm run dev

# 类型检查
npm run ts-check

# 构建
npm run build

# 代码检查
npm run lint

# 格式化
npm run prettier-format
```

## 项目特定规则

### 提交前检查
- 自动运行 ESLint
- 自动运行 Prettier
- 自动运行 Stylelint
- 类型检查必须通过

### 命名规范
- 组件：PascalCase
- 文件夹：kebab-case
- 变量/函数：camelCase
- 类型：PascalCase

### 代码规范
- 继承企业开发规范（app-enterprise-standards.md）
- 使用 Composition API
- 使用 `<script setup>` 语法
- 严格的 TypeScript 类型检查

## 注意事项

1. **企业内部包**：使用 @tiansu 命名空间的包
2. **微前端**：使用 qiankun 集成
3. **Node 版本**：需要 Node >= 16.0.0（推荐 18.20.4）
4. **提交规范**：遵循 conventional commits
