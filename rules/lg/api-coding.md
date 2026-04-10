# CIOaas-api 代码规范

## 1. REST API

- 路径全小写 + `-` 分隔，资源名词复数
- 响应：`{ success, code, message, data }`，空列表 `[]` 禁止 `null`，分页含 `totalElements` + `content`
- 业务错误 HTTP 200 + `success: false`，JSON key lowerCamelCase
- Long 用 String 返回，时间 `"yyyy-MM-dd HH:mm:ss"` GMT/UTC

## 2. 三层传输实体

| 实体 | 作用域 | 命名 | 位置 |
|------|--------|------|------|
| Request | 仅 Controller | `XxxCreateRequest`、`XxxUpdateRequest`、`XxxQueryRequest` | `interfaces/vo/request/` |
| Response | 仅 Controller | `XxxResponse`、`XxxDetailResponse` | `interfaces/vo/response/` |
| DTO | 仅 Service | `XxxDTO` | `application/dto/{xxx}/` |
| Feign Request | 仅 Feign | `XxxFeignRequest` | `infrastructure/feign/vo/request/` |
| Feign Response | 仅 Feign | `XxxFeignResponse` | `infrastructure/feign/vo/response/` |

转换链：`Request → DTO → Service → DTO → Response`，Service 不接触 Request/Response。

**Converter**（`interfaces/converter/`）— Request/Response ↔ DTO：

```java
@Mapper(componentModel = "spring",
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface XxxConverter {
    XxxDTO toDTO(XxxCreateRequest request);
    XxxResponse toResponse(XxxDTO dto);
}
```

**Assembler**（`application/assembler/`）— DTO ↔ Entity，审计字段 ignore

## 3. Entity

- 继承审计基类，主键 `String` + `@UuidGenerator`（36 位）
- 表名/字段名 `lower_snake_case`，关联默认 LAZY，禁止 `CascadeType.ALL`
- 软删除 `@SQLRestriction`，必须 `equals()` + `hashCode()`

## 4. Service

- 接口 + Impl 分离，签名只用 DTO
- 类级别 `@Transactional(readOnly = true, rollbackFor = Exception.class)`
- 写方法 `@Transactional(propagation = REQUIRED, rollbackFor = Exception.class)`
- 注入 `@Resource`，循环依赖 `@Lazy`

## 5. Controller

```java
@Tag(name = "Xxx") @RestController @RequestMapping("/xxx")
public class XxxController {
    @Resource private XxxService xxxService;
    @Resource private XxxConverter xxxConverter;

    @PostMapping
    public Result<XxxResponse> create(@RequestBody @Valid XxxCreateRequest request) {
        return Result.success(xxxConverter.toResponse(xxxService.create(xxxConverter.toDTO(request))));
    }
}
```

Controller 不写业务逻辑，参数 `@Valid`，OpenAPI `@Tag` + `@Operation`

## 6. Repository

- domain 层定义接口，infrastructure 层实现
- 继承 `JpaRepository<Entity, String>`，优先方法名查询
- 禁止返回 Map，禁止原生 SQL（除非 JPQL 无法表达）

## 7. 命名与质量

- 数据库 `lower_snake_case`，Boolean 不加 `is` 前缀，禁止保留字
- 禁止双重循环内调 DB/远程，金额用 `BigDecimal`
- 注释说明为什么，禁止废弃代码残留
- 全局异常处理器兜底，禁止吞异常，日志 `log.error("msg", e)`

## 8. 数据库

| 规则 | 说明 |
|------|------|
| 表名 | `lower_snake_case` + 业务域前缀 |
| 主键 | UUID 36 位 `xxx_id` |
| 审计 | `created_at/by`、`updated_at/by` |
| 软删除 | `is_deleted` tinyint |
| 小数 | `decimal` |
| 索引 | `pk_`、`uk_`、`idx_` |

## 9. 安全

- 原生 `@Query` 或 `JdbcTemplate` 必须用绑定参数，禁止 String 拼接 SQL
- Request 字段必须标注 JSR-380 注解（`@NotNull`/`@NotBlank`/`@Size`），不允许裸字段
- 密码、token、API Key 禁止出现在日志和 Response 中，DTO 含密码字段标 `@JsonIgnore`
- `/internal/openfeign/**` 须在 Gateway 限制为内网可达，不能仅靠路径约定
- 已发布接口禁止删除字段或改类型，破坏性变更须新路径 + `BREAKING CHANGE`

## 10. 性能

- 跨多条记录的关联加载必须 `JOIN FETCH` 或 `@EntityGraph`，禁止循环 findById
- 批量写入用 `saveAll()` + `hibernate.jdbc.batch_size`，禁止逐条 save
- 返回集合的接口必须接受 `Pageable`，禁止无界 `List<T>`
- HikariCP 参数（`maximumPoolSize`/`connectionTimeout`）须在 Nacos 显式声明
- 缓存 Key 格式 `{域}:{实体}:{id}`，TTL 在配置中声明

## 11. 日志

- DEBUG：入参出参详情；INFO：关键业务操作；WARN：可恢复异常；ERROR：需介入故障（必须附 Throwable）
- 每条业务日志须含 `traceId`（MDC）、`userId`、`organizationId`
- 禁止 log 直接打印含密码/token 的对象

## 12. 测试

- Controller 用 `@WebMvcTest`，Service 用 `@ExtendWith(MockitoExtension.class)` 全 Mock
- Repository 用 `@DataJpaTest` + H2/Testcontainers，禁止连真实 DB
- 核心业务覆盖率 >= 80%（Jacoco CI 强制）

## 13. 并发

- Service Bean 禁止可变实例字段，请求上下文通过 `SecurityUtils`（ThreadLocal）传递
- `@Async` 必须指定自定义 `ThreadPoolTaskExecutor`，禁止默认 `SimpleAsyncTaskExecutor`
- `@Scheduled` 不含阻塞 I/O，超 500ms 的任务异步化

## 14. 依赖

- 所有版本在根 pom `<dependencyManagement>` 统一声明，子模块禁止写版本号
- 新增依赖须无 CVE（OWASP dependency-check），禁止 `-SNAPSHOT` 上生产
