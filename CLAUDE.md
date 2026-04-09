# cc-skills

Claude Code 和 Cursor 的中文技能集合，提供实用的开发工作流技能。

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
| [dev-common](skills/dev-common/SKILL.md) | 开发 skill 公共规范 |
| [dev-run](skills/dev-run/SKILL.md) | 智能调度器，自动检测技术栈分发开发 |
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
| [dev-backend](agents/dev-backend.md) | 后端开发 |
| [dev-frontend](agents/dev-frontend.md) | 前端开发 |
| [dev-reviewer](agents/dev-reviewer.md) | 代码审查 |
| [pm-questioner](agents/pm-questioner.md) | 需求疑点收集 |
| [pm-reviewer](agents/pm-reviewer.md) | 需求审查 |
| [pm-writer](agents/pm-writer.md) | 需求编写 |
| [qa-designer](agents/qa-designer.md) | 测试设计 |
| [qa-developer](agents/qa-developer.md) | 测试开发 |
| [qa-executor](agents/qa-executor.md) | 测试执行 |

## 规则

`rules/common/` 下的规则会自动加载为项目级编码规范：

- **coding-style.md** — 编码风格（不可变性、文件组织、命名规范）
- **git-workflow.md** — Git 工作流（commit 格式、分支策略）
- **security.md** — 安全规范（密钥管理、输入校验、安全检查清单）

详见 [rules/README.md](rules/README.md)。

## 贡献指南

1. Fork 本仓库
2. 参考 `skills/_template/SKILL.md` 创建新 skill
3. 确保 frontmatter 包含必填字段：`name`、`description`、`tags`
4. 确保 skill 目录名与 frontmatter 中的 `name` 一致
5. 提交 PR，填写完整的 PR 模板
