# ISMS-Web 项目开发规范

> 规则 ID: PROJECT-ISMS-STANDARDS-001
> 版本: 1.0.0
> 创建日期: 2026-03-16
> 状态: 发布

## 代码规范

### 箭头函数使用规范

**规则：** 遵循 ESLint `arrow-body-style` 规则

**简单返回值：**
```typescript
// ✅ 正确 - 简洁的箭头函数体
const double = (x: number) => x * 2;
const getLabel = (item: Item) => item.name;

// ❌ 错误 - 不必要的花括号和 return
const double = (x: number) => {
  return x * 2;
};
```

**复杂逻辑：**
```typescript
// ✅ 正确 - 需要多行逻辑时使用花括号
const processData = (data: Data[]) => {
  const filtered = data.filter(item => item.active);
  const mapped = filtered.map(item => item.value);
  return mapped;
};
```

### 对象解构规范

**必须使用解构的场景：**
```typescript
// ✅ 正确 - 使用解构
const { name, age } = user;
const { data, error } = response;

// ❌ 错误 - 重复访问属性
const name = user.name;
const age = user.age;
```

### 类型定义规范

**接口命名：**
```typescript
// ✅ 正确 - 使用 PascalCase
interface UserInfo { }
interface ApiResponse<T> { }

// ❌ 错误
interface userInfo { }
interface api_response { }
```

**避免 any：**
```typescript
// ✅ 正确 - 使用具体类型
const handleData = (data: UserInfo) => { };

// ❌ 错误 - 使用 any
const handleData = (data: any) => { };
```
