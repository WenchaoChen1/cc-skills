# Git 规范

## 提交消息

```
<type>(<scope>): <subject>

<body>
```

### type

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

### scope 示例

`benchmarkEntry`、`companyFinance`、`settings`、`auth`、`components`、`utils`、`config`

### subject

- 祈使语气、≤72 字符、一个提交一件事
- 首字母小写，不加句号

### body（可选）

- 说明为什么做此更改
- 破坏性变更须加 `BREAKING CHANGE:` 前缀

### 示例

```
feat(benchmarkEntry): add benchmark comparison chart

BREAKING CHANGE: BenchmarkTable props changed from `items` to `data`
```

```
fix(auth): handle token refresh race condition on concurrent 401
```

## 分支

`sprint_2026/sprintXXX/sprintXXX-release`

## 环境

| 环境 | 分支 | CI/CD |
|------|------|-------|
| dev | dev | 手动 |
| test | test | CircleCI |
| uat | uat | CircleCI |
| staging | staging | CircleCI |
| prod | master | CircleCI |
