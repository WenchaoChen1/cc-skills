# Git 工作流

## Commit Message 格式

```
<type>: <description>

<可选的详细说明>
```

### Type 类型

| Type | 用途 |
|------|------|
| feat | 新功能 |
| fix | 修复缺陷 |
| refactor | 重构（不改变行为） |
| docs | 文档变更 |
| test | 测试相关 |
| chore | 构建、配置等杂项 |
| perf | 性能优化 |
| ci | CI/CD 配置 |

### 规则

- description 简明扼要，不超过 70 个字符
- 使用中文或英文均可，同一项目内保持一致
- 不以句号结尾
- 详细说明部分解释"为什么"而非"做了什么"

## 分支策略

| 分支 | 用途 | 说明 |
|------|------|------|
| `main` | 主分支 | 始终保持稳定可发布状态 |
| `feature/*` | 功能开发 | 从 main 创建，完成后合并回 main |
| `fix/*` | 缺陷修复 | 从 main 创建，修复后合并回 main |

- 禁止直接向 main 推送，通过 Pull Request 合并
- 分支名使用 kebab-case，如 `feature/add-session-hook`

## Pull Request 工作流

1. **分析完整 commit 历史**：使用 `git diff main...HEAD` 查看所有变更，而非仅看最新 commit
2. **撰写清晰摘要**：PR 标题不超过 70 字符，正文包含变更概述和影响范围
3. **包含测试计划**：列出需要验证的测试项
4. **推送时使用 `-u` flag**：新分支首次推送时设置 upstream tracking
