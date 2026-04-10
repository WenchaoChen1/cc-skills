---
name: dev-run
description: "TRIGGER: 当用户要求开发功能或开始实现时必须使用。智能调度器，读取设计文档自动检测技术栈并分发到对应子 skill 执行开发"
tags: [development, orchestration]
version: 1.0.0
author: Wenchao Chen
---

# /dev/run — 根据设计文档开发功能（调度器）

> 智能调度器：读取设计文档，自动检测涉及哪些技术栈，分发到对应的子 skill 执行开发。
> 子 skill：`/dev/backend-java`、`/dev/backend-python`、`/dev/frontend`
> 公共规则：`/dev/common`

## 使用方式

```
/dev/run <功能名称> [--java-only | --python-only | --frontend-only | --backend-only]
```

例如：
- `/dev/run financial-dashboard`（自动检测，全栈开发）
- `/dev/run forecast-engine --python-only`（仅 Python 后端）
- `/dev/run benchmark-entry --backend-only`（仅后端，自动检测 Java/Python）
- `/dev/run 财务看板 --frontend-only`（仅前端）

> **功能目录识别**：
> - 有参数：直接使用 `features/<功能名称>/`
> - 无参数：扫描 `features/` 列出含 `dev-design/` 子目录的功能目录供选择；若只有一个自动提示确认；若无则提示先运行 `/dev/gen-design-doc`
>
> 自动读取 `features/<功能名称>/dev-design/` 目录下所有文件作为设计文档
> 若 `features/<功能名称>/requirement/` 存在，同时读取其目录下所有文件作为需求补充

---

## 执行流程

```
┌─────────────────────────────────┐
│  准备阶段（遵循 /dev/common）     │
│  读 CLAUDE.md → 读设计文档 →      │
│  读需求文档 → 检测技术栈范围       │
└────────────┬────────────────────┘
             │
     ┌───────┼───────┬────────────┐
     ▼       ▼       ▼            │
  Java后端  Python后端  React前端   │ 并行（Agent Teams）或顺序
  /dev/     /dev/      /dev/       │
  backend   backend    frontend    │
  -java     -python                │
     │       │       │            │
     └───────┼───────┘            │
             ▼                    │
     ┌─────────────────┐         │
     │  合并阶段         │         │
     │  交叉验证 + 报告   │         │
     └─────────────────┘         │
```

---

## 第一步：准备阶段

遵循 `/dev/common` 的准备阶段（第一步至第三步）完整执行。

## 第二步：检测技术栈范围

从设计文档内容自动判断涉及哪些技术栈：

先读取 `CLAUDE.md` 确认项目中有哪些技术栈（Java/Python/前端等），再根据设计文档内容判断：

| 判断条件 | 涉及的技术栈 |
|---------|-------------|
| 设计文档第 4 章接口涉及 CLAUDE.md 中描述的 Java 后端项目 | Java 后端（`/dev/backend-java`） |
| 设计文档第 4 章接口涉及 CLAUDE.md 中描述的 Python 后端项目 | Python 后端（`/dev/backend-python`） |
| 设计文档有第 2 章（UI 界面设计）或第 3 章（前端实现要点） | 前端（`/dev/frontend`） |

**输出检测结果**：
```
【技术栈检测】
- Java 后端：✅ 涉及 / ❌ 不涉及
- Python 后端：✅ 涉及 / ❌ 不涉及
- 前端：✅ 涉及 / ❌ 不涉及

确认以上范围是否正确？[Y/n/调整]
```

若用户传了 `--java-only` / `--python-only` / `--frontend-only` / `--backend-only`，跳过检测，直接使用指定范围。

## 第三步：探索代码模式

按检测到的技术栈范围，执行 `/dev/common` 第四步（探索现有代码模式）。
只探索涉及到的技术栈，不涉及的跳过。

## 第四步：分发执行

### 并行模式（Agent Teams 可用时）

同时启动所有涉及的子 skill 对应的 Agent：

**Agent 后端 Java**（若涉及 Java）：
- Agent 类型：`dev-backend`
- 执行 `/dev/backend-java` 的完整实现步骤（1-A 至 1-H）
- 必须接收：CLAUDE.md 内容 + 设计文档（第 4/5/6/7 章）+ 需求文档（若有）+ Java 代码模式参考文件
- 工作目录：CLAUDE.md 中描述的 Java 后端项目目录

**Agent 后端 Python**（若涉及 Python）：
- Agent 类型：`dev-backend`（需适配 Python 流程）
- 执行 `/dev/backend-python` 的完整实现步骤（1-A 至 1-F）
- 必须接收：CLAUDE.md 内容 + 设计文档 + Python 代码模式参考文件
- 工作目录：CLAUDE.md 中描述的 Python 后端项目目录

**Agent 前端**（若涉及前端）：
- Agent 类型：`dev-frontend`
- 执行 `/dev/frontend` 的完整实现步骤（2-A 至 2-D）
- 必须接收：CLAUDE.md 内容 + 设计文档（第 2/3 章 + 第 4.1/4.2 章接口规格）+ 前端代码模式参考文件
- 工作目录：CLAUDE.md 中描述的前端项目目录

### 顺序模式（Agent Teams 不可用时）

按以下顺序逐一执行：
1. Java 后端 → 输出文件清单 + 数据存档，**等待用户确认**
2. Python 后端 → 输出文件清单 + 数据存档，**等待用户确认**
3. 前端 → 可直接引用后端数据存档（接口路径 + 响应字段），输出文件清单

## 第五步：合并与交叉验证

等待所有 Agent 完成后：

1. **合并文件清单**：收集所有子 skill 的新建/修改文件
2. **交叉验证**：
   - Java DTO 字段名 vs 前端 TypeScript interface 字段名 → 不一致则列出
   - Python Schema 字段名 vs 前端 TypeScript interface 字段名 → 不一致则列出
   - Java Controller 路径 vs 前端 API service 路径 → 不一致则列出
   - Python Router 路径 vs 前端 API service 路径 → 不一致则列出
3. **输出合并报告**

---

## 输出格式

```
### 开发完成 ✓

【技术栈范围】
- Java 后端：✅ N 个新文件，M 个修改
- Python 后端：❌ 不涉及
- React 前端：✅ N 个新文件，M 个修改

【合并文件清单】

▌ Java 后端
- `路径` — 说明

▌ Python 后端
- `路径` — 说明

▌ 前端
- `路径` — 说明

【交叉验证结果】
- ✓ Java DTO ↔ 前端 interface 字段一致
- ✓ Python Schema ↔ 前端 interface 字段一致
- ✓ 后端接口路径 ↔ 前端 API service 路径一致
- ⚠ [若有差异，列出具体字段名]

下一步：运行 /dev/review-implementation <功能名称> 审查实现闭环
```

---

## 规则

- **准备阶段统一执行一次**，不在每个子 skill 中重复
- 并行模式下取消阶段间暂停确认 —— 各 Agent 独立执行
- 顺序模式下每个后端阶段完成后暂停确认
- 前端 Agent 独立从设计文档提取接口规格（第 4.1/4.2 章），不依赖后端数据存档
- 交叉验证是调度器的职责，子 skill 不做跨栈检查
- 遵守 `/dev/common` 的所有公共规则
