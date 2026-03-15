---
title: AI 编码代理工作流
domain: coding/ai-workflow
keywords: [coding-agent, 编码代理, Codex, Claude Code, OpenCode, Pi, 后台进程, 并行处理, git worktree, PR 审查, 重构, 大型代码库, 多代理, 批处理]
triggers: [使用 Codex, 使用 Claude Code, 使用 OpenCode, 使用 Pi, 启动编码代理, 后台运行 AI, 并行处理任务, 审查 PR, 重构代码, 批处理任务, 多代理工作流, git worktree, 临时目录工作]
scope: 使用 bash + 后台进程模式委托编码任务给 Codex、Claude Code、OpenCode 或 Pi 代理
---

# AI 编码代理工作流

## 核心原则

1. **正确的 PTY 模式** - Codex/Pi/OpenCode 需要 `pty:true`，Claude Code 使用 `--print --permission-mode bypassPermissions`（无需 PTY）
2. **工作目录隔离** - 使用 `workdir` 参数确保代理只在目标目录工作，不读取无关文件
3. **后台监控** - 长任务使用 `background:true`，通过 `process` 工具监控进度
4. **安全边界** - 永远不在 OpenClaw 工作空间（~/clawd）中启动编码代理
5. **用户通知** - 启动时通知用户，完成时发送进度更新

## 规范细则

### PTY 模式规则

**Codex / Pi / OpenCode**（需要交互式终端）：
```bash
# ✅ 正确
bash pty:true workdir:/path/to/project command:"codex exec '你的任务'"

# ❌ 错误（缺少 PTY）
bash workdir:/path/to/project command:"codex exec '你的任务'"
```

**Claude Code**（无需 PTY）：
```bash
# ✅ 正确
bash workdir:/path/to/project command:"claude --permission-mode bypassPermissions --print '你的任务'"

# ❌ 错误（使用 PTY）
bash pty:true workdir:/path/to/project command:"claude --dangerously-skip-permissions '任务'"
```

### 工作目录管理

**基本原则**：
- 使用 `workdir` 参数限制代理的文件访问范围
- 对于临时任务，创建临时目录并初始化 git 仓库
- 永远不在用户的工作空间或 OpenClaw 目录中启动代理

**临时任务示例**：
```bash
# 创建临时目录并初始化 git（Codex 需要 git 仓库）
SCRATCH=$(mktemp -d) && cd $SCRATCH && git init
bash pty:true workdir:$SCRATCH command:"codex exec '你的任务'"
```

### 后台任务管理

**启动后台任务**：
```bash
# 启动后台编码代理
bash pty:true workdir:~/project background:true command:"codex exec --full-auto '构建功能'"
# 返回 sessionId 用于监控
```

**监控进度**：
```bash
# 查看日志
process action:log sessionId:XXX

# 检查是否完成
process action:poll sessionId:XXX

# 发送输入（如果代理提问）
process action:submit sessionId:XXX data:"是的"

# 终止任务
process action:kill sessionId:XXX
```

### PR 审查工作流

**关键安全规则**：永远不在原始项目目录中审查 PR，使用克隆或 git worktree

**方法 1：临时克隆**：
```bash
REVIEW_DIR=$(mktemp -d)
git clone https://github.com/user/repo.git $REVIEW_DIR
cd $REVIEW_DIR && gh pr checkout 130
bash pty:true workdir:$REVIEW_DIR command:"codex review --base origin/main"
# 完成后清理：trash $REVIEW_DIR
```

**方法 2：git worktree**：
```bash
git worktree add /tmp/pr-130-review pr-130-branch
bash pty:true workdir:/tmp/pr-130-review command:"codex review --base main"
# 完成后清理：git worktree remove /tmp/pr-130-review
```

### 并行任务处理

**批量 PR 审查**：
```bash
# 获取所有 PR 引用
git fetch origin '+refs/pull/*/head:refs/remotes/origin/pr/*'

# 并行启动多个代理（每个 PR 一个）
bash pty:true workdir:~/project background:true command:"codex exec '审查 PR #86. git diff origin/main...origin/pr/86'"
bash pty:true workdir:~/project background:true command:"codex exec '审查 PR #87. git diff origin/main...origin/pr/87'"

# 监控所有任务
process action:list
```

**并行问题修复（使用 git worktree）**：
```bash
# 为每个问题创建工作树
git worktree add -b fix/issue-78 /tmp/issue-78 main
git worktree add -b fix/issue-99 /tmp/issue-99 main

# 在每个工作树中启动代理
bash pty:true workdir:/tmp/issue-78 background:true command:"pnpm install && codex --yolo '修复问题 #78: <描述>'"
bash pty:true workdir:/tmp/issue-99 background:true command:"pnpm install && codex --yolo '修复问题 #99: <描述>'"
```

### 自动完成通知

**在提示中添加完成通知**：
```bash
bash pty:true workdir:~/project background:true command:"codex --yolo exec '构建 REST API。

完成后运行：openclaw system event --text \"完成：构建了 REST API\" --mode now'"
```

## 反例（Anti-patterns）

**❌ 在错误目录中启动代理**：
```bash
# 错误：在 OpenClaw 工作空间启动
bash pty:true workdir:~/clawd command:"codex exec '任务'"

# 错误：在用户主目录启动
bash pty:true workdir:~ command:"codex exec '任务'"
```

**❌ 错误的 PTY 配置**：
```bash
# 错误：Claude Code 使用 PTY
bash pty:true command:"claude --dangerously-skip-permissions '任务'"

# 错误：Codex 不使用 PTY
bash command:"codex exec '任务'"  # 可能挂起或输出异常
```

**❌ 不安全的 PR 审查**：
```bash
# 错误：直接在项目目录中切换分支
cd ~/project && git checkout pr-branch
bash pty:true workdir:~/project command:"codex review"  # 可能破坏工作区
```

**❌ 缺乏用户通知**：
```bash
# 错误：启动后台任务但不通知用户
bash pty:true background:true command:"codex exec '长任务'"
# 用户不知道任务已启动或何时完成
```

## 适用场景

**适合使用编码代理**：
- 构建新功能或应用
- 审查 PR（在临时目录中）
- 重构大型代码库
- 需要文件探索的迭代编码
- 批处理任务（多个并行代理）

**不适合使用编码代理**：
- 简单的一行修复（直接使用 `edit` 工具）
- 读取代码（使用 `read` 工具）
- 线程绑定的 ACP 请求（使用 `sessions_spawn` with `runtime:"acp"`）
- OpenClaw 工作空间中的任何工作

## 进度更新规范

**启动时**：
- 简短说明正在运行什么 + 在哪里运行
- 提供 sessionId 用于监控

**进行中**：
- 里程碑完成时更新（构建完成、测试通过）
- 代理提问或需要输入时
- 遇到错误或需要用户操作时

**完成时**：
- 说明完成了什么 + 发生了什么变化
- 提供结果摘要
- 清理临时资源

**终止时**：
- 立即说明终止了任务 + 原因
