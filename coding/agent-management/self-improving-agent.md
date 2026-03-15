---
title: 自我改进代理 - 持续学习与优化
domain: coding/agent-management
keywords: [self-improvement, 自我改进, 学习记录, 错误记录, 功能请求, 知识更新, 最佳实践, 模式检测, 技能提取, 持续改进, 学习循环]
triggers: [命令失败, 操作失败, 用户纠正, 知识过时, API 失败, 工具失败, 发现更好方法, 记录学习, 记录错误, 记录功能请求, 改进工作流, 简化模式, 强化模式]
scope: 捕获学习、错误和更正以实现持续改进，包括学习记录、错误跟踪、功能请求和技能提取
---

# 自我改进代理 - 持续学习与优化

## 核心原则

1. **立即记录** - 上下文最新时立即记录，不依赖"心理笔记"
2. **具体详细** - 未来代理需要快速理解，包括重现步骤
3. **结构化格式** - 使用一致格式实现过滤和搜索
4. **积极推广** - 如果怀疑应推广，就推广到项目内存
5. **定期审查** - 在自然断点审查学习，解决固定项目，推广适用学习

## 规范细则

### 快速参考表

| 情况 | 行动 |
|------|------|
| 命令/操作失败 | 记录到 `.learnings/ERRORS.md` |
| 用户纠正你 | 记录到 `.learnings/LEARNINGS.md`，类别 `correction` |
| 用户想要缺失功能 | 记录到 `.learnings/FEATURE_REQUESTS.md` |
| API/外部工具失败 | 记录到 `.learnings/ERRORS.md`，包含集成详情 |
| 知识过时 | 记录到 `.learnings/LEARNINGS.md`，类别 `knowledge_gap` |
| 发现更好方法 | 记录到 `.learnings/LEARNINGS.md`，类别 `best_practice` |
| 简化/强化重复模式 | 记录/更新 `.learnings/LEARNINGS.md`，`Source: simplify-and-harden` 和稳定 `Pattern-Key` |
| 与现有条目相似 | 使用 `**See Also**` 链接，考虑提高优先级 |
| 广泛适用的学习 | 推广到 `CLAUDE.md`、`AGENTS.md` 和/或 `.github/copilot-instructions.md` |
| 工作流改进 | 推广到 `AGENTS.md`（OpenClaw 工作空间） |
| 工具陷阱 | 推广到 `TOOLS.md`（OpenClaw 工作空间） |
| 行为模式 | 推广到 `SOUL.md`（OpenClaw 工作空间） |

### 学习记录格式

**学习条目**（追加到 `.learnings/LEARNINGS.md`）：

```markdown
## [LRN-YYYYMMDD-XXX] category

**Logged**: ISO-8601 时间戳
**Priority**: low | medium | high | critical
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
一行描述学到了什么

### Details
完整上下文：发生了什么，什么错了，什么是正确的

### Suggested Action
具体的修复或改进措施

### Metadata
- Source: conversation | error | user_feedback
- Related Files: path/to/file.ext
- Tags: tag1, tag2
- See Also: LRN-20250110-001（如果与现有条目相关）
- Pattern-Key: simplify.dead_code | harden.input_validation（可选，用于重复模式跟踪）
- Recurrence-Count: 1（可选）
- First-Seen: 2025-01-15（可选）
- Last-Seen: 2025-01-15（可选）

---
```

**错误条目**（追加到 `.learnings/ERRORS.md`）：

```markdown
## [ERR-YYYYMMDD-XXX] skill_or_command_name

**Logged**: ISO-8601 时间戳
**Priority**: high
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
失败情况的简要描述

### Error
```
实际错误消息或输出
```

### Context
- 尝试的命令/操作
- 使用的输入或参数
- 环境详情（如果相关）

### Suggested Fix
如果可识别，可能解决此问题的方法

### Metadata
- Reproducible: yes | no | unknown
- Related Files: path/to/file.ext
- See Also: ERR-20250110-001（如果重复）

---
```

**功能请求条目**（追加到 `.learnings/FEATURE_REQUESTS.md`）：

```markdown
## [FEAT-YYYYMMDD-XXX] capability_name

**Logged**: ISO-8601 时间戳
**Priority**: medium
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Requested Capability
用户想要做什么

### User Context
他们为什么需要它，他们解决什么问题

### Complexity Estimate
simple | medium | complex

### Suggested Implementation
如何构建，可能扩展什么

### Metadata
- Frequency: first_time | recurring
- Related Features: existing_feature_name

---
```

### ID 生成

格式：`TYPE-YYYYMMDD-XXX`
- TYPE: `LRN`（学习）、`ERR`（错误）、`FEAT`（功能）
- YYYYMMDD: 当前日期
- XXX: 顺序号或随机 3 字符（例如：`001`、`A7B`）

示例：`LRN-20250115-001`、`ERR-20250115-A3F`、`FEAT-20250115-002`

### 解决条目

当问题修复时，更新条目：

1. 更改 `**Status**: pending` → `**Status**: resolved`
2. 在元数据后添加解决块：

```markdown
### Resolution
- **Resolved**: 2025-01-16T09:00:00Z
- **Commit/PR**: abc123 或 #42
- **Notes**: 所做工作的简要描述
```

其他状态值：
- `in_progress` - 正在积极处理
- `wont_fix` - 决定不解决（在解决说明中添加原因）
- `promoted` - 提升到 CLAUDE.md、AGENTS.md 或 .github/copilot-instructions.md

### 推广到项目内存

当学习广泛适用（不是一次性修复）时，推广到永久项目内存。

**何时推广**：
- 学习适用于多个文件/功能
- 任何贡献者（人类或 AI）都应知道的知识
- 防止重复错误
- 记录项目特定约定

**推广目标**：

| 目标 | 应包含的内容 |
|------|------------|
| `CLAUDE.md` | 项目事实、约定、所有 Claude 交互的陷阱 |
| `AGENTS.md` | 代理特定工作流、工具使用模式、自动化规则 |
| `.github/copilot-instructions.md` | GitHub Copilot 的项目上下文和约定 |
| `SOUL.md` | 行为指南、沟通风格、原则（OpenClaw 工作空间） |
| `TOOLS.md` | 工具能力、使用模式、集成陷阱（OpenClaw 工作空间） |

**如何推广**：
1. **提炼**学习为简洁规则或事实
2. **添加**到目标文件的适当部分（如果需要则创建文件）
3. **更新**原始条目：
   - 更改 `**Status**: pending` → `**Status**: promoted`
   - 添加 `**Promoted**: CLAUDE.md`、`AGENTS.md` 或 `.github/copilot-instructions.md`

**推广示例**：

**学习**（详细）：
> 项目使用 pnpm workspaces。尝试了 `npm install` 但失败。
> 锁定文件是 `pnpm-lock.yaml`。必须使用 `pnpm install`。

**在 CLAUDE.md 中**（简洁）：
```markdown
## 构建与依赖
- 包管理器：pnpm（不是 npm）- 使用 `pnpm install`
```

**学习**（详细）：
> 修改 API 端点时，必须重新生成 TypeScript 客户端。
> 忘记这会导致运行时类型不匹配。

**在 AGENTS.md 中**（可操作）：
```markdown
## API 更改后
1. 重新生成客户端：`pnpm run generate:api`
2. 检查类型错误：`pnpm tsc --noEmit`
```

### 重复模式检测

如果记录的内容与现有条目相似：

1. **先搜索**：`grep -r "keyword" .learnings/`
2. **链接条目**：在元数据中添加 `**See Also**: ERR-20250110-001`
3. **提高优先级**：如果问题持续重复
4. **考虑系统修复**：重复问题通常表明：
   - 缺少文档（→ 推广到 CLAUDE.md 或 .github/copilot-instructions.md）
   - 缺少自动化（→ 添加到 AGENTS.md）
   - 架构问题（→ 创建技术债务票证）

### 简化与强化反馈

使用此工作流从 `simplify-and-harden` 技能中提取重复模式，并将其转化为持久的提示指导。

**提取工作流**：
1. 从任务摘要中读取 `simplify_and_harden.learning_loop.candidates`
2. 对于每个候选，使用 `pattern_key` 作为稳定的去重键
3. 搜索 `.learnings/LEARNINGS.md` 中具有该键的现有条目：
   - `grep -n "Pattern-Key: <pattern_key>" .learnings/LEARNINGS.md`
4. 如果找到：
   - 增加 `Recurrence-Count`
   - 更新 `Last-Seen`
   - 添加 `See Also` 链接到相关条目/任务
5. 如果未找到：
   - 创建新的 `LRN-...` 条目
   - 设置 `Source: simplify-and-harden`
   - 设置 `Pattern-Key`、`Recurrence-Count: 1` 和 `First-Seen`/`Last-Seen`

**推广规则（系统提示反馈）**：

当以下所有条件为真时，将重复模式推广到代理上下文/系统提示文件：
- `Recurrence-Count >= 3`
- 在至少 2 个不同任务中看到
- 在 30 天窗口内发生

推广目标：
- `CLAUDE.md`
- `AGENTS.md`
- `.github/copilot-instructions.md`
- `SOUL.md` / `TOOLS.md`（适用于 OpenClaw 工作空间级指导）

将推广的规则写为简短的预防规则（编码前/编码中应做什么），而不是长的事件报告。

### 检测触发器

自动记录当你注意到：

**更正**（→ 学习，类别 `correction`）：
- "不，那不对..."
- "实际上，应该是..."
- "你错了..."
- "那是过时的..."

**功能请求**（→ 功能请求）：
- "你还能..."
- "我希望你能..."
- "有没有办法..."
- "为什么你不能..."

**知识差距**（→ 学习，类别 `knowledge_gap`）：
- 用户提供你不知道的信息
- 你引用的文档已过时
- API 行为与你的理解不同

**错误**（→ 错误条目）：
- 命令返回非零退出代码
- 异常或堆栈跟踪
- 意外输出或行为
- 超时或连接失败

### 优先级指南

| 优先级 | 何时使用 |
|--------|----------|
| `critical` | 阻塞核心功能、数据丢失风险、安全问题 |
| `high` | 重大影响、影响常见工作流、重复问题 |
| `medium` | 中等影响、存在变通方法 |
| `low` | 轻微不便、边缘情况、锦上添花 |

### 区域标签

用于按代码库区域过滤学习：

| 区域 | 范围 |
|------|------|
| `frontend` | UI、组件、客户端代码 |
| `backend` | API、服务、服务器端代码 |
| `infra` | CI/CD、部署、Docker、云 |
| `tests` | 测试文件、测试工具、覆盖率 |
| `docs` | 文档、注释、README |
| `config` | 配置文件、环境、设置 |

### 自动技能提取

当学习足够有价值成为可重用技能时，使用提供的帮助程序提取它。

**技能提取标准**：

当学习满足以下任何条件时，有资格进行技能提取：

| 标准 | 描述 |
|------|------|
| **重复** | 有 `See Also` 链接到 2+ 个类似问题 |
| **已验证** | 状态为 `resolved` 且修复有效 |
| **非显而易见** | 需要实际调试/调查才能发现 |
| **广泛适用** | 非项目特定；跨代码库有用 |
| **用户标记** | 用户说"将此保存为技能"或类似 |

**提取工作流**：
1. **识别候选**：学习满足提取标准
2. **运行帮助程序**（或手动创建）：
   ```bash
   ./skills/self-improvement/scripts/extract-skill.sh skill-name --dry-run
   ./skills/self-improvement/scripts/extract-skill.sh skill-name
   ```
3. **自定义 SKILL.md**：用学习内容填充模板
4. **更新学习**：设置状态为 `promoted_to_skill`，添加 `Skill-Path`
5. **验证**：在新会话中阅读技能以确保自包含

**提取检测触发器**：

**在对话中**：
- "将此保存为技能"
- "我一直遇到这个问题"
- "这对其他项目会有用"
- "记住这个模式"

**在学习条目中**：
- 多个 `See Also` 链接（重复问题）
- 高优先级 + 已解决状态
- 类别：具有广泛适用性的 `best_practice`
- 用户反馈赞扬解决方案

**技能质量门**：

提取前验证：
- [ ] 解决方案经过测试且有效
- [ ] 描述清晰，无需原始上下文
- [ ] 代码示例自包含
- [ ] 没有项目特定的硬编码值
- [ ] 遵循技能命名约定（小写、连字符）

## 反例（Anti-patterns）

**❌ 依赖"心理笔记"**：
```bash
# 错误：认为你会记住
# 实际上：会话重启后忘记

# 正确：立即写入文件
echo "## [LRN-20250315-001] correction" >> .learnings/LEARNINGS.md
```

**❌ 记录不具体**：
```markdown
## [LRN-20250315-001] something

**Logged**: 2025-03-15T15:30:00Z
**Priority**: medium
**Status**: pending

### Summary
有个问题

### Details
东西坏了

### Suggested Action
修好它
# 错误：不够具体，未来代理无法理解
```

**❌ 不包含重现步骤**：
```markdown
### Error
```
命令失败
```
# 错误：不显示实际命令或错误消息
```

**❌ 不推广有价值的学习**：
```markdown
# 学习：项目使用 pnpm，不是 npm
# 错误：只留在 .learnings/ 中，不推广到 CLAUDE.md
# 正确：推广到 CLAUDE.md 供所有未来代理使用
```

**❌ 创建重复条目**：
```markdown
# 已有：LRN-20250310-001 关于 pnpm
# 错误：创建新的 LRN-20250315-001 关于相同问题
# 正确：更新现有条目，增加 Recurrence-Count
```

## 适用场景

**适合使用此技能**：
- 命令或操作意外失败
- 用户纠正你（"不，那错了..."，"实际上..."）
- 用户请求不存在的功能
- 外部 API 或工具失败
- 你意识到知识已过时或不正确
- 发现重复任务的更好方法
- 在主要任务前审查学习

**不适合使用此技能**：
- 简单、预期的错误（如权限被拒绝，已知原因）
- 用户提供常规信息（非纠正）
- 一次性、不重要的问题
- 已经充分记录在项目文档中的信息
