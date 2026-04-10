# CIOaas-python 项目架构规范

## 1. 目录结构

```
source/
├── main.py                         # FastAPI 入口、路由挂载、MCP 集成
├── {模块}/
│   ├── __init__.py
│   ├── routes.py                   # 路由层 — 接收 Request，返回 Response
│   ├── dto/
│   │   ├── request.py              # XxxCreateRequest（仅路由层）
│   │   ├── response.py             # XxxResponse（仅路由层）
│   │   └── dto.py                  # XxxDTO（Service 层间传输）
│   └── xxx_service.py              # 服务层 — 签名只用 DTO
├── forecast/                       # 时间序列预测（ETS/ARIMA/Momentum + 蒙特卡洛）
├── financial/                      # AI 财务报表处理
├── lgpi/                           # LGPI Admin API 客户端
├── cioaas_mcp/                     # MCP 工具（FastMCP，挂载 /mcp）
├── lg/                             # 文件上传 + 异步处理
└── common/                         # 日志、数据库连接
```

## 2. 分层数据流

```
路由层(Request/Response) → DTO 转换 → Service(操作 DTO) → 返回 DTO → 路由转 Response
```

路由层：`Request → DTO → Service → DTO → Response`，Service 不接触 Request/Response

## 3. 项目特有模式

**MCP**：`@mcp.tool()` → `execute_tool()` → 服务层。返回 `str`(JSON)，不抛异常，错误用 `{"success": false}`

**AI 组件**：`LangChainService`(GPT-4o)、`StatementClassifier`、`MetricsExtractor`、`FieldMapper`

**异步**：`POST /lg/upload` → `BackgroundTasks` → `GET /lg/task/{id}/status|result`

**LGPI 客户端**：`get_lgpi_client()` 单例

**数据库**：PostgreSQL（主库）+ Redshift（分析）
