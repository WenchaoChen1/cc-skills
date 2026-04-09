# cc-skills 项目初始化实施计划

> **For agentic workers:** 按任务顺序逐个执行，每个任务完成后 commit。步骤使用 checkbox (`- [ ]`) 语法跟踪进度。

**Goal:** 初始化 cc-skills 项目，创建完整的目录结构、插件元数据、两个 demo skills、规则系统、hooks、README 等全部文件。

**Architecture:** 纯静态文件项目（Markdown + JSON + Shell），无运行时依赖。采用方案 C 混合架构：扁平 skills 目录 + tags 逻辑分类 + 平台 dotfile 原生兼容。

**Tech Stack:** Markdown, JSON, Bash, jq

---

## Task 1: Git 初始化和基础配置文件

**Files:**
- Create: `.gitignore`
- Create: `package.json`
- Create: `LICENSE`
- Create: `.version-sync.json`

- [ ] **Step 1: 初始化 Git 仓库**

```bash
cd D:/github-code/cc-skills
git init
git remote add origin https://github.com/WenchaoChen1/cc-skills.git
```

- [ ] **Step 2: 创建 .gitignore**

```
node_modules/
.DS_Store
*.log
.superpowers/
```

- [ ] **Step 3: 创建 package.json**

```json
{
  "name": "cc-skills",
  "version": "0.1.0",
  "description": "Claude Code 和 Cursor 的中文技能集合",
  "author": "Wenchao Chen",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/WenchaoChen1/cc-skills.git"
  }
}
```

- [ ] **Step 4: 创建 LICENSE（MIT）**

MIT License，Copyright (c) 2026 Wenchao Chen

- [ ] **Step 5: 创建 .version-sync.json**

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

- [ ] **Step 6: Commit**

```bash
git add .gitignore package.json LICENSE .version-sync.json
git commit -m "chore: 初始化项目基础配置文件"
```

---

## Task 2: 平台插件元数据

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`
- Create: `.cursor-plugin/plugin.json`
- Create: `.codex/INSTALL.md`
- Create: `.opencode/INSTALL.md`

- [ ] **Step 1: 创建 .claude-plugin/plugin.json**

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

- [ ] **Step 2: 创建 .claude-plugin/marketplace.json**

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

- [ ] **Step 3: 创建 .cursor-plugin/plugin.json**

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

- [ ] **Step 4: 创建占位平台目录**

`.codex/INSTALL.md`:
```markdown
# Codex 安装说明

Codex 平台支持正在规划中，敬请期待。
```

`.opencode/INSTALL.md`:
```markdown
# OpenCode 安装说明

OpenCode 平台支持正在规划中，敬请期待。
```

- [ ] **Step 5: Commit**

```bash
git add .claude-plugin/ .cursor-plugin/ .codex/ .opencode/
git commit -m "chore: 添加多平台插件元数据和 marketplace 配置"
```

---

## Task 3: Hooks 系统

**Files:**
- Create: `hooks/hooks.json`
- Create: `hooks/hooks-cursor.json`
- Create: `hooks/session-start`
- Create: `hooks/run-hook.cmd`

- [ ] **Step 1: 创建 hooks/hooks.json（Claude Code）**

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

- [ ] **Step 2: 创建 hooks/hooks-cursor.json（Cursor）**

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

- [ ] **Step 3: 创建 hooks/session-start**

Bash 脚本功能：
1. 确定 PLUGIN_ROOT（支持 CLAUDE_PLUGIN_ROOT / CURSOR_PLUGIN_ROOT 环境变量）
2. 扫描 `skills/` 下所有 SKILL.md，提取 name 和 description
3. 拼装 skill 目录列表文本
4. 根据平台（Claude Code / Cursor / 其他）输出对应 JSON 格式到 stdout

- [ ] **Step 4: 创建 hooks/run-hook.cmd**

多语言脚本（批处理 + bash 混合）：
- Windows 部分：查找 Git Bash（`C:\Program Files\Git\bin\bash.exe`），回退到 PATH 中的 bash，找不到则静默退出
- Unix 部分：直接执行对应的 bash 脚本

- [ ] **Step 5: 设置可执行权限**

```bash
chmod +x hooks/session-start
```

- [ ] **Step 6: Commit**

```bash
git add hooks/
git commit -m "feat: 添加 SessionStart hooks 系统（Claude Code + Cursor）"
```

---

## Task 4: Rules 规则系统

**Files:**
- Create: `rules/README.md`
- Create: `rules/common/coding-style.md`
- Create: `rules/common/git-workflow.md`
- Create: `rules/common/security.md`

- [ ] **Step 1: 创建 rules/README.md**

内容：规则系统说明、目录结构、优先级规则、使用方式。

- [ ] **Step 2: 创建 rules/common/coding-style.md**

内容：不可变性原则、文件组织（小文件优于大文件）、命名规范、错误处理、代码质量检查清单。

- [ ] **Step 3: 创建 rules/common/git-workflow.md**

内容：commit message 格式（type: description）、分支策略、PR 工作流。

- [ ] **Step 4: 创建 rules/common/security.md**

内容：强制安全检查清单（禁止硬编码密钥、参数化查询、XSS/CSRF 防护、输入校验、错误信息不泄露敏感数据）。

- [ ] **Step 5: Commit**

```bash
git add rules/
git commit -m "feat: 添加分层规则系统（common 通用规则）"
```

---

## Task 5: Demo Skill — review-requirement-doc

**Files:**
- Create: `skills/review-requirement-doc/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

frontmatter:
```yaml
---
name: review-requirement-doc
description: 审查产品功能需求文档的完整性、一致性和可行性，输出按严重度排序的问题清单
tags: [review, documentation, requirements]
version: 1.0.0
author: Wenchao Chen
---
```

正文：从 `~/.claude/commands/review-requirement-doc.md` 迁移全部内容。去掉顶部标题（由 frontmatter name 代替），保留使用方式、执行步骤（5 步）、审查原则。将 `$ARGUMENTS` 语法适配为 skill 的参数说明格式。

- [ ] **Step 2: Commit**

```bash
git add skills/review-requirement-doc/
git commit -m "feat: 添加 review-requirement-doc skill（审查需求文档）"
```

---

## Task 6: Demo Skill — review-design-doc

**Files:**
- Create: `skills/review-design-doc/SKILL.md`

- [ ] **Step 1: 创建 SKILL.md**

frontmatter:
```yaml
---
name: review-design-doc
description: 审查功能设计文档，检查需求覆盖率、接口规范、前后端一致性，输出审查报告
tags: [review, documentation, design]
version: 1.0.0
author: Wenchao Chen
---
```

正文：从 `~/.claude/commands/dev/review-design-doc.md` 迁移全部内容。同样去掉顶部标题，保留使用方式、执行步骤（5 步）、规则。适配参数说明格式。

- [ ] **Step 2: Commit**

```bash
git add skills/review-design-doc/
git commit -m "feat: 添加 review-design-doc skill（审查设计文档）"
```

---

## Task 7: Skill 模板

**Files:**
- Create: `skills/_template/SKILL.md`

- [ ] **Step 1: 创建 _template/SKILL.md**

```yaml
---
name: your-skill-name
description: 一句话描述这个 skill 的用途和触发时机
tags: []
version: 1.0.0
author: Wenchao Chen
---
```

```markdown
# Skill 标题

简要说明这个 skill 做什么。

## 使用方式

说明如何调用这个 skill，包括参数和示例。

## 执行步骤

### 第一步：...

### 第二步：...

## 规则

- 规则 1
- 规则 2
```

- [ ] **Step 2: Commit**

```bash
git add skills/_template/
git commit -m "chore: 添加 skill 脚手架模板"
```

---

## Task 8: 预留目录

**Files:**
- Create: `agents/.gitkeep`
- Create: `commands/.gitkeep`

- [ ] **Step 1: 创建占位文件**

```bash
touch agents/.gitkeep commands/.gitkeep
```

- [ ] **Step 2: Commit**

```bash
git add agents/ commands/
git commit -m "chore: 添加 agents 和 commands 预留目录"
```

---

## Task 9: GitHub 模板

**Files:**
- Create: `.github/PULL_REQUEST_TEMPLATE.md`
- Create: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `.github/ISSUE_TEMPLATE/feature_request.md`

- [ ] **Step 1: 创建 PR 模板**

中文 PR 模板，包含：变更说明、变更类型（新 skill / 规则 / 修复 / 其他）、检查清单。

- [ ] **Step 2: 创建 Bug 报告模板**

中文 Issue 模板，包含：环境信息、重现步骤、预期行为、实际行为。

- [ ] **Step 3: 创建功能请求模板**

中文 Issue 模板，包含：使用场景、建议方案、替代方案。

- [ ] **Step 4: Commit**

```bash
git add .github/
git commit -m "chore: 添加 GitHub PR 和 Issue 模板"
```

---

## Task 10: 版本同步脚本

**Files:**
- Create: `scripts/bump-version.sh`

- [ ] **Step 1: 创建 bump-version.sh**

功能：
- `--check`：读取 `.version-sync.json`，用 `jq` 提取各文件版本号，检查是否一致
- `<version>`：验证 semver 格式，用 `jq` 更新所有声明文件的版本字段
- 支持嵌套 JSON 路径（如 `plugins.0.version`）

- [ ] **Step 2: 设置可执行权限**

```bash
chmod +x scripts/bump-version.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/
git commit -m "chore: 添加版本同步脚本"
```

---

## Task 11: 文档 — CLAUDE.md、AGENTS.md

**Files:**
- Create: `CLAUDE.md`
- Create: `AGENTS.md`

- [ ] **Step 1: 创建 CLAUDE.md**

内容：
1. 项目简介（一句话）
2. 技能目录表格（name + description）
3. 规则说明（指向 rules/）
4. 贡献指南简述

- [ ] **Step 2: 创建 AGENTS.md**

```markdown
参见 CLAUDE.md
```

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md AGENTS.md
git commit -m "docs: 添加 CLAUDE.md 和 AGENTS.md"
```

---

## Task 12: 文档 — README.md

**Files:**
- Create: `README.md`

- [ ] **Step 1: 创建 README.md**

结构（全中文）：
1. **标题 + 简介**：cc-skills 定位说明
2. **安装**：Claude Code marketplace 安装命令 + Cursor 安装命令 + 其他平台占位
3. **技能列表**：表格（技能名、说明、标签）
4. **技能使用说明**：
   - review-requirement-doc：用途、调用方式、输出格式
   - review-design-doc：用途、调用方式、输出格式
5. **规则系统**：简述 + 指向 rules/README.md
6. **项目结构**：目录树 + 各目录用途
7. **贡献**：Fork → 参考模板 → 提 PR
8. **许可证**：MIT

目标大小：3-5KB。

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: 添加 README.md 项目介绍和使用说明"
```

---

## Task 13: 文档 — Skill 编写指南

**Files:**
- Create: `docs/skill-authoring-guide.md`

- [ ] **Step 1: 创建 skill-authoring-guide.md**

内容：
1. Frontmatter 规范（必填/可选字段、格式约束）
2. 目录命名规则（kebab-case、与 name 一致）
3. Skill 正文结构建议（使用方式、执行步骤、规则）
4. 从 _template 创建新 skill 的步骤
5. 提交 PR 前的检查清单

- [ ] **Step 2: Commit**

```bash
git add docs/skill-authoring-guide.md
git commit -m "docs: 添加 skill 编写指南"
```

---

## Task 14: 最终检查和推送

- [ ] **Step 1: 验证目录结构完整**

```bash
find . -not -path './.git/*' | sort
```

确认所有文件存在且位置正确。

- [ ] **Step 2: 验证版本一致性**

```bash
./scripts/bump-version.sh --check
```

预期输出：All files in sync at 0.1.0

- [ ] **Step 3: 推送到远程**

```bash
git push -u origin main
```
