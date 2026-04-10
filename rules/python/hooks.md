---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python Hooks

> 本文件扩展了 [common/hooks.md](../common/hooks.md)，补充 Python 特定内容。

## PostToolUse Hooks

在 `~/.claude/settings.json` 中配置：

- **black/ruff**：编辑后自动格式化 `.py` 文件
- **mypy/pyright**：编辑 `.py` 文件后运行类型检查

## 警告

- 在编辑的文件中发现 `print()` 语句时发出警告（应使用 `logging` 模块代替）
