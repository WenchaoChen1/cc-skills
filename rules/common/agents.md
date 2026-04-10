# Agent 编排

## 可用 Agent

位于 `~/.claude/agents/`：

| Agent | 用途 | 使用时机 |
|-------|------|----------|
| planner | 实现规划 | 复杂功能、重构 |
| architect | 系统设计 | 架构决策 |
| tdd-guide | 测试驱动开发 | 新功能、修复 bug |
| code-reviewer | 代码审查 | 编写代码之后 |
| security-reviewer | 安全分析 | 提交代码之前 |
| build-error-resolver | 修复构建错误 | 构建失败时 |
| e2e-runner | E2E 测试 | 关键用户流程 |
| refactor-cleaner | 清理无用代码 | 代码维护 |
| doc-updater | 文档更新 | 更新文档时 |
| rust-reviewer | Rust 代码审查 | Rust 项目 |

## 自动调用 Agent

无需用户提示：
1. 复杂功能需求 - 使用 **planner** agent
2. 刚编写/修改的代码 - 使用 **code-reviewer** agent
3. 修复 bug 或新功能 - 使用 **tdd-guide** agent
4. 架构决策 - 使用 **architect** agent

## 并行任务执行

对于独立操作，始终使用并行 Task 执行：

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: Security analysis of auth module
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utilities

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## 多视角分析

对于复杂问题，使用分角色子 agent：
- 事实审查员
- 高级工程师
- 安全专家
- 一致性审查员
- 冗余检查员
