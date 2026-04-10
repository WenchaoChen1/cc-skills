# CIOaas-api 项目架构规范

## 1. DDD 四层目录结构

```
{业务域}/
├── interfaces/                   # 接口层
│   ├── controller/               # 入参和出参只能来自于本级目录层级下的 /vo
│   ├── vo/
│   │   ├── request/              # XxxCreateReqVo、XxxUpdateReqVo、XxxQueryReqVo
│   │   └── response/             # XxxRespVo、XxxDetailRespVo
│   └── converter/                # Request/Response ↔ DTO（MapStruct）
├── application/                  # 应用层
│   ├── service/
│   │   ├── XxxService.java
│   │   └── XxxServiceImpl.java
│   ├── dto/{xxx}/                # Service 层 DTO（XxxDto）
│   └── mapper/                # DTO ↔ Entity（MapStruct）
├── domain/                       # 领域层（零框架依赖）
│   ├── entity/                   # 与表 1:1，不允许其它代码
│   ├── enums/
│   ├── event/
│   ├── service/                  # 领域服务（可选）
│   └── repository/               # Repository 接口实现
├── infrastructure/               # 基础设施层            
│   ├── feign/
│   │   ├── service/              # XxxFeignService / XxxFeignServiceImpl
│   │   └── dto/
│   │       ├── request/          # XxxFeignReqDto
│   │       └── response/         # XxxFeignRespDto
│   ├── converter/                # 手动数据转换
│   ├── generator/                # 自定义 ID 生成
│   └── config/
├── properties/                   # 启动加载变量
└── util/
```

**依赖方向**：`interfaces → application → domain ← infrastructure`，domain 零外部依赖。

## 2. 模块结构

```
gstdev-cioaas-common      ← 安全、JWT、Result<T>、SecurityUtils、基类、注解
gstdev-cioaas-logging      ← Logstash JSON + Sentry
gstdev-cioaas-openfeign    ← Feign 客户端契约
gstdev-cioaas-web          ← 主服务（DI、FI、system、quickbooks、oauth、scheduler、SQS）
gstdev-cioaas-etl          ← ETL（airflow、datasync、query）
gstdev-cioaas-gateway      ← Spring Cloud Gateway 路由
```

依赖：`common ← logging ← openfeign ← web/etl/gateway`
请求链路：`浏览器 → 前端代理 → Gateway:9000 → Web:5213 | ETL:5214`

## 3. 项目特有模式

**审计基类**：所有 Entity 继承 `AbstractCustomEntity`，自动填充 `createdAt/createdBy/updatedAt/updatedBy`（来源 `SecurityUtils`）。Converter/Assembler 映射中 ignore 这四个字段。

**统一响应**：`Result.success(data)` / `Result.fail("message")` / `Result.fail("CODE", "message")`

**异常体系**：`BadRequestException`(400)、`EntityNotFoundException`、`EntityExistException`、`ServiceException`(code)、`DataNotFoundException`。`GlobalExceptionHandler` 统一捕获，Controller 不 try-catch。断言：`ServiceAssert.notNull/isTrue`

**认证**：JWT + OAuth2(`/web/oauth/token`)、`@AnonymousAccess` 免认证、Feign `/internal/openfeign/` 免认证

**缓存**：`TwoLevelCache`（Caffeine L1 + Redis L2）

**查询**：`@Query` 注解支持 EQUAL、INNER_LIKE、IN、BETWEEN

**配置**：Nacos 配置中心（`spring.config.import: nacos:{service-name}.yml`）

**工具类**：`SecurityUtils`(userId/orgId)、`PageResponse`(分页)、Hutool

**外部集成**：AWS S3/SQS/EventBridge、SendGrid、Stripe、QuickBooks、Sentry、Airflow、Redshift

**受保护文件**（skip-worktree）：`gstdev-cioaas-gateway/src/main/resources/bootstrap.yml`、`gstdev-cioaas-web/src/main/resources/bootstrap.yml`
