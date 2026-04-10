# Java 后端开发

> 基于设计文档实现 Java 后端代码。适用于 Spring Boot / Spring Cloud / 其他 Java 框架（从 CLAUDE.md 确认）。
> 公共规则见 common.md，本文件仅定义 Java 后端特有的实现流程。
> 工作目录：由 `CLAUDE.md` 中的 Java 后端项目路径决定。

---

## 前置：从 CLAUDE.md 提取项目信息

开始实现前，必须从 `CLAUDE.md` 和现有代码中确认以下信息（**不得使用预设值**）：

| 需确认项 | 获取方式 |
|---------|---------|
| Java 版本 | `CLAUDE.md` 或 `pom.xml` |
| 框架与版本 | `CLAUDE.md` 或 `pom.xml`（Spring Boot/Cloud 等） |
| ORM 框架 | 现有 Entity 文件（JPA/MyBatis/MyBatis-Plus 等） |
| 映射工具 | 现有 Mapper 文件（MapStruct/手动映射/BeanUtils 等） |
| 数据库类型 | `CLAUDE.md` 或 `application.yml` |
| 异常体系 | 现有 Service/Controller（项目自定义异常类名） |
| 统一响应格式 | 现有 Controller 返回类型（`Result<T>` / `ResponseEntity` / 其他） |
| 模块结构 | `CLAUDE.md`（单模块 / 多模块 Maven / Gradle） |
| 包命名约定 | 现有代码的 package 声明 |
| 分层目录 | 现有代码（controller/service/repository/domain/dto/mapper 或其他命名） |

---

## 实现步骤

按设计文档第 4、5 章（接口 + 数据模型）从底层到上层逐一实现。

### 1-A. 数据库 DDL（若有新表）

- 按设计文档第 5 章的表结构建表
- 加字段注释
- 创建必要索引（外键、常用查询字段）
- 文件放在项目约定的 migration/SQL 目录（从 CLAUDE.md 或现有项目中确认位置）

### 1-B. 数据模型层（Entity / Model）

- 位置：参照现有 Entity 所在的包路径
- 每张新表对应一个模型类
- 遵循现有模型文件的注解、命名、继承风格：
  - ORM 注解风格（`@Entity`+`@Table` / MyBatis XML 等）
  - 主键生成策略（参照同模块）
  - 审计字段（`created_at`/`updated_at`）处理方式参照现有代码
  - Lombok 或手写 getter/setter（参照现有代码）

### 1-C. 数据访问层（Repository / DAO / Mapper）

- 位置：参照现有 Repository/DAO 所在包路径
- 继承项目现有的基类或接口
- 按设计文档的查询/排序需求添加自定义方法
- 方法命名和查询方式（JPA 命名查询 / `@Query` / XML Mapper）参照现有代码

### 1-D. 数据传输层（DTO / VO / Contract）

- 位置：参照现有 DTO 所在包路径（可能叫 `dto`/`vo`/`contract`/`request`/`response` 等）
- 响应 DTO：含 `id`、所有业务字段、时间戳
- 新增请求体：必填字段明确标注（参照现有校验注解风格）
- 编辑请求体：字段全部可选（PATCH 语义）

### 1-E. 映射层（若项目有此层）

- 参照现有映射文件的工具和配置风格
- 覆盖：新增转换、编辑转换（partial update）
- 若项目无独立映射层（直接在 Service 中手动转换），跳过此步

### 1-F. 业务逻辑层（Service）

- 接口 + 实现分离（若项目有此惯例），否则直接写实现类
- 写操作加事务（参照现有事务注解方式）
- 校验失败抛项目约定的业务异常
- 分页查询使用项目现有的分页方式
- 参照现有 Service 的日志、校验、异常处理模式

### 1-G. 接口层（Controller / Router）

- 路径与设计文档第 4.1 表**完全一致**
- 使用项目约定的注解
- 每个方法返回项目统一响应格式
- 入参校验方式参照现有 Controller

### 1-H. 自检

完成后逐项确认：
- [ ] 所有接口路径与设计文档第 4.1 表一致
- [ ] 所有 DTO 字段名与设计文档第 5 章一致
- [ ] 必填字段有校验注解
- [ ] 写操作有事务注解
- [ ] Entity 主键、审计字段与现有代码风格一致
- [ ] 无编译/语法错误（包名正确、import 无遗漏）
- [ ] 没有引入不必要的新依赖

---

## 输出格式

```
### Java 后端实现完成 ✓

**新建文件（N 个）：**
- `<项目路径>/.../domain/Xxx.java` — Entity
- `<项目路径>/.../repository/XxxRepository.java` — Repository
- ...（每层各列出）

**修改文件（N 个）：**
- `路径/文件名` — 说明修改内容

**自检结果：**
- ✓ 接口路径与设计文档一致
- ✓ 必填字段校验已实现
- ⚠ [若有需要用户确认的事项]

【数据存档 — 供前端对齐】

▌ 接口清单
- METHOD /api/路径 → Controller类名.方法名 → 已实现 ✅

▌ 关键响应字段（前端 interface 必须与此对齐）
{ "fieldName": "type // 说明" }

▌ 业务规则（前端需体现的规则）
- 规则1: ...
```
