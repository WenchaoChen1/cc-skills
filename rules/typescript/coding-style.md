---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 TypeScript/JavaScript 的特定内容。

## 类型与接口

使用类型使公共 API、共享模型和组件 props 更加明确、可读和可复用。

### 公共 API

- 为导出函数、共享工具函数和公共类方法添加参数类型和返回类型
- 让 TypeScript 自动推断显而易见的局部变量类型
- 将重复出现的内联对象结构提取为命名类型或接口

```typescript
// WRONG: Exported function without explicit types
export function formatUser(user) {
  return `${user.firstName} ${user.lastName}`
}

// CORRECT: Explicit types on public APIs
interface User {
  firstName: string
  lastName: string
}

export function formatUser(user: User): string {
  return `${user.firstName} ${user.lastName}`
}
```

### 接口 vs. 类型别名

- 使用 `interface` 定义可能被扩展或实现的对象结构
- 使用 `type` 定义联合类型、交叉类型、元组、映射类型和工具类型
- 优先使用字符串字面量联合类型而非 `enum`，除非 `enum` 是互操作性所必需的

```typescript
interface User {
  id: string
  email: string
}

type UserRole = 'admin' | 'member'
type UserWithRole = User & {
  role: UserRole
}
```

### 避免使用 `any`

- 在应用代码中避免使用 `any`
- 对外部或不可信输入使用 `unknown`，然后安全地进行类型收窄
- 当值的类型取决于调用方时，使用泛型

```typescript
// WRONG: any removes type safety
function getErrorMessage(error: any) {
  return error.message
}

// CORRECT: unknown forces safe narrowing
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }

  return 'Unexpected error'
}
```

### React Props

- 使用命名的 `interface` 或 `type` 定义组件 props
- 显式声明回调 props 的类型
- 除非有特定原因，否则不要使用 `React.FC`

```typescript
interface User {
  id: string
  email: string
}

interface UserCardProps {
  user: User
  onSelect: (id: string) => void
}

function UserCard({ user, onSelect }: UserCardProps) {
  return <button onClick={() => onSelect(user.id)}>{user.email}</button>
}
```

### JavaScript 文件

- 在 `.js` 和 `.jsx` 文件中，当类型能提升代码清晰度且不适合迁移到 TypeScript 时，使用 JSDoc
- 保持 JSDoc 与运行时行为一致

```javascript
/**
 * @param {{ firstName: string, lastName: string }} user
 * @returns {string}
 */
export function formatUser(user) {
  return `${user.firstName} ${user.lastName}`
}
```

## 不可变性

使用展开运算符进行不可变更新：

```typescript
interface User {
  id: string
  name: string
}

// WRONG: Mutation
function updateUser(user: User, name: string): User {
  user.name = name // MUTATION!
  return user
}

// CORRECT: Immutability
function updateUser(user: Readonly<User>, name: string): User {
  return {
    ...user,
    name
  }
}
```

## 错误处理

使用 async/await 配合 try-catch，并安全地收窄 unknown 类型的错误：

```typescript
interface User {
  id: string
  email: string
}

declare function riskyOperation(userId: string): Promise<User>

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }

  return 'Unexpected error'
}

const logger = {
  error: (message: string, error: unknown) => {
    // Replace with your production logger (for example, pino or winston).
  }
}

async function loadUser(userId: string): Promise<User> {
  try {
    const result = await riskyOperation(userId)
    return result
  } catch (error: unknown) {
    logger.error('Operation failed', error)
    throw new Error(getErrorMessage(error))
  }
}
```

## 输入校验

使用 Zod 进行基于 schema 的校验，并从 schema 推断类型：

```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

type UserInput = z.infer<typeof userSchema>

const validated: UserInput = userSchema.parse(input)
```

## Console.log

- 生产代码中不允许出现 `console.log` 语句
- 使用专业的日志库代替
- 参见 hooks 中的自动检测机制
