# Skill — 个人经验大一统

跨领域个人经验的规范文档库。以规范文档为主，代码片段为辅，供 AI 编程工具读取使用。

## 给 AI 的指令

你正在读取这个 skill 仓库。请遵循以下工作方式：

1. 启动时读取本文件的「Skill 触发索引」表
2. 用户每次提问前，先匹配触发词
3. 命中触发词时，主动读取对应 skill 文档，再回答
4. 未命中时，按常规方式回答，但如果生成的内容涉及某个领域，仍应主动检查是否有对应 skill
5. 新增或修改任何 skill 文件后，必须同步更新本文件的「Skill 触发索引」表，将该文件的 keywords 和 triggers 字段合并写入对应行

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
| 中间件、middleware、认证、JWT、API Key、限流、rate limit、输入验证、XSS、SQL注入、CORS、CSRF、GZip、缓存中间件、ETag、Metrics、链路追踪、多租户、Feature Flag、设计中间件、写认证逻辑、实现限流、防止API滥用、保护接口安全、跨域问题、响应压缩、接口监控、多租户隔离、灰度发布 | [coding/backend/middleware.md](./coding/backend/middleware.md) |

> 维护说明：每次新增或修改 skill 文件的 `keywords` / `triggers` 字段后，同步更新此表。

---

## 内容索引

### Meta
- [如何写 Skill 文档](./meta/how-to-write-skill.md)

### Coding — Backend
- [中间件规范](./coding/backend/middleware.md)
