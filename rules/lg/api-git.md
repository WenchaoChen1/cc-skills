# Git 规范

## 提交消息

```
<type>(<scope>): <subject>
```

| type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 Bug |
| `refactor` | 重构 |
| `docs` | 文档 |
| `style` | 格式（不影响逻辑） |
| `test` | 测试 |
| `chore` | 构建/依赖/配置 |
| `perf` | 性能优化 |
| `ci` | CI/CD |
| `revert` | 回滚 |

- subject 祈使语气、首字母小写、不加句号、≤72 字符
- scope 标明范围（`fi`、`quickbooks`、`auth`）
- body 说明**为什么**，破坏性变更加 `BREAKING CHANGE:`
- 一个提交一件事

示例：`feat(fi): add benchmark entry CRUD` / `fix(quickbooks): prevent N+1 in getConnections`

## 分支

`sprint/sprintXXX`（如 `sprint/sprint107-airflow`）

## 环境

| 环境 | 分支 | CI/CD |
|------|------|-------|
| dev | dev | 手动 |
| test | test | CircleCI |
| uat | uat | CircleCI |
| staging | staging | CircleCI |
| prod | master | CircleCI |
