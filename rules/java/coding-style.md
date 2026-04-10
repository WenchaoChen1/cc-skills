---
paths:
  - "**/*.java"
---
# Java 编码风格

> 本文件扩展了 [common/coding-style.md](../common/coding-style.md)，补充 Java 特有的内容。

## 格式化

- 使用 **google-java-format** 或 **Checkstyle**（Google 或 Sun 风格）进行规范执行
- 每个文件只包含一个公共顶层类型
- 一致的缩进：2 或 4 个空格（与项目标准保持一致）
- 成员排列顺序：常量、字段、构造方法、公共方法、受保护方法、私有方法

## 不可变性

- 值类型优先使用 `record`（Java 16+）
- 默认将字段标记为 `final` —— 仅在确实需要时才使用可变状态
- 公共 API 返回防御性副本：`List.copyOf()`、`Map.copyOf()`、`Set.copyOf()`
- 写时复制：返回新实例而非修改现有实例

```java
// GOOD — immutable value type
public record OrderSummary(Long id, String customerName, BigDecimal total) {}

// GOOD — final fields, no setters
public class Order {
    private final Long id;
    private final List<LineItem> items;

    public List<LineItem> getItems() {
        return List.copyOf(items);
    }
}
```

## 命名

遵循标准 Java 命名规范：
- `PascalCase` 用于类、接口、record、枚举
- `camelCase` 用于方法、字段、参数、局部变量
- `SCREAMING_SNAKE_CASE` 用于 `static final` 常量
- 包名：全部小写，反向域名（`com.example.app.service`）

## 现代 Java 特性

在能提升代码清晰度的地方使用现代语言特性：
- **Records** 用于 DTO 和值类型（Java 16+）
- **Sealed classes** 用于封闭类型层次结构（Java 17+）
- **Pattern matching** 配合 `instanceof` —— 无需显式类型转换（Java 16+）
- **Text blocks** 用于多行字符串 —— SQL、JSON 模板（Java 15+）
- **Switch expressions** 使用箭头语法（Java 14+）
- **Pattern matching in switch** —— 对 sealed 类型进行穷举处理（Java 21+）

```java
// Pattern matching instanceof
if (shape instanceof Circle c) {
    return Math.PI * c.radius() * c.radius();
}

// Sealed type hierarchy
public sealed interface PaymentMethod permits CreditCard, BankTransfer, Wallet {}

// Switch expression
String label = switch (status) {
    case ACTIVE -> "Active";
    case SUSPENDED -> "Suspended";
    case CLOSED -> "Closed";
};
```

## Optional 使用规范

- 对于可能无结果的查找方法，返回 `Optional<T>`
- 使用 `map()`、`flatMap()`、`orElseThrow()` —— 绝不在未调用 `isPresent()` 的情况下调用 `get()`
- 绝不将 `Optional` 用作字段类型或方法参数

```java
// GOOD
return repository.findById(id)
    .map(ResponseDto::from)
    .orElseThrow(() -> new OrderNotFoundException(id));

// BAD — Optional as parameter
public void process(Optional<String> name) {}
```

## 错误处理

- 领域错误优先使用非受检异常
- 创建继承 `RuntimeException` 的领域特定异常类
- 避免宽泛的 `catch (Exception e)`，除非在顶层处理器中
- 异常消息中包含上下文信息

```java
public class OrderNotFoundException extends RuntimeException {
    public OrderNotFoundException(Long id) {
        super("Order not found: id=" + id);
    }
}
```

## Stream 使用规范

- 使用 Stream 进行数据转换；保持管道简短（最多 3-4 个操作）
- 在可读性良好时优先使用方法引用：`.map(Order::getTotal)`
- 避免在 Stream 操作中产生副作用
- 对于复杂逻辑，优先使用循环而非复杂的 Stream 管道

## 参考资料

参见技能：`java-coding-standards` 获取包含示例的完整编码标准。
参见技能：`jpa-patterns` 获取 JPA/Hibernate 实体设计模式。
