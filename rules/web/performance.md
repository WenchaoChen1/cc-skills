> 本文件扩展 [common/performance.md](../common/performance.md)，补充 Web 特定的性能内容。

# Web 性能规则

## Core Web Vitals 目标

| 指标 | 目标值 |
|------|--------|
| LCP | < 2.5s |
| INP | < 200ms |
| CLS | < 0.1 |
| FCP | < 1.5s |
| TBT | < 200ms |

## 包体积预算

| 页面类型 | JS 预算（gzipped） | CSS 预算 |
|----------|---------------------|----------|
| 落地页 | < 150kb | < 30kb |
| 应用页 | < 300kb | < 50kb |
| 微站点 | < 80kb | < 15kb |

## 加载策略

1. 在合理情况下内联首屏关键 CSS
2. 仅预加载首屏图片和主字体
3. 延迟加载非关键 CSS 或 JS
4. 动态导入大型库

```js
const gsapModule = await import('gsap');
const { ScrollTrigger } = await import('gsap/ScrollTrigger');
```

## 图片优化

- 显式设置 `width` 和 `height`
- 仅对首屏媒体资源使用 `loading="eager"` 加 `fetchpriority="high"`
- 对首屏以下资源使用 `loading="lazy"`
- 优先使用 AVIF 或 WebP 格式并提供回退方案
- 切勿提供远超渲染尺寸的源图片

## 字体加载

- 最多使用两个字体族，除非有明确的例外理由
- 使用 `font-display: swap`
- 尽可能使用子集化
- 仅预加载真正关键的字重/样式

## 动画性能

- 仅对合成器友好的属性做动画
- 谨慎使用 `will-change`，完成后移除
- 简单过渡优先使用 CSS
- JS 动画使用 `requestAnimationFrame` 或成熟的动画库
- 避免滚动事件处理器的频繁触发；使用 IntersectionObserver 或行为良好的库

## 性能检查清单

- [ ] 所有图片都有显式尺寸
- [ ] 没有意外的渲染阻塞资源
- [ ] 没有因动态内容导致的布局偏移
- [ ] 动效仅使用合成器友好的属性
- [ ] 第三方脚本使用 async/defer 加载且仅在需要时加载
