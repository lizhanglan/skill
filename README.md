# Skill — 个人经验大一统

个人全栈开发经验的规范文档库。以规范文档为主，代码片段为辅，供 AI 编程工具读取使用。

## 适用工具

| 工具 | 接入方式 |
|------|----------|
| Kiro | 复制 `.adapters/kiro-steering.md` 内容到项目 `.kiro/steering/` |
| Cursor | 复制 `.adapters/cursor-rules.md` 内容到项目 `.cursorrules` |
| Claude Code | 复制 `.adapters/claude-instructions.md` 内容到项目 `CLAUDE.md` |
| OpenCode | 复制 `.adapters/opencode-instructions.md` 内容到项目根目录 |

## 目录结构

```
skill/
├── backend/          # 后端开发规范
├── frontend/         # 前端开发规范
├── fullstack/        # 全栈通用规范
├── infra/            # 基础设施规范
├── ai-workflow/      # AI 协作工作流规范
└── .adapters/        # 各工具接入配置模板
```

## 规范文档格式

每个规范文档遵循统一结构：

```markdown
# 规范名称

## 核心原则
（3-5 条，AI 优先读取）

## 规范细则

## 反例（Anti-patterns）

## 代码示例
```

## 内容索引

### Backend
- [API 设计规范](./backend/api-design.md)
- [认证授权规范](./backend/auth.md)
- [中间件规范](./backend/middleware.md)
- [数据库规范](./backend/database.md)
- [缓存策略规范](./backend/cache.md)
- [错误处理规范](./backend/error-handling.md)
- [日志规范](./backend/logging.md)

### Frontend
- [组件设计规范](./frontend/component-design.md)
- [状态管理规范](./frontend/state-management.md)
- [API 客户端规范](./frontend/api-client.md)
- [样式规范](./frontend/styling.md)

### Fullstack
- [项目结构规范](./fullstack/project-structure.md)
- [命名规范](./fullstack/naming-conventions.md)
- [Git 工作流规范](./fullstack/git-workflow.md)
- [安全规范](./fullstack/security.md)

### Infra
- [Docker 规范](./infra/docker.md)
- [CI/CD 规范](./infra/cicd.md)
- [监控告警规范](./infra/monitoring.md)

### AI Workflow
- [Prompt 模式](./ai-workflow/prompt-patterns.md)
- [代码审查规范](./ai-workflow/code-review.md)
- [AI 协作规范](./ai-workflow/collaboration.md)
