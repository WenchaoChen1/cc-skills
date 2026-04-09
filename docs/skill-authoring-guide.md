# Skill 编写指南

本指南帮助你创建新的 cc-skills 技能。

## 快速开始

1. 复制模板目录：将 `skills/_template/` 复制为 `skills/your-skill-name/`
2. 编辑 `SKILL.md`：修改 frontmatter 和正文内容
3. 测试：在 Claude Code 中使用你的 skill 验证效果
4. 提交 PR

## Frontmatter 规范

每个 `SKILL.md` 文件必须以 YAML frontmatter 开头：

```yaml
---
name: your-skill-name
description: 一句话描述这个 skill 的用途和触发时机
tags: [tag1, tag2]
version: 1.0.0
author: Your Name
---
```

### 必填字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 唯一标识，必须与目录名一致，使用 kebab-case |
| `description` | string | 一句话说明用途，用于 skill 发现和搜索 |
| `tags` | string[] | 逻辑分类标签，使用小写英文 |

### 可选字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `version` | string | 语义化版本（X.Y.Z），默认跟随项目版本 |
| `author` | string | 作者姓名 |

### 约束

- `name` 必须与 skill 目录名完全一致
- frontmatter 总大小不超过 1024 字符
- tags 使用小写英文，多个标签用逗号分隔

## 目录命名规则

- 使用 `kebab-case`（小写字母 + 连字符）
- 动词开头（如 `review-requirement-doc` 而非 `requirement-doc-review`）
- 名称应清晰表达 skill 的功能
- `_` 前缀的目录（如 `_template/`）不会被识别为 skill

## 正文结构建议

```markdown
# Skill 标题

简要说明。

## 使用方式

调用方式和参数说明，包含示例。

## 执行步骤

### 第一步：...
### 第二步：...
（按实际流程组织）

## 规则

列出该 skill 的行为约束和注意事项。
```

### 编写原则

- **具体优于模糊**：不写"适当处理"，写明具体的处理方式
- **示例优于描述**：用实际的输入/输出示例说明预期行为
- **中文为主**：文档内容使用中文，技术术语保持英文
- **保持聚焦**：每个 skill 解决一个明确的问题，不贪多

## 提交前检查清单

- [ ] `name` 与目录名一致
- [ ] frontmatter 包含所有必填字段
- [ ] description 清晰描述了触发时机和用途
- [ ] tags 准确反映 skill 的分类
- [ ] 正文包含使用方式和执行步骤
- [ ] 已在 Claude Code 中测试通过
- [ ] 已更新 README.md 和 CLAUDE.md 中的技能列表
