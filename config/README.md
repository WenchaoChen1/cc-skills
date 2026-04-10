# 路径配置

## 路径公式

```
{根变量} / {可配变量} / 固定后缀
```

- **根变量**：可配置（`project_root`、`personal_root`）
- **可配变量**：可配置（`features`、`rules`、`standards`）
- **固定后缀**：不可配置（`requirement/`、`dev-design/`、`reviews/` 等）

**插件安装时自动创建个人配置目录**（通过 SessionStart hook）。

## 可配置变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `project_root` | `cc-cache-doc` | 项目配置根目录 |
| `personal_root` | `~/.cc-cache-doc` | 个人配置根目录 |
| `features` | `features` | 功能目录名 |
| `rules` | `rules` | 规则目录名 |
| `standards` | `standards` | 规范目录名 |

## 完整路径解析

### 项目级

| 路径 | = 根变量 / 可配变量 / 固定后缀 |
|------|-------------------------------|
| `{project_root}/{features}/{name}/requirement/` | 需求文档 |
| `{project_root}/{features}/{name}/dev-design/` | 设计文档 |
| `{project_root}/{features}/{name}/reviews/` | 审查报告 |
| `{project_root}/{features}/{name}/user-test/` | 手动测试文档 |
| `{project_root}/{features}/{name}/unit-test/` | 自动化测试代码 |
| `{project_root}/{rules}/` | 项目规则 |
| `{project_root}/{standards}/` | 项目规范 |

### 个人级

| 路径 | = 根变量 / 可配变量 |
|------|---------------------|
| `{personal_root}/{rules}/` | 个人规则 |
| `{personal_root}/{standards}/` | 个人规范 |

## 目录结构

### 项目级（默认值示例）

```
cc-cache-doc/                       ← project_root
├── cc-skills.json                  ← 配置文件
├── features/                       ← features（可改为 modules 等）
│   └── {name}/
│       ├── requirement/            ← 固定后缀
│       ├── dev-design/             ← 固定后缀
│       ├── reviews/                ← 固定后缀
│       ├── user-test/              ← 固定后缀
│       └── unit-test/              ← 固定后缀
├── rules/                          ← rules（可改名）
└── standards/                      ← standards（可改名）
```

### 个人级（默认值示例）

```
~/.cc-cache-doc/                    ← personal_root
├── cc-skills.json                  ← 配置文件
├── rules/                          ← rules（可改名）
└── standards/                      ← standards（可改名）
```

## 配置文件格式

cc-skills.json 配置所有变量（只写需要改的，其余用默认值）：

```json
{
  "project_root": "cc-cache-doc",
  "personal_root": "~/.cc-cache-doc",
  "features": "features",
  "rules": "rules",
  "standards": "standards"
}
```

### 自定义示例

把功能目录改为 `modules`，规则改为 `coding-rules`：

```json
{
  "project_root": "docs",
  "features": "modules",
  "rules": "coding-rules"
}
```

路径变为：`docs/modules/{name}/requirement/`、`docs/coding-rules/`

## Skills 中的简写

| 简写 | 实际路径 |
|------|---------|
| `{features}` | `{project_root}/{features}` |
| `{rules}` | `{project_root}/{rules}` |
| `{standards}` | `{project_root}/{standards}` |
| `{personal_rules}` | `{personal_root}/{rules}` |
| `{personal_standards}` | `{personal_root}/{standards}` |

## 加载优先级

```
项目配置（最高） > 个人配置（最低）
```

## 自动安装

SessionStart hook 每次会话启动时自动检查并创建：

1. `~/.cc-cache-doc/` 目录
2. `~/.cc-cache-doc/cc-skills.json` 默认配置（含全部 5 个变量）
3. `~/.cc-cache-doc/rules/` 和 `~/.cc-cache-doc/standards/` 目录

项目级目录由 skill 执行时按需创建。

## 兼容性

`~/.cc-cache-doc/` 独立于 `~/.claude/`、`~/.cursor/` 等 IDE 目录。Claude Code、Cursor、Codex 等所有工具共享同一份配置。
