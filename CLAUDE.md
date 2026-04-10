# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

cc-skills 是一个 Claude Code / Cursor 插件项目，提供 20 个中文技能（skills）和 13 个 Agent。通过 marketplace 分发，用户安装后获得需求、设计、开发、测试全流程的 AI 辅助能力。

## 版本管理

所有版本号必须通过脚本同步更新，不要手动修改单个文件：

```bash
# 检查版本一致性
./scripts/bump-version.sh --check

# 更新版本（同步 package.json、plugin.json、marketplace.json）
./scripts/bump-version.sh 0.2.0
```

版本同步配置在 `.version-sync.json`，当前同步 4 个文件。

## 插件架构

```
.claude-plugin/plugin.json     → Claude Code 插件发现入口
.claude-plugin/marketplace.json → marketplace 发布元数据
.cursor-plugin/plugin.json     → Cursor 插件发现入口
hooks/hooks.json               → Claude Code SessionStart hook
hooks/hooks-cursor.json        → Cursor SessionStart hook
hooks/session-start            → bash 脚本，扫描 skills 注入会话上下文
hooks/run-hook.cmd             → Windows 兼容 wrapper（batch+bash 混合）
```

Claude Code 自动扫描 `skills/` 和 `agents/` 目录发现内容，**不需要**在 plugin.json 中显式声明路径。

## Skill 文件规范

每个 skill 是 `skills/<name>/SKILL.md`，必须包含 YAML frontmatter：

```yaml
---
name: review-requirement-doc       # 必须与目录名一致
description: 一句话描述             # 必填
tags: [review, documentation]      # 必填，小写英文
version: 1.0.0                     # 可选
author: Wenchao Chen               # 可选
---
```

关键约束：
- `name` 必须与目录名完全匹配
- frontmatter 总大小 ≤ 1024 字符
- 目录名用 kebab-case，动词开头
- Skill 模板在 `docs/_template/SKILL.md`

## Agent 文件规范

每个 agent 是 `agents/<name>.md`，使用 YAML frontmatter 定义 name、description、tools、model 等。

## 规则系统

`rules/` 下的规则文件按层级组织，详见 [rules/README.md](rules/README.md)：

- **common/**（10 文件）— 语言无关的通用规则（英文）
- **zh/**（11 文件）— 中文翻译版本，含增强内容（命名规范、分支策略等）
- **12 个语言目录**（各 5 文件）— cpp、csharp、dart、golang、java、kotlin、perl、php、python、rust、swift、typescript
- **web/**（7 文件）— Web 前端通用规则
- **lg/**（11 文件）— LG (CIOaaS) 项目特定规则

优先级：项目特定 > 语言特定 > 通用 > 默认行为。

## 添加新 Skill

1. 复制 `docs/_template/SKILL.md` 到 `skills/<new-name>/SKILL.md`
2. 修改 frontmatter（name 必须与目录名一致）
3. 更新 CLAUDE.md 和 README.md 中的技能列表
4. Commit 后推送，用户通过 `/plugin update` 获取

## 技能目录

### 产品与需求

| 技能 | 说明 |
|------|------|
| [gen-requirement-doc](skills/gen-requirement-doc/SKILL.md) | 生成产品功能需求文档（PRD） |
| [review-requirement-doc](skills/review-requirement-doc/SKILL.md) | 审查产品功能需求文档 |

### 设计与开发

| 技能 | 说明 |
|------|------|
| [gen-design-doc](skills/gen-design-doc/SKILL.md) | 生成功能设计文档 |
| [review-design-doc](skills/review-design-doc/SKILL.md) | 审查功能设计文档 |
| [dev-code](skills/dev-code/SKILL.md) | **统一写代码入口**（自动检测技术栈） |
| [dev-common](skills/dev-common/SKILL.md) | 开发公共规范 |
| [dev-run](skills/dev-run/SKILL.md) | 智能调度器 |
| [backend-java](skills/backend-java/SKILL.md) | Java 后端开发 |
| [backend-python](skills/backend-python/SKILL.md) | Python 后端开发 |
| [frontend](skills/frontend/SKILL.md) | 前端开发 |
| [hotfix](skills/hotfix/SKILL.md) | 快速修复 bug |
| [review-implementation](skills/review-implementation/SKILL.md) | 审查代码实现闭环 |

### 测试

| 技能 | 说明 |
|------|------|
| [gen-unit-test](skills/gen-unit-test/SKILL.md) | 生成自动化测试代码 |
| [gen-user-test-doc](skills/gen-user-test-doc/SKILL.md) | 生成手动测试文档 |
| [run-tests](skills/run-tests/SKILL.md) | 执行测试并报告 |

### 团队协作

| 技能 | 说明 |
|------|------|
| [team-all](skills/team-all/SKILL.md) | 全流程串联（4 团队） |
| [team-product](skills/team-product/SKILL.md) | 产品讨论团队 |
| [team-design](skills/team-design/SKILL.md) | 技术设计团队 |
| [team-code](skills/team-code/SKILL.md) | 开发团队 |
| [team-test](skills/team-test/SKILL.md) | 测试团队 |

### 项目管理

| 技能 | 说明 |
|------|------|
| [review-asana-ticket](skills/review-asana-ticket/SKILL.md) | 审查 Asana ticket 需求质量（六维度打分） |

### 流水线与审计

| 技能 | 说明 |
|------|------|
| [run-e2e-pipeline](skills/run-e2e-pipeline/SKILL.md) | 一键端到端开发流水线 |
| [team-usage-audit](skills/team-usage-audit/SKILL.md) | Claude Code 使用审计报告 |

## Agents

| Agent | 用途 |
|-------|------|
| [arch-designer](agents/arch-designer.md) | 设计编写角色 |
| [arch-questioner](agents/arch-questioner.md) | 技术疑点收集 |
| [arch-reviewer](agents/arch-reviewer.md) | 设计审查 |
| [demo-researcher](agents/demo-researcher.md) | 代码研究员 |
| [dev-coder](agents/dev-coder.md) | 统一代码编写（自动检测技术栈） |
| [dev-reviewer](agents/dev-reviewer.md) | 代码审查 |
| [pm-questioner](agents/pm-questioner.md) | 需求疑点收集 |
| [pm-reviewer](agents/pm-reviewer.md) | 需求审查 |
| [pm-writer](agents/pm-writer.md) | 需求编写 |
| [qa-designer](agents/qa-designer.md) | 测试设计 |
| [qa-developer](agents/qa-developer.md) | 测试开发 |
| [qa-executor](agents/qa-executor.md) | 测试执行 |

## 贡献指南

1. Fork 本仓库
2. 参考 `docs/_template/SKILL.md` 创建新 skill
3. 确保 frontmatter 包含必填字段：`name`、`description`、`tags`
4. 确保 skill 目录名与 frontmatter 中的 `name` 一致
5. 提交 PR，填写完整的 PR 模板
