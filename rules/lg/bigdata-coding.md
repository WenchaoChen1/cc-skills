# BigData 端编码规范

> 适用于 `cio-bigdata/` 子项目（Singer / Airflow 数据集成）。

## Python 版本约束

- 使用 **Python 3.6+**（注意：不同于 CIOaas-python 的 3.12）
- 依赖 `pipelinewise-singer-python`，不使用原版 `singer-python`

## Tap 执行模式

### QuickBooks（最复杂的 Tap）

```python
# 入口：tap-quickbooks --datasourceId {uuid}
# 1. 从 PostgreSQL 获取数据源配置
# 2. 从打包的 JSON 加载 Schema（quickbooks_properties.json）
# 3. 创建 QBOData 实例进行 API 调用
# 4. 遍历选中的流，发出 Singer SCHEMA/RECORD/STATE
# 5. 更新 company_quickbooks 表的同步状态
```

### 标准 Tap（GitHub、SonarQube、NewRelic 等）

- 从 datasource 表加载配置
- 定义 `KEY_PROPERTIES` 和 `REQUIRED_CONFIG_KEYS`
- 使用自定义异常实现错误处理
- 使用 `singer.write_schema()`、`singer.write_record()`、`singer.write_state()`
- 使用 Singer Transformer 进行 Schema 校验

### AWS Tap（CloudWatch、AWSCost）

- 使用 `boto3` 调用 AWS API
- 需要 `awsAccessKeyId`、`awsSecretAccessKey`
- 通过 AWS SDK 获取指标/成本数据

## 环境变量管理

### 必需的环境变量（`.env`）

```
REDSHIFT_HOST/PORT/USER/PASSWORD/DATABASE    # 分析数据仓库
PSQL_HOST/PORT/USER/PASSWORD/DATABASE        # PostgreSQL 状态/元数据
QUICKBOOKS_ENVIRONMENT=SANDBOX|PRODUCTION    # QB API 环境
```

### Base 类配置模式（`common/base.py`）

- 配置从环境变量获取
- ThreadedConnectionPool（min=1, max=10）用于 PostgreSQL
- DatabaseConnection 上下文管理器，支持事务
- 方法：`execute_query()`、`execute_sql()`、`executemany()`

## 错误处理

- 认证异常触发令牌刷新（QuickBooks 专用）
- 数据库操作封装在事务中，保证事务完整性
- QuickBooks 同步记录到 `schedule_log` 表
- 连接池复用 PostgreSQL 连接
- Singer Transformer 校验记录是否符合 Schema

## 依赖管理

### 安装依赖

```bash
pip install -r requirements-dev.txt  # 包含本地 common/ 包
# 或
pip install pipelinewise-singer-python psycopg2-binary requests boto3
```

### 测试 Tap

```bash
python -m tap_{name}  # 运行入口点
# 或在 PyCharm 中：Run > Edit Configurations > Python > 设置 .env 文件
```

## 关键文件路径

- PostgreSQL 基础类：`source/common/common/base.py`
- QuickBooks：`source/quickbooks/tap_quickbooks/{main.py,quickbook.py,QBOData.py}`
- GitHub：`source/github/tap_github/__init__.py`
- 依赖文件：`requirements.txt`、`requirements-dev.txt`
- Docker 配置：`Dockerfile`
- 环境变量模板：`.env_example`
