---
name: code
description: "TRIGGER: 当用户要求写代码、开发功能或开始实现时必须使用。统一代码编写技能，自动检测技术栈调度 Java/Python/前端开发"
tags: [development, coding, unified]
version: 1.0.0
author: Wenchao Chen
---

# 写代码 — 统一代码编写

统一代码编写入口。加载路径配置和规则，自动检测技术栈，根据设计文档完成代码编写。

> **本 skill 包含以下子文件**：
> - `common.md` — 公共开发规范（始终加载）
> - `java.md` — Java 后端实现逻辑
> - `python.md` — Python 后端实现逻辑
> - `frontend.md` — 前端实现逻辑
> - `run.md` — 调度与合并逻辑

## 使用方式

```
/code <功能名称> [--java-only | --python-only | --frontend-only | --backend-only]
```

例如：
- `/code financial-dashboard`（自动检测，全栈开发）
- `/code forecast-engine --python-only`（仅 Python 后端）
- `/code benchmark-entry --backend-only`（仅后端，自动检测 Java/Python）
- `/code 财务看板 --frontend-only`（仅前端）

---

## 执行流程

```
第零步：加载路径配置
    ↓
第一步：加载规则（rules）
    ↓
第二步：加载公共规范（common.md）
    ↓
第三步：读取材料（CLAUDE.md + 设计文档 + 需求文档）
    ↓
第四步：检测技术栈
    ↓
第五步：探索现有代码模式
    ↓
第六步：执行开发（路由到 java.md / python.md / frontend.md）
    ↓
第七步：合并与交叉验证（run.md）
```

---

## 第零步：加载路径配置

> **最先执行，不可跳过。后续所有路径从此配置获取。**
> 详见 `config/README.md`。

从用户的 `cc-skills.json` 配置文件读取路径变量（`{project_root}`、`{personal_root}`、`{features}`、`{rules}`、`{standards}`），后续所有 `{变量}` 引用的路径均从此配置获取。

---

## 第一步：加载规则

> **不可跳过。**

### 1-A. 加载项目规则

按优先级搜索并加载：

| 优先级 | 位置 | 说明 |
|--------|------|------|
| 1（最高） | `{standards}` | 项目规范（architecture.md、coding.md、git.md） |
| 2 | `{rules}` | 项目规则 |
| 3 | `{personal_rules}` | 个人规则 |
| 4（最低） | 本插件 `rules/` 目录 | 插件自带规则（兜底） |

### 1-B. 按技术栈加载语言规则

| 技术栈 | 规则目录 |
|--------|---------|
| Java | `rules/java/` |
| Python | `rules/python/` |
| TypeScript/JavaScript | `rules/typescript/` + `rules/web/` |

### 1-C. 加载通用规则

始终加载 `rules/common/`。

冲突时：项目规则 > 语言规则 > 通用规则。

---

## 第二步：加载公共规范

> 加载本目录下 `common.md`，以下规则贯穿整个开发过程。

- **规则 A — 先读后写**：任何文件动笔之前，必须先读至少 2 个同类现有文件
- **规则 B — 改动最小化**：不修改无关文件，不做"顺便优化"
- **规则 C — 不确定时停下来问**：设计文档未覆盖的问题，暂停询问
- **规则 D — 输出可追溯**：每阶段输出文件清单和自检结果

详细规范见 `common.md`。

---

## 第三步：读取材料

### 3-A. 读 CLAUDE.md + 代码规范

读取项目 `CLAUDE.md`，了解技术栈、目录结构、构建命令。
读取 `{standards}` 下的代码规范（优先级：子项目 > 项目 > 个人）。

> 后续所有路径、包名、框架版本以 CLAUDE.md 和实际代码为准，**不使用预设值**。

### 3-B. 读设计文档

读取 `{features}/{name}/dev-design/` 目录下所有文件，提取：
- 后端接口列表（第 4 章）
- 数据库表结构（第 5 章）
- 前端页面路由（第 2、3 章）
- 业务规则和异常处理（第 6、7 章）

**容错**：
- 目录不存在 → 提示「缺少设计文档，请先生成设计文档」，终止
- 文件为空 → 提示「文件存在但内容为空」

### 3-C. 读需求文档（补充）

若 `{features}/{name}/requirement/` 存在，补充边界条件、必填规则、权限。

---

## 第四步：检测技术栈

从 CLAUDE.md 和设计文档判断涉及哪些技术栈：

| 判断条件 | 技术栈 |
|---------|--------|
| 设计文档第 4 章涉及 Java 后端项目 | → 加载 `java.md` |
| 设计文档第 4 章涉及 Python 后端项目 | → 加载 `python.md` |
| 设计文档有第 2/3 章（UI/前端） | → 加载 `frontend.md` |

输出检测结果，等待用户确认。`--java-only` 等参数可跳过检测。

---

## 第五步：探索现有代码模式

按检测到的技术栈，读取对应参考文件（详见各子文件中的「前置信息提取」章节）。

---

## 第六步：执行开发

根据检测结果路由到对应子文件执行：

| 技术栈 | 子文件 | 实现流程 |
|--------|--------|---------|
| Java 后端 | `java.md` | DDL → Entity → Repository → DTO → Mapper → Service → Controller → 自检 |
| Python 后端 | `python.md` | Model → Schema → Service → Router → 注册路由 → 自检 |
| 前端 | `frontend.md` | API Service → 页面组件 → 路由注册 → 自检 |

### 并行模式（并行代理可用时）
同时启动所有涉及技术栈的代理并行执行。

### 顺序模式
按顺序：Java 后端 → Python 后端 → 前端，每个后端完成后等待确认。

---

## 第七步：合并与交叉验证

> 使用 `run.md` 中的合并逻辑。

1. 合并所有技术栈的文件清单
2. 交叉验证：
   - 后端 DTO/Schema 字段名 vs 前端 TypeScript interface 字段名
   - 后端接口路径 vs 前端 API service 路径
3. 不一致项列出，等待用户确认

---

## 输出格式

```
### 开发完成 ✓

【技术栈范围】
- Java 后端：✅/❌
- Python 后端：✅/❌
- 前端：✅/❌

【合并文件清单】
▌ Java 后端
- `路径` — 说明
▌ Python 后端
- `路径` — 说明
▌ 前端
- `路径` — 说明

【交叉验证结果】
- ✓/⚠ 字段名一致性
- ✓/⚠ 接口路径一致性

下一步：/dev/review-implementation {name}
```

---

## 规则

- **第零步加载配置、第一步加载规则均不可跳过**
- 所有路径从配置获取，不硬编码
- 公共规范统一执行一次，不在每个技术栈中重复
- 后端实现对照设计文档第 4 章，前端实现对照第 2 章
- 不做设计文档未要求的功能
- 代码风格与现有代码保持一致
- 交叉验证是本 skill 的职责，子文件不做跨栈检查

$ARGUMENTS
