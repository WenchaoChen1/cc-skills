---
name: run-tests
description: 自动探测并运行后端和前端测试，汇总结果并给出失败用例的修复建议
tags: [development, testing]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：本 skill 使用 `config/defaults.json` 定义的路径变量。`{features}` 默认为 `cc-cache-doc/features`。详见 `config/README.md`。

# 执行测试并报告

读取 `{features}/{name}/user-test/user-test-doc.md`，自动探测并运行后端/前端测试，汇总结果，标记失败项并给出修复建议。

## 使用方式

```
/dev/run-tests <功能名称 或 测试文件路径> [--backend-only | --frontend-only]
```

例如：
- `/dev/run-tests financial-dashboard`（按功能名称，运行全部测试）
- `/dev/run-tests financial-dashboard --backend-only`（仅后端）
- `/dev/run-tests financial-dashboard --frontend-only`（仅前端）
- `/dev/run-tests path/to/XxxServiceTest.java`（直接指定测试文件路径）

> 传入功能名称时，自动定位 `{features}/{name}/unit-test/` 索引或搜索测试文件
> 传入文件路径时，直接运行指定的测试文件，不依赖 `{features}/` 目录结构

---

## 并行策略（Agent Teams）

> 当可以启动多个并行 Agent 时（TaskCreate / Agent tool 可用），后端测试和前端测试可以同时运行。若不可用，跳过本节，按下方「执行步骤」顺序执行。
> 若传入 `--backend-only` 或 `--frontend-only`，无需并行，直接按顺序执行对应步骤。

### 并行执行流程

```
主线程（准备阶段）
  ↓ 执行第一步（确定功能目录）+ 第二步（探测测试环境）
  ├──→ Agent 后端：执行第三步（mvn test）+ 后端失败用例分析
  └──→ Agent 前端：执行第四步（npm test）+ 前端失败用例分析
  ↓ 等待两个 Agent 均完成
主线程（合并阶段）
  ↓ 合并测试结果 → 输出统一报告（第六步）
```

### Agent 后端 — 运行 Maven 测试

| 项目 | 说明 |
|------|------|
| **任务** | 在后端项目目录下运行 `mvn test` 指定测试类，收集结果，对失败用例逐一分析（读取错误信息 + 定位源码 + 给出修复建议） |
| **必须接收** | ① 后端测试文件路径列表 ② 测试运行命令 ③ 后端项目根路径 |
| **输出** | 后端测试结果表格（类名、方法名、状态、耗时）+ 失败用例分析（错误信息、原因、修复建议、文件位置） |

### Agent 前端 — 运行 npm 测试

| 项目 | 说明 |
|------|------|
| **任务** | 在前端项目目录下运行 `npm test` 指定测试文件，收集结果，对失败用例逐一分析 |
| **必须接收** | ① 前端测试文件路径列表 ② 测试运行命令 ③ 前端项目根路径 |
| **输出** | 前端测试结果表格（文件名、描述、状态）+ 失败用例分析 |

### 主线程合并阶段

1. 等待两个 Agent 均完成
2. 合并后端和前端的测试结果表格
3. 生成统一的第六步测试报告（汇总表、通过率、是否可以提测）
4. 若任一端存在编译错误，在报告中醒目标注

### 并行模式下的规则调整

- **取消**「后端测试失败率 >50% 则暂停前端测试」门控——两端同时运行，失败率统一在合并阶段判定
- **保留**逐项分析失败用例的规则——每个 Agent 内部仍然分析完一个立即输出一个

---

## 执行步骤

### 第一步：确定功能目录并读取材料

**参数解析逻辑**：

| 输入示例 | 功能名称 | 选项 |
|---------|---------|------|
| `financial-dashboard` | `financial-dashboard` | 无（运行全部） |
| `financial-dashboard --backend-only` | `financial-dashboard` | 仅后端 |
| `financial-dashboard --frontend-only` | `financial-dashboard` | 仅前端 |
| `--backend-only` | 自动检测（扫描 {features}/） | 仅后端 |
| `{features}/financial-dashboard --backend-only` | `financial-dashboard` | 仅后端 |

> `--backend-only` 和 `--frontend-only` 互斥，若同时传入，提示「`--backend-only` 和 `--frontend-only` 不能同时使用，请选择其一或不传（运行全部）」并终止。

1. 若 `$ARGUMENTS` 非空，先判断第一个非 `--` 开头参数的类型：
   - **情况 A — 指定了测试文件路径**（参数含文件扩展名如 `.java`、`.tsx`、`.ts`、`.test.js`，或指向已存在的文件路径）：
     - 直接使用指定的测试文件，**不扫描 `{features}/` 固定目录**
     - 支持多个文件路径（空格分隔），依次收集
     - **跳过下方第 3 条的索引/搜索逻辑**
   - **情况 B — 仅指定功能名称**（参数不含文件扩展名，如 `xxx` 或 `{features}/xxx`）：
     - 解析功能名称，继续执行下方第 3 条
2. 若 `$ARGUMENTS` 为空（或只有选项参数）：
   - 扫描 `{features}/` 目录，列出所有子目录
   - 若只有一个：提示「检测到 `{features}/{name}/`，是否运行该功能的测试？[Y/n]」
   - 若有多个：列出编号清单，提示用户选择
   - 若无匹配：提示「未找到功能目录，请提供功能名称」
3. **仅情况 B 和空参数时执行 — 定位测试文件**（优先索引，降级搜索）：
   - **优先**：读取 `{features}/{name}/unit-test/README.md` 测试文件索引，从中获取测试文件路径
   - **降级**（索引不存在时）：
     - 后端：在后端项目目录下搜索 `*Test.java` 文件（按功能名或接口名匹配）
     - 前端：在前端项目页面目录下搜索 `__tests__/*.test.tsx` 文件
4. 读取 `CLAUDE.md`，确认测试命令和目录结构

**文件读取容错**：
- 测试文件不存在 → 提示「未找到测试文件，请先运行 `/dev/gen-unit-test <功能名称>` 生成测试代码」，不继续后续步骤
- 测试文件索引与实际文件不一致 → 以实际文件为准，提示「索引与实际文件不一致，建议重新运行 /dev/gen-unit-test 更新索引」

**框架探测失败降级**：
- `pom.xml` 不存在或 Maven 不可用 → 提示「无法运行后端测试（Maven 不可用），跳过后端测试」
- `package.json` 不存在或 npm 不可用 → 提示「无法运行前端测试（npm 不可用），跳过前端测试」

### 第二步：探测测试环境

**后端**（读取后端项目的构建配置文件）：
- 确认测试框架（JUnit 5 / JUnit 4）
- 找到测试文件路径

**前端**（读取前端项目的 package.json）：
- 确认测试命令（`npm run test` / `npm run test:component`）
- 找到测试文件路径

### 第三步：运行后端测试

> **Agent Teams 模式**：此步骤由 Agent 后端并行执行，Agent 前端同时执行第四步（见「并行策略」章节）。

根据第二步探测到的后端语言和构建工具，选择对应的测试运行命令：

**Java（Maven）**：
```bash
mvn test -pl <模块名> -Dtest=XxxServiceTest,XxxControllerTest -q
```

**Java（Gradle）**：
```bash
./gradlew test --tests "XxxServiceTest" --tests "XxxControllerTest" -q
```

**Python（pytest）**：
```bash
pytest <测试文件路径> -v
```

若构建工具不可用或测试文件不存在，说明原因并跳过。

**后端测试完成后条件暂停**：
- 若后端测试失败率 > 50% 或存在编译错误 → 暂停并提示：
  ```
  ⚠️ 后端测试失败率较高（X/Y 失败）或存在编译错误。
  选项：A. 继续运行前端测试  B. 停止，仅输出后端测试报告  C. 先修复后端问题再继续
  ```
  等待用户选择后再决定是否执行前端测试。
- 若后端测试失败率 ≤ 50% 且无编译错误 → 自动继续前端测试

### 第四步：运行前端测试

> **Agent Teams 模式**：此步骤由 Agent 前端并行执行，不受后端测试结果门控（见「并行策略」章节）。

若有前端测试文件（`src/pages/xxx/__tests__/` 下对应文件），执行：

```bash
# 在前端项目目录下运行指定测试文件
npm run test -- --testPathPattern="xxx" --watchAll=false
```

若测试命令不可用或测试文件不存在，说明原因并跳过。

### 第五步：逐项分析失败用例（立即输出，不缓冲）

对每个失败的测试用例，**分析完一个立即输出一个**，不等所有用例分析完再统一输出：

1. 读取该用例的错误信息
2. 定位相关源码（Service/Controller/组件）
3. 分析失败原因（逻辑错误、mock 配置错误、断言条件错误等）
4. 立即输出该用例的分析结果（格式见下方报告模板中的「失败用例分析」节）
5. 继续下一个用例

> ⚠️ 原因：若失败用例较多（10+），缓冲全部分析后再输出，会导致早期用例的根因细节在上下文中淡出。逐项输出可以保证每条分析的完整性。

### 第六步：输出测试报告

```
## 测试执行报告
**功能**：<功能名称>
**执行时间**：<日期时间>

---

### 后端测试结果

**运行命令**：`mvn test -Dtest=...`

| 测试类 | 测试方法 | 状态 | 耗时 |
|--------|---------|------|------|
| XxxServiceTest | queryList_normalCase | ✅ PASSED | 12ms |
| XxxServiceTest | getById_notFound | ❌ FAILED | 5ms |
| XxxControllerTest | getList_return200 | ✅ PASSED | 45ms |

**后端统计**：总计 N 个，通过 X 个，失败 X 个，跳过 X 个

---

### 前端测试结果

**运行命令**：`npm run test -- --testPathPattern=...`

| 测试文件 | 测试描述 | 状态 |
|---------|---------|------|
| XxxPage | 应正常渲染页面标题和表格 | ✅ PASSED |
| XxxPage | 点击新增按钮应打开弹窗 | ❌ FAILED |

**前端统计**：总计 N 个，通过 X 个，失败 X 个

---

### 失败用例分析

#### ❌ XxxServiceTest.getById_notFound

**错误信息**：
```
expected: <<项目异常类>>
but was: <java.lang.NullPointerException>
```

**原因分析**：Service 层查询不到记录时直接 NullPointerException，未捕获并转换为 BusinessException

**修复建议**：
在 `XxxServiceImpl.getById()` 中添加：
```java
Xxx entity = xxxRepository.findById(id)
    .orElseThrow(() -> new BusinessException("记录不存在"));
```
**文件位置**：`<后端项目>/src/.../service/impl/XxxServiceImpl.java`

---

#### ❌ XxxPage.点击新增按钮应打开弹窗

**错误信息**：`Unable to find element with text: "新增"`

**原因分析**：组件中按钮文字为"新建"，与测试用例期望的"新增"不符

**修复建议**：
- 方案A（改测试）：将测试中 `getByText('新增')` 改为 `getByText('新建')`
- 方案B（改代码）：将组件中 `新建` 改为 `新增`（以设计文档为准，设计文档第 2.2 章写的是「新增按钮」）

---

### 汇总

| 类别 | 总计 | ✅ 通过 | ❌ 失败 | ⏭️ 跳过 |
|------|------|--------|--------|--------|
| 后端测试 | N | X | X | X |
| 前端测试 | N | X | X | X |
| **合计** | **N** | **X** | **X** | **X** |

**测试通过率**：X%

**是否可以提测**：<是 / 否，需修复 N 个失败用例>

**需要立即修复的问题（共 N 个）**：
1. <问题>
```

---

## 规则

- 测试运行失败（命令报错）与测试用例失败（断言失败）需要区分说明
- 必须读取实际错误信息再分析，不得凭猜测给出原因
- 若测试文件不存在，提示用户先运行 `/dev/gen-unit-test <功能名称>` 生成测试代码
- 修复建议必须包含具体文件路径和代码行级别的定位
- 所有测试通过后提示：`✅ 测试全部通过，功能 <name> 可以提测`
