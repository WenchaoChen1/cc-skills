# 规则系统

## 概述

`rules/` 目录下的规则文件定义项目级编码规范。Claude Code 和 Cursor 会在会话启动时自动加载这些规则，确保 AI 辅助编码过程中遵循团队约定的最佳实践。

## 目录结构

```
rules/
├── README.md          # 本说明文件
└── common/            # 语言无关的通用规则
    ├── coding-style.md    # 编码风格
    ├── git-workflow.md    # Git 工作流
    └── security.md        # 安全规范
```

- **common/** — 语言无关的通用规则，适用于所有项目
- 未来可扩展语言特定目录，例如 `typescript/`、`python/`、`go/` 等

## 优先级

规则按以下优先级生效（高优先级覆盖低优先级）：

1. **语言特定规则**（如 `typescript/`）— 最高优先级
2. **通用规则**（`common/`）— 次优先级
3. **默认行为** — AI 模型内置的编码习惯

## 如何添加新规则

1. 确定规则类别：通用规则放入 `common/`，语言特定规则放入对应目录
2. 创建 Markdown 文件，文件名使用 `kebab-case`（如 `error-handling.md`）
3. 文件内容包含：标题、规范说明、示例代码（如适用）、检查清单
4. 在本 README 中更新目录结构说明
