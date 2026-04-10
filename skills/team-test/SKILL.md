---
name: team-test
description: 启动测试团队，生成测试文档、测试代码并执行测试
tags: [team, testing]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：路径 = `{根变量}/{可配变量}/固定后缀`。根变量和可配变量均可在 `cc-skills.json` 中自定义，仅后缀固定。详见 `config/README.md`。

# /team-test — 测试团队

> 启动测试团队（qa-designer + qa-developer + qa-executor），生成测试文档、测试代码并执行测试。
> 需要先有代码实现（由 /team-code 或 /dev/run 产出）。

## 使用方式

/team-test <功能名称>

前置条件：
- {features}/{name}/dev-design/dev-design-doc.md 存在
- 对应的后端/前端代码已实现

---

## 团队角色

| Agent | 角色 | 职责 |
|-------|------|------|
| qa-designer | 测试设计 | 手动测试用例（功能/边界/UI/验收） |
| qa-developer | 测试开发 | 自动化测试代码 |
| qa-executor | 测试执行 | 运行测试、分析失败、协调修复 |

---

## 执行步骤

### 第一步：初始化

1. 解析参数：功能名称
2. 检查 dev-design-doc.md 和代码文件是否存在
3. 确保 {features}/{name}/user-test/ 和 {features}/{name}/unit-test/ 目录存在

### 第二步：qa-designer + qa-developer 并行

**同时**启动：

**qa-designer**（测试设计）：
- 输入：requirement-doc.md + dev-design-doc.md
- 遵循 /gen-user-test-doc 完整流程
- 产出：{features}/{name}/user-test/user-test-doc.md（功能测试 + 边界测试 + UI 测试 + 验收测试）

**qa-developer**（测试代码）：
- 输入：dev-design-doc.md + requirement-doc.md
- 遵循 /dev/gen-unit-test 完整流程
- 产出：JUnit 测试 + Jest 测试 + {features}/{name}/unit-test/README.md

等待两者均完成。

### 第三步：qa-executor 执行测试

- 遵循 /dev/run-tests 完整流程
- 运行后端 mvn test + 前端 npm test
- 产出：{features}/{name}/reviews/test-execution.md

### 第四步：修复失败项（若有）

若有测试失败：
- 后端失败 → 通知开发团队 coder 修复（或由用户手动修复）
- 前端失败 → 通知开发团队 coder 修复
- 修复后 qa-executor 重跑（仅 1 轮）

### 完成输出

```
【Team Test 完成】
▌ qa-designer：测试文档（P0 用例 N 条，边界场景 N 条）
▌ qa-developer：后端测试 N 个类，前端测试 N 个文件
▌ qa-executor：测试通过率 N%
▌ 测试报告：{features}/{name}/reviews/test-execution.md

测试全部通过：功能可以提测 ✅
或：需修复 N 个失败项后重测
```

---

## 规则

- 测试用例必须覆盖需求文档中所有验收标准
- 失败分析必须读取实际错误信息，不凭猜测
- 修复建议必须包含具体文件路径
- 最多 1 轮测试失败修复
- 若 Agent Teams 不可用，由主线程顺序执行
