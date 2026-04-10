# 路径配置

路径公式：`{基础路径} / {根变量} / {可配变量} / {name} / 固定后缀`

| 层 | 可为空 | 说明 |
|----|--------|------|
| 基础路径 | 不可 | `<project>`（当前工作目录）或 `~`（用户 home），自动获取 |
| 根变量 | ✅ | `project_root` / `personal_root` |
| 可配变量 | ✅ | `features` / `rules` / `standards` |
| {name} | - | 功能名称，用户传入 |
| 固定后缀 | 必填 | `requirement/`、`dev-design/` 等 |

## 变量

| 变量 | 默认值 | 可为空 |
|------|--------|--------|
| `project_root` | `cc-cache-doc` | ✅ |
| `personal_root` | `.cc-cache-doc` | ✅ |
| `features` | `features` | ✅ |
| `rules` | `rules` | ✅ |
| `standards` | `standards` | ✅ |

## 固定后缀（必填，不可配置）

`requirement/`、`dev-design/`、`reviews/`、`user-test/`、`unit-test/`

## 路径示例

| 场景 | 路径 |
|------|------|
| 全部配置 | `<project>/cc-cache-doc/features/dashboard/requirement/` |
| project_root 为空 | `<project>/features/dashboard/requirement/` |
| features 为空 | `<project>/cc-cache-doc/dashboard/requirement/` |
| 个人规则 | `~/.cc-cache-doc/rules/` |
| personal_root 为空 | `~/rules/` |

## 配置文件

项目级：`<project>/{project_root}/cc-skills.json`
个人级：`~/{personal_root}/cc-skills.json`

```json
{
  "project_root": "cc-cache-doc",
  "personal_root": ".cc-cache-doc",
  "features": "features",
  "rules": "rules",
  "standards": "standards"
}
```

只写需要改的字段。项目配置优先于个人配置。

## 自动安装

SessionStart hook 自动创建 `~/{personal_root}/` 目录和默认配置。

## 兼容性

个人配置独立于 IDE 目录，Claude Code、Cursor 等共享。
