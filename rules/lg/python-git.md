# Git 规范

## 提交消息

```
<type>(<scope>): <subject>

<body>
```

| type | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 |
| `refactor` | 重构 |
| `docs` | 文档 |
| `style` | 格式 |
| `test` | 测试 |
| `chore` | 构建/依赖 |
| `perf` | 性能 |
| `ci` | CI/CD |
| `revert` | 回退 |

- subject 祈使语气、首字母小写、不加句号、≤72 字符
- scope 标明范围（`forecast`、`financial`、`mcp`、`lgpi`、`common`）
- body 说明**为什么**，破坏性变更加 `BREAKING CHANGE:`
- 一个提交一件事

示例：`feat(mcp): add financial statements query tool` / `fix(forecast): handle missing data in ETS model`

## 分支

环境名称：`test`、`staging`（无 sprint 命名）

## 环境

| 环境 | 分支 | CI/CD |
|------|------|-------|
| dev | dev | 手动 |
| test | test | CircleCI |
| staging | staging | CircleCI |
| prod | master | CircleCI |
