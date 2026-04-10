# 路径配置

## 概述

cc-skills 的所有 skill 通过统一的路径变量引用文件位置，不硬编码路径。用户可以在个人级和项目级覆盖默认路径。

## 变量列表

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `{features}` | `cc-cache-doc/features` | 功能目录（需求/设计/测试） |
| `{rules}` | `cc-cache-doc/rules` | 项目规则 |
| `{standards}` | `cc-cache-doc/standards` | 项目规范 |
| `{personal_rules}` | `~/.cc-cache-doc/rules` | 个人规则 |
| `{personal_standards}` | `~/.cc-cache-doc/standards` | 个人规范 |

## 固定子目录（不可配置）

`{features}/{name}/` 下的子目录结构是固定约定：

```
{features}/{name}/
├── requirement/        ← 需求文档
├── dev-design/         ← 设计文档
├── reviews/            ← 审查报告
├── user-test/          ← 手动测试文档
└── unit-test/          ← 自动化测试代码
```

## 配置加载优先级

```
项目配置（最高） > 个人配置 > 插件默认值（最低）
```

| 优先级 | 配置文件位置 |
|--------|-------------|
| 1（最高） | `<project>/cc-cache-doc/cc-skills.json` |
| 2 | `~/.cc-cache-doc/cc-skills.json` |
| 3（最低） | 本目录 `defaults.json` |

## 配置文件格式

只需写要覆盖的字段，未写的自动使用默认值。

**项目配置**（`<project>/cc-cache-doc/cc-skills.json`）：

```json
{
  "project": {
    "features": "cc-cache-doc/features",
    "rules": "cc-cache-doc/rules",
    "standards": "cc-cache-doc/standards"
  }
}
```

**个人配置**（`~/.cc-cache-doc/cc-skills.json`）：

```json
{
  "personal": {
    "rules": "~/.cc-cache-doc/rules",
    "standards": "~/.cc-cache-doc/standards"
  }
}
```

## 初始化

### 项目初始化

在目标项目中创建 `cc-cache-doc/` 目录：

```bash
mkdir -p cc-cache-doc/features cc-cache-doc/rules cc-cache-doc/standards
```

如需自定义路径，创建配置文件：

```bash
cat > cc-cache-doc/cc-skills.json << 'EOF'
{
  "project": {
    "features": "cc-cache-doc/features",
    "rules": "cc-cache-doc/rules",
    "standards": "cc-cache-doc/standards"
  }
}
EOF
```

### 个人初始化

```bash
mkdir -p ~/.cc-cache-doc/rules ~/.cc-cache-doc/standards
```

如需自定义路径，创建配置文件：

```bash
cat > ~/.cc-cache-doc/cc-skills.json << 'EOF'
{
  "personal": {
    "rules": "~/.cc-cache-doc/rules",
    "standards": "~/.cc-cache-doc/standards"
  }
}
EOF
```

## 兼容性

`~/.cc-cache-doc/` 是独立目录，不在任何 IDE 特定目录下。Claude Code、Cursor、Codex 等工具共享同一份配置。
