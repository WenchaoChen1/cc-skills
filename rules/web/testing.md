> 本文件扩展 [common/testing.md](../common/testing.md)，补充 Web 特定的测试内容。

# Web 测试规则

## 优先级顺序

### 1. 视觉回归测试

- 对关键断点截图：320、768、1024、1440
- 测试首屏、滚动叙事区域和有意义的状态
- 对视觉密集型工作使用 Playwright 截图
- 如果存在双主题，两个主题都要测试

### 2. 无障碍性

- 运行自动化无障碍检查
- 测试键盘导航
- 验证减弱动效行为
- 验证色彩对比度

### 3. 性能

- 对有意义的页面运行 Lighthouse 或等效工具
- 保持 [performance.md](performance.md) 中的 CWV 目标

### 4. 跨浏览器

- 最低要求：Chrome、Firefox、Safari
- 测试滚动、动效和回退行为

### 5. 响应式

- 测试 320、375、768、1024、1440、1920
- 验证无溢出
- 验证触摸交互

## E2E 测试结构

```ts
import { test, expect } from '@playwright/test';

test('landing hero loads', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('h1')).toBeVisible();
});
```

- 避免基于超时的脆弱断言
- 优先使用确定性等待

## 单元测试

- 测试工具函数、数据转换和自定义 Hooks
- 对于高度视觉化的组件，视觉回归测试通常比脆弱的标记断言更有价值
- 视觉回归测试是覆盖率目标的补充，而非替代
