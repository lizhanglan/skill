---
title: 飞书文档操作规范
domain: coding/tools/feishu
keywords: [feishu-doc, 飞书文档, 云文档, docx链接, 文档读写, 文档创建, 表格创建, 图片上传, 块操作, 文档编辑, 飞书集成]
triggers: [飞书文档, 云文档, docx链接, 读写文档, 创建文档, 编辑文档, 上传图片到文档, 创建表格, 读取文档内容, 飞书集成, 文档自动化]
scope: 飞书文档的读写操作，包括文档创建、编辑、表格操作、图片上传和块级操作
---

# 飞书文档操作规范

## 核心原则

1. **令牌提取** - 从URL提取doc_token：`https://xxx.feishu.cn/docx/ABC123def` → `ABC123def`
2. **渐进操作** - 简单任务用`read`/`write`，复杂结构用`list_blocks`获取块数据
3. **权限管理** - 创建文档时传递`owner_open_id`确保用户自动获得`full_access`权限
4. **格式兼容** - 支持Markdown基础格式，但表格需使用专用表格操作
5. **错误处理** - 检查响应中的`hint`字段，了解结构化内容需求

## 规范细则

### 基础操作

#### 读取文档
```json
{
  "action": "read",
  "doc_token": "ABC123def"
}
```

**响应检查**：
- 返回标题、纯文本内容、块统计信息
- 检查`hint`字段 - 如果存在，表示有结构化内容（表格、图片）需要`list_blocks`
- 检查`block_types`了解文档包含的块类型

#### 写入文档（替换全部内容）
```json
{
  "action": "write",
  "doc_token": "ABC123def",
  "content": "# 标题\n\nMarkdown内容..."
}
```

**支持的Markdown格式**：
- 标题（#、##、###）
- 列表（有序、无序）
- 代码块（```）
- 引用（>）
- 链接（[text](url)）
- 图片（![](url) - 自动上传）
- 粗体/斜体/删除线

**限制**：Markdown表格不被支持，需使用专用表格操作。

#### 追加内容
```json
{
  "action": "append",
  "doc_token": "ABC123def",
  "content": "追加内容"
}
```

#### 创建文档
```json
{
  "action": "create",
  "title": "新文档",
  "owner_open_id": "ou_xxx"
}
```

**带文件夹创建**：
```json
{
  "action": "create",
  "title": "新文档",
  "folder_token": "fldcnXXX",
  "owner_open_id": "ou_xxx"
}
```

**重要**：始终传递`owner_open_id`（来自运行时上下文`sender_id`的请求用户`open_id`），确保用户自动获得`full_access`权限。没有此参数，只有机器人应用有访问权限。

### 块级操作

#### 列出所有块
```json
{
  "action": "list_blocks",
  "doc_token": "ABC123def"
}
```

**使用场景**：
- 文档有表格、图片等结构化内容时
- 需要获取块ID进行后续操作时
- 需要了解文档完整结构时

#### 获取单个块
```json
{
  "action": "get_block",
  "doc_token": "ABC123def",
  "block_id": "doxcnXXX"
}
```

#### 更新块文本
```json
{
  "action": "update_block",
  "doc_token": "ABC123def",
  "block_id": "doxcnXXX",
  "content": "新文本"
}
```

#### 删除块
```json
{
  "action": "delete_block",
  "doc_token": "ABC123def",
  "block_id": "doxcnXXX"
}
```

### 表格操作

#### 创建表格（Docx表格块）
```json
{
  "action": "create_table",
  "doc_token": "ABC123def",
  "row_size": 2,
  "column_size": 2,
  "column_width": [200, 200]
}
```

**可选参数**：
- `parent_block_id` - 在特定块下插入表格

#### 写入表格单元格
```json
{
  "action": "write_table_cells",
  "doc_token": "ABC123def",
  "table_block_id": "doxcnTABLE",
  "values": [
    ["A1", "B1"],
    ["A2", "B2"]
  ]
}
```

#### 一步创建带值的表格
```json
{
  "action": "create_table_with_values",
  "doc_token": "ABC123def",
  "row_size": 2,
  "column_size": 2,
  "column_width": [200, 200],
  "values": [
    ["A1", "B1"],
    ["A2", "B2"]
  ]
}
```

### 媒体操作

#### 上传图片到文档
**从URL上传**：
```json
{
  "action": "upload_image",
  "doc_token": "ABC123def",
  "url": "https://example.com/image.png"
}
```

**从本地文件上传**（带位置控制）：
```json
{
  "action": "upload_image",
  "doc_token": "ABC123def",
  "file_path": "/tmp/image.png",
  "parent_block_id": "doxcnParent",
  "index": 5
}
```

**参数说明**：
- `index`（0-based）- 在兄弟块中的特定位置插入图片，省略则追加到末尾
- 图片显示大小由上传图片的像素尺寸决定
- 对于小图片（如480x270 GIF），上传前缩放到800px+宽度以确保正确显示

#### 上传文件附件
**从URL上传**：
```json
{
  "action": "upload_file",
  "doc_token": "ABC123def",
  "url": "https://example.com/report.pdf"
}
```

**从本地文件上传**：
```json
{
  "action": "upload_file",
  "doc_token": "ABC123def",
  "file_path": "/tmp/report.pdf",
  "filename": "Q1-report.pdf"
}
```

**规则**：
- 必须且只能使用`url`或`file_path`之一
- 可选`filename`覆盖原文件名
- 可选`parent_block_id`指定父块

### 读取工作流

**标准工作流**：
1. 从`action: "read"`开始 - 获取纯文本 + 统计信息
2. 检查响应中的`block_types`了解是否包含表格、图片、代码等
3. 如果存在结构化内容，使用`action: "list_blocks"`获取完整数据

**示例**：
```json
// 1. 读取文档基本信息
{
  "action": "read",
  "doc_token": "doxcnXXX"
}

// 响应显示有表格，继续获取块数据
{
  "action": "list_blocks",
  "doc_token": "doxcnXXX"
}

// 3. 基于块数据进行操作
{
  "action": "write_table_cells",
  "doc_token": "doxcnXXX",
  "table_block_id": "doxcnTABLE123",
  "values": [["更新A1", "更新B1"]]
}
```

### 配置

**OpenClaw配置**：
```yaml
channels:
  feishu:
    tools:
      doc: true  # 默认: true
```

**注意**：`feishu_wiki`依赖此工具 - 知识库页面内容通过`feishu_doc`读写。

### 权限要求

所需权限：
- `docx:document`
- `docx:document:readonly`
- `docx:document.block:convert`
- `drive:drive`

## 反例（Anti-patterns）

**❌ 不传递owner_open_id**：
```json
{
  "action": "create",
  "title": "新文档"
  // ❌ 缺少owner_open_id，用户无法访问创建的文档
}
```

**❌ 尝试用Markdown写表格**：
```markdown
# 错误：Markdown表格不被支持
| 列1 | 列2 |
|-----|-----|
| 数据 | 数据 |

# 正确：使用create_table_with_values
```

**❌ 忽略hint字段**：
```json
// 响应包含hint字段但被忽略
{
  "hint": "Document contains tables, use list_blocks for full data"
}
// ❌ 继续用read操作处理表格内容
```

**❌ 小图片不缩放**：
```json
{
  "action": "upload_image",
  "doc_token": "doxcnXXX",
  "url": "https://example.com/small.gif"  // 480x270
  // ❌ 可能显示过小，应先缩放
}
```

**❌ 不检查块类型直接操作**：
```json
// 错误：不检查文档是否包含表格
{
  "action": "write_table_cells",
  "doc_token": "doxcnXXX",
  "table_block_id": "假设的ID",  // 可能不是表格块
  "values": [["数据"]]
}
```

**❌ 使用无效的令牌格式**：
```json
{
  "action": "read",
  "doc_token": "https://xxx.feishu.cn/docx/ABC123def"  // ❌ 应只提取ABC123def
}
```

## 适用场景

**适合使用此技能**：
- 读取飞书文档内容进行分析或处理
- 创建新的飞书文档（报告、笔记、文档）
- 编辑现有文档（更新内容、添加章节）
- 在文档中创建和填充表格
- 上传图片或文件到文档
- 自动化文档生成工作流
- 与飞书知识库集成（通过feishu_wiki）

**不适合使用此技能**：
- 复杂的文档格式化（使用飞书原生编辑器）
- 实时协作编辑（使用飞书客户端）
- 文档权限管理（使用feishu_perm技能）
- 文件夹和文件管理（使用feishu_drive技能）
- 知识库导航（使用feishu_wiki技能）

## 最佳实践

### 文档创建流程
1. 始终传递`owner_open_id`确保用户权限
2. 考虑文档存放位置（根目录或特定文件夹）
3. 设置适当的文档标题和初始内容

### 内容更新策略
1. 简单文本更新使用`write`或`append`
2. 结构化更新先`list_blocks`了解现有结构
3. 表格操作使用专用表格方法
4. 媒体上传考虑文件大小和格式

### 错误处理
1. 检查操作响应状态
2. 查看`hint`字段了解额外需求
3. 处理权限错误（检查所需权限）
4. 处理网络或文件错误

### 性能考虑
1. 大文档分块读取和处理
2. 批量操作减少API调用
3. 缓存频繁访问的文档信息
4. 异步处理长时间操作

## 常见用例

### 用例1：生成报告文档
```json
// 1. 创建文档
{
  "action": "create",
  "title": "月度报告 - 2025年3月",
  "owner_open_id": "ou_xxx",
  "folder_token": "fldcnReports"
}

// 2. 写入报告内容
{
  "action": "write",
  "doc_token": "新文档token",
  "content": "# 月度报告\n\n## 概述\n本月完成...\n\n## 关键指标\n- 指标1: 100%\n- 指标2: 95%\n\n## 下一步计划\n1. 任务A\n2. 任务B"
}

// 3. 添加数据表格
{
  "action": "create_table_with_values",
  "doc_token": "新文档token",
  "row_size": 4,
  "column_size": 3,
  "values": [
    ["项目", "目标", "完成"],
    ["项目A", "100", "95"],
    ["项目B", "50", "48"],
    ["总计", "150", "143"]
  ]
}
```

### 用例2：文档内容分析
```json
// 1. 读取文档
{
  "action": "read",
  "doc_token": "doxcnAnalysis"
}

// 2. 如果有表格，获取详细数据
{
  "action": "list_blocks",
  "doc_token": "doxcnAnalysis"
}

// 3. 提取表格数据进行分析
// （基于list_blocks响应处理表格数据）
```

### 用例3：文档模板填充
```json
// 1. 读取模板文档
{
  "action": "read",
  "doc_token": "doxcnTemplate"
}

// 2. 替换模板变量
const content = response.content
  .replace("{{name}}", "张三")
  .replace("{{date}}", "2025-03-15");

// 3. 创建新文档并填充
{
  "action": "create",
  "title": "填充的文档",
  "owner_open_id": "ou_xxx",
  "content": content
}
```
