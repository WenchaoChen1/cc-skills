# 规则系统

## 概述

`rules/` 目录下的规则文件定义项目级编码规范。Claude Code 和 Cursor 会在会话启动时自动加载这些规则，确保 AI 辅助编码过程中遵循团队约定的最佳实践。

## 目录结构

```
rules/
├── README.md              # 本说明文件
├── common/                # 语言无关的通用规则
│   ├── coding-style.md        # 编码风格
│   ├── git-workflow.md        # Git 工作流
│   └── security.md            # 安全规范
└── lg/                    # LG (CIOaaS) 项目特定规则
    ├── README.md              # LG 规则说明
    ├── api-architecture.md    # API（Java）架构规范
    ├── api-coding.md          # API（Java）代码规范
    ├── api-git.md             # API Git 规范
    ├── web-architecture.md    # Web（React）架构规范
    ├── web-coding.md          # Web（React）代码规范
    ├── web-git.md             # Web Git 规范
    ├── python-architecture.md # Python 架构规范
    ├── python-coding.md       # Python 代码规范
    ├── python-git.md          # Python Git 规范
    └── mcp-tools.md           # MCP 工具使用规则
```

- **common/** — 语言无关的通用规则，适用于所有项目
- **lg/** — LG (CIOaaS) 项目特定规则，包含 API（Java）、Web（React）、Python 三个子项目的架构、编码、Git 规范及 MCP 工具使用规则
- 未来可扩展语言特定目录，例如 `typescript/`、`python/`、`go/` 等

## 优先级

规则按以下优先级生效（高优先级覆盖低优先级）：

1. **项目特定规则**（如 `lg/`）— 最高优先级
2. **语言特定规则**（如 `typescript/`）— 次高优先级
3. **通用规则**（`common/`）— 次优先级
4. **默认行为** — AI 模型内置的编码习惯

## 如何添加新规则

1. 确定规则类别：通用规则放入 `common/`，语言特定规则放入对应目录
2. 创建 Markdown 文件，文件名使用 `kebab-case`（如 `error-handling.md`）
3. 文件内容包含：标题、规范说明、示例代码（如适用）、检查清单
4. 在本 README 中更新目录结构说明
