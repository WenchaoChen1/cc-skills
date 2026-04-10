> 本文件扩展 [common/patterns.md](../common/patterns.md)，补充 Web 特定的模式。

# Web 模式

## 组件组合

### 复合组件

当关联的 UI 共享状态和交互语义时，使用复合组件：

```tsx
<Tabs defaultValue="overview">
  <Tabs.List>
    <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
    <Tabs.Trigger value="settings">Settings</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="overview">...</Tabs.Content>
  <Tabs.Content value="settings">...</Tabs.Content>
</Tabs>
```

- 父组件拥有状态
- 子组件通过 context 消费
- 对于复杂组件，优先使用此模式而非逐层传递 props

### Render Props / 插槽

- 当行为共享但标记需要变化时，使用 render props 或插槽模式
- 将键盘处理、ARIA 和焦点管理逻辑保留在无样式（headless）层

### 容器 / 展示分离

- 容器组件负责数据加载和副作用
- 展示组件接收 props 并渲染 UI
- 展示组件应保持纯净

## 状态管理

分别对待以下关注点：

| 关注点 | 工具选型 |
|---------|---------|
| 服务端状态 | TanStack Query、SWR、tRPC |
| 客户端状态 | Zustand、Jotai、signals |
| URL 状态 | search params、路由分段 |
| 表单状态 | React Hook Form 或等效方案 |

- 不要将服务端状态复制到客户端 store 中
- 通过派生值代替存储冗余的计算状态

## URL 即状态

将可共享的状态持久化到 URL 中：
- 筛选条件
- 排序方式
- 分页
- 当前标签页
- 搜索关键词

## 数据获取

### Stale-While-Revalidate

- 立即返回缓存数据
- 在后台重新验证
- 优先使用现有库而非手动实现

### 乐观更新

- 快照当前状态
- 应用乐观更新
- 失败时回滚
- 回滚时显示可见的错误反馈

### 并行加载

- 并行获取互不依赖的数据
- 避免父子请求瀑布流
- 在合理情况下预取可能的下一个路由或状态
