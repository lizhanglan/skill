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
| coding-agent、编码代理、Codex、Claude Code、OpenCode、Pi、后台进程、并行处理、git worktree、PR 审查、重构、大型代码库、多代理、批处理、使用 Codex、使用 Claude Code、使用 OpenCode、使用 Pi、启动编码代理、后台运行 AI、并行处理任务、审查 PR、重构代码、批处理任务、多代理工作流、git worktree、临时目录工作 | [coding/ai-workflow/coding-agent.md](./coding/ai-workflow/coding-agent.md) |
| skill-creator、技能创建、技能编写、技能审核、技能改进、技能清理、技能重构、AgentSkills、SKILL.md、技能规范、技能模板、技能打包、创建技能、编写技能、审核技能、改进技能、清理技能、重构技能、更新技能、打包技能、验证技能、技能模板、技能规范 | [coding/ai-workflow/skill-creator.md](./coding/ai-workflow/skill-creator.md) |
| find-skills、技能发现、技能搜索、技能安装、npx skills、skills.sh、技能生态系统、技能包管理器、扩展能力、技能查找、技能推荐、如何做 X、查找 X 的技能、有技能可以做 X 吗、你能做 X 吗、扩展能力、搜索工具、搜索模板、搜索工作流、安装技能、更新技能、检查技能更新 | [coding/agent-management/find-skills.md](./coding/agent-management/find-skills.md) |
| self-improvement、自我改进、学习记录、错误记录、功能请求、知识更新、最佳实践、模式检测、技能提取、持续改进、学习循环、命令失败、操作失败、用户纠正、知识过时、API 失败、工具失败、发现更好方法、记录学习、记录错误、记录功能请求、改进工作流、简化模式、强化模式 | [coding/agent-management/self-improving-agent.md](./coding/agent-management/self-improving-agent.md) |
| healthcheck、健康检查、安全审计、防火墙、SSH 加固、系统更新、风险配置、安全加固、暴露审查、OpenClaw cron、版本状态检查、安全扫描、安全审计、防火墙配置、SSH 安全、系统更新、风险审查、暴露审查、OpenClaw 安全检查、版本状态检查、主机加固、安全配置、漏洞扫描 | [coding/infra/healthcheck.md](./coding/infra/healthcheck.md) |
| node-connect、节点连接、配对故障、QR码、设置代码、Android、iOS、macOS、伴侣应用、本地Wi-Fi、VPS、tailnet、网关绑定、引导令牌、未授权、配对要求、QR码失败、设置代码无效、手动连接失败、本地Wi-Fi正常但VPS失败、节点未连接、配对失败、引导令牌无效、引导令牌过期、gateway.bind、gateway.remote.url、Tailscale、plugins.entries.device-pair.config.publicUrl | [coding/infra/node-connect.md](./coding/infra/node-connect.md) |
| feishu-doc、飞书文档、云文档、docx链接、文档读写、文档创建、表格创建、图片上传、块操作、文档编辑、飞书集成、飞书文档、云文档、docx链接、读写文档、创建文档、编辑文档、上传图片到文档、创建表格、读取文档内容、飞书集成、文档自动化 | [coding/tools/feishu/feishu-doc.md](./coding/tools/feishu/feishu-doc.md) |
| feishu-drive、飞书云盘、云存储、文件夹管理、文件管理、文件列表、创建文件夹、移动文件、删除文件、文件信息、云空间、飞书云盘、云存储、文件夹、文件列表、创建文件夹、移动文件、删除文件、文件信息、云空间管理、文件整理 | [coding/tools/feishu/feishu-drive.md](./coding/tools/feishu/feishu-drive.md) |
| feishu-perm、飞书权限、文档共享、权限管理、协作者、添加协作者、移除协作者、权限级别、共享设置、访问控制、飞书权限、文档共享、添加协作者、移除协作者、权限管理、共享设置、访问控制、协作权限、文档分享 | [coding/tools/feishu/feishu-perm.md](./coding/tools/feishu/feishu-perm.md) |
| feishu-wiki、飞书知识库、知识库、wiki、知识空间、节点导航、知识库创建、页面管理、知识库搜索、文档组织、飞书知识库、wiki、知识库导航、创建知识页面、管理知识库、搜索知识库、知识库节点、知识空间、文档组织 | [coding/tools/feishu/feishu-wiki.md](./coding/tools/feishu/feishu-wiki.md) |
| clawhub、ClawHub、技能管理、技能搜索、技能安装、技能更新、技能发布、clawhub.com、技能生态系统、技能发现、clawhub、ClawHub、搜索技能、安装技能、更新技能、发布技能、技能管理、技能发现、技能同步、技能版本 | [coding/tools/clawhub.md](./coding/tools/clawhub.md) |
| video-frames、视频帧、帧提取、ffmpeg、视频处理、截图、缩略图、视频分析、关键帧、时间戳、视频帧提取、视频截图、提取关键帧、生成缩略图、视频分析、ffmpeg、时间戳截图、视频处理、帧率分析 | [coding/tools/video-frames.md](./coding/tools/video-frames.md) |
| weather、天气、天气预报、温度、湿度、降水、风速、wttr.in、Open-Meteo、天气API、实时天气、天气预警、天气查询、天气预报、温度、湿度、风速、降水概率、实时天气、天气状况、气象数据、天气预警 | [coding/tools/weather.md](./coding/tools/weather.md) |

> 维护说明：每次新增或修改 skill 文件的 `keywords` / `triggers` 字段后，同步更新此表。

---

## 内容索引

### Meta
- [如何写 Skill 文档](./meta/how-to-write-skill.md)

### Coding — AI Workflow
- [AI 编码代理工作流](./coding/ai-workflow/coding-agent.md)
- [技能创建与维护规范](./coding/ai-workflow/skill-creator.md)

### Coding — Agent Management
- [技能发现与安装](./coding/agent-management/find-skills.md)
- [自我改进代理 - 持续学习与优化](./coding/agent-management/self-improving-agent.md)

### Coding — Infrastructure
- [主机安全加固与风险配置](./coding/infra/healthcheck.md)
- [OpenClaw节点连接与配对诊断](./coding/infra/node-connect.md)

### Coding — Backend
- [中间件规范](./coding/backend/middleware.md)

### Coding — Tools
- [ClawHub CLI技能管理](./coding/tools/clawhub.md)
- [视频帧提取与处理](./coding/tools/video-frames.md)
- [天气查询与预报](./coding/tools/weather.md)

### Coding — Tools / Feishu
- [飞书文档操作规范](./coding/tools/feishu/feishu-doc.md)
- [飞书云存储管理](./coding/tools/feishu/feishu-drive.md)
- [飞书权限管理](./coding/tools/feishu/feishu-perm.md)
- [飞书知识库导航](./coding/tools/feishu/feishu-wiki.md)
