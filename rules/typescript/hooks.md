---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript Hooks

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 TypeScript/JavaScript 的特定内容。

## PostToolUse Hooks

在 `~/.claude/settings.json` 中配置：

- **Prettier**：编辑后自动格式化 JS/TS 文件
- **TypeScript 检查**：编辑 `.ts`/`.tsx` 文件后运行 `tsc`
- **console.log 警告**：对编辑过的文件中的 `console.log` 发出警告

## Stop Hooks

- **console.log 审查**：在会话结束前检查所有修改过的文件是否包含 `console.log`
