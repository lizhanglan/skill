# Skill — 个人经验大一统

跨领域个人经验的规范文档库。以规范文档为主，代码片段为辅，供 AI 编程工具读取使用。

## 给 AI 的指令

你正在读取这个 skill 仓库。请遵循以下工作方式：

1. 启动时读取本文件的「Skill 触发索引」表
2. 用户每次提问前，先匹配触发词
3. 命中触发词时，主动读取对应 skill 文档，再回答
4. 未命中时，按常规方式回答，但如果生成的内容涉及某个领域，仍应主动检查是否有对应 skill

## 目录结构

```
skill/
├── meta/              # 关于这个仓库本身的规范
├── coding/            # 编程开发相关
│   ├── backend/
│   ├── frontend/
│   ├── fullstack/
│   ├── infra/
│   ├── ai-workflow/
│   └── .adapters/     # 各 AI 工具接入模板
└── {其他领域}/        # 按需扩展
```

## 适用工具

| 工具 | 接入方式 |
|------|----------|
| Kiro | 复制 `coding/.adapters/kiro-steering.md` 到项目 `.kiro/steering/` |
| Cursor | 复制 `coding/.adapters/cursor-rules.md` 到项目 `.cursorrules` |
| Claude Code | 复制 `coding/.adapters/claude-instructions.md` 到项目 `CLAUDE.md` |
| OpenCode | 复制 `coding/.adapters/opencode-instructions.md` 到项目根目录 |

---

## Skill 触发索引

当用户提到以下关键词或场景时，读取对应的 skill 文档后再回答。

| 触发词 / 场景 | 读取文件 |
|--------------|---------|
| *(待填充，随 skill 内容同步更新)* | — |

> 维护说明：每次新增或修改 skill 文件的 `keywords` / `triggers` 字段后，同步更新此表。

---

## 内容索引

### Meta
- [如何写 Skill 文档](./meta/how-to-write-skill.md)

### Coding — Backend
- [API 设计规范](./coding/backend/api-design.md)
- [认证授权规范](./coding/backend/auth.md)
- [中间件规范](./coding/backend/middleware.md)
- [数据库规范](./coding/backend/database.md)
- [缓存策略规范](./coding/backend/cache.md)
- [错误处理规范](./coding/backend/error-handling.md)
- [日志规范](./coding/backend/logging.md)

### Coding — Frontend
- [组件设计规范](./coding/frontend/component-design.md)
- [状态管理规范](./coding/frontend/state-management.md)
- [API 客户端规范](./coding/frontend/api-client.md)
- [样式规范](./coding/frontend/styling.md)

### Coding — Fullstack
- [项目结构规范](./coding/fullstack/project-structure.md)
- [命名规范](./coding/fullstack/naming-conventions.md)
- [Git 工作流规范](./coding/fullstack/git-workflow.md)
- [安全规范](./coding/fullstack/security.md)

### Coding — Infra
- [Docker 规范](./coding/infra/docker.md)
- [CI/CD 规范](./coding/infra/cicd.md)
- [监控告警规范](./coding/infra/monitoring.md)

### Coding — AI Workflow
- [Prompt 模式](./coding/ai-workflow/prompt-patterns.md)
- [代码审查规范](./coding/ai-workflow/code-review.md)
- [AI 协作规范](./coding/ai-workflow/collaboration.md)
