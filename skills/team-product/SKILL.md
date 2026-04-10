---
name: team-product
description: 启动产品讨论团队，通过内部讨论和问题收集生成纯业务需求文档
tags: [team, product]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：路径 = `{根变量}/{固定变量}/固定后缀`。根变量可配置（`project_root` / `personal_root`），其余固定。详见 `config/README.md`。

# /team-product — 产品讨论团队

> 启动产品讨论团队（pm-writer + pm-reviewer + pm-questioner），通过内部讨论和问题收集生成纯业务需求文档。
> 需求文档**禁止包含**任何技术实现细节（接口、数据库、代码层级等）。

## 使用方式

/team-product <功能名称> [材料路径] [截图...]

例如：
- /team-product benchmark-entry requirements/raw/需求.docx screenshots/list.png
- /team-product 财务看板（无材料，手动描述）

功能目录：{features}/{name}/

---

## 团队角色

| Agent | 角色 | 职责 |
|-------|------|------|
| pm-writer | 需求编写 | 起草纯业务需求文档 |
| pm-reviewer | 需求审查 | 审查业务完整性、逻辑闭环、规范合规 |
| pm-questioner | 疑点收集 | 整理所有业务疑点到 questions.md |

---

## 执行步骤

### 第一步：初始化

1. 解析参数：功能名称、材料路径、截图
2. 确保 {features}/{name}/requirement/ 和 {features}/{name}/reviews/ 目录存在
3. 输出启动信息：
Team Product 启动：<功能名称>
角色：pm-writer + pm-reviewer + pm-questioner
材料：<路径 或 "无">

### 第二步：pm-writer 起草初稿

派发任务给 pm-writer：
- 输入：原始材料 + 截图
- 遵循 /gen-requirement-doc 的完整流程（skill 已预注入）
- **严格禁止**输出技术实现细节
- 产出：{features}/{name}/requirement/requirement-doc.md

### 第三步：pm-reviewer + pm-questioner 并行

pm-writer 完成后，**同时**启动：

**pm-reviewer**（审查）：
- 遵循 /review-requirement-doc 完整流程
- 审查维度：完整性、逻辑闭环、可实现性、规范合规、技术泄漏检查
- 产出：{features}/{name}/reviews/requirement-review.md

**pm-questioner**（疑点收集）：
- 从需求初稿中提取所有需要用户确认的业务问题
- 产出：{features}/{name}/requirement/questions.md

### 第四步：暂停等用户回答

两个审查完成后，暂停并提示用户：

```
PM Team 初稿完成，请查看并处理：
1. 审查报告：{features}/{name}/reviews/requirement-review.md
2. 业务疑点：{features}/{name}/requirement/questions.md

请回答 questions.md 中的问题（在文件中填写或在对话中回答），完成后输入「继续」。
```

### 第五步：pm-writer 修正定稿

用户回答后，派发任务给 pm-writer：
- 读取 requirement-review.md（审查反馈）
- 读取 questions.md（用户答案）
- 逐条处理反馈 → 修正 requirement-doc.md → 定稿
- 输出修正摘要

### 完成输出

```
【Team Product 完成】
▌ 需求文档：{features}/{name}/requirement/requirement-doc.md
▌ 审查报告：{features}/{name}/reviews/requirement-review.md
▌ pm-reviewer：严重 N 个 → 已处理，建议 N 个 → 已处理
▌ pm-questioner：N 个问题 → 用户已回答

下一步：运行 /team-design <名称> 启动技术设计团队
```

---

## 规则

- 需求文档严禁技术实现内容（pm-reviewer 会检查）
- 疑点收集只问真正需要用户决策的问题（5-15 个）
- 最多 1 轮审查 + 1 轮修正
- 若 Agent Teams 不可用，由主线程顺序执行 3 个角色的工作
