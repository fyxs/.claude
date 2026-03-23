# 项目配置模板

## 项目信息

**项目名称**：[项目名称]
**技术栈**：Vue 3 + TypeScript
**开发类型**：企业开发

---

## 项目特定规则

### 构建配置

- 使用 Vite 作为构建工具
- 开发服务器端口：[端口号]
- 生产环境 base path：[路径]

### API 配置

- API Base URL：使用环境变量 `VITE_API_BASE_URL`
- 超时时间：30s
- 请求拦截：添加 token
- 响应拦截：统一错误处理

### 路由配置

- 使用 hash 模式或 history 模式
- 路由懒加载
- 路由守卫：权限验证

---

## 环境变量

```env
# .env.development
VITE_API_BASE_URL=http://localhost:3000/api

# .env.production
VITE_API_BASE_URL=https://api.example.com
```

---

## 开发命令

```bash
npm run dev      # 开发服务器
npm run build    # 生产构建
npm run preview  # 预览构建结果
npm run test     # 运行测试
npm run lint     # 代码检查
```
