# 代码标准与安全

> 规则 ID: DOMAIN-STANDARD-001
> 版本: 1.1.0
> 创建日期: 2026-03-10
> 最后更新: 2026-03-18
> 状态: 发布

> 本文档定义了软件工程领域的编码标准和安全最佳实践。

## 目录

1. [编码风格](#编码风格)
2. [通用模式](#通用模式)
3. [安全指南](#安全指南)
4. [代码质量检查清单](#代码质量检查清单)

> 变更历史：v1.1.0 - 新增注释规范（JSDoc + 单行注释最佳实践）

---

## 编码风格

### 不可变性（CRITICAL）

**核心原则：** ALWAYS 创建新对象，NEVER 修改现有对象。

**理由：**
- 不可变数据防止隐藏的副作用
- 使调试更容易
- 启用安全的并发
- 提高代码可预测性
- 简化状态管理

**实践示例：**

```javascript
// JavaScript - 错误方式
function addItem(cart, item) {
  cart.items.push(item);  // ❌ 修改原对象
  return cart;
}

// JavaScript - 正确方式
function addItem(cart, item) {
  return {
    ...cart,
    items: [...cart.items, item]  // ✅ 返回新对象
  };
}
```

---

### 文件组织

**核心原则：** 多个小文件 > 少数大文件

**文件大小指南：**

| 类型 | 理想大小 | 最大限制 | 行动 |
|------|---------|---------|------|
| 典型文件 | 200-400 行 | 800 行 | 保持在此范围 |
| 超大文件 | - | >800 行 | 立即拆分 |
| 工具模块 | 50-200 行 | 400 行 | 从大模块中提取 |

**组织原则：**
- 高内聚，低耦合
- 按功能/领域组织，而非按类型
- 提取工具函数

---

### 错误处理

**核心原则：** ALWAYS 全面处理错误

**错误处理层级：**
1. 在每个层级显式处理错误
2. UI 层面提供用户友好的错误消息
3. 服务器端记录详细的错误上下文
4. 永远不要静默吞掉错误

---

### 输入验证

**核心原则：** ALWAYS 在系统边界验证

**验证层级：**
1. 在处理前验证所有用户输入
2. 使用基于 schema 的验证（如果可用）
3. 快速失败，提供清晰的错误消息
4. 永远不要信任外部数据

---

### 注释规范

**核心原则：** 注释解释"为什么"，代码表达"是什么"。

#### JavaScript / TypeScript

**变量与常量 - 单行注释**

```javascript
// 最大重试次数，超过后放弃请求
const MAX_RETRIES = 3;

// 缓存有效期（毫秒），5 分钟
const CACHE_TTL = 5 * 60 * 1000;

const userId = req.params.id; // 从路由参数获取，已由中间件验证
```

**函数与方法 - JSDoc 注释**

```javascript
/**
 * 计算购物车总价，含折扣和税费。
 *
 * @param {CartItem[]} items - 购物车商品列表
 * @param {number} discountRate - 折扣率，0-1 之间（如 0.1 表示 9 折）
 * @param {number} taxRate - 税率，0-1 之间
 * @returns {number} 最终总价（保留两位小数）
 */
function calculateTotal(items, discountRate, taxRate) {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const discounted = subtotal * (1 - discountRate);
  return parseFloat((discounted * (1 + taxRate)).toFixed(2));
}
```

**类 - JSDoc 注释**

```javascript
/**
 * 用户认证服务，处理登录、登出和 token 刷新。
 * 依赖 JWT 策略，token 存储在 HttpOnly Cookie 中。
 */
class AuthService {
  /**
   * @param {UserRepository} userRepo - 用户数据访问层
   * @param {TokenService} tokenService - JWT token 管理服务
   */
  constructor(userRepo, tokenService) {
    this.userRepo = userRepo;
    this.tokenService = tokenService;
  }

  /**
   * 验证用户凭据并返回访问 token。
   *
   * @param {string} email - 用户邮箱
   * @param {string} password - 明文密码（传输层已加密）
   * @returns {Promise<{ accessToken: string, refreshToken: string }>}
   * @throws {UnauthorizedError} 凭据无效时抛出
   */
  async login(email, password) { /* ... */ }
}
```

**复杂逻辑 - 解释性注释**

```javascript
// 使用指数退避避免雪崩效应：1s, 2s, 4s, 8s...
const delay = Math.pow(2, attempt) * 1000;

// 必须先检查 token 过期，再验证签名
// 否则过期的 token 会触发签名验证错误，掩盖真实原因
if (isExpired(token)) throw new TokenExpiredError();
```

#### 注释规范总结

| 场景 | 注释风格 | 说明 |
|------|---------|------|
| 变量、常量 | `//` 单行注释 | 说明用途或非显而易见的值含义 |
| 函数、方法 | JSDoc `/** */` | 必须包含 `@param`、`@returns`，可选 `@throws` |
| 类 | JSDoc `/** */` | 说明职责和关键依赖 |
| 复杂算法/逻辑 | `//` 单行或多行 | 解释"为什么"这样做 |
| TODO/FIXME | `// TODO:` `// FIXME:` | 标注待处理问题，附上原因 |

**不需要注释的情况：**
```javascript
// ❌ 无意义注释（代码已自解释）
const userName = user.name; // 获取用户名

// ✅ 无需注释
const userName = user.name;
```

---

## 通用模式

### Repository Pattern（仓储模式）

**目的：** 在一致的接口后封装数据访问

**核心概念：**
- 定义标准操作：findAll、findById、create、update、delete
- 具体实现处理存储细节（数据库、API、文件等）
- 业务逻辑依赖抽象接口，而非存储机制

---

### API Response Format（API 响应格式）

**标准格式：**

```typescript
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  metadata?: { total: number; page: number; limit: number; };
}
```

---

## 安全指南

### 强制安全检查

**在任何提交前：**

- [ ] 无硬编码密钥（API keys、密码、tokens）
- [ ] 所有用户输入已验证
- [ ] SQL 注入防护（使用参数化查询）
- [ ] XSS 防护（清理 HTML、转义输出）
- [ ] CSRF 保护已启用
- [ ] 认证/授权已验证
- [ ] 所有端点都有速率限制
- [ ] 错误消息不泄露敏感数据

---

### 密钥管理

**核心原则：**
1. 永远不要在源代码中硬编码密钥
2. 始终使用环境变量或密钥管理器
3. 启动时验证必需的密钥存在
4. 轮换任何可能已暴露的密钥

---

### 常见安全漏洞

#### SQL 注入
```javascript
// ❌ 危险
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ 安全
const query = 'SELECT * FROM users WHERE id = ?';
db.execute(query, [userId]);
```

#### XSS
```javascript
// ❌ 危险
element.innerHTML = userInput;

// ✅ 安全
element.textContent = userInput;
```

---

## 代码质量检查清单

**在标记工作完成前：**

### 可读性
- [ ] 代码易读且命名良好
- [ ] 变量名描述性强
- [ ] 函数名清晰表达意图
- [ ] 函数/方法使用 JSDoc 注释（含 @param、@returns）
- [ ] 复杂逻辑有单行注释解释"为什么"
- [ ] 无无意义注释（代码已自解释的不加注释）

### 函数大小
- [ ] 函数小于 50 行
- [ ] 每个函数做一件事

### 文件大小
- [ ] 文件专注于单一职责
- [ ] 文件小于 800 行

### 代码复杂度
- [ ] 无深层嵌套（>4 层）
- [ ] 使用提前返回减少嵌套

### 错误处理
- [ ] 适当的错误处理
- [ ] 无静默失败
- [ ] 用户友好的错误消息

### 配置
- [ ] 无硬编码值
- [ ] 使用常量或配置

### 不可变性
- [ ] 无修改（使用不可变模式）
- [ ] 函数返回新对象

### 安全性
- [ ] 输入验证
- [ ] 无 SQL 注入风险
- [ ] 无 XSS 漏洞
- [ ] 无硬编码密钥

### 测试（视项目情况决定）
- [ ] 有测试需求时：单元测试覆盖核心逻辑
- [ ] 有测试需求时：集成测试覆盖关键路径
- [ ] 有测试需求时：E2E 测试覆盖用户流程

---

## 最佳实践总结

**编码风格：**
1. 不可变性优先 - 创建新对象，不修改现有对象
2. 小文件 - 保持文件在 200-400 行
3. 全面错误处理 - 在每个层级处理错误
4. 输入验证 - 在系统边界验证

**安全保护：**
1. 强制安全检查清单
2. 安全的密钥管理
3. 防护常见漏洞
4. 定期安全审计

**记住：** 安全是基础，质量是保证。

---

## 测试用例

### 测试用例 1：不可变性原则的强制执行（正常场景）

**规则**：编码风格 - 不可变性（CRITICAL）

**输入**：
- 用户消息：`实现购物车添加商品功能`
- 对话上下文：用户编写了以下代码：
  ```javascript
  function addItem(cart, item) {
    cart.items.push(item);
    return cart;
  }
  ```

**期望行为**：
1. **识别不可变性违规**
   - 识别代码使用了 `push()` 修改原对象
   - 这违反了 CRITICAL 级别的不可变性原则
2. **使用 code-reviewer agent**
   - 自动启动 code-reviewer agent
   - 标记为 CRITICAL 问题
3. **要求修改代码**
   - 拒绝接受当前实现
   - 提供正确的不可变实现示例
4. **验证修改**
   - 确认修改后的代码返回新对象
   - 使用扩展运算符或其他不可变方法

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ✅ / ❌ 识别了不可变性违规
- ✅ / ❌ 标记为 CRITICAL 级别问题
- ✅ / ❌ 拒绝了修改原对象的实现
- ✅ / ❌ 提供了正确的不可变实现
- ✅ / ❌ 验证修改后的代码符合不可变性原则

---

### 测试用例 2：提交前安全检查清单执行（边界场景）

**规则**：安全指南 - 强制安全检查

**输入**：
- 用户消息：`代码已完成，准备提交`
- 对话上下文：用户完成了认证功能的开发，代码中包含硬编码的 API key

**期望行为**：
1. **自动执行安全检查**
   - 使用 security-reviewer agent
   - 运行安全扫描命令检查硬编码密钥
2. **发现安全问题**
   - 检测到硬编码的 API key
   - 标记为 CRITICAL 安全问题
3. **阻止提交**
   - 拒绝提交代码
   - 明确说明发现的安全问题
4. **要求修复**
   - 要求移除硬编码密钥
   - 建议使用环境变量
5. **重新验证**
   - 修复后重新运行安全检查
   - 确认所有安全检查项通过

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ✅ / ❌ 自动执行了安全检查清单
- ✅ / ❌ 发现了硬编码密钥
- ✅ / ❌ 阻止了提交
- ✅ / ❌ 要求使用环境变量
- ✅ / ❌ 修复后重新验证

---

### 测试用例 3：SQL 注入漏洞的识别和修复（异常场景）

**规则**：安全指南 - 常见安全漏洞 - SQL 注入

**输入**：
- 用户消息：`实现用户查询功能`
- 对话上下文：用户编写了以下代码：
  ```javascript
  const userId = req.params.id;
  const query = `SELECT * FROM users WHERE id = ${userId}`;
  db.execute(query);
  ```

**期望行为**：
1. **识别 SQL 注入风险**
   - 识别代码使用字符串拼接构建 SQL 查询
   - 这是典型的 SQL 注入漏洞
2. **使用 security-reviewer agent**
   - 自动启动 security-reviewer agent
   - 标记为 CRITICAL 安全问题
3. **阻止代码使用**
   - 拒绝接受当前实现
   - 明确说明 SQL 注入风险
4. **提供安全实现**
   - 要求使用参数化查询
   - 提供正确的实现示例：
     ```javascript
     const query = 'SELECT * FROM users WHERE id = ?';
     db.execute(query, [userId]);
     ```
5. **验证修复**
   - 确认修改后的代码使用参数化查询
   - 重新运行安全检查

**实际行为**：
[待测试]

**状态**：⏳ 待测试

**关键验证点**：
- ✅ / ❌ 识别了 SQL 注入风险
- ✅ / ❌ 标记为 CRITICAL 安全问题
- ✅ / ❌ 阻止了不安全的实现
- ✅ / ❌ 提供了参数化查询的正确实现
- ✅ / ❌ 验证修复后的代码安全
