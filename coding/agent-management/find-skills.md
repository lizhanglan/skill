---
title: 技能发现与安装
domain: coding/agent-management
keywords: [find-skills, 技能发现, 技能搜索, 技能安装, npx skills, skills.sh, 技能生态系统, 技能包管理器, 扩展能力, 技能查找, 技能推荐]
triggers: [如何做 X, 查找 X 的技能, 有技能可以做 X 吗, 你能做 X 吗, 扩展能力, 搜索工具, 搜索模板, 搜索工作流, 安装技能, 更新技能, 检查技能更新]
scope: 帮助用户发现和安装来自开放代理技能生态系统的技能
---

# 技能发现与安装

## 核心原则

1. **先理解需求** - 明确用户需要的领域、具体任务和常见性
2. **有效搜索** - 使用具体关键词搜索技能，尝试替代术语
3. **清晰呈现** - 提供技能名称、功能和安装命令
4. **安全安装** - 使用 `-g -y` 标志进行全局安装并跳过确认
5. **备选方案** - 当没有找到技能时，提供直接帮助或创建建议

## 规范细则

### Skills CLI 工具

Skills CLI (`npx skills`) 是开放代理技能生态系统的包管理器。

**关键命令**：
- `npx skills find [query]` - 交互式或按关键词搜索技能
- `npx skills add <package>` - 从 GitHub 或其他源安装技能
- `npx skills check` - 检查技能更新
- `npx skills update` - 更新所有已安装技能

**浏览技能**：https://skills.sh/

### 帮助用户查找技能的工作流

#### 步骤 1：理解用户需求

当用户请求帮助时，识别：

1. **领域**（例如：React、测试、设计、部署）
2. **具体任务**（例如：编写测试、创建动画、审查 PR）
3. **常见性**（这个任务是否常见到可能有现有技能）

#### 步骤 2：搜索技能

使用相关查询运行 find 命令：

```bash
npx skills find [query]
```

**示例**：
- 用户问"如何让我的 React 应用更快？" → `npx skills find react performance`
- 用户问"你能帮我审查 PR 吗？" → `npx skills find pr review`
- 用户问"我需要创建变更日志" → `npx skills find changelog`

**命令返回示例**：
```
Install with npx skills add <owner/repo@skill>

vercel-labs/agent-skills@vercel-react-best-practices
└ https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices
```

#### 步骤 3：向用户呈现选项

找到相关技能后，向用户呈现：

1. 技能名称及其功能
2. 他们可以运行的安装命令
3. 在 skills.sh 上了解更多信息的链接

**示例响应**：
```
我找到了一个可能有所帮助的技能！"vercel-react-best-practices" 技能提供
来自 Vercel Engineering 的 React 和 Next.js 性能优化指南。

安装命令：
npx skills add vercel-labs/agent-skills@vercel-react-best-practices

了解更多：https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices
```

#### 步骤 4：提供安装帮助

如果用户想继续，你可以为他们安装技能：

```bash
npx skills add <owner/repo@skill> -g -y
```

`-g` 标志全局安装（用户级别），`-y` 跳过确认提示。

### 常见技能类别

搜索时考虑这些常见类别：

| 类别 | 示例查询 |
|------|----------|
| Web 开发 | react, nextjs, typescript, css, tailwind |
| 测试 | testing, jest, playwright, e2e |
| DevOps | deploy, docker, kubernetes, ci-cd |
| 文档 | docs, readme, changelog, api-docs |
| 代码质量 | review, lint, refactor, best-practices |
| 设计 | ui, ux, design-system, accessibility |
| 生产力 | workflow, automation, git |

### 有效搜索技巧

1. **使用具体关键词**："react testing" 比仅 "testing" 更好
2. **尝试替代术语**：如果 "deploy" 无效，尝试 "deployment" 或 "ci-cd"
3. **检查流行源**：许多技能来自 `vercel-labs/agent-skills` 或 `ComposioHQ/awesome-claude-skills`

### 未找到技能时的处理

如果未找到相关技能：

1. 确认未找到现有技能
2. 提供使用通用能力直接帮助
3. 建议用户可以使用 `npx skills init` 创建自己的技能

**示例响应**：
```
我搜索了与 "xyz" 相关的技能，但没有找到匹配项。
我仍然可以直接帮助你完成这个任务！你希望我继续吗？

如果这是你经常做的事情，你可以创建自己的技能：
npx skills init my-xyz-skill
```

## 反例（Anti-patterns）

**❌ 不询问具体需求就搜索**：
```bash
# 错误：用户说"我需要帮助"，但不清楚具体需求
npx skills find help  # 结果可能不相关
```

**❌ 使用过于宽泛的搜索词**：
```bash
# 错误：搜索词太宽泛
npx skills find code  # 返回太多不相关结果

# 正确：具体搜索
npx skills find react testing library
```

**❌ 不检查流行源**：
```bash
# 错误：只搜索一次就放弃
npx skills find deployment
# 如果没有结果，尝试：
npx skills find aws deployment
npx skills find vercel-labs/agent-skills
```

**❌ 不提供安装帮助**：
```
我找到了一个技能：vercel-react-best-practices
# 错误：不提供安装命令或链接
```

**❌ 当没有技能时直接放弃**：
```
没有找到相关技能。
# 错误：不提供备选方案
```

## 适用场景

**适合使用此技能**：
- 用户问"如何做 X"，其中 X 可能是具有现有技能的常见任务
- 用户说"查找 X 的技能"或"有技能可以做 X 吗"
- 用户问"你能做 X 吗"，其中 X 是专业能力
- 用户表示有兴趣扩展代理能力
- 用户想要搜索工具、模板或工作流
- 用户提到他们希望有特定领域（设计、测试、部署等）的帮助

**不适合使用此技能**：
- 用户请求简单、直接的任务（直接帮助）
- 用户已经知道他们需要的具体技能
- 用户请求高度特定、自定义的解决方案
- 用户在工作流中间请求帮助（继续当前工作流）

## 搜索模式示例

**前端开发**：
- React 性能：`npx skills find react performance optimization`
- 组件库：`npx skills find component library design system`
- 状态管理：`npx skills find state management redux zustand`

**后端开发**：
- API 设计：`npx skills find api design rest graphql`
- 数据库：`npx skills find database orm migration`
- 认证：`npx skills find authentication jwt oauth`

**DevOps**：
- 部署：`npx skills find deployment docker kubernetes`
- CI/CD：`npx skills find ci-cd github-actions`
- 监控：`npx skills find monitoring observability`

**测试**：
- 单元测试：`npx skills find unit testing jest`
- E2E 测试：`npx skills find e2e testing playwright cypress`
- 测试覆盖率：`npx skills find test coverage`

## 安装后建议

技能安装后，建议用户：

1. **验证安装**：`npx skills list` 查看已安装技能
2. **阅读文档**：访问 skills.sh 页面了解详细信息
3. **测试使用**：在相关任务中尝试使用新技能
4. **提供反馈**：如果技能有帮助或需要改进，提供反馈

## 技能更新管理

**检查更新**：
```bash
npx skills check
```

**更新所有技能**：
```bash
npx skills update
```

**更新特定技能**：
```bash
npx skills add <owner/repo@skill> -g -y  # 重新安装以更新
```

建议定期检查更新，特别是对于关键工作流技能。
