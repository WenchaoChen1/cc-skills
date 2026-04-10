# Python 后端开发

> 基于设计文档实现 Python 后端代码。适用于 FastAPI / Flask / Django / 其他 Python 框架（从 CLAUDE.md 确认）。
> 公共规则见 common.md，本文件仅定义 Python 后端特有的实现流程。
> 工作目录：由 `CLAUDE.md` 中的 Python 后端项目路径决定。

---

## 前置：从 CLAUDE.md 和现有代码提取项目信息

开始实现前，必须确认以下信息（**不得使用预设值**）：

| 需确认项 | 获取方式 |
|---------|---------|
| Python 版本 | `CLAUDE.md` 或 `pyproject.toml` / `setup.py` |
| Web 框架 | 现有代码（FastAPI / Flask / Django 等） |
| 数据验证 | 现有 Schema/Model（Pydantic v1/v2 / Marshmallow / Django Form 等） |
| 数据库访问 | 现有代码（SQLAlchemy / 原生 SQL / Django ORM 等） |
| 项目入口文件 | `CLAUDE.md` 或目录结构（`main.py` / `app.py` / `manage.py` 等） |
| 模块组织方式 | 现有目录结构（按功能分包 / 按层分包） |
| 异常处理方式 | 现有代码（HTTPException / 自定义异常类） |
| 路由注册方式 | 现有代码（`include_router` / `url_patterns` / Blueprint 等） |
| 依赖管理 | `requirements.txt` / `pyproject.toml` / `Pipfile` |

---

## 实现步骤

按设计文档从底层到上层逐一实现。具体层名和文件组织方式以项目实际结构为准。

### 1-A. 数据模型层（若需要 ORM）

- 位置：参照现有模块的 model 文件路径
- 若项目使用 ORM → 定义 ORM 模型
- 若项目直接写 SQL → 跳过此步，在 Service 中直接操作
- 参照现有模块的数据库访问方式（**先读，不假设**）

### 1-B. 数据验证层（Schema / Serializer）

- 位置：参照现有模块的 schema/serializer 文件路径
- 使用项目现有的验证框架和基类
- 请求 Schema：必填字段无默认值，选填字段可选
- 响应 Schema：支持从 ORM 模型转换（若有此需要）
- 命名方式参照现有代码

### 1-C. 业务逻辑层（Service）

- 位置：参照现有模块的 service 文件路径
- 封装业务逻辑，接口层只做参数转发和响应格式化
- 数据库操作方式参照同模块现有代码
- 异常处理方式参照现有代码

### 1-D. 接口层（Router / View）

- 位置：参照现有模块的 router/view 文件路径
- 路径与设计文档第 4.1 表**完全一致**
- 使用项目现有的路由装饰器和响应模型方式
- 参数验证方式参照现有代码

### 1-E. 注册路由

- 在项目入口文件中注册新模块的路由
- 参照现有路由的注册方式和顺序

### 1-F. 自检

完成后逐项确认：
- [ ] 所有接口路径与设计文档第 4.1 表一致
- [ ] Schema 字段名与设计文档第 5 章一致
- [ ] 必填字段有验证
- [ ] 异常处理方式与现有代码一致
- [ ] 路由已在入口文件注册
- [ ] 无语法错误（import 路径正确）
- [ ] 新环境变量已有文档说明或默认值

---

## 输出格式

```
### Python 后端实现完成 ✓

**新建文件（N 个）：**
- `<项目路径>/<module>/schema.py` — 数据验证模型
- `<项目路径>/<module>/service.py` — 业务逻辑
- `<项目路径>/<module>/router.py` — 接口路由

**修改文件（N 个）：**
- `<项目路径>/main.py` — 注册新路由

**自检结果：**
- ✓ 接口路径与设计文档一致
- ✓ 数据验证已实现
- ⚠ [若有需要用户确认的事项]

【数据存档 — 供前端对齐】

▌ 接口清单
- METHOD /api/路径 → 函数名 → 已实现 ✅

▌ 关键响应字段
{ "fieldName": "type // 说明" }
```

---

## Python 代码风格

> 以下为通用 Python 规范。若项目有自己的代码风格配置（如 `pyproject.toml` 中的 ruff/black 配置），以项目配置为准。

- 类型注解：所有函数参数和返回值使用类型注解
- 异步：若项目使用异步框架，优先 `async def`
- 命名：模块/变量 `snake_case`，类 `PascalCase`
- import 顺序：标准库 → 第三方库 → 项目内部
- 不使用 `print()`，使用项目现有的日志方式
