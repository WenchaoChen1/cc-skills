# 代码审查标准

## 目的

代码审查确保代码在合并前具备质量、安全性和可维护性。本规则定义了何时以及如何进行代码审查。

## 何时进行审查

**必须审查的触发条件：**

- 编写或修改代码之后
- 向共享分支提交代码之前
- 修改安全敏感代码时（认证、支付、用户数据）
- 进行架构变更时
- 合并 Pull Request 之前

**审查前置要求：**

在请求审查之前，请确保：

- 所有自动化检查（CI/CD）已通过
- 合并冲突已解决
- 分支已与目标分支保持同步

## 审查清单

在标记代码完成之前：

- [ ] 代码可读性好且命名规范
- [ ] 函数职责单一（<50 行）
- [ ] 文件内聚性高（<800 行）
- [ ] 无深层嵌套（>4 层）
- [ ] 错误已显式处理
- [ ] 无硬编码的密钥或凭证
- [ ] 无 console.log 或调试语句
- [ ] 新功能已编写测试
- [ ] 测试覆盖率达到 80% 以上

## 安全审查触发条件

**遇到以下情况时，停下来使用 security-reviewer agent：**

- 认证或授权代码
- 用户输入处理
- 数据库查询
- 文件系统操作
- 外部 API 调用
- 加密操作
- 支付或金融代码

## 审查严重级别

| 级别 | 含义 | 处理方式 |
|------|------|----------|
| CRITICAL | 安全漏洞或数据丢失风险 | **BLOCK** - 合并前必须修复 |
| HIGH | Bug 或重大质量问题 | **WARN** - 合并前应当修复 |
| MEDIUM | 可维护性问题 | **INFO** - 建议修复 |
| LOW | 风格或次要建议 | **NOTE** - 可选 |

## Agent 使用

使用以下 agent 进行代码审查：

| Agent | 用途 |
|-------|------|
| **code-reviewer** | 通用代码质量、模式、最佳实践 |
| **security-reviewer** | 安全漏洞、OWASP Top 10 |
| **typescript-reviewer** | TypeScript/JavaScript 特定问题 |
| **python-reviewer** | Python 特定问题 |
| **go-reviewer** | Go 特定问题 |
| **rust-reviewer** | Rust 特定问题 |

## 审查工作流

```
1. Run git diff to understand changes
2. Check security checklist first
3. Review code quality checklist
4. Run relevant tests
5. Verify coverage >= 80%
6. Use appropriate agent for detailed review
```

## 常见问题排查

### 安全

- 硬编码凭证（API keys、密码、tokens）
- SQL 注入（查询中使用字符串拼接）
- XSS 漏洞（未转义的用户输入）
- 路径遍历（未过滤的文件路径）
- 缺少 CSRF 防护
- 认证绕过

### 代码质量

- 函数过长（>50 行）- 拆分为更小的函数
- 文件过大（>800 行）- 提取模块
- 深层嵌套（>4 层）- 使用提前返回
- 缺少错误处理 - 显式处理
- 可变模式 - 优先使用不可变操作
- 缺少测试 - 增加测试覆盖

### 性能

- N+1 查询 - 使用 JOIN 或批量查询
- 缺少分页 - 为查询添加 LIMIT
- 无界查询 - 添加约束条件
- 缺少缓存 - 缓存高开销操作

## 审批标准

- **通过**：无 CRITICAL 或 HIGH 问题
- **警告**：仅有 HIGH 问题（谨慎合并）
- **阻止**：发现 CRITICAL 问题

## 与其他规则的集成

本规则与以下规则配合使用：

- [testing.md](testing.md) - 测试覆盖率要求
- [security.md](security.md) - 安全检查清单
- [git-workflow.md](git-workflow.md) - 提交规范
- [agents.md](agents.md) - Agent 委派
