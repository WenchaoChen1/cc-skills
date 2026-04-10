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

### 产品与需求

| 技能 | 说明 |
|------|------|
| gen-requirement-doc | 生成产品功能需求文档（PRD） |
| review-requirement-doc | 审查产品功能需求文档 |

### 设计与开发

| 技能 | 说明 |
|------|------|
| gen-design-doc | 生成功能设计文档 |
| review-design-doc | 审查功能设计文档 |
| dev-common | 开发 skill 公共规范 |
| dev-run | 智能调度器，自动检测技术栈分发开发 |
| backend-java | Java 后端开发 |
| backend-python | Python 后端开发 |
| frontend | 前端开发 |
| hotfix | 快速修复 bug |
| review-implementation | 审查代码实现闭环 |

### 测试

| 技能 | 说明 |
|------|------|
| gen-unit-test | 生成自动化测试代码 |
| gen-user-test-doc | 生成手动测试文档 |
| run-tests | 执行测试并报告 |

### 团队协作

| 技能 | 说明 |
|------|------|
| team-all | 全流程串联（4 团队） |
| team-product | 产品讨论团队 |
| team-design | 技术设计团队 |
| team-code | 开发团队 |
| team-test | 测试团队 |

### 流水线与审计

| 技能 | 说明 |
|------|------|
| run-e2e-pipeline | 一键端到端开发流水线 |
| team-usage-audit | Claude Code 使用审计报告 |

### 项目管理

| 技能 | 说明 |
|------|------|
| review-asana-ticket | 审查 Asana ticket 需求质量（六维度打分） |

## Agents

13 个专业化 Agent，覆盖产品、设计、开发、测试四个团队：

| Agent | 用途 |
|-------|------|
| arch-designer | 设计编写 |
| arch-questioner | 技术疑点收集 |
| arch-reviewer | 设计审查 |
| demo-researcher | 代码研究员 |
| dev-backend | 后端开发 |
| dev-frontend | 前端开发 |
| dev-reviewer | 代码审查 |
| pm-questioner | 需求疑点收集 |
| pm-reviewer | 需求审查 |
| pm-writer | 需求编写 |
| qa-designer | 测试设计 |
| qa-developer | 测试开发 |
| qa-executor | 测试执行 |

## 技能使用示例

### review-requirement-doc — 审查需求文档

站在开发、QA、PM 三个角色视角，深度审查产品功能需求文档，输出按严重度排序的问题清单。

```
/review-requirement-doc <功能名称或文档路径>
```

**输出：** 按严重度分级的审查报告（🔴 阻断性 / 🟡 重要 / 🔵 改进），自动保存到 `reviews/` 目录。

### review-design-doc — 审查设计文档

检查设计文档是否完整覆盖需求、接口是否规范、前后端是否一致。

```
/dev/review-design-doc <功能名称或文档路径>
```

**输出：** 包含需求覆盖矩阵的审查报告（🔴 严重 / 🟡 一般 / 🔵 建议），自动保存到 `reviews/` 目录。

### team-all — 全流程串联

一键启动产品、设计、开发、测试 4 个团队完成完整功能开发。

```
/team-all <功能名称>
```

### run-e2e-pipeline — 端到端流水线

从需求材料出发，自动执行 9 步端到端开发工作流。

```
/run-e2e-pipeline <功能名称>
```

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
├── agents/             # 13 个专业化 Agent 定义
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
