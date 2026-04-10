# CIOaas-web 项目架构规范

> 完整目录树、代码示例、依赖版本见项目 `README.md`

## 1. 核心目录结构

```
src/
├── pages/{业务域}/                     # 路由级页面（按业务域组织）
│   ├── index.tsx / index.less          #   页面入口 + 样式
│   ├── types.ts / constants.ts         #   类型定义 / 页面常量
│   ├── hooks/                          #   ★ 业务逻辑（调 API、管状态）
│   └── components/                     #   ★ 展示组件（不调 API）
│       ├── XxxTable.tsx                #     组件逻辑 + JSX
│       ├── XxxTable.less               #     组件样式（CSS Modules）
│       └── hooks/useXxxTable.ts        #     组件内部 UI 交互逻辑（排序、筛选、展开收起等）
├── services/
│   ├── api/{domain}/                   #   HTTP 调用（1:1 后端接口）
│   │   ├── xxxApi.ts                   #     请求函数
│   │   ├── request.ts / response.ts    #     传输实体
│   │   └── dto.ts                      #     DTO 实体
│   ├── service/{domain}/               #   中间服务层（Response ↔ DTO 转换，多页面复用）
│   │   └── xxxService.ts
│   └── type/                           #   现有类型定义（.d.ts，历史遗留）
│       ├── index.ts                    #     统一导出入口
│       └── {domain}/xxx.d.ts
├── components/                         # 公共组件（每个组件一个目录，按类型分三种）
│   │
│   │  # ① UI 组件（有样式有 JSX）
│   │  {ComponentName}/
│   │   ├── index.tsx / XxxPart.tsx     #     组件逻辑 + JSX
│   │   ├── index.less                  #     组件样式（CSS Modules）
│   │   ├── hooks/useXxx.ts             #     组件内部 UI 交互逻辑（可选）
│   │   └── index.test.tsx              #     组件测试（可选）
│   │
│   │  # ② 逻辑组件（无样式，纯函数/纯逻辑）
│   │  {ComponentName}/
│   │   ├── index.tsx                   #     导出入口
│   │   └── xxxHelper.ts               #     纯计算/纯逻辑（无 JSX 或极少 JSX）
│   │
│   │  # ③ 简单组件（单文件）
│   │  {ComponentName}/index.tsx        #     逻辑简单时一个文件即可
│   │
│   ├── GlobalHeader/ / StepBar/        #   ① UI 组件（.tsx + .less）
│   ├── moneyFormat/                    #   ① UI 组件（金额格式化 + 样式）
│   ├── common/                         #   ① UI 组件集合（DropdownCompany、ImgUpload、ErrorBanner 等）
│   ├── Authorized/                     #   ② 逻辑组件（权限检查，纯 .tsx/.ts 无样式）
│   ├── Charts/                         #   ② 逻辑组件（ECharts 图表集合，纯 .tsx 无样式）
│   ├── PageLoading/                    #   ③ 简单组件（单 index.tsx）
│   └── HeaderDropdown/ / HeaderSearch/ / NoticeIcon/
├── models/                             # DVA 全局状态（global/login/user/setting，已冻结禁止新增）
├── layouts/                            # SecurityLayout → BasicLayout → 页面 / UserLayout → 登录页
├── utils/                              # 工具函数
│   ├── request.ts                      #   umi-request 封装（拦截器、401、错误处理）
│   ├── authority.ts / Authorized.ts    #   权限检查
│   ├── env.ts                          #   环境变量校验
│   ├── globalErrorHandler.ts           #   全局错误处理
│   └── ga4Tracking.ts / charts.ts / enum.ts / utils.ts
├── contexts/                           # React Context（CurrencyContext、MobileContext、usePermission）
├── locales/                            # 国际化（en-US / zh-CN / zh-TW / pt-BR）
└── assets/                             # 静态资源
```

## 2. services/ 业务域与后端对齐

| 前端 domain | 后端包 | 说明 |
|-------------|--------|------|
| `fi/` | `fi/` | 财务智能（Financial Intelligence） |
| `di/` | `di/` | 数据智能（Data Intelligence） |
| `quickbooks/` | `quickbooks/` | QuickBooks 集成 |
| `benchmark/` | `benchmark/` | 基准管理 |
| `system/` | `system/` | 系统管理/配置 |
| `oauth/` | `oauth/` | OAuth2 认证 |
| `index/` | `index/` | 指标/KPI 校验 |
| `storage/` | `storage/` | S3 文件存储 |
| `common/` | — | 前端通用 API（登录、用户、项目） |

新增功能的 API 须按此 domain 组织，禁止自创目录名。

## 3. 页面内部结构与业务逻辑归属

```
pages/{PageName}/
├── index.tsx                           # 页面入口（组装 Hook + Component）
├── index.less                          # 样式
├── types.ts                            # 页面类型定义
├── constants.ts                        # 页面常量
├── hooks/                              # ★ 业务逻辑写在这里
│   ├── useXxxData.ts                   #   数据获取/提交（调用 service 层，管理 loading/error/data）
│   └── useXxxForm.ts                   #   表单校验/交互（表单状态、提交处理）
└── components/                         # ★ 纯展示组件（接收 DTO props，不调 API）
    ├── XxxTable.tsx                    #   组件逻辑 + JSX
    ├── XxxTable.less                   #   组件样式（CSS Modules）
    ├── XxxModal.tsx                    #   弹窗组件（表单由 hooks/ 管理，组件只渲染）
    └── XxxModal.less
```

| 逻辑类型 | 归属位置 | 能否调 API |
|----------|----------|:----------:|
| 数据获取/提交 | `pages/hooks/useXxxData.ts` | **能** |
| 数据转换/编排 | `services/service/{domain}/` | **能** |
| 表单校验/交互 | `pages/hooks/useXxxForm.ts` | **能** |
| 组件 UI 交互（排序、筛选、展开收起、分页切换） | `components/hooks/useXxx.ts` | **否** |
| UI 展示 | `components/*.tsx`（渲染 + 事件上报） | **否** |
| 页面组装 | `index.tsx`（组合 hooks + components） | — |

> 简单的组件内部状态（如一个 `visible` 开关）直接 `useState` 写在组件内即可，不必抽 hook。当逻辑超过 ~20 行或需要在多个组件间复用时再抽到 `hooks/`。

## 4. 三层数据流

```
API 层(Request/Response) → Service 层(Response↔DTO) → Hook(业务逻辑+状态) → Component(纯展示)
```

- Service 层不接触 Request/Response，Hook 不直接调用 API 层
- 现有页面中 Hook 直接调 API 属于历史遗留，新功能必须加 Service 层

## 5. 状态管理

| 场景 | 方案 | 位置 |
|------|------|------|
| 全局（用户、登录、设置） | DVA（已冻结，禁止新增） | `src/models/` |
| 跨组件主题级（货币、权限） | React Context | `src/contexts/` |
| 页面级复杂 | `useReducer` + Hook | `pages/{Page}/hooks/` |
| 组件级简单 | `useState` | 组件内部 |

## 6. 项目特有模式

**双系统**：Admin 端（`/login`）+ Client 端（`/signin`），通过 `isAdminEnd()`/`isClientEnd()` 区分

**布局**：`SecurityLayout → BasicLayout → 页面` / `UserLayout → 登录页`

**请求**：`umi-request`（`utils/request.ts`），拦截器注入 Bearer token，401→登录，≥400→全局错误，业务错误 HTTP 200 + `success: false`

**路由权限**：`config/routes.ts` 的 `authority` 字段 + `hasAuthority()` 按钮级权限

**技术栈**：React 16 + UmiJS 3.2.27 + Ant Design Pro v4 + DVA 2.4.1 + TypeScript + Less + ECharts 5.6.0

## 7. 构建与部署

```
npm run build:{env}    # env = dev | test | staging | uat | prod
CircleCI → Docker（Node 16 构建 + Nginx 托管）→ ECR → 部署
```
