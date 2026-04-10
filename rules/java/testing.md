---
paths:
  - "**/*.java"
---
# Java 测试规范

> 本文件扩展了 [common/testing.md](../common/testing.md)，补充 Java 特有的内容。

## 测试框架

- **JUnit 5**（`@Test`、`@ParameterizedTest`、`@Nested`、`@DisplayName`）
- **AssertJ** 用于流式断言（`assertThat(result).isEqualTo(expected)`）
- **Mockito** 用于模拟依赖
- **Testcontainers** 用于需要数据库或服务的集成测试

## 测试组织结构

```
src/test/java/com/example/app/
  service/           # Service 层单元测试
  controller/        # Web 层 / API 测试
  repository/        # 数据访问层测试
  integration/       # 跨层集成测试
```

在 `src/test/java` 中镜像 `src/main/java` 的包结构。

## 单元测试模式

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    private OrderService orderService;

    @BeforeEach
    void setUp() {
        orderService = new OrderService(orderRepository);
    }

    @Test
    @DisplayName("findById returns order when exists")
    void findById_existingOrder_returnsOrder() {
        var order = new Order(1L, "Alice", BigDecimal.TEN);
        when(orderRepository.findById(1L)).thenReturn(Optional.of(order));

        var result = orderService.findById(1L);

        assertThat(result.customerName()).isEqualTo("Alice");
        verify(orderRepository).findById(1L);
    }

    @Test
    @DisplayName("findById throws when order not found")
    void findById_missingOrder_throws() {
        when(orderRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> orderService.findById(99L))
            .isInstanceOf(OrderNotFoundException.class)
            .hasMessageContaining("99");
    }
}
```

## 参数化测试

```java
@ParameterizedTest
@CsvSource({
    "100.00, 10, 90.00",
    "50.00, 0, 50.00",
    "200.00, 25, 150.00"
})
@DisplayName("discount applied correctly")
void applyDiscount(BigDecimal price, int pct, BigDecimal expected) {
    assertThat(PricingUtils.discount(price, pct)).isEqualByComparingTo(expected);
}
```

## 集成测试

使用 Testcontainers 进行真实数据库集成测试：

```java
@Testcontainers
class OrderRepositoryIT {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    private OrderRepository repository;

    @BeforeEach
    void setUp() {
        var dataSource = new PGSimpleDataSource();
        dataSource.setUrl(postgres.getJdbcUrl());
        dataSource.setUser(postgres.getUsername());
        dataSource.setPassword(postgres.getPassword());
        repository = new JdbcOrderRepository(dataSource);
    }

    @Test
    void save_and_findById() {
        var saved = repository.save(new Order(null, "Bob", BigDecimal.ONE));
        var found = repository.findById(saved.getId());
        assertThat(found).isPresent();
    }
}
```

关于 Spring Boot 集成测试，参见技能：`springboot-tdd`。

## 测试命名

使用描述性名称并配合 `@DisplayName`：
- `methodName_scenario_expectedBehavior()` 作为方法名格式
- `@DisplayName("人类可读的描述")` 用于测试报告

## 覆盖率

- 目标行覆盖率 80% 以上
- 使用 JaCoCo 进行覆盖率报告
- 重点覆盖 Service 和领域逻辑 —— 跳过简单的 getter/配置类

## 参考资料

参见技能：`springboot-tdd` 获取使用 MockMvc 和 Testcontainers 的 Spring Boot TDD 模式。
参见技能：`java-coding-standards` 获取测试相关要求。
