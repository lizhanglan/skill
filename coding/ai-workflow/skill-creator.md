---
title: 技能创建与维护规范
domain: coding/ai-workflow
keywords: [skill-creator, 技能创建, 技能编写, 技能审核, 技能改进, 技能清理, 技能重构, AgentSkills, SKILL.md, 技能规范, 技能模板, 技能打包]
triggers: [创建技能, 编写技能, 审核技能, 改进技能, 清理技能, 重构技能, 更新技能, 打包技能, 验证技能, 技能模板, 技能规范]
scope: 创建、编辑、改进或审核 AgentSkills，包括技能目录结构、SKILL.md 编写和技能打包
---

# 技能创建与维护规范

## 核心原则

1. **为 AI 而写，非为人而写** - 结构优先于叙述，结论优先于过程，保持简洁
2. **渐进式披露设计** - 使用三级加载系统：元数据 → SKILL.md → 资源文件
3. **适当的自由度** - 根据任务脆弱性设置自由度：高自由度（文本指令）、中自由度（伪代码）、低自由度（具体脚本）
4. **无重复内容** - 信息只存在于一处：SKILL.md 或资源文件，不重复
5. **验证优先** - 创建技能后必须验证，打包前必须通过验证检查

## 规范细则

### 技能结构

**标准技能目录结构**：
```
skill-name/
├── SKILL.md (必需)
│   ├── YAML 前端元数据 (必需)
│   │   ├── name: (必需)
│   │   └── description: (必需)
│   └── Markdown 指令 (必需)
└── 资源文件 (可选)
    ├── scripts/          - 可执行代码 (Python/Bash 等)
    ├── references/       - 文档和参考材料
    └── assets/           - 输出中使用的文件 (模板、图标等)
```

**禁止的文件**：
- README.md
- INSTALLATION_GUIDE.md  
- QUICK_REFERENCE.md
- CHANGELOG.md
- 其他辅助文档文件

### SKILL.md 编写规范

**前端元数据 (YAML)**：
```yaml
---
name: skill-name
description: |
  完整的技能描述，包括：
  1. 技能做什么
  2. 何时使用该技能（所有触发条件）
  3. 具体的使用场景
  4. 关键的限制或前提条件
---
```

**描述字段要求**：
- 包含所有"何时使用"信息（不在正文中重复）
- 使用具体、可操作的触发词
- 描述技能功能和限制
- 示例：对于 `docx` 技能："全面的文档创建、编辑和分析，支持跟踪更改、评论、格式保留和文本提取。当 Codex 需要处理专业文档 (.docx 文件) 时使用：(1) 创建新文档，(2) 修改或编辑内容，(3) 处理跟踪更改，(4) 添加评论，或任何其他文档任务"

**正文编写指南**：
- 使用命令式/不定式形式
- 保持简洁，挑战每个信息："Codex 真的需要这个解释吗？"
- 优先使用简洁示例而非冗长解释
- 正文长度控制在 500 行以内

### 渐进式披露模式

**模式 1：高级指南 + 引用**：
```markdown
# PDF 处理

## 快速开始

使用 pdfplumber 提取文本：
[代码示例]

## 高级功能

- **表单填写**：参见 [FORMS.md](FORMS.md) 获取完整指南
- **API 参考**：参见 [REFERENCE.md](REFERENCE.md) 获取所有方法
- **示例**：参见 [EXAMPLES.md](EXAMPLES.md) 获取常见模式
```

**模式 2：领域特定组织**：
```
bigquery-skill/
├── SKILL.md (概述和导航)
└── reference/
    ├── finance.md (收入、账单指标)
    ├── sales.md (机会、管道)
    ├── product.md (API 使用、功能)
    └── marketing.md (活动、归因)
```

**模式 3：条件细节**：
```markdown
# DOCX 处理

## 创建文档

使用 docx-js 创建新文档。参见 [DOCX-JS.md](DOCX-JS.md)。

## 编辑文档

对于简单编辑，直接修改 XML。

**对于跟踪更改**：参见 [REDLINING.md](REDLINING.md)
**对于 OOXML 详情**：参见 [OOXML.md](OOXML.md)
```

### 资源文件管理

**scripts/ 目录**：
- 包含需要确定性可靠性或重复编写的可执行代码
- 示例：`scripts/rotate_pdf.py` 用于 PDF 旋转任务
- 优势：令牌高效、确定性、无需加载到上下文中即可执行
- 注意：脚本可能仍需要被 Codex 读取以进行修补或环境特定调整

**references/ 目录**：
- 包含 Codex 工作过程中需要参考的文档和参考材料
- 示例：`references/finance.md` 用于财务模式，`references/api_docs.md` 用于 API 规范
- 最佳实践：如果文件较大 (>10k 词)，在 SKILL.md 中包含 grep 搜索模式
- 避免重复：信息应只存在于 SKILL.md 或引用文件中，不在两处都存

**assets/ 目录**：
- 包含在 Codex 输出中使用的文件，不加载到上下文中
- 示例：`assets/logo.png` 用于品牌资源，`assets/frontend-template/` 用于 HTML/React 样板
- 用例：模板、图像、图标、样板代码、字体、示例文档

### 技能创建流程

**步骤 1：通过具体示例理解技能**
- 询问："这个技能应该支持什么功能？"
- 询问："你能给出一些这个技能如何使用的例子吗？"
- 询问："用户说什么会触发这个技能？"
- 避免在单个消息中问太多问题

**步骤 2：规划可重用技能内容**
- 分析每个示例如何从头执行
- 识别执行这些工作流时会有帮助的脚本、引用和资源
- 示例：`pdf-editor` 技能 → `scripts/rotate_pdf.py`

**步骤 3：初始化技能**
```bash
scripts/init_skill.py my-skill --path skills/public --resources scripts,references --examples
```

**步骤 4：编辑技能**
- 从可重用资源开始（scripts/, references/, assets/）
- 测试添加的脚本以确保没有错误
- 更新 SKILL.md 前端元数据和正文
- 如果使用了 `--examples`，删除不需要的占位符文件

**步骤 5：打包技能**
```bash
scripts/package_skill.py <path/to/skill-folder>
```
- 自动验证技能
- 创建 .skill 文件（zip 格式，.skill 扩展名）
- 安全限制：拒绝符号链接

**步骤 6：迭代**
- 在真实任务上使用技能
- 注意困难或低效之处
- 识别 SKILL.md 或资源文件应如何更新
- 实施更改并再次测试

### 技能命名规范

- 使用小写字母、数字和连字符
- 将用户提供的标题规范化为连字符格式（例如，"Plan Mode" → `plan-mode`）
- 生成名称不超过 64 个字符
- 优先使用简短、动词引导的短语描述动作
- 当提高清晰度或触发时，按工具命名空间（例如，`gh-address-comments`, `linear-address-issue`）
- 技能文件夹名称必须与技能名称完全一致

## 反例（Anti-patterns）

**❌ 冗长的描述**：
```yaml
description: "这是一个处理 PDF 文件的技能。它有很多功能。你可以用它做很多事情。"
# 正确：具体描述功能和触发条件
```

**❌ 在正文中重复触发信息**：
```markdown
# 技能名称

## 何时使用此技能
当用户需要处理 PDF 时使用...
# 错误：触发信息应在描述字段中，不在正文中
```

**❌ 创建不必要的文档文件**：
```
skill-name/
├── SKILL.md
├── README.md          # ❌ 不需要
├── INSTALLATION.md    # ❌ 不需要
└── CHANGELOG.md       # ❌ 不需要
```

**❌ 深度嵌套的引用**：
```
skill-name/
├── SKILL.md
└── references/
    └── subfolder/     # ❌ 避免深度嵌套
        └── deep.md
```

**❌ 未测试的脚本**：
```python
# scripts/buggy.py
def process():
    return 1/0  # ❌ 未测试，会崩溃
```

**❌ 符号链接**：
```
skill-name/
├── SKILL.md
└── scripts/
    └── link.py -> ../other-skill/script.py  # ❌ 打包会失败
```

## 适用场景

**适合使用此技能**：
- 从头创建新技能
- 改进现有技能
- 审核技能质量和完整性
- 清理技能目录结构
- 重构技能以符合规范
- 打包技能进行分发

**不适合使用此技能**：
- 简单的技能内容更新（直接编辑文件）
- 技能使用指导（使用具体技能本身）
- 技能发现（使用 find-skills 技能）
