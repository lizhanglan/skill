---
title: ClawHub CLI技能管理
domain: coding/tools
keywords: [clawhub, ClawHub, 技能管理, 技能搜索, 技能安装, 技能更新, 技能发布, clawhub.com, 技能生态系统, 技能发现]
triggers: [clawhub, ClawHub, 搜索技能, 安装技能, 更新技能, 发布技能, 技能管理, 技能发现, 技能同步, 技能版本]
scope: 使用ClawHub CLI从clawhub.com搜索、安装、更新和发布代理技能
---

# ClawHub CLI技能管理

## 核心原则

1. **技能生态系统** - ClawHub是OpenClaw的技能包管理器，类似npm但针对AI代理技能
2. **动态获取** - 可以按需获取新技能，无需预先安装所有技能
3. **版本管理** - 支持技能版本控制，可以安装特定版本或最新版本
4. **安全来源** - 技能来自可信的clawhub.com仓库，经过审核
5. **工作空间集成** - 安装的技能自动集成到OpenClaw工作空间

## 规范细则

### ClawHub CLI基础

**安装ClawHub CLI**：
```bash
# 如果尚未安装
npm install -g @openclaw/clawhub
# 或
openclaw plugins install clawhub
```

**验证安装**：
```bash
clawhub --version
clawhub help
```

### 核心命令

#### 搜索技能
```bash
# 搜索技能（交互式）
clawhub search [查询词]

# 搜索特定技能
clawhub search react
clawhub search "weather forecast"
clawhub search --category infrastructure
```

**搜索选项**：
- `--category <类别>`：按类别筛选（ai-workflow, infrastructure, tools等）
- `--author <作者>`：按作者筛选
- `--limit <数量>`：限制结果数量
- `--json`：JSON格式输出

#### 安装技能
```bash
# 安装技能（最新版本）
clawhub install <技能名>

# 安装特定版本
clawhub install <技能名>@<版本>

# 安装到全局（所有会话可用）
clawhub install <技能名> --global

# 安装到项目本地
clawhub install <技能名> --local

# 示例
clawhub install weather
clawhub install coding-agent@1.2.0
clawhub install feishu-doc --global
```

#### 更新技能
```bash
# 检查可更新技能
clawhub outdated

# 更新特定技能
clawhub update <技能名>

# 更新所有技能
clawhub update --all

# 更新到特定版本
clawhub update <技能名>@<版本>
```

#### 列出已安装技能
```bash
# 列出所有已安装技能
clawhub list

# 列出全局技能
clawhub list --global

# 列出本地技能
clawhub list --local

# 详细列表
clawhub list --verbose
```

#### 移除技能
```bash
# 移除技能
clawhub remove <技能名>

# 移除全局技能
clawhub remove <技能名> --global

# 强制移除（不确认）
clawhub remove <技能名> --force
```

#### 发布技能
```bash
# 发布新技能
clawhub publish <技能目录>

# 发布新版本
clawhub publish <技能目录> --bump <major|minor|patch>

# 发布前验证
clawhub publish <技能目录> --dry-run

# 示例
clawhub publish ./my-skill
clawhub publish ./weather-skill --bump minor
```

### 技能类别参考

ClawHub技能按类别组织，便于搜索和发现：

| 类别 | 描述 | 示例技能 |
|------|------|----------|
| `ai-workflow` | AI工作流和代理管理 | coding-agent, skill-creator |
| `infrastructure` | 基础设施和运维 | healthcheck, node-connect |
| `tools` | 工具集成 | feishu-doc, feishu-drive |
| `agent-management` | 代理管理和发现 | find-skills, self-improving-agent |
| `productivity` | 生产力工具 | weather, video-frames |
| `communication` | 通信和消息 | 各种消息通道技能 |
| `data-processing` | 数据处理和分析 | 数据提取和转换技能 |

### 技能版本管理

**版本格式**：遵循语义化版本控制（SemVer）`主版本.次版本.修订版本`

**版本标识**：
- `latest`：最新稳定版本（默认）
- `1.2.3`：特定版本
- `^1.2.0`：兼容1.2.x的最新版本
- `~1.2.3`：兼容1.2.3的最新修订版
- `beta`：测试版本
- `next`：预发布版本

**版本策略**：
- 主版本变更：不兼容的API变更
- 次版本变更：向后兼容的功能性新增
- 修订版本变更：向后兼容的问题修复

### 配置管理

**ClawHub配置文件**：`~/.clawhub/config.json`
```json
{
  "registry": "https://registry.clawhub.com",
  "defaultScope": "global",
  "autoUpdateCheck": true,
  "updateCheckInterval": 86400000,
  "skillDirectories": {
    "global": "~/.openclaw/skills",
    "local": "./.openclaw/skills"
  },
  "proxy": null,
  "timeout": 30000
}
```

**环境变量**：
- `CLAWHUB_REGISTRY`：覆盖注册表URL
- `CLAWHUB_TOKEN`：发布技能时的认证令牌
- `CLAWHUB_CACHE_DIR`：缓存目录
- `HTTP_PROXY` / `HTTPS_PROXY`：代理设置

### 工作流集成

#### 按需技能获取工作流
```bash
# 1. 用户请求特定功能
# 例如："帮我查一下天气"

# 2. 检查是否已有相关技能
clawhub list | grep -i weather

# 3. 如果没有，搜索可用技能
clawhub search weather

# 4. 安装技能
clawhub install weather --global

# 5. 技能自动加载到OpenClaw
# OpenClaw会检测新技能并使其可用
```

#### 技能更新维护工作流
```bash
# 1. 定期检查更新（例如通过cron）
clawhub outdated

# 2. 查看更新详情
clawhub info <技能名>

# 3. 测试更新（在测试环境）
clawhub update <技能名> --dry-run

# 4. 应用更新
clawhub update <技能名>

# 5. 验证更新
clawhub list --verbose <技能名>
```

#### 技能开发发布工作流
```bash
# 1. 初始化技能项目
mkdir my-new-skill
cd my-new-skill
# 创建SKILL.md和所需文件

# 2. 本地测试
# 将技能链接到OpenClaw测试
ln -s $(pwd) ~/.openclaw/skills/my-new-skill

# 3. 验证技能格式
clawhub validate .

# 4. 发布到ClawHub
clawhub publish . --dry-run
clawhub publish .

# 5. 更新版本
# 修改技能后
clawhub publish . --bump patch
```

## 反例（Anti-patterns）

**❌ 不检查直接安装**：
```bash
# 错误：不搜索直接安装可能不存在的技能
clawhub install non-existent-skill
# 正确：先搜索验证
clawhub search non-existent-skill
clawhub install existing-skill
```

**❌ 忽略版本兼容性**：
```bash
# 错误：安装不兼容版本
clawhub install some-skill@10.0.0
# 当前系统只支持1.x版本
# 正确：检查兼容性
clawhub info some-skill
clawhub install some-skill@^1.0.0
```

**❌ 全局和本地混淆**：
```bash
# 错误：项目需要但安装在全局
clawhub install project-skill --global
# 项目成员无法访问

# 错误：通用技能安装在本地
clawhub install weather --local
# 其他项目无法使用

# 正确：根据用途选择
clawhub install project-specific --local
clawhub install general-utility --global
```

**❌ 不维护技能更新**：
```bash
# 错误：从不检查更新
# 技能可能有过期安全问题或缺失功能
# 正确：定期检查
clawhub outdated
clawhub update --all
```

**❌ 发布前不验证**：
```bash
# 错误：直接发布未验证技能
clawhub publish ./buggy-skill
# 可能包含格式错误或缺失文件
# 正确：先验证
clawhub validate ./buggy-skill
clawhub publish ./buggy-skill --dry-run
```

**❌ 使用未经验证的源**：
```bash
# 错误：使用非官方注册表
clawhub --registry http://untrusted-source.com install skill
# 安全风险
# 正确：使用官方源
clawhub --registry https://registry.clawhub.com install skill
```

## 适用场景

**适合使用此技能**：
- 需要动态获取新技能扩展OpenClaw能力
- 搜索特定领域的功能技能
- 安装、更新或移除技能
- 发布自己开发的技能到ClawHub
- 管理技能版本和依赖
- 同步团队间的技能配置

**不适合使用此技能**：
- 简单的技能使用（直接使用技能本身）
- 技能内容开发（使用skill-creator技能）
- 复杂的技能依赖解析（需要手动处理）
- 技能内部实现修改（直接编辑技能文件）

## 最佳实践

### 技能选择策略
1. **官方优先**：优先选择官方维护或验证的技能
2. **社区评价**：查看技能的下载量、星标和评价
3. **维护状态**：检查最后更新时间和问题响应
4. **文档完整**：选择有完整文档和示例的技能

### 安装管理
1. **全局常用**：常用工具技能安装到全局
2. **本地专用**：项目特定技能安装到本地
3. **版本锁定**：生产环境锁定技能版本
4. **依赖记录**：记录技能依赖关系

### 更新策略
1. **定期检查**：设置定期更新检查（每周/每月）
2. **测试环境**：先在测试环境验证更新
3. **回滚计划**：重要更新前准备回滚方案
4. **变更日志**：查看技能更新日志了解变更

### 发布质量
1. **完整测试**：发布前充分测试技能功能
2. **文档更新**：确保技能文档与功能同步
3. **版本规范**：遵循语义化版本控制
4. **向后兼容**：尽量保持向后兼容性

## 常见用例

### 用例1：按需技能发现和安装
```bash
# 场景：用户需要天气功能
# 1. 搜索天气相关技能
clawhub search weather

# 输出示例：
# Found 3 skills:
# 1. weather (v2.1.0) - 天气查询和预报
# 2. advanced-weather (v1.0.0) - 高级天气分析
# 3. weather-alerts (v0.5.0) - 天气警报通知

# 2. 查看技能详情
clawhub info weather

# 3. 安装最合适的技能
clawhub install weather --global

# 4. 验证安装
clawhub list weather
```

### 用例2：团队技能配置同步
```bash
# 场景：同步团队项目技能配置
# 1. 创建技能清单文件
cat > .clawhub-skills.json << 'EOF'
{
  "project": "team-project",
  "skills": {
    "coding-agent": "^2.0.0",
    "feishu-doc": "^1.5.0",
    "healthcheck": "^1.2.0",
    "project-specific": "file:./local-skills/project-specific"
  }
}
EOF

# 2. 安装清单中的所有技能
clawhub install-from .clawhub-skills.json

# 3. 团队成员同步
# 新成员加入时运行相同命令
clawhub install-from .clawhub-skills.json

# 4. 更新清单
# 当需要更新技能版本时，修改.clawhub-skills.json
# 然后团队成员运行更新
clawhub update-from .clawhub-skills.json
```

### 用例3：技能开发和发布
```bash
# 场景：开发并发布自定义技能
# 1. 创建技能目录结构
mkdir my-data-processor
cd my-data-processor
mkdir scripts references

# 2. 创建SKILL.md
cat > SKILL.md << 'EOF'
---
name: data-processor
description: 数据清洗和处理工具，支持CSV、JSON格式转换和验证
---

# 数据处理器
...
EOF

# 3. 添加脚本和资源
# 创建scripts/process.py等

# 4. 本地测试
ln -s $(pwd) ~/.openclaw/skills/data-processor
# 在OpenClaw中测试技能

# 5. 验证技能格式
clawhub validate .

# 6. 发布到ClawHub
clawhub publish . --dry-run
clawhub publish .

# 7. 后续更新
# 修改技能后
clawhub publish . --bump minor
```

### 用例4：技能健康检查和维护
```bash
# 场景：定期维护已安装技能
# 1. 创建维护脚本
cat > maintain-skills.sh << 'EOF'
#!/bin/bash
echo "=== 技能维护检查 $(date) ==="

# 检查过时技能
echo "1. 检查过时技能:"
clawhub outdated

# 检查技能健康状态
echo "2. 技能健康状态:"
for skill in $(clawhub list --global --quiet); do
  echo "检查 $skill..."
  clawhub info $skill --json | jq -r '"  版本: \(.version), 最后更新: \(.updated), 状态: \(.status)"'
done

# 检查安全公告
echo "3. 安全公告检查:"
clawhub audit

echo "=== 检查完成 ==="
EOF

chmod +x maintain-skills.sh

# 2. 设置定期执行（如每周一次）
# 添加到cron
(crontab -l 2>/dev/null; echo "0 9 * * 1 $PWD/maintain-skills.sh >> $PWD/skill-maintenance.log") | crontab -

# 3. 手动执行检查
./maintain-skills.sh
```

### 用例5：技能故障排除
```bash
# 场景：技能出现问题需要诊断
# 1. 检查技能状态
clawhub list --verbose problem-skill

# 2. 查看技能详情
clawhub info problem-skill

# 3. 检查技能文件
ls -la ~/.openclaw/skills/problem-skill/

# 4. 重新安装技能
clawhub remove problem-skill --global
clawhub install problem-skill@latest --global

# 5. 检查依赖
clawhub info problem-skill --dependencies

# 6. 如果问题持续，尝试旧版本
clawhub remove problem-skill --global
clawhub install problem-skill@1.0.0 --global

# 7. 报告问题
# 查看技能的问题跟踪
# 或通过ClawHub报告问题
```

## 错误处理指南

### 常见错误及处理

**错误：技能未找到**
- **症状**：`Error: Skill 'xxx' not found in registry`
- **原因**：技能名称错误、技能不存在、注册表连接问题
- **处理**：验证技能名称，搜索技能，检查网络连接

**错误：版本不兼容**
- **症状**：`Error: Incompatible version requirement`
- **原因**：请求的版本与系统或其他技能不兼容
- **处理**：检查兼容版本，使用`clawhub info`查看版本信息

**错误：权限不足**
- **症状**：`Error: Permission denied` 或 `EACCES`
- **原因**：没有写入技能目录的权限
- **处理**：检查目录权限，使用sudo（谨慎），或安装到用户目录

**错误：网络超时**
- **症状**：`Error: Network timeout` 或 `ETIMEDOUT`
- **原因**：网络连接慢，注册表服务器问题
- **处理**：检查网络，增加超时时间，使用镜像源

**错误：技能验证失败**
- **症状**：`Error: Skill validation failed`
- **原因**：技能格式错误，缺失必要文件
- **处理**：检查SKILL.md格式，确保所有必需文件存在

### 调试技巧
```bash
# 启用详细输出
clawhub --verbose install skill-name

# 查看调试信息
CLAWHUB_DEBUG=1 clawhub command

# 清理缓存
clawhub cache clean

# 重置配置
clawhub config reset
```

### 故障排除流程
1. **验证命令**：`clawhub --version` 确认CLI工作
2. **检查网络**：`curl -I https://registry.clawhub.com` 测试连接
3. **查看日志**：检查`~/.clawhub/clawhub.log`
4. **清理状态**：`clawhub cache clean` 清理缓存
5. **简化