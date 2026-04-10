---
name: team-design
description: 启动技术设计团队，基于需求文档生成完整技术设计文档
tags: [team, design]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：本 skill 使用 `config/defaults.json` 定义的路径变量。`{features}` 默认为 `cc-cache-doc/features`。详见 `config/README.md`。

# /team-design — 技术设计团队

> 启动技术设计团队（arch-designer + arch-reviewer + arch-questioner），基于需求文档生成完整技术设计文档。
> 需要先有 requirement-doc.md（由 /team-product 或 /gen-requirement-doc 产出）。

## 使用方式

/team-design <功能名称> [截图...]

例如：
- /team-design benchmark-entry screenshots/detail.png
- /team-design 财务看板

前置条件：{features}/{name}/requirement/requirement-doc.md 必须存在

---

## 团队角色

| Agent | 角色 | 职责 |
|-------|------|------|
| arch-designer | 设计编写 | 起草技术设计文档（7 章） |
| arch-reviewer | 设计审查 | 审查需求覆盖度、接口规范、架构合规 |
| arch-questioner | 技术疑点收集 | 整理技术决策问题到 tech-questions.md |

---

## 执行步骤

### 第一步：初始化

1. 解析参数：功能名称、截图
2. 检查 {features}/{name}/requirement/requirement-doc.md 是否存在
   - 不存在 → 提示「缺少需求文档，请先运行 /team-product 或 /gen-requirement-doc」
3. 确保 {features}/{name}/dev-design/ 和 {features}/{name}/reviews/ 目录存在

### 第二步：arch-designer 起草设计

派发任务给 arch-designer：
- 输入：requirement-doc.md + 截图
- 遵循 /dev/gen-design-doc 的完整流程（skill 已预注入）
- 先读 CLAUDE.md + 同类现有代码作为参考
- 产出：{features}/{name}/dev-design/dev-design-doc.md（7 章结构：功能概述、UI 设计、前端实现、接口设计、数据模型、业务规则、异常处理）

### 第三步：arch-reviewer + arch-questioner 并行

**arch-reviewer**（审查）：
- 遵循 /dev/review-design-doc 完整流程
- 审查维度：需求覆盖度、接口规范性、前后端一致性、架构规范合规
- 产出：{features}/{name}/reviews/dev-design-review.md

**arch-questioner**（技术疑点收集）：
- 从设计初稿中提取需要用户确认的技术决策问题
- 产出：{features}/{name}/dev-design/tech-questions.md

### 第四步：暂停等用户回答（若有问题）

若 tech-questions.md 中有问题，暂停并提示：

```
Architect Team 初稿完成，请查看并处理：
1. 审查报告：{features}/{name}/reviews/dev-design-review.md
2. 技术疑点：{features}/{name}/dev-design/tech-questions.md

请回答 tech-questions.md 中的问题，完成后输入「继续」。
```

若无技术疑点，跳过此步直接进入修正。

### 第五步：arch-designer 修正定稿

- 读取 dev-design-review.md + tech-questions.md（用户答案）
- 修正 dev-design-doc.md → 定稿

### 完成输出

```
【Team Design 完成】
▌ 设计文档：{features}/{name}/dev-design/dev-design-doc.md
▌ 审查报告：{features}/{name}/reviews/dev-design-review.md
▌ arch-reviewer：严重 N 个 → 已处理
▌ arch-questioner：N 个技术问题 → 用户已回答
▌ 接口数：N 个，数据表：N 张

下一步：运行 /team-code <名称> 启动开发团队
```

---

## 规则

- 设计文档必须覆盖需求文档中所有 P0 功能点
- 技术疑点只问需要用户决策的问题（3-10 个），有最佳实践的直接给推荐方案
- 最多 1 轮审查 + 1 轮修正
- 若 Agent Teams 不可用，由主线程顺序执行
