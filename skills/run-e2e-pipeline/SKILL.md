---
name: run-e2e-pipeline
description: 从需求材料出发，自动执行 9 步端到端开发工作流，中间通过自动门控决定继续或暂停
tags: [pipeline, e2e, automation]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：本 skill 使用 `config/defaults.json` 定义的路径变量。`{features}` 默认为 `cc-cache-doc/features`。详见 `config/README.md`。

# 一键端到端开发管道

从需求材料出发，自动执行 9 步开发工作流（需求→审查→设计→审查→测试文档→开发→审查→单元测试→执行测试），中间通过自动门控决定继续或暂停。

## 使用方式

```
/run-e2e-pipeline <功能名> [材料路径] [截图...] [--resume] [--from=N]
```

例如：
- `/run-e2e-pipeline financial-dashboard requirements/raw/财务看板.docx screenshots/list.png`
- `/run-e2e-pipeline financial-dashboard --resume`（从上次中断处继续）
- `/run-e2e-pipeline financial-dashboard --from=6`（从步骤 6 开始）

**参数说明**：

| 参数 | 说明 |
|------|------|
| `<功能名>` | 功能目录名（对应 `{features}/{name}/`），必填 |
| `[材料路径]` | 需求原始文件（.md/.txt/.docx），可选 |
| `[截图...]` | 截图文件路径，可传多个，可选 |
| `--resume` | 从上次中断处继续（读取 `.pipeline-status.json`） |
| `--from=N` | 从第 N 步开始（跳过前面的步骤，要求对应产物已存在） |

---

## 9 步管道总览

```
步骤 1  gen-requirement-doc      ← 需要用户回答疑点（唯一必须交互）
步骤 2  review-requirement-doc   ← 自动门控
步骤 3  gen-dev-design-doc
步骤 4  review-dev-design-doc    ← 自动门控
步骤 5  gen-user-test-doc
步骤 6  run-dev-design-doc       ← 自动继续两阶段
步骤 7  review-implementation    ← 自动门控
步骤 8  gen-unit-test
步骤 9  run-tests
```

> **Agent Teams 可用时**：步骤 5 和 6 并行执行；步骤 6/8/9 内部可进一步并行后端与前端。详见下方「并行策略」章节。

---

## 并行策略（Agent Teams）

> 当可以启动多个并行 Agent 时（TaskCreate / Agent tool 可用），管道中部分步骤可以并行执行。若不可用，跳过本节，按下方「执行步骤」顺序执行全部 9 步。

### 管道并行化总览

步骤 1→2→3→4 **必须严格顺序执行**（每步依赖前一步的产物或门控结果）。

步骤 4 通过后，**步骤 5 和步骤 6 可以并行**：

```
步骤 1 → 2（门控）→ 3 → 4（门控）
                                 ↓
                           ┌─────┴─────┐
                           ↓           ↓
                        步骤 5      步骤 6（内部可并行后端/前端）
                           ↓           ↓
                           └─────┬─────┘
                                 ↓
                   步骤 7（门控）→ 8（内部可并行）→ 9（内部可并行）
```

步骤 5 和 6 均完成后，步骤 7→8→9 恢复顺序执行。

### 步骤 5+6 并行的 Agent 分配

**Agent A — 步骤 5（gen-user-test-doc）：**

| 项目 | 说明 |
|------|------|
| **任务** | 按 `/gen-user-test-doc` 完整流程生成测试文档 |
| **必须接收** | ① `{features}/{name}/requirement/requirement-doc.md` 全文 ② `{features}/{name}/dev-design/dev-design-doc.md` 全文 ③ `/gen-user-test-doc` skill 的完整指令 ④ 管道上下文：自动覆盖已有文件 |
| **输出** | `user-test-doc.md` 文件 + 步骤完成摘要（P0 测试用例数、边界场景数） |

**Agent B — 步骤 6（run-dev-design-doc）：**

| 项目 | 说明 |
|------|------|
| **任务** | 按 `/dev/run` 完整流程开发代码（含自身的并行策略，允许内部进一步并行后端/前端） |
| **必须接收** | ① `{features}/{name}/dev-design/dev-design-doc.md` 全文 ② `{features}/{name}/requirement/requirement-doc.md` 全文（若存在） ③ CLAUDE.md 全文 ④ `/dev/run` skill 的完整指令（含并行策略） ⑤ 管道上下文：阶段一完成后自动继续阶段二（不暂停） |
| **输出** | 代码文件 + 步骤完成摘要（新建/修改文件清单） |

### 主线程合并（步骤 5+6 完成后）

1. 等待两个 Agent 均完成
2. 校验产物：`user-test-doc.md` 存在、代码文件已创建
3. 更新 `.pipeline-status.json`：`steps.5.status = "completed"`, `steps.6.status = "completed"`
4. 输出两个步骤的合并摘要
5. 继续步骤 7

### 内部并行继承

步骤 6、7、8、9 各自内部的并行策略继承自对应 skill 文件的「并行策略」章节：
- 步骤 6（`/dev/run`）：后端 + 前端并行开发
- 步骤 7（`/dev/review-implementation`）：后端核对 + 前端核对并行
- 步骤 8（`/dev/gen-unit-test`）：后端 + 前端测试并行生成
- 步骤 9（`/dev/run-tests`）：mvn test + npm test 并行运行

若 Agent 嵌套层级过深（已在子 Agent 中执行），则退回顺序执行。

---

## 执行步骤

### 第〇步：初始化

1. **解析参数**：
   - 提取功能名（第一个非 `--` 且非文件后缀的参数）
   - 提取材料路径和截图路径
   - 检查 `--resume` 和 `--from=N` 标志

2. **检查已有状态**：
   - 若 `{features}/{name}/.pipeline-status.json` 存在且未传 `--resume` 或 `--from`：
     ```
     ⚠️ 检测到功能「<name>」已有管道执行记录（上次停在步骤 N）。
     选项：A. 从中断处继续  B. 从头开始（覆盖）  C. 取消
     ```
   - 若传了 `--resume`：读取状态文件，从上次中断处继续
   - 若传了 `--from=N`：从第 N 步开始，校验前置产物存在

3. **初始化状态文件**：
   创建或更新 `{features}/{name}/.pipeline-status.json`：
   ```json
   {
     "feature": "<name>",
     "startedAt": "<ISO datetime>",
     "currentStep": 1,
     "steps": {
       "1": { "status": "pending", "startedAt": null, "completedAt": null },
       "2": { "status": "pending", "startedAt": null, "completedAt": null, "severeIssues": null, "autoFixAttempted": false },
       "3": { "status": "pending", "startedAt": null, "completedAt": null },
       "4": { "status": "pending", "startedAt": null, "completedAt": null, "severeIssues": null, "autoFixAttempted": false },
       "5": { "status": "pending", "startedAt": null, "completedAt": null },
       "6": { "status": "pending", "startedAt": null, "completedAt": null, "phase": null },
       "7": { "status": "pending", "startedAt": null, "completedAt": null, "severeIssues": null, "autoFixAttempted": false },
       "8": { "status": "pending", "startedAt": null, "completedAt": null },
       "9": { "status": "pending", "startedAt": null, "completedAt": null, "passRate": null }
     }
   }
   ```

4. **输出管道启动信息**：
   ```
   ═══════════════════════════════════════════
    E2E 管道启动：<功能名>
    起始步骤：<N>
    材料：<材料路径 或 "无">
    截图：<截图数量> 张
   ═══════════════════════════════════════════
   ```

---

### 步骤 1：生成需求文档（gen-requirement-doc）

**前置检查**：
- 若 `{features}/{name}/requirement/requirement-doc.md` 已存在 → 自动覆盖（不询问）
- 更新状态：`steps.1.status = "in_progress"`

**执行**：
- 按 `/gen-requirement-doc` 的完整流程执行
- 传入材料路径和截图路径
- **保留疑点提问环节**（这是关键质量门控，用户必须回答）
- UI 审查环节：自动标注所有待确认项（选择 C），不暂停等待

**完成后**：
- 更新状态：`steps.1.status = "completed"`
- 输出存档摘要：
  ```
  【步骤 1 完成】需求文档已生成
  ▌ 路径：{features}/{name}/requirement/requirement-doc.md
  ▌ 功能点：P0 x N, P1 x N, P2 x N
  ▌ 待确认项：N 个
  ▌ 耗时：N 分钟
  ```

---

### 步骤 2：审查需求文档（review-requirement-doc）— 自动门控

**执行**：按 `/review-requirement-doc <name>` 完整流程执行

**门控策略**（读取保存的审查报告 `{features}/{name}/reviews/requirement-review.md` 中的结构化元数据）：

| 严重问题数 | 处理 |
|-----------|------|
| 0 | 输出「需求审查通过」，自动继续步骤 3 |
| 1-3 | 进入**自动修复**（见下方） |
| >3 | 直接暂停（见下方「暂停处理」） |

**自动修复流程**（仅 1 轮）：
1. 读取审查报告中的严重问题列表
2. 逐条修改 `requirement-doc.md` 中对应的内容
3. 重新执行 `/review-requirement-doc <name>`
4. 若修复后严重问题数 = 0 → 自动继续
5. 若仍有严重问题 → 暂停

**暂停处理**：
```
⚠️ 需求审查发现 N 个严重问题（自动修复后仍有 M 个）。

选项：
  A. 我来修改需求文档，修改完成后输入「继续」恢复管道
  B. 强制继续（忽略问题，进入设计阶段）
  C. 终止管道
```

- 更新状态：`steps.2.status = "completed"` 或 `"paused"`

---

### 步骤 3：生成设计文档（gen-dev-design-doc）

**前置检查**：
- 若 `{features}/{name}/dev-design/dev-design-doc.md` 已存在 → 自动覆盖
- 更新状态：`steps.3.status = "in_progress"`

**执行**：
- 按 `/dev/gen-design-doc <name>` 的完整流程执行
- 截图参数从管道初始化时传入
- 重复创建检查：自动选择覆盖（A）

**完成后**：
- 更新状态：`steps.3.status = "completed"`
- 输出存档摘要：
  ```
  【步骤 3 完成】设计文档已生成
  ▌ 路径：{features}/{name}/dev-design/dev-design-doc.md
  ▌ 接口数：N 个
  ▌ 数据表：N 张
  ▌ 耗时：N 分钟
  ```

---

### 步骤 4：审查设计文档（review-dev-design-doc）— 自动门控

**执行**：按 `/dev/review-design-doc <name>` 完整流程执行

**门控策略**（同步骤 2）：

| 严重问题数 | 处理 |
|-----------|------|
| 0 | 自动继续步骤 5 |
| 1-3 | 自动修复 `dev-design-doc.md` 1 轮 → 重新审查 → 仍有问题则暂停 |
| >3 | 直接暂停 |

**暂停处理**（同步骤 2 格式，选项 A/B/C）

---

### 步骤 5：生成测试文档（gen-user-test-doc）

> **Agent Teams 模式**：步骤 5 与步骤 6 并行启动（见「并行策略」章节）。

**前置检查**：
- 若 `{features}/{name}/user-test/user-test-doc.md` 已存在 → 自动覆盖
- 更新状态：`steps.5.status = "in_progress"`

**执行**：
- 按 `/gen-user-test-doc <name>` 的完整流程执行
- 重复创建检查：自动选择覆盖（A）

**完成后**：
- 更新状态：`steps.5.status = "completed"`
- 输出存档摘要：
  ```
  【步骤 5 完成】测试文档已生成
  ▌ 路径：{features}/{name}/user-test/user-test-doc.md
  ▌ P0 测试用例：N 条
  ▌ 边界场景：N 条
  ▌ 耗时：N 分钟
  ```

---

### 步骤 6：执行开发（run-dev-design-doc）

> **Agent Teams 模式**：步骤 6 与步骤 5 并行启动，内部可进一步并行后端/前端（见「并行策略」章节）。

**前置检查**：
- 更新状态：`steps.6.status = "in_progress"`, `steps.6.phase = "backend"`

**执行**：
- 按 `/dev/run <name>` 的完整流程执行
- **阶段一（后端）完成后**：自动继续阶段二（不等用户确认），除非遇到编译错误
  - 若有编译错误 → 暂停：
    ```
    ⚠️ 后端阶段存在编译错误：
    - <错误描述>
    选项：A. 尝试自动修复  B. 我来修复，修复后输入「继续」  C. 强制继续前端  D. 终止
    ```
- **阶段二（前端）完成后**：更新状态，继续步骤 7

**完成后**：
- 更新状态：`steps.6.status = "completed"`, `steps.6.phase = "completed"`
- 输出存档摘要：
  ```
  【步骤 6 完成】开发完成
  ▌ 后端：新建 N 个文件，修改 N 个文件
  ▌ 前端：新建 N 个文件，修改 N 个文件
  ▌ 耗时：N 分钟
  ```

---

### 步骤 7：审查实现（review-implementation）— 自动门控

**执行**：按 `/dev/review-implementation <name>` 完整流程执行

**门控策略**（同步骤 2/4）：

| 严重问题数 | 处理 |
|-----------|------|
| 0 | 自动继续步骤 8 |
| 1-3 | 自动修复代码 1 轮 → 重新审查 → 仍有问题则暂停 |
| >3 | 直接暂停 |

**自动修复说明**：此步骤修复的是代码（不是文档），修复后重新运行 `/dev/review-implementation` 验证。

---

### 步骤 8：生成单元测试（gen-unit-test）

> **Agent Teams 模式**：步骤 8 内部可并行生成后端和前端测试（继承 `/dev/gen-unit-test` 并行策略）。

**前置检查**：
- 更新状态：`steps.8.status = "in_progress"`

**执行**：
- 按 `/dev/gen-unit-test <name>` 的完整流程执行
- 重复创建检查：自动选择覆盖（A）

**完成后**：
- 更新状态：`steps.8.status = "completed"`
- 输出存档摘要：
  ```
  【步骤 8 完成】单元测试已生成
  ▌ 后端测试：N 个类，N 个用例
  ▌ 前端测试：N 个文件，N 个用例
  ▌ 耗时：N 分钟
  ```

---

### 步骤 9：执行测试（run-tests）

> **Agent Teams 模式**：步骤 9 内部可并行运行后端和前端测试（继承 `/dev/run-tests` 并行策略）。

**执行**：
- 按 `/dev/run-tests <name>` 的完整流程执行
- 后端测试高失败率暂停：自动选择继续（A），除非存在编译错误

**完成后**：
- 更新状态：`steps.9.status = "completed"`, `steps.9.passRate = <百分比>`
- 进入「管道完成」阶段

---

## 管道完成：输出最终报告

9 步全部完成后，输出管道执行总览，同时保存至 `{features}/{name}/reviews/pipeline-report.md`：

```markdown
# E2E 管道执行报告

**功能**：<功能名称>
**执行时间**：<起始时间> ~ <结束时间>
**总耗时**：约 N 分钟

---

## 步骤执行状态

| # | 步骤 | 状态 | 耗时 | 备注 |
|---|------|------|------|------|
| 1 | gen-requirement-doc | ✅ 完成 | Nm | |
| 2 | review-requirement-doc | ✅ 通过 | Nm | 严重问题：0 |
| 3 | gen-dev-design-doc | ✅ 完成 | Nm | 接口 N 个 |
| 4 | review-dev-design-doc | ✅ 通过 | Nm | 自动修复 1 轮 |
| 5 | gen-user-test-doc | ✅ 完成 | Nm | |
| 6 | run-dev-design-doc | ✅ 完成 | Nm | 后端+前端 |
| 7 | review-implementation | ⚠️ 有问题 | Nm | 严重问题：2（已修复 1） |
| 8 | gen-unit-test | ✅ 完成 | Nm | |
| 9 | run-tests | ✅ 通过 | Nm | 通过率 95% |

---

## 产物清单

| 产物 | 路径 | 状态 |
|------|------|------|
| 需求文档 | `{features}/{name}/requirement/requirement-doc.md` | ✅ |
| 需求审查 | `{features}/{name}/reviews/requirement-review.md` | ✅ |
| 设计文档 | `{features}/{name}/dev-design/dev-design-doc.md` | ✅ |
| 设计审查 | `{features}/{name}/reviews/dev-design-review.md` | ✅ |
| 测试文档 | `{features}/{name}/user-test/user-test-doc.md` | ✅ |
| 后端代码 | `<后端项目>/...` | ✅ |
| 前端代码 | `<前端项目>/...` | ✅ |
| 实现审查 | `{features}/{name}/reviews/implementation-review.md` | ✅ |
| 单元测试 | `{features}/{name}/unit-test/README.md` | ✅ |
| 测试报告 | （控制台输出） | ✅ |
| 管道报告 | `{features}/{name}/reviews/pipeline-report.md` | ✅ |

---

## 遗留问题

- <未解决的审查问题>
- <测试失败项>
- <待确认项>

---

## 下一步建议

- 若有遗留问题：逐条修复后重新运行 `/dev/review-implementation <name>`
- 若测试全部通过：可以提交代码并创建 PR
```

最后更新状态文件，标记管道完成：
```json
{
  "completedAt": "<ISO datetime>",
  "currentStep": "done"
}
```

---

## 审查自动门控策略详解

步骤 2、4、7 共用相同的门控逻辑：

```
读取审查报告 → 提取「严重问题数」元数据
  ├── 0 个 → 自动继续下一步
  ├── 1-3 个 → 自动修复 1 轮
  │     ├── 修复后 0 个 → 自动继续
  │     └── 修复后仍有 → 暂停（A/B/C 选项）
  └── >3 个 → 直接暂停（A/B/C 选项）
```

**暂停选项说明**：
- **A. 用户修改后继续**：用户手动修改文档/代码，输入「继续」后管道从当前步骤重新执行审查
- **B. 强制继续**：忽略问题，跳到下一步（在最终报告中记录为「跳过」）
- **C. 终止管道**：更新状态文件为 `"paused"`，下次可用 `--resume` 恢复

---

## Context 管理策略

为避免长管道执行中上下文溢出，采用以下策略：

1. **每步存档**：每个步骤完成后输出结构化「存档摘要」（关键数字和路径），供后续步骤引用
2. **按需读取**：
   - 步骤 3（设计）基于步骤 1 的需求文档重新读取（因为步骤 2 可能修改了文档）
   - 步骤 6（开发）基于步骤 3 的设计文档读取，不重读需求
   - 步骤 7（审查）只读设计文档的接口清单章节 + 代码文件，不读完整需求
3. **审查步骤精简读取**：只读取审查报告的结构化元数据（整体评估结论、严重问题数），不重读完整报告内容来做门控决策

---

## 断点续跑

**状态文件**：`{features}/{name}/.pipeline-status.json`

- 每个步骤开始/完成时更新状态
- `--resume`：读取 `currentStep`，从该步骤重新执行
- `--from=N`：直接跳到第 N 步，但会校验前置产物：
  - `--from=3` 需要 `requirement-doc.md` 存在
  - `--from=6` 需要 `dev-design-doc.md` 存在
  - `--from=8` 需要 `dev-design-doc.md` 存在且代码已生成
  - `--from=9` 需要测试文件存在

---

## 用户交互汇总

| 场景 | 是否暂停 | 说明 |
|------|---------|------|
| 步骤 1 疑点提问 | **是**（必须） | 用户回答需求疑点，管道中唯一必须交互 |
| 步骤 1 UI 审查 | 否 | 自动标注待确认，不暂停 |
| 步骤 2/4/7 审查通过 | 否 | 自动继续 |
| 步骤 2/4/7 审查 1-3 问题 | 视修复结果 | 自动修复后通过则继续，否则暂停 |
| 步骤 2/4/7 审查 >3 问题 | **是** | 暂停等待用户选择 |
| 步骤 6 阶段间 | 否 | 自动继续（除非编译错误） |
| 重复创建检查 | 否 | 自动覆盖 |

**最少交互**：1 次（步骤 1 回答疑点，所有审查全部通过）
**最多交互**：4 次（+3 个审查暂停）

---

## 规则

- 管道中调用各子 skill 时，遵守该 skill 的所有规则（容错处理、模板格式等）
- 自动覆盖仅适用于管道内部产物，不覆盖不属于当前功能的文件
- 自动修复仅尝试 1 轮，不循环修复（防止越改越乱）
- 状态文件 `.pipeline-status.json` 不提交到 Git（建议加入 `.gitignore`）
- 管道中断后，已完成的步骤产物保留，不回滚
- 最终报告必须同时输出到控制台和保存到 `{features}/{name}/reviews/pipeline-report.md`
