# cc-skills 项目设计文档

**日期**：2026-04-08
**版本**：0.1.0
**作者**：Wenchao Chen

---

## 1. 项目定位

cc-skills 是一个独立的技能（skills）插件项目，为 Claude Code 和 Cursor 提供实用的开发工作流技能。项目以中文为主要语言，技术术语保持英文。持续更新升级，与 superpowers、everything-claude-code 等项目互补。

### 核心特征

- **独立生态**：不依赖任何第三方 skill 项目
- **中文优先**：所有文档、skill 内容、规则均以中文撰写
- **双平台支持**：主要支持 Claude Code + Cursor，其他平台留占位
- **Marketplace 发布**：支持 Claude Code marketplace 安装
- **零依赖**：纯 Markdown + JSON + Shell，无 npm 运行时依赖

---

## 2. 项目结构

```
cc-skills/
├── .claude-plugin/
│   ├── plugin.json                 # Claude Code 插件元数据
│   └── marketplace.json            # Marketplace 发布配置
├── .cursor-plugin/
│   └── plugin.json                 # Cursor 插件元数据
├── .codex/
│   └── INSTALL.md                  # Codex 安装占位
├── .opencode/
│   └── INSTALL.md                  # OpenCode 安装占位
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
│
├── skills/                         # 核心 skills
│   ├── review-requirement-doc/
│   │   └── SKILL.md
│   ├── review-design-doc/
│   │   └── SKILL.md
│   └── _template/
│       └── SKILL.md                # 新 skill 脚手架模板
│
├── agents/                         # Agent 定义（预留）
│   └── .gitkeep
│
├── rules/                          # 分层规则系统
│   ├── README.md
│   └── common/
│       ├── coding-style.md
│       ├── git-workflow.md
│       └── security.md
│
├── hooks/
│   ├── hooks.json                  # Claude Code hooks
│   ├── hooks-cursor.json           # Cursor hooks
│   ├── session-start               # 会话启动脚本
│   └── run-hook.cmd                # Windows 兼容 wrapper
│
├── commands/                       # 遗留命令兼容层（预留）
│   └── .gitkeep
│
├── scripts/
│   └── bump-version.sh             # 版本同步脚本
│
├── docs/
│   ├── skill-authoring-guide.md    # Skill 编写指南
│   └── specs/                      # 设计文档
│
├── .version-sync.json              # 版本同步配置
├── .gitignore
├── CLAUDE.md                       # Claude Code 入口 + skill/rule 目录
├── AGENTS.md                       # Agent 指引
├── README.md                       # 项目介绍 + 安装 + skill 使用说明
├── LICENSE                         # MIT
└── package.json                    # 版本 + 包元数据
```

### 设计原则

- 平台 dotfile（`.claude-plugin/`、`.cursor-plugin/`）保持根目录，确保原生兼容
- `skills/` 扁平排列，用 frontmatter 中的 `tags` 实现逻辑分类
- `_` 前缀目录为非 skill（模板、工具等），脚本扫描时排除
- 未来 skills 超过 50 个时，可引入子目录分类而不破坏现有结构

---

## 3. 插件元数据

### .claude-plugin/plugin.json

```json
{
  "name": "cc-skills",
  "description": "Claude Code 和 Cursor 的技能集合：需求审查、设计审查、开发工作流",
  "version": "0.1.0",
  "author": {
    "name": "Wenchao Chen",
    "url": "https://github.com/WenchaoChen1"
  },
  "homepage": "https://github.com/WenchaoChen1/cc-skills",
  "repository": "https://github.com/WenchaoChen1/cc-skills",
  "license": "MIT",
  "keywords": ["skills", "review", "requirements", "design", "中文"]
}
```

### .claude-plugin/marketplace.json

```json
{
  "name": "cc-skills-marketplace",
  "description": "cc-skills 技能集合的发布市场",
  "owner": {
    "name": "Wenchao Chen",
    "url": "https://github.com/WenchaoChen1"
  },
  "plugins": [
    {
      "name": "cc-skills",
      "description": "Claude Code 和 Cursor 的技能集合",
      "version": "0.1.0",
      "source": "./"
    }
  ]
}
```

### .cursor-plugin/plugin.json

```json
{
  "name": "cc-skills",
  "displayName": "CC Skills",
  "description": "Claude Code 和 Cursor 的技能集合",
  "version": "0.1.0",
  "skills": "./skills/",
  "agents": "./agents/",
  "commands": "./commands/",
  "hooks": "./hooks/hooks-cursor.json"
}
```

### 安装方式

```bash
# Claude Code — marketplace 方式
/plugin marketplace add WenchaoChen1/cc-skills
/plugin install cc-skills@cc-skills-marketplace

# Cursor
/add-plugin cc-skills
```

---

## 4. SKILL.md Frontmatter 规范

### 必填字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 唯一标识，与目录名一致，kebab-case |
| `description` | string | 一句话，说明做什么和何时用 |
| `tags` | string[] | 逻辑分类标签，用于搜索和索引 |

### 可选字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `version` | string | 语义化版本，默认跟随项目版本 |
| `author` | string | 作者 |

### 示例

```yaml
---
name: review-requirement-doc
description: 审查产品功能需求文档的完整性、一致性和可行性，输出按严重度排序的问题清单
tags: [review, documentation, requirements]
version: 1.0.0
author: Wenchao Chen
---
```

### 约束

- `name` 必须与目录名一致
- frontmatter 总大小不超过 1024 字符
- tags 使用小写英文，多个标签用逗号分隔

---

## 5. Demo Skills

### 5.1 review-requirement-doc

**来源**：从 `~/.claude/commands/review-requirement-doc.md` 迁移

**功能**：站在开发、QA、PM 三个角色视角审查需求文档，输出按严重度排序的问题清单。

**核心流程**：
1. 定位并读取所有材料
2. 理解业务，建立心智模型
3. 多维度审查（5 个维度：业务逻辑完备性、公式与计算、UI 对照、可测试性、文档质量）
4. 输出审查报告（按严重度：🔴 阻断性 / 🟡 重要 / 🔵 改进）
5. 保存审查报告到文件

### 5.2 review-design-doc

**来源**：从 `~/.claude/commands/dev/review-design-doc.md` 迁移

**功能**：检查设计文档是否完整覆盖需求、接口是否规范、前后端是否一致。

**核心流程**：
1. 读取所有材料（设计文档 + 需求文档）
2. 需求覆盖检查（功能点、业务规则、计算公式、异常场景）
3. 设计内部质量审查（接口设计、数据模型、前后端一致性、UI 完整性、文档质量）
4. 输出审查报告
5. 保存审查报告到文件

---

## 6. Rules 规则系统

### 目录结构

```
rules/
├── README.md
└── common/
    ├── coding-style.md    # 编码风格
    ├── git-workflow.md    # Git 工作流
    └── security.md        # 安全规范
```

### 规则文件格式

纯 Markdown，无 frontmatter。以检查清单和条目式组织。

### 扩展策略

- 初始：仅 `common/` 通用规则（3 个文件）
- 未来：按需添加语言目录（`typescript/`、`python/`、`java/` 等）
- 优先级：语言特定规则 > 通用规则

---

## 7. Hooks 系统

### hooks/hooks.json（Claude Code）

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "async": false
          }
        ]
      }
    ]
  }
}
```

### hooks/hooks-cursor.json（Cursor）

```json
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "command": "./hooks/session-start"
      }
    ]
  }
}
```

### session-start 脚本

- 读取 `skills/` 下所有 SKILL.md 的 name + description
- 生成 skill 目录注入到会话上下文
- 根据平台输出对应 JSON 格式

### run-hook.cmd

- Windows 下查找 Git Bash 执行脚本
- 回退到 PATH 中的 bash
- 找不到则静默退出

---

## 8. 版本管理

### .version-sync.json

```json
{
  "files": [
    { "path": "package.json", "field": "version" },
    { "path": ".claude-plugin/plugin.json", "field": "version" },
    { "path": ".cursor-plugin/plugin.json", "field": "version" },
    { "path": ".claude-plugin/marketplace.json", "field": "plugins.0.version" }
  ]
}
```

### scripts/bump-version.sh

- `--check`：检查版本一致性
- `<version>`：同步更新所有文件
- 依赖 `jq`，支持嵌套 JSON 路径

---

## 9. README.md 结构

1. **项目标题 + 简介** — 一段话说明定位
2. **安装** — Claude Code marketplace 安装 + Cursor 安装 + 其他平台
3. **技能列表** — 表格：技能名、说明、标签
4. **技能使用** — 每个 skill 的用法、示例、输出说明
5. **规则系统** — 简要说明 + 指向 rules/README.md
6. **项目结构** — 目录树 + 用途说明
7. **贡献** — Fork → 参考模板 → 提交 PR
8. **许可证** — MIT

目标控制在 3-5KB，简洁清晰。

---

## 10. 未来演进

- **更多 skills**：从本地 `~/.claude/commands/` 逐步迁移
- **语言规则**：按需添加 `rules/typescript/`、`rules/java/` 等
- **Agent 定义**：添加专业化 agent（如代码审查 agent）
- **更多平台**：实现 Codex、OpenCode、Gemini 支持
- **CI/CD**：GitHub Actions 校验 SKILL.md 格式和版本一致性
