# CIOaas-web 代码规范

## 1. REST API

- 响应格式：`{ success, code, message, data }`，空列表 `[]`，Long 用 String
- 业务错误：HTTP 200 + `success: false`，前端读 `success` 字段判断
- JSON key lowerCamelCase，时间 `"yyyy-MM-dd HH:mm:ss"`（UTC）
- 列表接口必须传分页参数，禁止前端加载全量再截取

## 2. 三层传输实体

| 实体 | 作用域 | 位置 | 命名 |
|------|--------|------|------|
| Request | 仅 API 层 | `services/api/{domain}/request.ts` | `XxxCreateRequest` |
| Response | 仅 API 层 | `services/api/{domain}/response.ts` | `XxxResponse` |
| DTO | Service/Hook | `services/api/{domain}/dto.ts` | `XxxDTO` |

- 转换链：`Request → API → Response → Service 转换 → DTO → Hook → Component`
- Service 层不接触 Request/Response
- `ApiResult<T> = { success, code, message, data: T }`
- 优先 `type`，`import type`，禁止裸 `any`

## 3. 组件与业务逻辑

- 函数组件 + Hooks，三态必处理（Loading/Error/Empty）
- `useCallback` 包裹传子组件回调
- **业务逻辑写在 `hooks/`**，组件只做展示 + 事件上报
- 公共 props 删除字段须标注 `BREAKING CHANGE`

## 4. 状态管理

- 全局 → DVA（已冻结禁止新增），跨组件 → Context，页面级 → Hook，简单 → useState

## 5. 样式

- Less + CSS Modules，颜色用变量，禁止内联样式

## 6. 命名

- 组件文件 PascalCase，工具/服务 camelCase，目录名 camelCase
- 金额禁止 `number` 直接运算（浮点精度），用字符串传输 + 展示格式化

## 7. 环境变量

- `.env`/`.env.local` 须在 `.gitignore`，仅提交 `.env.example`
- `utils/env.ts` 启动校验必填变量
- `REACT_APP_OAUTH_BASIC_AUTH` 仅存 `client_id`，禁止 `client_secret` 入前端

## 8. 安全

- `dangerouslySetInnerHTML` 禁用，富文本须 `DOMPurify.sanitize()`
- URL 参数反射到页面前须 sanitize，动态 URL 须校验站内路径防开放重定向
- Token 仅 `utils/request.ts` 读取，禁止透传到组件/console/URL
- 按钮级权限用 `hasAuthority()`，禁止组件直读 localStorage
- 文件上传须类型白名单 + 大小限制（≤ 10MB）+ 文件名 sanitize
- Nginx 须配 CSP、X-Frame-Options、X-Content-Type-Options，生产禁暴露 source map

## 9. 性能

- `dynamicImport` 按需加载，禁止 routes.ts 直接 import
- 长列表虚拟滚动，展示组件 `React.memo`，`useMemo` 限高开销派生
- 搜索/翻页 debounce（300ms），页面卸载 `AbortController` 取消请求

## 10. 错误处理

- 超时 30s + Toast，403 停留当前页，5xx Sentry 上报 + 通用提示
- 路由页顶层须 `<ErrorBoundary>` + Sentry
- `useEffect` cleanup 须取消异步（AbortController / ignore flag）
- POST 禁止自动重试

## 11. 日志

- 生产禁 `console.log`（ESLint `no-console`），Sentry `beforeSend` 过滤 PII
- GA4/New Relic 禁含 PII，上报分级：Critical→Sentry / Error→Sentry+Toast / Warning→Toast / Info→GA4

## 12. 异步

- `useEffect` 异步须 cleanup 取消（AbortController）
- 无依赖并发用 `Promise.all`，`forEach` 禁 `async` 回调
- Token 刷新防竞态（并发 401 仅发一次刷新）

## 13. 测试

- Service 转换函数 + 公共 Hook + 安全工具函数须单测，覆盖率 >= 80%
- 关键页面交互须集成测试，禁止只写快照测试
- 测试文件 `__tests__/` 或 `.test.ts(x)`，CI Jest `--coverageThreshold` 强制

## 14. 可访问性

- 交互元素语义化标签或 `aria-label`，图片须 `alt`

## 15. 国际化

- 字符串禁硬编码，`useIntl().formatMessage()`，key `{domain}.{page}.{element}`
- 新增 key 四语言同步，fallback en-US

## 16. 依赖

- 新增依赖须 `npm audit` 无 HIGH/CRITICAL CVE
- CI 运行 `npm audit --audit-level=high` 阻断，禁引入 beta/alpha/rc
