# 路径配置

路径公式：`{基础路径} / {根变量} / {可配变量} / {name} / 固定后缀`

每一层（除基础路径外）均可为空，为空时跳过该层。

## 基础路径（隐含，不可配置）

| 基础路径 | 值 |
|---------|-----|
| `<project>` | 当前项目目录 |
| `~` | 用户 home 目录 |

## 可配变量

| 变量 | 默认值 | 可为空 |
|------|--------|--------|
| `project_root` | `cc-cache-doc` | ✅ |
| `personal_root` | `.cc-cache-doc` | ✅ |
| `features` | `features` | ✅ |
| `rules` | `rules` | 必填 |
| `standards` | `standards` | 必填 |

## 路径示例

| 场景 | 完整路径 |
|------|---------|
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

## 固定后缀

`{name}/` 下：`requirement/`、`dev-design/`、`reviews/`、`user-test/`、`unit-test/`

## 自动安装

SessionStart hook 自动创建 `~/{personal_root}/` 目录和默认配置。

## 兼容性

个人配置独立于 IDE 目录，Claude Code、Cursor 等共享。
