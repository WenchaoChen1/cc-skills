---
name: code
description: "TRIGGER: 当用户要求写代码、开发功能或开始实现时必须使用。统一代码编写技能，自动检测技术栈调度 Java/Python/前端开发"
tags: [development, coding, unified]
version: 1.0.0
author: Wenchao Chen
---

# 写代码 — 统一代码编写

统一代码编写入口。加载 dev-common 公共规范，自动检测技术栈并调度对应开发流程。

## 使用方式

```
/dev/code <功能名称或设计文档路径> [选项]
```

例如：
- `/dev/code financial-dashboard` — 自动检测技术栈，全栈开发
- `/dev/code financial-dashboard --java-only` — 仅 Java 后端
- `/dev/code financial-dashboard --python-only` — 仅 Python 后端
- `/dev/code financial-dashboard --frontend-only` — 仅前端

## 技术栈检测规则

| 条件 | 执行 |
|------|------|
| 检测到 pom.xml 或 build.gradle | Java 后端开发（遵循 backend-java 流程） |
| 检测到 requirements.txt 或 pyproject.toml | Python 后端开发（遵循 backend-python 流程） |
| 检测到 package.json + React/Vue/Angular | 前端开发（遵循 frontend 流程） |
| 设计文档涉及多个技术栈 | 按顺序：后端 → 前端 |
| 无法判断 | 调用 dev-run 智能调度器 |

## 执行流程

### 第一步：加载公共规范

加载 dev-common 公共规范，以下规则贯穿整个开发过程：

- **规则 A — 先读后写**：任何文件动笔之前，必须先读至少 2 个同类现有文件作为模式参考
- **规则 B — 改动最小化**：不修改无关文件，不做"顺便优化"
- **规则 C — 不确定时停下来问**：遇到设计文档未覆盖的问题，立即暂停并询问
- **规则 D — 从代码获取事实**：所有路径、包名、框架版本从 CLAUDE.md 和现有代码获取，不使用预设值

### 第二步：读取设计文档

1. 若有 `$ARGUMENTS`，定位 `features/<功能名称>/dev-design/dev-design-doc.md`
2. 若无参数，扫描 `features/` 列出含 `dev-design/` 子目录的功能目录
3. 提取设计文档中的关键信息：
   - 第 2 章：UI 设计（前端实现依据）
   - 第 4 章：接口设计（后端实现依据）
   - 第 5 章：数据模型
   - 第 6 章：业务规则

### 第三步：检测技术栈并调度

1. 检查项目根目录文件，匹配技术栈检测规则
2. 如果指定了 `--java-only`/`--python-only`/`--frontend-only`，跳过检测直接执行
3. 如果设计文档涉及多个技术栈，按顺序执行：后端 → 前端

### 第四步：执行开发

#### Java 后端（匹配 backend-java 流程）

1. 读取 CLAUDE.md 获取项目结构和模块信息
2. 先读 2 个同模块现有接口作为参考
3. 逐个接口实现：Controller → Service → Repository → VO/DTO
4. 实现业务规则和异常处理
5. 编译验证

#### Python 后端（匹配 backend-python 流程）

1. 读取 CLAUDE.md 获取项目结构
2. 先读 2 个同类现有路由/服务作为参考
3. 逐个接口实现：Router → Service → Schema → Model
4. 实现业务规则和异常处理
5. 运行验证

#### 前端（匹配 frontend 流程）

1. 读取 CLAUDE.md 获取前端框架和目录结构
2. 先读 1 个相似页面 + 1 个 API Service + 路由配置
3. 按顺序实现：API Service → 页面组件 → 路由注册
4. 逐条对照设计文档第 2 章的每个小节
5. 确认所有交互行为已实现

### 第五步：自检与产出

1. 编译/构建验证通过
2. 输出文件清单（新增/修改的文件列表）
3. 输出数据存档（接口清单、响应字段、业务规则）
4. 输出自检结果（对照设计文档逐项确认）

## 规则

- 严格遵守 dev-common 公共规范
- 后端实现对照设计文档第 4 章，前端实现对照第 2 章
- 不做设计文档未要求的功能
- 代码风格与现有代码保持一致
- 完成后提示：`如需审查实现，运行 /dev/review-implementation <功能名称>`
