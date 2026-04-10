# BigData 端架构规范

> 适用于 `cio-bigdata/` 子项目（Singer / Airflow 数据集成）。

## 项目概述

多数据源抽取与转换流水线，基于 Singer.io 协议（Tap/Target 架构）。使用 Apache Airflow 编排，从多个企业系统抽取数据，加载到 PostgreSQL（状态追踪）和 Amazon Redshift（分析）。

## 技术栈

- **Python 3.6+** + pipelinewise-singer-python
- **PostgreSQL**：元数据、数据源配置、状态追踪
- **Amazon Redshift**：数据仓库（通过 pipelinewise-target-redshift）
- **Apache Airflow 2.1.0**：DAG 编排
- **Docker**：容器化部署

## Singer 协议模式

### Tap（数据源）

- 从外部系统抽取数据，发出 Singer 消息（SCHEMA、RECORD、STATE）
- 每个 Tap 对应一个数据源
- 使用 `singer.write_schema()`、`singer.write_record()`、`singer.write_state()` 输出

### Target（数据目标）

- 接收 Tap 的 Singer 消息并写入目标存储
- 项目使用 `pipelinewise-target-redshift` 写入 Redshift

### 公共基础类

- `source/common/common/base.py`：集中式 PostgreSQL 连接池，用于状态和配置管理
- ThreadedConnectionPool（min=1, max=10）
- DatabaseConnection 上下文管理器，支持事务
- 方法：`execute_query()`、`execute_sql()`、`executemany()`

## 项目结构

```
source/
├── common/              # 所有 Tap 的基础类
│   └── common/base.py   # PostgreSQL 连接池、配置管理
├── quickbooks/          # QuickBooks Online API
│   ├── main.py         # 入口，接受 --datasourceId 参数
│   ├── quickbook.py    # 同步编排、状态管理
│   └── QBOData.py      # API 调用、数据转换
├── github/             # GitHub 仓库指标
├── sonarqube/          # 代码质量分析
├── newrelic/           # APM 性能指标
├── cloudwatch/         # AWS CloudWatch 指标
├── awscost/            # AWS 成本追踪（使用 boto3）
├── circleci/           # CI/CD 流水线指标
├── intruder/           # 安全漏洞扫描
├── etlscore/          # 自定义 ETL 评分
└── ai/                 # HTTP 服务（端口 5004）
```

## 配置文件规范

每个 Tap 包含以下配置文件：

- `setup.py`：入口点定义（`tap-{name}=module:main`）、依赖声明
- `config.json`：配置模板
- `properties.json`：流 Schema 定义，含 KEY_PROPERTIES
- `schemas/*.json`：各个流的独立 Schema

入口点示例：

```python
"console_scripts": ["tap-quickbooks=tap_quickbooks.main:main"]
```

## 状态管理

- **Bookmarks**：按流追踪上次同步时间（存储在 Singer STATE 中）
- **批次处理**：QuickBooks 使用 batch_id 追踪关联记录
- **流选择**：元数据驱动（Schema 或 mdata 中 `selected=true`）

### 同步工作流

1. 从 PostgreSQL 读取数据源配置
2. 从文件/数据库加载上次 STATE
3. 同步选中的流，发出 RECORD 消息
4. 用新 Bookmark 更新 STATE
5. 写出最终 STATE（`singer.write_state()`）

## 部署

### Docker 构建

```dockerfile
FROM apache/airflow:2.1.0
# 安装所有 Tap：common, github, circleci, sonarqube, intruder, newrelic, cloudwatch, awscost, etlscore, quickbooks
RUN cd /source/{module} && python setup.py install
```

### 运行 Tap

```bash
# QuickBooks 专用格式
tap-quickbooks --datasourceId {uuid}

# 标准 Tap（通过 JSON 配置）
tap-github | target-redshift
```

## 添加新 Tap

1. 创建 `source/{name}/tap_{name}/` 目录
2. 使用 Base 类实现 `main()` 和同步逻辑
3. 添加 `setup.py`，定义 `console_scripts` 入口点
4. 添加到 Dockerfile 的 RUN 命令
5. 在 `schemas/` 下创建 Schema JSON 文件
