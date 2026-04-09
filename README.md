# cc-skills

Claude Code 和 Cursor 的中文技能集合。

## 简介

cc-skills 是一个独立的技能（skills）插件项目，为 Claude Code 和 Cursor 提供实用的开发工作流技能。项目以中文为主要语言，持续更新升级。

## 安装

### Claude Code

```bash
# 注册 marketplace
/plugin marketplace add WenchaoChen1/cc-skills

# 安装插件
/plugin install cc-skills@cc-skills-marketplace
```

### Cursor

```
/add-plugin cc-skills
```

### 其他平台

Codex、OpenCode 等平台的支持正在规划中，详见对应目录下的 `INSTALL.md`。

## 技能列表

| 技能 | 说明 | 标签 |
|------|------|------|
| review-requirement-doc | 审查产品功能需求文档 | review, documentation, requirements |
| review-design-doc | 审查功能设计文档 | review, documentation, design |

## 技能使用

### review-requirement-doc — 审查需求文档

站在开发、QA、PM 三个角色视角，深度审查产品功能需求文档，输出按严重度排序的问题清单。

**调用方式：**
```
/review-requirement-doc <功能名称或文档路径>
```

**示例：**
- `/review-requirement-doc financial-dashboard` — 按功能名称自动定位文档
- `/review-requirement-doc path/to/requirement.md` — 指定文档路径

**审查维度：**
- 业务逻辑完备性
- 公式与计算逻辑
- UI 与文档对照
- 可测试性
- 文档结构与质量

**输出：** 按严重度分级的审查报告（🔴 阻断性 / 🟡 重要 / 🔵 改进），自动保存到 `reviews/` 目录。

### review-design-doc — 审查设计文档

读取产品需求文档和开发设计文档，检查设计是否完整覆盖需求、接口是否规范、前后端是否一致。

**调用方式：**
```
/dev/review-design-doc <功能名称或文档路径>
```

**示例：**
- `/dev/review-design-doc financial-dashboard` — 按功能名称自动定位文档
- `/dev/review-design-doc design.md requirement.md` — 指定多个文档

**审查维度：**
- 需求覆盖检查（功能点、业务规则、计算公式、异常场景）
- 接口设计审查
- 数据模型审查
- 前后端一致性检查
- UI 完整性审查
- 文档质量检查

**输出：** 包含需求覆盖矩阵的审查报告（🔴 严重 / 🟡 一般 / 🔵 建议），自动保存到 `reviews/` 目录。

## 规则系统

`rules/` 目录包含项目级编码规范和工作流约定，Claude Code 和 Cursor 会自动加载。

当前包含通用规则（`rules/common/`）：
- 编码风格
- Git 工作流
- 安全规范

未来将按需添加语言特定规则。详见 [rules/README.md](rules/README.md)。

## 项目结构

```
cc-skills/
├── .claude-plugin/     # Claude Code 插件配置和 marketplace
├── .cursor-plugin/     # Cursor 插件配置
├── .codex/             # Codex 支持（规划中）
├── .opencode/          # OpenCode 支持（规划中）
├── skills/             # 技能集合
├── agents/             # Agent 定义（预留）
├── rules/              # 编码规范和规则
├── hooks/              # 生命周期钩子
├── commands/           # 命令兼容层（预留）
├── scripts/            # 工具脚本
├── docs/               # 文档
├── CLAUDE.md           # Claude Code 入口
└── README.md           # 项目介绍
```

## 贡献

欢迎贡献新的 skill 或改进现有内容！

1. Fork 本仓库
2. 参考 `skills/_template/SKILL.md` 创建新 skill
3. 阅读 [Skill 编写指南](docs/skill-authoring-guide.md)
4. 提交 PR

## 许可证

[MIT](LICENSE)
