# cc-skills

Claude Code 和 Cursor 的中文技能集合，提供实用的开发工作流技能。

## 技能目录

| 技能 | 说明 | 标签 |
|------|------|------|
| [review-requirement-doc](skills/review-requirement-doc/SKILL.md) | 审查产品功能需求文档的完整性、一致性和可行性 | review, documentation, requirements |
| [review-design-doc](skills/review-design-doc/SKILL.md) | 审查功能设计文档，检查需求覆盖率、接口规范、前后端一致性 | review, documentation, design |

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
