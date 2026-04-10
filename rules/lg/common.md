# LG 项目公共规范

> 跨端通用规则，适用于 LG (CIOaaS) 项目所有子项目。

## 项目架构

本仓库是一个 monorepo，包含 5 个子项目：

| 目录 | 技术栈 | 用途 |
|------|--------|------|
| `CIOaas-api/` | Java 17、Spring Boot 3、Spring Cloud | 后端 REST API + API 网关 |
| `CIOaas-web/` | React 16、Ant Design Pro、UmiJS 3、TypeScript | 前端单页应用 |
| `CIOaas-python/` | Python 3.12、FastAPI、FastMCP | 预测/财务 ML API + MCP 服务 |
| `cio-bigdata/` | Python 3.6、ETL / Singer、Airflow | 数据集成（Redshift、QuickBooks 等） |
| `db-optimization/` | SQL | PostgreSQL 数据库优化脚本 |

### db-optimization 说明

`db-optimization/` 无独立 CLAUDE.md，按优先级组织 PostgreSQL 脚本：

- `P0_*` — 关键：敏感数据安全、主键、外键
- `P1_*` — 重要：枚举文档、数值字段单位、字段注释
- `P2_*` — 优化：索引、数据类型修正、约束与默认值
- `P3_*` — 增强：审计字段、大字段优化、命名规范

## 开发环境

### Windows 特定注意事项

- PowerShell 脚本（`.ps1`）必须在 PowerShell 中执行，**不能**在 bash/Git Bash 中运行
- `conda` 命令在 bash 终端中不可用，需使用 Anaconda Prompt 或 PowerShell
- Java/Maven 输出可能出现 GBK 编码乱码，可在 PowerShell 中运行：`chcp 65001` 切换为 UTF-8
- 路径使用正斜杠（`/`）或双反斜杠（`\\`），避免在 bash 环境中混用

## 子项目依赖关系

- `CIOaas-api/`、`CIOaas-web/`、`CIOaas-python/` 为三个主工程，问题涉及任意子项目时须读取对应 CLAUDE.md
- `cio-bigdata/` 为数据集成工程，仅在问题涉及时读取
- `db-optimization/` 为独立 SQL 脚本集，无独立 CLAUDE.md
- 各子项目另有 `standards/` 目录（含 `architecture.md`、`coding.md`、`git.md`），开发前按对应子项目 CLAUDE.md 中的「规范加载」执行

## 规范加载规则

1. 每次问答都必须先根据问题与扫描到的目录，读取并遵循对应子项目的 `CLAUDE.md`
2. 若问题涉及多个子项目，按相关性依次读取
3. 若无法确定涉及哪个子项目，默认先读取三个主工程（`CIOaas-api/`、`CIOaas-web/`、`CIOaas-python/`）的 CLAUDE.md
4. 构建命令、模块结构、网关调试、分支命名等均以各子目录 `CLAUDE.md` 与 `standards/` 为准，不在根目录重复抄写
