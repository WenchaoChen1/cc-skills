---
name: team-code
description: 启动开发团队，基于设计文档并行开发后端和前端代码，完成后内部审查
tags: [team, development]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：路径 = `{基础路径}/{根变量}/{可配变量}/{name}/固定后缀`，每层可为空。变量从 `cc-skills.json` 读取。详见 `config/README.md`。

# /team-code — 开发团队

> 启动开发团队（coder + dev-reviewer），基于设计文档并行开发后端和前端代码，完成后内部审查。
> 需要先有 dev-design-doc.md（由 /team-design 或 /dev/gen-design-doc 产出）。

## 使用方式

/team-code <功能名称>

前置条件：{features}/{name}/dev-design/dev-design-doc.md 必须存在

---

## 团队角色

| Agent | 角色 | 职责 |
|-------|------|------|
| coder | 后端开发 | 后端全栈实现 |
| coder | 前端开发 | 前端全栈实现 |
| dev-reviewer | 代码审查 | 审查实现闭环，分派问题修复 |

---

## 执行步骤

### 第一步：初始化

1. 解析参数：功能名称
2. 检查 {features}/{name}/dev-design/dev-design-doc.md 是否存在
   - 不存在 → 提示「缺少设计文档，请先运行 /team-design 或 /dev/gen-design-doc」
3. 读取 CLAUDE.md 了解项目结构

### 第二步：coder 并行开发（后端 + 前端）

**同时**启动两个开发者：

**coder（后端）**：
- 输入：dev-design-doc.md（第 4/5/6/7 章）+ requirement-doc.md（若存在）+ CLAUDE.md
- 遵循 /code 阶段一的完整流程
- 先读 2 个同类现有文件作为模式参考
- 实现：DDL → Entity → Repository → DTO → Mapper → Service → Controller
- 产出：后端代码文件清单 + 自检结果

**coder（前端）**：
- 输入：dev-design-doc.md（第 2/3 章 + 第 4.1/4.2 章接口规格）+ CLAUDE.md
- 遵循 /code 阶段二的完整流程
- 先读同类现有页面 + API service + 路由配置
- 实现：API Service → 页面组件 → 路由注册
- 产出：前端代码文件清单 + 自检结果

等待两者均完成。

### 第三步：dev-reviewer 审查实现

- 遵循 /dev/review-implementation 完整流程（7 个核对维度）
- 产出：{features}/{name}/reviews/implementation-review.md

### 第四步：修复问题（若有）

若 dev-reviewer 发现严重问题：
- 后端问题 → 发给 coder 修复
- 前端问题 → 发给 coder 修复
- 修复后 dev-reviewer 复核（仅 1 轮）

### 完成输出

```
【Team Code 完成】
▌ coder（后端）：新建 N 文件，修改 N 文件
▌ coder（前端）：新建 N 文件，修改 N 文件
▌ dev-reviewer：审查结论 <完整闭环/存在缺口>，严重问题 N 个（已修复 N 个）
▌ 审查报告：{features}/{name}/reviews/implementation-review.md

下一步：运行 /team-test <名称> 启动测试团队
```

---

## 规则

- 先读后写：动笔前必须读同类现有文件
- 改动最小化：不修改无关文件
- 后端和前端操作不同目录（CLAUDE.md 中定义的后端 vs 前端项目目录），无文件冲突
- 遇到设计文档与现有代码冲突时，停下来问用户
- 最多 1 轮审查 + 1 轮修复
- 若 Agent Teams 不可用，先后端再前端顺序执行
