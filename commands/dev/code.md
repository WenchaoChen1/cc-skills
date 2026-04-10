# 写代码

调用 code 技能，使用 coder agent 执行。等同于 `/code`。

自动检测技术栈（Java/Python/前端），加载公共规范，根据设计文档完成代码编写。

```
/dev/code financial-dashboard              → 自动检测技术栈
/dev/code financial-dashboard --java-only  → 仅 Java 后端
/dev/code financial-dashboard --python-only → 仅 Python 后端
/dev/code financial-dashboard --frontend-only → 仅前端
```

$ARGUMENTS
