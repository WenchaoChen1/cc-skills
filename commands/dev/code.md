# 写代码

统一代码编写入口。加载 dev-common 公共规范，自动检测技术栈并调度对应技能执行。

## 调度规则

| 条件 | 执行技能 |
|------|---------|
| 检测到 pom.xml 或 build.gradle | backend-java |
| 检测到 requirements.txt 或 pyproject.toml | backend-python |
| 检测到 package.json + React/Vue/Angular | frontend |
| 无法判断或指定了设计文档 | dev-run（智能调度） |

## 执行流程

1. 加载 dev-common 公共规范（先读后写、改动最小化）
2. 读取设计文档（`$ARGUMENTS` 指定的功能名称或文档路径）
3. 检测项目技术栈，匹配调度规则
4. 调用对应技能执行完整开发流程
5. 开发完成后输出文件清单和自检结果

## 使用示例

```
/dev/code financial-dashboard          → 自动检测技术栈并开发
/dev/code java financial-dashboard     → 强制使用 Java 后端开发
/dev/code python etl-pipeline          → 强制使用 Python 后端开发
/dev/code frontend financial-dashboard → 强制使用前端开发
```

$ARGUMENTS
