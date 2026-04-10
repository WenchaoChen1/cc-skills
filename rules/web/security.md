> 本文件扩展 [common/security.md](../common/security.md)，补充 Web 特定的安全内容。

# Web 安全规则

## 内容安全策略

始终为生产环境配置 CSP。

### 基于 Nonce 的 CSP

为脚本使用每次请求的 nonce 代替 `'unsafe-inline'`。

```text
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{RANDOM}' https://cdn.jsdelivr.net;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  img-src 'self' data: https:;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://*.example.com;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
```

根据项目调整来源。不要原封不动地照搬此配置块。

## XSS 防护

- 永远不要注入未经净化的 HTML
- 避免使用 `innerHTML` / `dangerouslySetInnerHTML`，除非已先行净化
- 转义动态模板值
- 在绝对必要时使用经过验证的本地净化器来处理用户 HTML

## 第三方脚本

- 异步加载
- 从 CDN 加载时使用 SRI（子资源完整性）
- 每季度审计一次
- 对关键依赖，在可行时优先自行托管

## HTTPS 和安全头

```text
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

## 表单

- 对状态变更表单启用 CSRF 防护
- 对提交端点启用速率限制
- 客户端和服务端双重验证
- 优先使用蜜罐或轻量级反滥用控制，而非默认使用重型 CAPTCHA
