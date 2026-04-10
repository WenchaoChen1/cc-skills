# 规则

## 结构

规则按照 **common（通用）** 层加上 **特定语言** 目录组织：

```
rules/
├── common/          # 语言无关的原则（始终安装）
│   ├── coding-style.md
│   ├── git-workflow.md
│   ├── testing.md
│   ├── performance.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── agents.md
│   └── security.md
├── typescript/      # TypeScript/JavaScript 特定
├── python/          # Python 特定
├── golang/          # Go 特定
├── web/             # Web 和前端特定
├── swift/           # Swift 特定
└── php/             # PHP 特定
```

- **common/** 包含通用原则 — 不含特定语言的代码示例。
- **语言目录** 扩展通用规则，补充特定框架的模式、工具和代码示例。每个文件都引用其对应的通用文件。

## 安装

### 方式一：安装脚本（推荐）

```bash
# 安装 common + 一个或多个特定语言的规则集
./install.sh typescript
./install.sh python
./install.sh golang
./install.sh web
./install.sh swift
./install.sh php

# 一次安装多个语言
./install.sh typescript python
```

### 方式二：手动安装

> **重要：** 复制整个目录 — 不要用 `/*` 展平。
> common 和语言特定目录包含同名文件。
> 将它们展平到同一目录会导致语言特定文件覆盖通用规则，
> 并破坏语言特定文件中使用的 `../common/` 相对引用。

```bash
# 安装通用规则（所有项目必需）
cp -r rules/common ~/.claude/rules/common

# 根据项目技术栈安装语言特定规则
cp -r rules/typescript ~/.claude/rules/typescript
cp -r rules/python ~/.claude/rules/python
cp -r rules/golang ~/.claude/rules/golang
cp -r rules/web ~/.claude/rules/web
cp -r rules/swift ~/.claude/rules/swift
cp -r rules/php ~/.claude/rules/php

# 注意！！！请根据实际项目需求配置；此处配置仅供参考。
```

## 规则与技能的区别

- **规则** 定义广泛适用的标准、规范和检查清单（例如"80% 测试覆盖率"、"不硬编码密钥"）。
- **技能**（`skills/` 目录）为特定任务提供深入、可操作的参考材料（例如 `python-patterns`、`golang-testing`）。

语言特定的规则文件会在适当之处引用相关技能。规则告诉你 *做什么*；技能告诉你 *怎么做*。

## 添加新语言

要添加对新语言的支持（例如 `rust/`）：

1. 创建 `rules/rust/` 目录
2. 添加扩展通用规则的文件：
   - `coding-style.md` — 格式化工具、惯用法、错误处理模式
   - `testing.md` — 测试框架、覆盖率工具、测试组织
   - `patterns.md` — 语言特定的设计模式
   - `hooks.md` — 用于格式化器、lint 工具、类型检查器的 PostToolUse Hooks
   - `security.md` — 密钥管理、安全扫描工具
3. 每个文件应以如下内容开头：
   ```
   > This file extends [common/xxx.md](../common/xxx.md) with <Language> specific content.
   ```
4. 如果有可用的技能则引用，否则在 `skills/` 下创建新技能。

对于 `web/` 这类非语言领域，当有足够可复用的领域特定指南值得独立成规则集时，也遵循相同的分层模式。

## 规则优先级

当语言特定规则与通用规则冲突时，**语言特定规则优先**（具体覆盖通用）。这遵循标准的分层配置模式（类似于 CSS 特异性或 `.gitignore` 优先级）。

- `rules/common/` 定义适用于所有项目的通用默认值。
- `rules/golang/`、`rules/python/`、`rules/swift/`、`rules/php/`、`rules/typescript/` 等在语言惯用法不同的地方覆盖这些默认值。

### 示例

`common/coding-style.md` 推荐不可变性作为默认原则。语言特定的 `golang/coding-style.md` 可以覆盖此规则：

> 惯用的 Go 使用指针接收器进行结构体修改 — 通用原则参见 [common/coding-style.md](../common/coding-style.md)，但此处优先采用 Go 惯用的修改方式。

### 带覆盖说明的通用规则

`rules/common/` 中可能被语言特定文件覆盖的规则标注有：

> **语言说明**：对于该模式非惯用的语言，此规则可能被语言特定规则覆盖。
