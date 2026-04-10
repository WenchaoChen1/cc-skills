---
name: gen-unit-test
description: 根据需求文档和设计文档，自动探测测试框架并生成后端单元测试和前端组件测试代码
tags: [development, testing, unit-test]
version: 1.0.0
author: Wenchao Chen
---

> **路径变量**：路径 = `{根变量}/{可配变量}/固定后缀`。根变量和可配变量均可在 `cc-skills.json` 中自定义，仅后缀固定。详见 `config/README.md`。

# 生成自动化测试代码

根据 `{features}/{name}/` 下的需求文档和设计文档，自动探测项目测试框架，生成后端单元测试、接口测试和前端组件测试代码，写入各代码仓库。

## 使用方式

```
/dev/gen-unit-test <功能名称 或 文档路径>
```

例如：
- `/dev/gen-unit-test financial-dashboard` — 按功能名称，自动读取 `{features}/` 下对应目录
- `/dev/gen-unit-test 财务看板`
- `/dev/gen-unit-test path/to/design-doc.md` — 直接指定设计文档路径
- `/dev/gen-unit-test design.md requirement.md` — 同时指定多个文档

> 传入功能名称时，自动读取 `{features}/{name}/dev-design/` 和 `{features}/{name}/requirement/` 目录
> 传入文件路径时，直接读取指定文件，不依赖 `{features}/` 目录结构

---

## 并行策略（Agent Teams）

> 当可以启动多个并行 Agent 时（TaskCreate / Agent tool 可用），后端测试和前端测试可以同时生成。若不可用，跳过本节，按下方「执行步骤」顺序执行。

### 并行执行流程

```
主线程（准备阶段）
  ↓ 执行第一步（读取材料）+ 第二步（探测测试框架）
  ├──→ Agent 后端：执行第三步（生成后端测试）
  └──→ Agent 前端：执行第四步（生成前端测试）
  ↓ 等待两个 Agent 均完成
主线程（合并阶段）
  ↓ 执行第五步（写入文件）+ 第六步（写入索引）
```

### Agent 后端 — 生成后端测试

| 项目 | 说明 |
|------|------|
| **任务** | 执行第三步全部内容（3-A Service 单元测试 + 3-B Controller/Router 集成测试） |
| **必须读取** | ① 设计文档第 4 章（接口规格）、第 6 章（计算公式）、第 7 章（异常处理） ② 需求文档第 2 章（使用场景）、第 5 章（业务规则/边界条件）（若存在） ③ 后端测试框架探测结果 ④ 一个现有后端测试文件（参照命名和包结构） |
| **输出** | 后端测试文件的完整代码内容 |

### Agent 前端 — 生成前端测试

| 项目 | 说明 |
|------|------|
| **任务** | 执行第四步全部内容（渲染/交互/API调用/空态/加载态测试） |
| **必须读取** | ① 设计文档第 2.4 章（交互行为）、第 2.5 章（空态/加载态） ② 前端测试框架探测结果 ③ 一个现有前端测试文件（参照风格） |
| **输出** | 前端测试文件的完整代码内容 |

### 主线程合并阶段

1. 等待两个 Agent 均完成
2. 询问用户确认后，将测试代码写入对应位置（第五步）
3. 生成 `{features}/{name}/unit-test/README.md` 测试文件索引（第六步）

---

## 执行步骤

### 第一步：读取材料

1. 若 `$ARGUMENTS` 非空，先判断参数类型：
   - **情况 A — 指定了文档路径**（参数含文件扩展名如 `.md`、`.docx`、`.txt`，或指向已存在的文件路径）：
     - 直接读取指定文件作为输入材料，**不扫描 `{features}/` 固定目录**
     - 支持多个文件路径（空格分隔），依次读取
     - 测试代码仍写入代码仓库对应位置，索引保存到文档所在目录的同级 `unit-test/` 下
   - **情况 B — 仅指定功能名称**（参数不含文件扩展名，如 `xxx` 或 `{features}/xxx`）：
     - 解析功能名称，自动读取 `{features}/{name}/dev-design/` 和 `{features}/{name}/requirement/` 目录
2. 若 `$ARGUMENTS` 为空：
   - 扫描 `{features}/` 目录，列出含 `dev-design/` 子目录的功能目录
   - 若只有一个：提示「检测到 `{features}/{name}/`，是否为该功能生成单元测试？[Y/n]」
   - 若有多个：列出编号清单，提示用户选择
   - 若无匹配：提示「未找到设计文档，请先运行 /dev/gen-design-doc」
3. **文件读取容错**：
   - `dev-design/` 目录不存在 → 提示「缺少设计文档，请先运行 `/dev/gen-design-doc <功能名称>`」，不继续后续步骤
   - `requirement/` 目录不存在 → 提示「缺少需求文档，仅基于设计文档生成测试」，继续执行
   - 文件存在但内容为空 → 提示「文件存在但内容为空，请检查对应文件」
   - 编码问题（乱码） → 提示「文件编码异常，建议重新保存为 UTF-8」
4. **重复创建检查**：在代码仓库中检查是否已存在对应的测试文件（`XxxServiceTest.java` / `index.test.tsx`）：
   ```
   ⚠️ 测试文件已存在：<文件路径>
   选项：A. 覆盖（原文件被替换）  B. 取消（默认）  C. 查看现有文件内容
   ```
   等待用户选择，默认取消。
5. **仅情况 B 和空参数时执行** — 读取以下目录下所有文件（逐一读取）：
   - `{features}/{name}/dev-design/`（接口规格、数据模型、业务规则）
   - `{features}/{name}/requirement/`（若存在，补充测试场景：重点关注第 2 章使用场景、第 5 章业务规则和第 5.4 章边界条件）
6. 读取 `CLAUDE.md`，了解技术栈和目录结构

### 第二步：自动探测测试框架

**Java 后端探测**（读取 `pom.xml` 或 `build.gradle`）：
- 有 `spring-boot-starter-test` → Spring Boot Test + JUnit 5 + Mockito
- 有 `junit-jupiter` → JUnit 5
- 有 `junit` (4.x) → JUnit 4
- 有 `rest-assured` → RestAssured 集成测试

**Python 后端探测**（读取 `requirements.txt` / `pyproject.toml` / `setup.cfg`）：
- 有 `pytest` → pytest（优先）
- 有 `pytest-asyncio` → pytest + 异步支持
- 有 `unittest`（标准库） → unittest
- 有 `httpx` → HTTPX TestClient（FastAPI 项目常用）

**前端探测**（读取 `package.json`）：
- 有 `@testing-library/react` 或 `@testing-library/vue` → Testing Library
- 有 `jest` / `jest-dom` → Jest
- 有 `vitest` → Vitest
- 有 `puppeteer` / `@umijs/test` → UmiJS 测试

**若无法探测**，提示用户确认框架后再生成，不使用默认值盲写。

**框架探测失败降级**：
- 构建配置文件不存在或解析失败 → 提示「无法探测后端测试框架，请告知使用的测试框架（如 JUnit 5 / pytest / 其他）」
- `package.json` 不存在或解析失败 → 提示「无法探测前端测试框架，请告知使用的测试框架（如 Jest / Vitest / 其他）」
- 若探测到的框架版本与常见模板不兼容（如 JUnit 4 vs JUnit 5），明确提示差异并调整生成的代码风格

### 第三步：生成后端测试

> **Agent Teams 模式**：此步骤由 Agent 后端并行执行，Agent 前端同时执行第四步（见「并行策略」章节）。
> 根据第二步探测到的后端语言和测试框架，选择对应分支。

#### 3-A. Service/业务逻辑层 单元测试

对设计文档第 4 章的每个接口，为其业务逻辑层生成单元测试：

覆盖场景：
1. **正常流程**：标准输入 → 预期返回
2. **边界条件**：空列表、零值、最大值
3. **异常场景**：数据不存在（抛项目约定的异常）、参数非法
4. **计算公式**：若设计文档第 6 章有公式，验证计算正确性

测试文件路径：参照现有测试文件位置和命名规则。

**Java 示例**（具体注解和风格以探测结果为准）：
```java
// JUnit 5 + Mockito 示例
@ExtendWith(MockitoExtension.class)
class XxxServiceTest {
    @Mock private XxxRepository xxxRepository;
    @InjectMocks private XxxServiceImpl xxxService;

    @Test
    @DisplayName("正常查询 - 返回分页数据")
    void queryList_normalCase_returnPageData() { ... }
}
```

**Python 示例**（具体 fixture 和风格以探测结果为准）：
```python
# pytest 示例
import pytest
from unittest.mock import MagicMock, patch

class TestXxxService:
    def test_query_list_normal_case(self):
        """正常查询 - 返回分页数据"""
        ...

    def test_get_by_id_not_found(self):
        """查询不存在的记录 - 抛出异常"""
        with pytest.raises(HTTPException):
            ...
```

#### 3-B. 接口层 集成测试

对每个接口生成集成测试（Java 用 MockMvc / Python 用 TestClient 等，以探测结果为准）：

覆盖场景：
1. 正常请求 → HTTP 200 + 正确响应结构
2. 缺少必填参数 → HTTP 400/422
3. 不存在的资源 → HTTP 404
4. 无权限访问 → HTTP 401/403（若有权限控制）

### 第四步：生成前端测试

> **Agent Teams 模式**：此步骤由 Agent 前端并行执行（见「并行策略」章节）。

对设计文档第 2.4 章（交互行为）的每条交互生成组件测试：

覆盖场景：
1. **渲染测试**：组件正常渲染，包含关键 UI 元素
2. **交互测试**：点击按钮/触发事件后状态变化正确
3. **API 调用测试**：mock service 层，验证调用参数正确
4. **空态测试**：数据为空时显示正确的空态
5. **加载态测试**：请求中显示 loading

**示例**（具体框架以探测结果为准）：
```typescript
// Jest + Testing Library 示例
describe('XxxPage', () => {
  it('应正常渲染页面标题和表格', () => { ... })
  it('点击新增按钮应打开弹窗', async () => { ... })
  it('筛选条件变化应重新请求数据', async () => { ... })
  it('无数据时应显示空态提示', () => { ... })
})
```

### 第五步：写入测试代码文件

询问用户确认后，将测试代码写入：
- 后端：`<后端项目>/.../test/.../XxxServiceTest.java`
- 前端：`<前端项目>/src/pages/xxx/__tests__/index.test.tsx`

写入前先读一个同类现有测试文件，参照其命名和包结构风格。

### 第六步：写入测试文件索引

**索引保存路径**：
- 情况 B / 空参数：`{features}/{name}/unit-test/README.md`
- 情况 A：文档所在目录的同级 `unit-test/README.md`

写入测试文件路径索引，格式如下：

```markdown
# 测试文件索引

**功能**：<功能名称>
**生成时间**：<日期>

## 后端测试
- `<后端项目>/.../XxxServiceTest.java` — Service 单元测试
- `<后端项目>/.../XxxControllerTest.java` — Controller 集成测试

## 前端测试
- `<前端项目>/src/pages/xxx/__tests__/index.test.tsx` — 页面组件测试
```

> 此索引供 `/dev/run-tests` 快速定位测试文件，避免全局搜索。

---

## 规则

- 每个测试用例必须有明确的「输入」和「预期输出」
- 设计文档第 6 章的计算公式必须有对应的单元测试验证
- 异常场景测试必须覆盖设计文档第 7 章的全部场景
- 生成代码时遵循项目现有测试文件的命名和包结构风格（先读一个现有测试文件参考）
- 完成后提示：`测试代码已生成，运行 /dev/run-tests <功能名称> 执行测试`
