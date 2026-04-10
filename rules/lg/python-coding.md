# CIOaas-python 代码规范

## 1. REST API

- 响应：`{ success, code, message, data }`，空列表 `[]`，Long 用 String
- JSON key lowerCamelCase，时间 `"yyyy-MM-dd HH:mm:ss"`（UTC 时区）

## 2. 三层传输实体（Pydantic）

| 实体 | 位置 | 作用域 |
|------|------|--------|
| Request | `dto/request.py` | 仅路由层 |
| Response | `dto/response.py` | 仅路由层 |
| DTO | `dto/dto.py` | 仅 Service |

- 必填 `...`，可选 `Optional[X] = None`，字段有 `description`
- `@model_validator` 处理复杂校验，路由指定 `response_model`

## 3. 路由层

```python
@router.post("", response_model=XxxResponse)
async def create(request: XxxCreateRequest):
    dto = XxxDTO(**request.model_dump())
    result = await xxx_service.create(dto)
    return XxxResponse(**result.model_dump())
```

所有路由 `async def`，后台任务 `BackgroundTasks`

## 4. 服务层

签名只用 DTO，构造函数注入，全局对象用单例 `get_xxx()`

## 5. 错误处理

路由 `HTTPException`，服务 `ValueError`/`RuntimeError`，日志 `logger.error(msg, exc_info=True)`

## 6. 命名与质量

- 禁止双重循环调 DB，金额用 `Decimal`
- 注释说明为什么，禁止废弃代码
- 配置通过 `.env` + 环境变量，不硬编码

## 7. 环境变量

| 变量 | 用途 |
|------|------|
| `OPENAI_API_KEY` | GPT-4o |
| `LGPI_BEARER_TOKEN` | LGPI API |
| `ENABLE_NEWRELIC` / `ENABLE_SENTRY` | 监控 |
| `PSQL_*` / `REDSHIFT_*` | 数据库 |

## 8. 日志

- logger 名 `CIOaaS.{模块名}`，Windows 用 `SafeTimedRotatingFileHandler`
- 禁止日志输出密码/token/PII，第三方异常只写日志不透传到响应体

## 9. 安全

- MCP `file_path` 须 `Path.resolve()` + 目录白名单，拒绝含 `..` 的路径
- MCP `file_url` 须域名白名单，禁止访问内网 IP（10.x/172.16.x/192.168.x/127.x）
- `file_content_base64` 解码后校验文件头 magic bytes，只允许 PDF/xlsx/xls/图片，限 20MB
- `/mcp` 端点须 Bearer Token 验证（`MCP_ACCESS_TOKEN`），生产禁止无鉴权暴露
- 第三方异常对外只返回通用错误码，原始异常仅写日志

## 10. 性能

- 数据库连接池显式设置 `pool_size`/`max_overflow`/`pool_pre_ping`，禁止每次新建连接
- AI API 调用必须设 `timeout`（60s）+ 指数退避重试（最多 3 次），慢调用 >10s 记日志
- `pd.read_excel` 前检查文件大小，超 50MB 拒绝处理

## 11. 测试

- 使用 `pytest` + `pytest-asyncio`，测试目录 `tests/` 与 `source/` 并列
- 覆盖率 >= 80%（`pytest --cov`），AI 组件调用必须 mock
- MCP 工具须独立单元测试，覆盖参数边界和错误路径

## 12. 类型注解

- 公开函数必须有完整参数和返回值类型注解，禁止裸 `Any`
- 使用 `from __future__ import annotations`

## 13. 依赖

- `requirements.txt` 用 `==` 精确锁定版本，CI 运行 `pip audit` 阻断 HIGH/CRITICAL CVE

## 14. MCP 审计

- 每次 `@mcp.tool()` 调用记录结构化日志（tool_name、参数摘要、耗时、success/fail）
- 敏感参数须脱敏

## 15. AI Prompt 管理

- Prompt 模板存放 `source/financial/prompts/` 独立文件，禁止内联 Python 字符串
- 每个 prompt 文件含版本字段（`# version: x.x`），纳入 Git
- Prompt 变更须附回归测试（固定输入 → 验证输出结构）
