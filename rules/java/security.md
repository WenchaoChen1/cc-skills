---
paths:
  - "**/*.java"
---
# Java 安全规范

> 本文件扩展了 [common/security.md](../common/security.md)，补充 Java 特有的内容。

## 密钥管理

- 绝不在源代码中硬编码 API 密钥、令牌或凭证
- 使用环境变量：`System.getenv("API_KEY")`
- 生产环境使用密钥管理器（Vault、AWS Secrets Manager）
- 将包含密钥的本地配置文件加入 `.gitignore`

```java
// BAD
private static final String API_KEY = "sk-abc123...";

// GOOD — environment variable
String apiKey = System.getenv("PAYMENT_API_KEY");
Objects.requireNonNull(apiKey, "PAYMENT_API_KEY must be set");
```

## SQL 注入防护

- 始终使用参数化查询 —— 绝不将用户输入拼接到 SQL 中
- 使用 `PreparedStatement` 或框架提供的参数化查询 API
- 对原生查询中使用的任何输入进行验证和清洗

```java
// BAD — SQL injection via string concatenation
Statement stmt = conn.createStatement();
String sql = "SELECT * FROM orders WHERE name = '" + name + "'";
stmt.executeQuery(sql);

// GOOD — PreparedStatement with parameterized query
PreparedStatement ps = conn.prepareStatement("SELECT * FROM orders WHERE name = ?");
ps.setString(1, name);

// GOOD — JDBC template
jdbcTemplate.query("SELECT * FROM orders WHERE name = ?", mapper, name);
```

## 输入验证

- 在系统边界处理之前验证所有用户输入
- 使用验证框架时，在 DTO 上使用 Bean Validation（`@NotNull`、`@NotBlank`、`@Size`）
- 在使用前清洗文件路径和用户提供的字符串
- 对验证失败的输入返回明确的错误消息

```java
// Validate manually in plain Java
public Order createOrder(String customerName, BigDecimal amount) {
    if (customerName == null || customerName.isBlank()) {
        throw new IllegalArgumentException("Customer name is required");
    }
    if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
        throw new IllegalArgumentException("Amount must be positive");
    }
    return new Order(customerName, amount);
}
```

## 认证与授权

- 绝不自行实现加密算法 —— 使用成熟的库
- 使用 bcrypt 或 Argon2 存储密码，绝不使用 MD5/SHA1
- 在 Service 边界强制执行授权检查
- 从日志中清除敏感数据 —— 绝不记录密码、令牌或个人身份信息

## 依赖安全

- 运行 `mvn dependency:tree` 或 `./gradlew dependencies` 审计传递性依赖
- 使用 OWASP Dependency-Check 或 Snyk 扫描已知 CVE
- 保持依赖更新 —— 配置 Dependabot 或 Renovate

## 错误消息

- 绝不在 API 响应中暴露堆栈跟踪、内部路径或 SQL 错误
- 在处理器边界将异常映射为安全、通用的客户端消息
- 在服务端记录详细错误；向客户端返回通用消息

```java
// Log the detail, return a generic message
try {
    return orderService.findById(id);
} catch (OrderNotFoundException ex) {
    log.warn("Order not found: id={}", id);
    return ApiResponse.error("Resource not found");  // generic, no internals
} catch (Exception ex) {
    log.error("Unexpected error processing order id={}", id, ex);
    return ApiResponse.error("Internal server error");  // never expose ex.getMessage()
}
```

## 参考资料

参见技能：`springboot-security` 获取 Spring Security 认证和授权模式。
参见技能：`security-review` 获取通用安全检查清单。
