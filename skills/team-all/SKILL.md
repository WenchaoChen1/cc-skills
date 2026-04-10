---
name: team-all
description: "TRIGGER: 当用户要求完整功能开发或全流程串联时必须使用。按顺序启动产品、设计、开发、测试 4 个团队，完成一个功能的全流程开发"
tags: [team, orchestration]
version: 1.0.0
author: Wenchao Chen
---

# /team-all — 全流程串联（4 团队）

> 按顺序启动 4 个团队：产品讨论 → 技术设计 → 开发 → 测试，完成一个功能的全流程开发。
> 每个团队内部有讨论和审查，团队之间通过产物传递。

## 使用方式

```
/team-all <功能名称> [材料路径] [截图...]
```

例如：
- `/team-all benchmark-entry requirements/raw/需求.docx screenshots/list.png`
- `/team-all 财务看板`

---

## 4 团队串联流程

```
/team-product  产品讨论团队（3 人）
  pm-writer 起草 → pm-reviewer 审查 → pm-questioner 收集疑点
  → 暂停等用户回答 → pm-writer 修正定稿
  产出：requirement-doc.md
                    ↓
/team-design   技术设计团队（3 人）
  arch-designer 起草 → arch-reviewer 审查 → arch-questioner 收集疑点
  → 暂停等用户回答（若有）→ arch-designer 修正定稿
  产出：dev-design-doc.md
                    ↓
/team-code     开发团队（3 人）
  dev-backend ‖ dev-frontend 并行开发
  → dev-reviewer 审查 → 修复
  产出：后端代码 + 前端代码
                    ↓
/team-test     测试团队（3 人）
  qa-designer ‖ qa-developer 并行
  → qa-executor 执行测试 → 修复
  产出：测试文档 + 测试代码 + 测试报告
```

---

## 执行步骤

### 第〇步：初始化

1. 解析参数：功能名称、材料路径、截图
2. 创建 `features/<name>/` 完整目录结构（requirement/、dev-design/、user-test/、unit-test/、reviews/）
3. 输出启动信息：

```
═══════════════════════════════════════════════════════
 Team All 启动：<功能名称>
 流程：产品讨论 → 技术设计 → 开发 → 测试
 团队：PM (3) + Architect (3) + Dev (3) + QA (3) = 12 角色
 材料：<路径 或 "无">
 截图：<N> 张
═══════════════════════════════════════════════════════
```

---

### 阶段 1：产品讨论团队

按 `/team-product` 完整流程执行：
1. pm-writer 起草纯业务需求（禁止技术内容）
2. pm-reviewer 审查 + pm-questioner 收集疑点（并行）
3. **暂停等用户回答 questions.md**
4. pm-writer 修正定稿

**Gate**：requirement-doc.md 定稿后进入阶段 2。

---

### 阶段 2：技术设计团队

按 `/team-design` 完整流程执行：
1. arch-designer 读取 requirement-doc.md → 起草设计文档
2. arch-reviewer 审查 + arch-questioner 收集技术疑点（并行）
3. **若有技术疑点：暂停等用户回答 tech-questions.md**
4. arch-designer 修正定稿

**Gate**：dev-design-doc.md 定稿后进入阶段 3。

---

### 阶段 3：开发团队

按 `/team-code` 完整流程执行：
1. dev-backend + dev-frontend 并行开发
2. dev-reviewer 审查实现
3. 若有问题 → 修复 → 复核（1 轮）

**Gate**：审查通过后进入阶段 4。

---

### 阶段 4：测试团队

按 `/team-test` 完整流程执行：
1. qa-designer + qa-developer 并行（测试文档 + 测试代码）
2. qa-executor 执行测试
3. 若有失败 → Dev Team 修复 → 重跑（1 轮）

---

### 最终报告

4 个团队全部完成后，输出最终报告并保存至 `features/<name>/reviews/team-report.md`：

```markdown
# 全流程团队开发报告

**功能**：<功能名称>
**团队**：PM (3) + Architect (3) + Dev (3) + QA (3) = 12 角色

---

## 阶段执行记录

| # | 阶段 | 团队 | 状态 | 关键产出 |
|---|------|------|------|---------|
| 1 | 产品讨论 | PM Team | ✅ | requirement-doc.md |
| 2 | 技术设计 | Architect Team | ✅ | dev-design-doc.md |
| 3 | 开发 | Dev Team | ✅ | 后端 N 文件 + 前端 N 文件 |
| 4 | 测试 | QA Team | ✅ | 通过率 N% |

---

## 完整产物清单

| 产物 | 路径 | 团队 |
|------|------|------|
| 需求文档 | features/<name>/requirement/requirement-doc.md | PM |
| 需求审查 | features/<name>/reviews/requirement-review.md | PM |
| 设计文档 | features/<name>/dev-design/dev-design-doc.md | Architect |
| 设计审查 | features/<name>/reviews/dev-design-review.md | Architect |
| 后端代码 | <后端项目>/... | Dev |
| 前端代码 | <前端项目>/... | Dev |
| 实现审查 | features/<name>/reviews/implementation-review.md | Dev |
| 测试文档 | features/<name>/user-test/user-test-doc.md | QA |
| 测试代码 | features/<name>/unit-test/README.md | QA |
| 测试报告 | features/<name>/reviews/test-execution.md | QA |
| 团队报告 | features/<name>/reviews/team-report.md | Lead |

---

## 遗留问题

- <各团队未解决的问题>
```

---

## 规则

- 4 个团队严格按顺序执行（产出依赖关系）
- 每个团队遵循各自 skill 的完整规则
- 暂停点：阶段 1 的 questions.md + 阶段 2 的 tech-questions.md（若有）
- 每个团队内部最多 1 轮审查 + 1 轮修正
- 若 Agent Teams 不可用，退化为 `/run-e2e-pipeline` 的顺序模式
