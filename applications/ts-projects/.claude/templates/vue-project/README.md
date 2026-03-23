# Vue 项目模板

## 模板说明

本模板用于快速初始化 Vue 3 + TypeScript 企业级项目。

---

## 使用方法

1. 复制此模板目录到新项目位置
2. 根据项目需求调整配置
3. 安装依赖并开始开发

---

## 推荐技术栈

- **框架**：Vue 3 + TypeScript
- **构建工具**：Vite
- **状态管理**：Pinia
- **路由**：Vue Router
- **UI 框架**：Element Plus / Ant Design Vue（根据需要选择）
- **HTTP 客户端**：Axios
- **代码规范**：ESLint + Prettier
- **测试**：Vitest + Vue Test Utils

---

## 项目结构

```
project-name/
├── .claude/              # Claude 配置
│   └── rules/
│       └── project-config.md
├── public/               # 静态资源
├── src/
│   ├── api/             # API 接口
│   ├── assets/          # 资源文件
│   ├── components/      # 公共组件
│   ├── composables/     # 组合式函数
│   ├── layouts/         # 布局组件
│   ├── router/          # 路由配置
│   ├── stores/          # Pinia stores
│   ├── types/           # TypeScript 类型
│   ├── utils/           # 工具函数
│   ├── views/           # 页面组件
│   ├── App.vue
│   └── main.ts
├── tests/               # 测试文件
├── .env.example         # 环境变量示例
├── .eslintrc.js         # ESLint 配置
├── .prettierrc          # Prettier 配置
├── tsconfig.json        # TypeScript 配置
├── vite.config.ts       # Vite 配置
└── package.json
```

---

## 初始化步骤

### 1. 创建项目

```bash
npm create vite@latest project-name -- --template vue-ts
cd project-name
```

### 2. 安装依赖

```bash
# 核心依赖
npm install vue-router pinia axios

# UI 框架（选择一个）
npm install element-plus
# 或
npm install ant-design-vue

# 开发依赖
npm install -D @types/node
npm install -D eslint prettier
npm install -D vitest @vue/test-utils
```

### 3. 配置文件

参考模板中的配置文件进行设置。

---

## 开发规范

遵循 `app-enterprise-standards.md` 中的企业开发规范。
