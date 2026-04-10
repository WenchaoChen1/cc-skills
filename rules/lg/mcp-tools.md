# MCP 工具使用规则

## Excel 处理

当用户请求「处理 Excel 文件」「帮我处理这个 Excel」「处理这个报表」等，且对话中已能列出 `process_excel` 等 CIOaaS 工具时：

1. **必须优先调用** CIOaaS MCP 的 **process_excel** 工具（`call_mcp_tool`，server: `CIOaaS`，toolName: `process_excel`，arguments: `{ "file_path": "用户提供的路径" }`）。
2. **不要**在未尝试 MCP 调用的情况下就「改用项目内 API」「编写并运行脚本」或「直接运行处理逻辑」。只有在 **call_mcp_tool 明确返回错误**（例如 server 不存在、调用失败）时，才退而求其次用本地 API/脚本处理。
3. 用户提供的文件路径可能是 Windows 路径（如 `E:\CIOass-python\xxx.xlsx`），传入时保持原样或使用双反斜杠 `E:\\path\\file.xlsx` 即可。

### 正确流程

- 用户：「帮我处理这个 Excel 文件：E:\CIOass-python\2019 Balance Sheet Detail.xlsx」
- 你先调用：`call_mcp_tool(server="CIOaaS", toolName="process_excel", arguments={"file_path": "E:\\CIOass-python\\2019 Balance Sheet Detail.xlsx"})`
- 若调用成功：直接使用返回结果并回复用户。
- 若调用失败（如 "MCP server does not exist"）：再说明 CIOaaS 不可用，并改用项目内 API/脚本处理。

### 错误做法

- 在未调用 `process_excel` 的情况下就说「CIOaaS MCP 不可用」或「我们改用项目内的 API 在本地处理」并开始写脚本。

### 若用户说「没有走 MCP / 没有调用 process_excel」——排查提示

请提醒用户按下列顺序自检（AI 只有在 Cursor 已成功加载 CIOaaS 时才能调用 process_excel）：

1. **是否在 Agent 模式**：MCP 工具仅在 Composer 的 **Agent 模式**下可用，普通聊天无法调用。
2. **CIOaaS 是否在「可用工具」中**：在对话里让用户输入「列出可用的工具」；若列表中没有 `process_excel`，说明 CIOaaS 未连接。
3. **查看 MCP 输出**：菜单 **View → Output**，选择 **MCP**，看是否有 CIOaaS 启动报错（如 Python 路径、模块导入失败）。
4. **项目打开方式**：必须用 **File → Open Folder** 打开项目根目录（如 `CIOaas-python`），这样才会加载 `.cursor/mcp.json`。
5. **重启 Cursor**：修改过 `mcp.json` 后需完全退出再打开。
6. **Windows 建议**：在 `.cursor/mcp.json` 中把 `command` 改为本机 Python 的**完整路径**（如 `C:\\Users\\xxx\\AppData\\Local\\Programs\\Python\\Python311\\python.exe`），避免 `python` 找不到或指向错误版本。

## 财务报表查询

当用户问题涉及「公司 + 时间 + 财务指标」时，使用 LGPI 的 **lgpi_company_query** 与 **lgpi_financial_statements**，**不要**依赖已废弃的 lgpi_query_financial。公司匹配由你在拿到列表后按规则完成，并自行组装 lgpi_financial_statements 的必填/可选参数。

### 典型问法

- 「帮我统计 XX 公司 2025 年第一季度总收入（Gross Revenue）」
- 「查一下 YY 公司今年的净利润」
- 「ZZ 公司 Q2 的 ARR 是多少」

关键词：财务报表、财务数据、收入、利润、Gross Revenue、Net Income、ARR、MRR、季度、年度、Q1～Q4 等。

### 正确流程

1. **调用 lgpi_company_query**（无参数）
   获取 `flattened_companies`，每项含 `id`（即 companyId）、`name`、`path`。

2. **由你按规则匹配公司**
   - 从用户表述中解析出公司名或简称（如「XX 公司」「Acme」）。
   - 匹配规则（按优先级）：
     - 优先：用户输入在某一项的 `name` 或 `path` 中**完整出现**（不区分大小写）。
     - 其次：用户输入拆成多个词，每个词都出现在该条的 `name` 或 `path` 中。
     - 再次：该条的 `name` 或 `path` 整体是用户输入的子串。
   - 选中匹配到的那一项，取其 **`id`** 作为 `company_id`。

3. **调用 lgpi_financial_statements**
   - **必填**：`company_id`（上一步得到的 id）。
   - **可选**：`from_date`（YYYY-MM-DD，如 2025-01-01）、`type`（entry|forecast|system）、`view`（Quarterly|Annually|Single）。
   从用户问题中解析时间与视图（季度/年度等），填入对应参数。

4. **根据返回做统计与回复**
   返回中有 `data_structure_for_ai`、`meta`、`rows`、`metrics_index`。由你根据说明对 `rows` 做汇总（如按季度相加）、找指标（如 Gross Revenue、Net Income），并用用户使用的语言组织回复。

### 未匹配到公司时

若在列表中找不到匹配项，不要继续调 lgpi_financial_statements。应提示用户「未找到对应公司」，并可附上部分公司名样例（来自 flattened_companies），建议用户确认名称或先查公司列表。

### 说明

- 接口**不再**在服务端按公司名自动匹配；匹配逻辑已交给 AI，请严格按上述规则用 `lgpi_company_query` + 匹配 + `lgpi_financial_statements` 组装请求。
