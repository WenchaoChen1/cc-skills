# 路径配置

路径公式：`{根变量}/{可配变量}/固定后缀`

## 变量

| 变量 | 默认值 | 必填 |
|------|--------|------|
| `project_root` | `cc-cache-doc` | 可为空 |
| `personal_root` | `.cc-cache-doc` | 可为空 |
| `features` | `features` | 必填 |
| `rules` | `rules` | 必填 |
| `standards` | `standards` | 必填 |

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

`{features}/{name}/` 下：`requirement/`、`dev-design/`、`reviews/`、`user-test/`、`unit-test/`

## 自动安装

SessionStart hook 自动创建 `~/.cc-cache-doc/` 目录和默认配置。

## 兼容性

`~/.cc-cache-doc/` 独立于 IDE 目录，Claude Code、Cursor 等共享。
