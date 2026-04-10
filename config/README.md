# 路径配置

## 路径公式

```
{根变量} / {固定变量} / 固定后缀
```

- **根变量**：用户可配置（`project_root`、`personal_root`）
- **固定变量**：不可配置（`features`、`rules`、`standards`）
- **固定后缀**：不可配置（`requirement/`、`dev-design/` 等）

**插件安装时自动创建个人配置目录**（通过 SessionStart hook）。

## 根变量（仅此可配置）

| 根变量 | 默认值 | 配置位置 |
|--------|--------|---------|
| `project_root` | `cc-cache-doc` | `<project>/cc-cache-doc/cc-skills.json` |
| `personal_root` | `~/.cc-cache-doc` | `~/.cc-cache-doc/cc-skills.json` |

## 完整路径解析

### 项目级路径

| 路径 | = 根变量 / 固定变量 / 固定后缀 |
|------|-------------------------------|
| `{project_root}/features/{name}/requirement/` | 需求文档 |
| `{project_root}/features/{name}/dev-design/` | 设计文档 |
| `{project_root}/features/{name}/reviews/` | 审查报告 |
| `{project_root}/features/{name}/user-test/` | 手动测试文档 |
| `{project_root}/features/{name}/unit-test/` | 自动化测试代码 |
| `{project_root}/rules/` | 项目规则 |
| `{project_root}/standards/` | 项目规范 |

### 个人级路径

| 路径 | = 根变量 / 固定变量 |
|------|---------------------|
| `{personal_root}/rules/` | 个人规则 |
| `{personal_root}/standards/` | 个人规范 |

## 目录结构

### 项目级

```
{project_root}/                     ← 根变量（可配置）
├── cc-skills.json                  ← 配置文件
├── features/                       ← 固定变量
│   └── {name}/                     ← 功能名称（用户传入）
│       ├── requirement/            ← 固定后缀
│       ├── dev-design/             ← 固定后缀
│       ├── reviews/                ← 固定后缀
│       ├── user-test/              ← 固定后缀
│       └── unit-test/              ← 固定后缀
├── rules/                          ← 固定变量
└── standards/                      ← 固定变量
```

### 个人级

```
{personal_root}/                    ← 根变量（可配置）
├── cc-skills.json                  ← 配置文件
├── rules/                          ← 固定变量
└── standards/                      ← 固定变量
```

## 配置文件格式

cc-skills.json 只配根变量：

```json
{
  "project_root": "cc-cache-doc",
  "personal_root": "~/.cc-cache-doc"
}
```

改 `project_root` 为 `docs` → 所有路径自动变为 `docs/features/...`、`docs/rules/` 等。

## Skills 中的简写变量

为简化 skill 中的路径引用，定义以下简写：

| 简写 | 实际路径 |
|------|---------|
| `{features}` | `{project_root}/features` |
| `{rules}` | `{project_root}/rules` |
| `{standards}` | `{project_root}/standards` |
| `{personal_rules}` | `{personal_root}/rules` |
| `{personal_standards}` | `{personal_root}/standards` |

## 加载优先级

```
项目配置（最高） > 个人配置（最低）
```

## 自动安装

SessionStart hook 每次会话启动时自动检查并创建：

1. `~/.cc-cache-doc/` 目录
2. `~/.cc-cache-doc/cc-skills.json` 默认配置
3. `~/.cc-cache-doc/rules/` 和 `~/.cc-cache-doc/standards/` 目录

项目级目录由 skill 执行时按需创建。

## 兼容性

`~/.cc-cache-doc/` 独立于 `~/.claude/`、`~/.cursor/` 等 IDE 目录。Claude Code、Cursor、Codex 等所有工具共享同一份配置。
