---
name: team-usage-audit
description: 生成多维度的 Claude Code 使用审计报告，覆盖所有本地项目，包含 10 个分析维度和综合评分
tags: [team, audit]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：路径 = `{根变量}/{可配变量}/固定后缀`。根变量和可配变量均可在 `cc-skills.json` 中自定义，仅后缀固定。详见 `config/README.md`。

# Claude Code 团队使用审计报告

生成多维度的 Claude Code 使用审计报告，覆盖 **所有本地项目**，包含 10 个分析维度和 0-100 综合评分。支持快速模式（默认）和深度模式（`--deep`，解析对话 JSONL）。

## 使用方式

```
/team-usage-audit                # 默认 30 天，快速模式
/team-usage-audit 14             # 最近 N 天
/team-usage-audit --deep         # 深度模式（解析对话 JSONL）
/team-usage-audit 30 --deep      # N 天 + 深度模式
```

---

## 执行步骤

### 第一步：解析参数

从 `$ARGUMENTS` 中解析：

1. **天数**：提取数字参数，默认 30
2. **--deep 标志**：是否存在 `--deep`，决定是否解析对话 JSONL
3. 计算 `START_TS` 和 `END_TS`（Unix 毫秒时间戳）
4. 获取用户名：优先 `git config user.name`，其次系统用户名

### 第二步：收集基础数据

按以下顺序读取本地数据（所有路径基于 `~/.claude/`）：

#### 2.1 读取 history.jsonl（命令历史）

**系统命令排除列表**（统计 skill 时排除以下内置 CLI 命令）：
- `/help`、`/clear`、`/compact`、`/config`、`/cost`、`/doctor`
- `/init`、`/login`、`/logout`、`/memory`、`/permissions`
- `/review`、`/status`、`/terminal-setup`、`/vim`、`/fast`
- 以及其他非 `gen-`/`review-`/`run-`/`parse-`/`req-`/`edit-`/`team-` 开头的斜杠命令

```bash
node -e "
const fs = require('fs');
const lines = fs.readFileSync(process.env.HOME + '/.claude/history.jsonl', 'utf8').trim().split('\n');
const start = $START_TS;
const end = $END_TS;
const records = lines
  .map(l => { try { return JSON.parse(l); } catch(e) { return null; } })
  .filter(r => r && r.timestamp >= start && r.timestamp <= end);
console.log(JSON.stringify(records));
"
```

从中提取：
- `display`（用户输入）、`timestamp`、`project`、`sessionId`
- 识别 skill 调用：以 `/` 开头的 display
- 识别项目分布：按 `project` 字段分组
- **工作流链检测**：按 sessionId 分组，追踪 9 阶段管道顺序

#### 2.2 读取 session-meta（会话元数据）

```bash
node -e "
const fs = require('fs');
const path = require('path');
const dir = process.env.HOME + '/.claude/usage-data/session-meta/';
const files = fs.readdirSync(dir).filter(f => f.endsWith('.json'));
const start = $START_TS;
const end = $END_TS;
const sessions = files.map(f => {
  try { return JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8')); } catch(e) { return null; }
}).filter(s => s && new Date(s.start_time).getTime() >= start && new Date(s.start_time).getTime() <= end);
console.log(JSON.stringify(sessions, null, 2));
"
```

从每个 session-meta 中提取：
- `session_id`、`project_path`、`start_time`、`duration_minutes`
- `user_message_count`、`assistant_message_count`
- `tool_counts`（工具使用次数分布）
- `input_tokens`、`output_tokens`
- `git_commits`、`git_pushes`
- `lines_added`、`lines_removed`、`files_modified`
- `first_prompt`（会话首条消息）
- `uses_task_agent`、`uses_mcp`、`uses_web_search`、`uses_web_fetch`
- `tool_errors`、`tool_error_categories`
- `message_hours`（消息发送的小时分布）

#### 2.3 读取 facets（会话质量摘要）

对 2.2 中获取的每个 `session_id`，读取 `~/.claude/usage-data/facets/` 下对应的 JSON 文件。

从每个 facets 中提取：
- `underlying_goal`、`goal_categories`
- `outcome`（achieved / mostly_achieved / partially_achieved / not_achieved）
- `session_type`、`brief_summary`
- `friction_counts`、`friction_detail`
- `helpfulness`（如存在）

### 第三步：收集扩展数据（审计专属）

#### 3.1 扫描所有项目目录

```bash
node -e "
const fs = require('fs');
const path = require('path');
const projectsDir = process.env.HOME + '/.claude/projects/';
if (!fs.existsSync(projectsDir)) { console.log('[]'); process.exit(0); }
const projects = fs.readdirSync(projectsDir)
  .filter(d => fs.statSync(path.join(projectsDir, d)).isDirectory())
  .map(d => {
    const fullPath = path.join(projectsDir, d);
    const memoryDir = path.join(fullPath, 'memory');
    const hasMemory = fs.existsSync(memoryDir);
    const memoryFiles = hasMemory ? fs.readdirSync(memoryDir).filter(f => f.endsWith('.md')) : [];
    const jsonlFiles = fs.readdirSync(fullPath).filter(f => f.endsWith('.jsonl'));
    return { name: d, path: fullPath, hasMemory, memoryCount: memoryFiles.length, sessionFiles: jsonlFiles.length };
  });
console.log(JSON.stringify(projects, null, 2));
"
```

统计：
- 总项目数（`total_projects`）
- 每个项目的 memory 文件数、对话文件数
- 在时间范围内有会话的项目数（`touched_projects`，来自 session-meta 的 project_path）

#### 3.2 [仅 --deep] 深度解析对话 JSONL

**仅在 `--deep` 模式下执行**。对时间范围内的每个 session_id，找到对应的对话 JSONL 文件并分析：

```bash
# 对每个 session_id，在 ~/.claude/projects/*/ 下查找匹配的 .jsonl 文件
# 文件名格式通常为 {session_id}.jsonl
# 解析工具调用链：提取 tool_use 类型的消息
```

深度分析指标：
- **Read-before-Edit 比率**：在每次 Edit 调用前，是否先调用了 Read 读取同一文件。计算 `有前置Read的Edit数 / 总Edit数`
- **工具调用链模式**：常见的连续工具调用序列（如 Grep→Read→Edit）
- **错误-重试模式**：工具调用失败后的重试行为
- **Agent 使用模式**：Agent 工具的调用频率和任务类型

#### 3.3 扫描 {features}/ 目录（文档产物完整性）

在当前工作目录及所有已知项目路径下扫描 `{features}/` 目录：

```bash
# 扫描当前项目和所有项目的 {features}/ 目录
# 对每个 feature 子目录，检查以下产物是否存在：
#   requirement/requirement-doc.md  (需求文档)
#   dev-design/dev-design-doc.md    (设计文档)
#   user-test/user-test-doc.md      (测试文档)
#   unit-test/                      (单元测试目录，含文件)
```

记录：
- 每个 feature 名称及其拥有的文档类型
- 文档完整率（有/应有）
- 每个文档的行数（深度指标）

#### 3.4 扫描配置与自定义

```bash
# 检查以下文件/目录是否存在及其内容
# ~/.claude/settings.json          → 全局设置自定义程度
# ~/.claude/commands/*.md           → 用户级自定义 Skill 数量
# <project>/.claude/commands/*.md   → 项目级自定义 Skill 数量
# <project>/.claude/settings.local.json → 项目设置自定义
```

统计：
- 全局 settings 是否有自定义（非默认配置项数）
- 用户级 Skill 数量
- 项目级 Skill 总数（跨所有项目）
- 是否配置了 hooks、MCP servers 等高级功能

#### 3.5 扫描 memory 文件（学习适应度）

```bash
node -e "
const fs = require('fs');
const path = require('path');
const projectsDir = process.env.HOME + '/.claude/projects/';
if (!fs.existsSync(projectsDir)) { console.log('{}'); process.exit(0); }
const result = {};
fs.readdirSync(projectsDir).forEach(d => {
  const memDir = path.join(projectsDir, d, 'memory');
  if (fs.existsSync(memDir)) {
    const files = fs.readdirSync(memDir).filter(f => f.endsWith('.md') && f !== 'MEMORY.md');
    const types = { user: 0, feedback: 0, project: 0, reference: 0 };
    files.forEach(f => {
      const content = fs.readFileSync(path.join(memDir, f), 'utf8');
      const typeMatch = content.match(/type:\\s*(user|feedback|project|reference)/);
      if (typeMatch) types[typeMatch[1]]++;
    });
    result[d] = { total: files.length, types };
  }
});
console.log(JSON.stringify(result, null, 2));
"
```

统计：
- 总 memory 文件数
- 各类型分布（user / feedback / project / reference）
- 是否覆盖多个项目

#### 3.6 采集 Git 数据

对时间范围内有会话的每个项目目录，采集 Git 历史：

```bash
# 对每个项目路径执行（使用 --no-pager）：
git --no-pager -C <project_path> log --oneline --after="$START_DATE" --before="$END_DATE" --format="%H %ai %s" 2>/dev/null
git --no-pager -C <project_path> log --after="$START_DATE" --before="$END_DATE" --shortstat 2>/dev/null
```

统计：
- 每个项目的提交数
- 总增/删行数
- 总修改文件数
- 是否有 Co-Authored-By Claude 的提交（识别 AI 辅助提交）

#### 3.7 扫描 plans 目录

```bash
# 检查 ~/.claude/plans/ 目录
# 统计 plan 文件数量和最近的 plan
```

### 第四步：10 维度聚合分析 + 综合评分

将收集的数据聚合为 10 个维度，每个维度计算 0-100 分：

#### 维度 A：基础使用量（权重 10%）

**数据源**：session-meta

| 指标 | 计算方式 |
|------|---------|
| 总会话数 | 时间范围内会话数 |
| 总消息数 | user_message_count 之和 |
| 总 Token | input_tokens + output_tokens 之和 |
| 总时长 | duration_minutes 之和 |
| 日均会话数 | 总会话数 / 天数 |

**评分规则**：
- 日均 ≥ 2 次会话 → 100 分
- 日均 1-2 次 → 75 分
- 日均 0.5-1 次 → 50 分
- 日均 < 0.5 次 → 25 分

#### 维度 B：项目覆盖度（权重 10%）

**数据源**：session-meta + projects/ 目录扫描

| 指标 | 计算方式 |
|------|---------|
| 总项目数 | projects/ 下的目录数 |
| 触达项目数 | 时间范围内有会话的项目数 |
| 各项目会话分布 | 按 project_path 分组 |
| Worktree 使用 | 是否使用过 worktree 功能 |

**评分规则**：
- `touched_projects / total_projects × 100`
- 最低 10 分（至少有使用）

#### 维度 C：工作流采纳（权重 15%）

**数据源**：history.jsonl + [--deep] 对话 JSONL

9 阶段工作流管道：
1. `/gen-requirement-doc`
2. `/review-requirement-doc`
3. `/dev/gen-design-doc`
4. `/dev/review-design-doc`
5. `/gen-user-test-doc`
6. `/dev/run`
7. `/dev/review-implementation`
8. `/dev/gen-unit-test`
9. `/dev/run-tests`

**分析指标**：
- 每个 Skill 的调用次数和频率
- 完整链完成次数（同一 feature 走完全部 9 步）
- 部分链完成次数（走完 3 步以上）
- 单步调用次数
- **掉落阶段分析**：统计每个阶段后掉落的比例，找出瓶颈

**评分规则**：
- 每次完整链 = 100 分
- 每次部分链（≥3 步）= 60 分
- 每次单步调用 = 20 分
- 取所有调用的加权平均
- 如无任何 Skill 调用 → 0 分

#### 维度 D：文档质量（权重 15%）

**数据源**：{features}/*/ 目录扫描

每个 feature 检查 4 类产物：
1. `requirement/requirement-doc.md` — 25 分
2. `dev-design/dev-design-doc.md` — 25 分
3. `user-test/user-test-doc.md` — 25 分
4. `unit-test/`（目录非空）— 25 分

**额外加分**：
- 文档行数 ≥ 50 行 → 该产物满分（深度足够）
- 文档行数 < 20 行 → 该产物扣 10 分（深度不足）
- 有 Review 记录（history 中有对应 `/review-*` 调用）→ 每次 +5 分（上限 100）

**评分规则**：
- 所有 feature 的平均文档完整度得分
- 如无 {features}/ 目录 → 标注"无文档产物"，得 0 分

#### 维度 E：工具效率（权重 10%）

**数据源**：session-meta + [--deep] 对话 JSONL

| 指标 | 计算方式 |
|------|---------|
| 工具使用分布 | tool_counts 汇总 |
| 工具错误率 | tool_errors / 总工具调用数 |
| [--deep] Read-before-Edit 比率 | 有前置 Read 的 Edit / 总 Edit |
| 高级功能采纳 | uses_mcp / uses_web_search / uses_web_fetch / uses_task_agent |

**评分规则**：
- 基础分 = 100 - (错误率 × 500)，最低 0
- [--deep] Read-before-Edit ≥ 0.8 → +20 分
- [--deep] Read-before-Edit < 0.5 → -20 分
- 每使用一项高级功能 → +10 分（最多 +40）
- 总分上限 100

#### 维度 F：代码产出（权重 10%）

**数据源**：session-meta + git log

| 指标 | 计算方式 |
|------|---------|
| 总新增行数 | lines_added 之和 |
| 总删除行数 | lines_removed 之和 |
| 总修改文件数 | files_modified 之和 |
| 总提交数 | git_commits 之和 |
| 代码密度 | 总变更行 / 总时长(小时) |
| AI 辅助提交占比 | Co-Authored-By Claude 的提交 / 总提交 |

**评分规则**：
- `min(日均变更行数 / 100 × 100, 100)`
- 日均变更行 = 总变更行 / 天数

#### 维度 G：会话质量（权重 15%）

**数据源**：facets

| 指标 | 计算方式 |
|------|---------|
| 目标达成率 | outcome 分布 |
| Helpfulness 评分 | helpfulness 字段平均值（如存在）|
| 摩擦点频率 | friction_counts 之和 / 总会话数 |
| 摩擦点类型分布 | friction_detail 汇总 |

**评分规则**：
- 每个会话按 outcome 赋分：
  - `achieved` = 100
  - `mostly_achieved` = 75
  - `partially_achieved` = 50
  - `not_achieved` = 0
- 取所有会话的加权平均
- 摩擦点频率 > 2/会话 → 扣 10 分
- 没有 facets 数据的会话不参与计算

#### 维度 H：学习适应（权重 10%）

**数据源**：memory + plans + settings + commands

| 指标 | 满分条件 | 分值 |
|------|---------|------|
| Memory 使用 | 任意项目有 memory 文件 | 25 分 |
| Plan 使用 | plans/ 目录非空 | 25 分 |
| 自定义 Skill | 有自定义 Skill 文件 | 25 分 |
| Settings 自定义 | 有非默认配置 | 25 分 |

**评分规则**：4 项各 25 分，满足即得分

#### 维度 I：使用习惯（权重 5%）

**数据源**：session-meta 的 message_hours + start_time

| 指标 | 计算方式 |
|------|---------|
| 活跃时段分布 | message_hours 汇总 |
| 会话时长分布 | duration_minutes 统计 |
| 使用一致性 | 日均会话数的标准差 |

**评分规则**：
- 一致性分 = max(0, 100 - (标准差 × 20))
- 标准差越小 → 使用越规律 → 分数越高

#### 维度 J：综合评分（汇总）

```
总分 = A×0.10 + B×0.10 + C×0.15 + D×0.15 + E×0.10 + F×0.10 + G×0.15 + H×0.10 + I×0.05

等级对照：
  A 级 = 90-100（卓越）
  B 级 = 80-89（优秀）
  C 级 = 70-79（良好）
  D 级 = 60-69（及格）
  F 级 = < 60（需改进）
```

生成 3-5 条**个性化改进建议**：
- 找出得分最低的 2-3 个维度
- 针对每个低分维度给出具体可执行的建议
- 如果综合分已很高（≥90），给出进阶优化建议

### 第五步：生成报告

将分析结果写入 Markdown 文件，路径（基于当前工作目录的绝对路径）：

```
{当前工作目录绝对路径}/usage-reports/team-audit-{用户名}-{起始日期}-{结束日期}.md
```

如果 `usage-reports/` 目录不存在则创建。

生成完成后输出完整绝对路径：

```
✅ 报告已生成：{完整绝对路径}
```

---

## 报告模板

```markdown
# Claude Code 团队使用审计报告

- **用户**：{用户名}
- **统计周期**：{起始日期} ~ {结束日期}（{N} 天）
- **分析模式**：{快速模式 / 深度模式}
- **生成时间**：{当前时间}

---

## 🏆 综合评分

```
╔══════════════════════════════════════╗
║                                      ║
║          综合评分：XX / 100          ║
║          等级：X 级                  ║
║          ★★★★☆                       ║
║                                      ║
╚══════════════════════════════════════╝
```

| 维度 | 得分 | 等级 | 评价 |
|------|------|------|------|
| A 基础使用量 | XX | X | {一句话评价} |
| B 项目覆盖度 | XX | X | {一句话评价} |
| C 工作流采纳 | XX | X | {一句话评价} |
| D 文档质量 | XX | X | {一句话评价} |
| E 工具效率 | XX | X | {一句话评价} |
| F 代码产出 | XX | X | {一句话评价} |
| G 会话质量 | XX | X | {一句话评价} |
| H 学习适应 | XX | X | {一句话评价} |
| I 使用习惯 | XX | X | {一句话评价} |

---

## A. 基础使用量（{XX}/100）

| 指标 | 数值 |
|------|------|
| 总会话数 | X |
| 总消息数 | X |
| 总 Token 消耗 | X K (输入 X K / 输出 X K) |
| 总活跃时长 | X 小时 X 分钟 |
| 日均会话数 | X.X |
| 日均消息数 | X.X |

---

## B. 项目覆盖度（{XX}/100）

| 指标 | 数值 |
|------|------|
| 已注册项目总数 | X |
| 本周期触达项目数 | X |
| 覆盖率 | XX% |

### 各项目会话分布

| 项目 | 会话数 | 消息数 | Token | 时长 |
|------|--------|--------|-------|------|
| {项目名} | X | X | X K | X 分钟 |
| ... | ... | ... | ... | ... |

---

## C. 工作流采纳（{XX}/100）

### Skill 调用统计

| Skill 名称 | 调用次数 | 占比 |
|------------|---------|------|
| /gen-requirement-doc | X | X% |
| /dev/gen-design-doc | X | X% |
| /dev/run | X | X% |
| ... | ... | ... |

### 9 阶段管道分析

```
gen-requirement-doc ──→ review-requirement-doc ──→ gen-dev-design-doc ──→ ...
       X 次                    X 次                      X 次
                   ↓ 掉落 X%                  ↓ 掉落 X%
```

| 阶段 | 进入次数 | 完成次数 | 掉落率 |
|------|---------|---------|--------|
| 1. gen-requirement-doc | X | X | X% |
| 2. review-requirement-doc | X | X | X% |
| 3. gen-dev-design-doc | X | X | X% |
| 4. review-dev-design-doc | X | X | X% |
| 5. gen-user-test-doc | X | X | X% |
| 6. run-dev-design-doc | X | X | X% |
| 7. review-implementation | X | X | X% |
| 8. gen-unit-test | X | X | X% |
| 9. run-tests | X | X | X% |

- **完整链完成**：X 次
- **部分链完成（≥3步）**：X 次
- **单步调用**：X 次

---

## D. 文档质量（{XX}/100）

### 各 Feature 文档完整性

| Feature | 需求文档 | 设计文档 | 测试文档 | 单元测试 | 完整度 |
|---------|---------|---------|---------|---------|--------|
| {feature名} | ✅ X行 | ✅ X行 | ❌ | ✅ | 75% |
| ... | ... | ... | ... | ... | ... |

### 汇总

| 指标 | 数值 |
|------|------|
| Feature 总数 | X |
| 平均文档完整度 | XX% |
| Review 执行率 | XX% |

---

## E. 工具效率（{XX}/100）

### 工具使用 Top 10

| 工具 | 调用次数 | 占比 |
|------|---------|------|
| Read | X | X% |
| Edit | X | X% |
| Bash | X | X% |
| ... | ... | ... |

### 效率指标

| 指标 | 数值 |
|------|------|
| 工具错误率 | X% |
| 高级功能使用 | MCP: {X} / Web搜索: {X} / Task Agent: {X} / Web获取: {X} |

{仅 --deep 模式显示}
### 深度分析

| 指标 | 数值 |
|------|------|
| Read-before-Edit 比率 | XX% |
| 常见工具链 | Grep→Read→Edit (X次), ... |
| 错误重试模式 | X 次 |

---

## F. 代码产出（{XX}/100）

| 指标 | 数值 |
|------|------|
| 总新增行数 | +X |
| 总删除行数 | -X |
| 总修改文件数 | X |
| 总提交数 | X |
| 日均变更行数 | X |
| 代码密度 | X 行/小时 |
| AI 辅助提交占比 | XX% |

### 各项目代码变更

| 项目 | 新增 | 删除 | 文件 | 提交 |
|------|------|------|------|------|
| {项目名} | +X | -X | X | X |
| ... | ... | ... | ... | ... |

---

## G. 会话质量（{XX}/100）

### 目标达成统计

| 结果 | 次数 | 占比 |
|------|------|------|
| ✅ 完全达成 | X | X% |
| ⚠️ 基本达成 | X | X% |
| 🔶 部分达成 | X | X% |
| ❌ 未达成 | X | X% |

### 目标分类

| 分类 | 次数 |
|------|------|
| {分类名} | X |
| ... | ... |

### 摩擦点分析

| 类型 | 次数 |
|------|------|
| {摩擦类型} | X |
| ... | ... |

**平均每会话摩擦点**：X.X

### 会话明细(给比较重要的10来条--最少  如果重要的多可增加条数)

| # | 日期 | 项目 | 目标摘要 | 结果 | 时长 |
|---|------|------|---------|------|------|
| 1 | MM-DD | {项目} | {brief_summary} | ✅ | Xm |
| ... | ... | ... | ... | ... | ... |

---

## H. 学习适应（{XX}/100）

| 能力 | 状态 | 详情 |
|------|------|------|
| Memory 使用 | ✅/❌ | X 个文件（user: X, feedback: X, project: X, reference: X）|
| Plan 使用 | ✅/❌ | X 个 plan 文件 |
| 自定义 Skill | ✅/❌ | 用户级: X 个，项目级: X 个 |
| Settings 自定义 | ✅/❌ | {自定义项描述} |

---

## I. 使用习惯（{XX}/100）

### 活跃时段分布

| 时段 | 消息数 | 活跃度 |
|------|--------|--------|
| 09:00-10:00 | X | ████████ |
| 10:00-11:00 | X | ████████████ |
| ... | ... | ... |

### 每日活跃度

| 日期 | 会话数 | 消息数 | 代码变更(+/-) |
|------|--------|--------|-------------|
| YYYY-MM-DD | X | X | +X/-X |
| ... | ... | ... | ... |

### 使用一致性

| 指标 | 数值 |
|------|------|
| 日均会话数 | X.X |
| 标准差 | X.X |
| 一致性评价 | {高/中/低} |

---

## 🎯 改进建议

基于各维度得分，提供 3-5 条个性化改进建议：

1. **{低分维度名}**：{具体可执行的改进建议}
2. **{低分维度名}**：{具体可执行的改进建议}
3. **{低分维度名}**：{具体可执行的改进建议}
{如有更多...}

---

## 📋 评分方法论

<details>
<summary>点击展开评分方法说明</summary>

### 综合评分公式

```
总分 = A×0.10 + B×0.10 + C×0.15 + D×0.15 + E×0.10 + F×0.10 + G×0.15 + H×0.10 + I×0.05
```

### 等级对照

| 等级 | 分数范围 | 含义 |
|------|---------|------|
| A | 90-100 | 卓越 — Claude Code 深度使用者 |
| B | 80-89 | 优秀 — 高效利用大部分功能 |
| C | 70-79 | 良好 — 有效使用，仍有提升空间 |
| D | 60-69 | 及格 — 基础使用，建议深化 |
| F | < 60 | 需改进 — 建议加强培训和实践 |

### 各维度评分规则

- **A 使用量**：日均 ≥2 会话=100，1-2=75，0.5-1=50，<0.5=25
- **B 覆盖度**：touched_projects / total_projects × 100（最低 10）
- **C 工作流**：完整链×100 + 部分链×60 + 单步×20，取平均（无调用=0）
- **D 文档**：每 feature 4 个产物各 25 分，Review 加分，取平均
- **E 工具效率**：100 - 错误率×500 + Read-before-Edit加减分 + 高级功能加分（上限100）
- **F 代码产出**：min(日均变更行/100 × 100, 100)
- **G 会话质量**：achieved=100, mostly=75, partial=50, not=0 取平均
- **H 学习适应**：has_memories×25 + has_plans×25 + has_custom_skills×25 + has_settings×25
- **I 使用习惯**：max(0, 100 - 标准差×20)

</details>

---

*报告由 `/team-usage-audit` 自动生成，数据均来自本地 `~/.claude/` 目录*
```

---

## 规则

1. **纯本地分析**：所有数据来自 `~/.claude/` 目录和项目本地文件，不访问任何远程 API
2. **允许读取对话内容**：`--deep` 模式下可读取对话 JSONL 文件（团队内部使用，用户已确认无隐私顾虑）
3. **容错处理**：如果某个数据源缺失（如没有 facets、没有 {features}/、没有 plans/），跳过该维度并在报告中标注"数据不可用"，对应维度给予中间分（50）
4. **时间戳处理**：history.jsonl 使用 Unix 毫秒时间戳，session-meta 使用 ISO 字符串，统一转换后比较
5. **系统命令过滤**：统计 skill 时排除 "无" 等内置 CLI 命令
6. **Git 命令**：所有 git 命令使用 `--no-pager` 参数，避免交互式输出
7. **大文件处理**：对话 JSONL 文件可能很大，先通过文件名（session_id）筛选，再逐行解析，避免一次性加载
8. **用户名获取**：优先从 `git config user.name` 获取，其次用系统用户名
9. **数字格式化**：Token 数量超过 1000 用 K 表示，超过 1000000 用 M 表示
10. **活跃度柱状图**：使用 `█` 字符按比例绘制，最长 20 个字符
11. **星级展示**：综合分对应星级：90+=★★★★★，80+=★★★★☆，70+=★★★☆☆，60+=★★☆☆☆，<60=★☆☆☆☆
12. **输出路径**：`{当前工作目录绝对路径}/usage-reports/team-audit-{用户名}-{起始日期}-{结束日期}.md`，生成完成后必须输出完整绝对路径
13. **默认周期**：30 天（区别于 usage-report 的 7 天默认）
14. **与 usage-report 的基础指标保持一致**：A 维度的总览数据应与 `/usage-report` 同周期结果一致
15. **评分公平性**：对于无法获取数据的维度（非用户未使用，而是数据源不存在），给予 50 分中间分并标注原因，不惩罚用户
