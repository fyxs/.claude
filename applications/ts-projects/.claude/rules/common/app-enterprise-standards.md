# 企业开发规范

## 适用范围

本规范适用于 `ts-projects` 下的所有企业级项目开发。

---

## 代码审查

### 强制要求

- ✅ 所有代码必须经过 code-reviewer agent 审查
- ✅ 所有 CRITICAL 和 HIGH 级别问题必须修复
- ✅ MEDIUM 级别问题应尽量修复
- ✅ 提交前必须通过 security-reviewer agent 检查

### 审查重点

1. **代码质量**
   - 命名规范
   - 代码复杂度
   - 可维护性

2. **安全性**
   - 无硬编码密钥
   - 输入验证
   - XSS/SQL 注入防护

3. **性能**
   - 避免不必要的重渲染
   - 合理的数据结构选择
   - 资源加载优化

---

## 提交规范

### Commit Message 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**：
- `feat`: 新功能
- `update`: 功能等更新
- `fix`: Bug 修复
- `refactor`: 重构
- `docs`: 文档
- `style`: 代码格式
- `test`: 测试
- `chore`: 构建/工具

**示例**：
```
feat(user): 添加用户登录功能

实现基于 JWT 的用户认证
- 登录接口
- Token 刷新
- 权限验证

Closes #123
```

---

## Pull Request 规范

### PR 标题

格式：`[类型] 简短描述`

示例：
- `[Feature] 用户认证模块`
- `[Fix] 修复登录页面样式问题`
- `[Refactor] 重构用户服务层`

### PR 描述模板

```markdown
## 变更说明
[描述本次变更的目的和内容]

## 变更类型
- [ ] 新功能
- [ ] Bug 修复
- [ ] 重构
- [ ] 文档更新

## 测试
- [ ] 单元测试已通过
- [ ] 集成测试已通过
- [ ] 手动测试已完成

## 截图（如适用）
[添加截图]

## 相关 Issue
Closes #[issue编号]
```

---

## 测试要求

### 覆盖率要求

- 单元测试覆盖率：≥ 80%
- 关键业务逻辑：≥ 90%
- 工具函数：100%

### 测试类型

1. **单元测试**（必需）
   - 所有组件
   - 所有工具函数
   - 所有业务逻辑

2. **集成测试**（必需）
   - API 调用
   - 组件交互
   - 状态管理

3. **E2E 测试**（关键流程）
   - 用户登录流程
   - 核心业务流程
   - 支付流程（如有）

---

## 文档要求

### 必需文档

1. **README.md**
   - 项目介绍
   - 技术栈
   - 安装和运行
   - 目录结构
   - 开发规范

2. **API 文档**
   - 接口说明
   - 请求/响应格式
   - 错误码说明

3. **组件文档**
   - 组件用途
   - Props 说明
   - 使用示例

### 代码注释

- 复杂逻辑必须注释
- 公共函数必须有 JSDoc
- 组件必须有用途说明

---

## Vue 项目规范

### 目录结构

```
src/
├── api/           # API 接口
├── assets/        # 静态资源
├── components/    # 公共组件
├── composables/   # 组合式函数
├── layouts/       # 布局组件
├── router/        # 路由配置
├── stores/        # 状态管理
├── types/         # TypeScript 类型
├── utils/         # 工具函数
├── views/         # 页面组件
└── App.vue
```

### 命名规范

- 组件：PascalCase（`UserProfile.vue`）
- 文件夹：kebab-case（`user-profile/`）
- 变量/函数：camelCase（`getUserInfo`）
- 常量：UPPER_SNAKE_CASE（`API_BASE_URL`）
- 类型：PascalCase（`UserInfo`）

### 组件规范

```vue
<script setup lang="ts">
// 1. 导入
import { ref, computed } from 'vue'

// 2. Props 定义
interface Props {
  userId: string
  userName?: string
}
const props = defineProps<Props>()

// 3. Emits 定义
const emit = defineEmits<{
  update: [id: string]
  delete: []
}>()

// 4. 响应式数据
const count = ref(0)

// 5. 计算属性
const doubleCount = computed(() => count.value * 2)

// 6. 方法
const handleClick = () => {
  emit('update', props.userId)
}
</script>

<template>
  <!-- 模板内容 -->
</template>

<style scoped>
/* 样式 */
</style>
```

---

## 安全规范

### 强制检查

- ❌ 禁止硬编码 API Key、密码、Token
- ❌ 禁止提交 `.env` 文件
- ✅ 使用环境变量管理敏感信息
- ✅ 所有用户输入必须验证和清理
- ✅ 使用 HTTPS
- ✅ 实施 CSRF 保护

### 依赖管理

- 定期更新依赖
- 使用 `npm audit` 检查漏洞
- 避免使用不维护的包

---

## 性能规范

### 优化要求

1. **首屏加载**
   - 首屏时间 < 3s
   - 使用路由懒加载
   - 图片懒加载

2. **打包优化**
   - 代码分割
   - Tree Shaking
   - 压缩资源

3. **运行时优化**
   - 避免不必要的重渲染
   - 使用虚拟滚动（长列表）
   - 防抖和节流

---

## 团队协作

### 分支策略

```
main          # 生产分支
├── develop   # 开发分支
    ├── feature/xxx  # 功能分支
    ├── fix/xxx      # 修复分支
    └── refactor/xxx # 重构分支
```

### 工作流程

1. 从 `develop` 创建功能分支
2. 开发并提交代码
3. 创建 PR 到 `develop`
4. 代码审查
5. 合并到 `develop`
6. 测试通过后合并到 `main`

---

## 发布流程

1. **版本号规范**：遵循语义化版本（SemVer）
2. **发布前检查**：
   - 所有测试通过
   - 代码审查完成
   - 文档已更新
   - 变更日志已更新
3. **发布后验证**：
   - 生产环境验证
   - 监控错误日志
   - 性能监控
