# LG 项目规则

LG (CIOaaS) 项目特定的编码规范和架构规则。

## 文件说明

### 公共规则（跨端通用）
- `common.md` — 项目架构、开发环境、子项目依赖关系

### API 端（Java / Spring Boot）
- `api-architecture.md` — DDD 四层架构、模块结构
- `api-coding.md` — REST API、Entity、Service、安全
- `api-git.md` — 提交格式、分支命名

### Web 端（React / TypeScript）
- `web-architecture.md` — 目录结构、数据流、状态管理
- `web-coding.md` — 组件、样式、国际化
- `web-git.md` — 提交格式、分支命名

### Python 端（FastAPI / MCP）
- `python-architecture.md` — 分层架构、MCP 架构
- `python-coding.md` — 路由、服务、类型注解
- `python-git.md` — 提交格式、分支命名

### BigData 端（Singer / Airflow）
- `bigdata-architecture.md` — Singer 协议、Tap/Target 模式
- `bigdata-coding.md` — 编码规范、配置文件

### MCP 工具
- `mcp-tools.md` — Excel 处理和财务报表查询的 MCP 规则

## 使用方式

将此目录复制到目标项目的 `.claude/rules/lg/` 即可生效：
```bash
cp -r rules/lg ~/.claude/rules/lg
```
