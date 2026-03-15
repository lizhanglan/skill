---
title: 飞书云存储管理
domain: coding/tools/feishu
keywords: [feishu-drive, 飞书云盘, 云存储, 文件夹管理, 文件管理, 文件列表, 创建文件夹, 移动文件, 删除文件, 文件信息, 云空间]
triggers: [飞书云盘, 云存储, 文件夹, 文件列表, 创建文件夹, 移动文件, 删除文件, 文件信息, 云空间管理, 文件整理]
scope: 飞书云存储的文件管理操作，包括文件列表、信息查询、文件夹创建、文件移动和删除
---

# 飞书云存储管理

## 核心原则

1. **令牌提取** - 从URL提取folder_token：`https://xxx.feishu.cn/drive/folder/ABC123` → `ABC123`
2. **机器人限制** - 飞书机器人没有自己的"我的空间"，只能访问共享给它的文件/文件夹
3. **类型识别** - 准确指定文件类型（docx、sheet、bitable等）进行操作
4. **根目录限制** - 机器人无法在根目录创建文件夹，需要用户先创建并共享文件夹
5. **权限检查** - 确保有足够的权限（drive:drive或drive:drive:readonly）执行操作

## 规范细则

### 基础操作

#### 列出文件夹内容
**根目录**：
```json
{
  "action": "list"
}
```

**特定文件夹**：
```json
{
  "action": "list",
  "folder_token": "fldcnXXX"
}
```

**响应包含**：
- 文件列表，包含token、名称、类型、URL、时间戳
- 分页信息（如果内容多）

#### 获取文件信息
```json
{
  "action": "info",
  "file_token": "ABC123",
  "type": "docx"
}
```

**注意**：文件必须在根目录中，或先使用`list`浏览文件夹找到文件。

**支持的类型**：
- `doc` - 旧格式文档
- `docx` - 新格式文档
- `sheet` - 电子表格
- `bitable` - 多维表格
- `folder` - 文件夹
- `file` - 上传的文件
- `mindnote` - 思维导图
- `shortcut` - 快捷方式

#### 创建文件夹
**在父文件夹中创建**：
```json
{
  "action": "create_folder",
  "name": "新文件夹",
  "folder_token": "fldcnXXX"
}
```

**重要限制**：机器人无法在根目录创建文件夹（`create_folder`不带`folder_token`会失败，400错误）。

**工作流程**：
1. 用户手动创建文件夹并共享给机器人
2. 机器人在该文件夹内创建子文件夹
3. 或用户通过其他方式（飞书客户端）创建所需文件夹结构

#### 移动文件
```json
{
  "action": "move",
  "file_token": "ABC123",
  "type": "docx",
  "folder_token": "fldcnXXX"
}
```

#### 删除文件
```json
{
  "action": "delete",
  "file_token": "ABC123",
  "type": "docx"
}
```

### 文件类型参考

| 类型 | 描述 |
|------|------|
| `doc` | 旧格式文档 |
| `docx` | 新格式文档 |
| `sheet` | 电子表格 |
| `bitable` | 多维表格 |
| `folder` | 文件夹 |
| `file` | 上传的文件（PDF、图片等） |
| `mindnote` | 思维导图 |
| `shortcut` | 快捷方式 |

### 配置

**OpenClaw配置**：
```yaml
channels:
  feishu:
    tools:
      drive: true  # 默认: true
```

### 权限要求

- `drive:drive` - 完全访问（创建、移动、删除）
- `drive:drive:readonly` - 只读访问（列表、信息）

## 已知限制

### 机器人空间限制

**关键限制**：
- 飞书机器人使用`tenant_access_token`，没有自己的"我的空间"
- 根目录概念仅适用于用户账户，不适用于机器人
- 机器人只能访问已**共享给它**的文件/文件夹

**具体表现**：
1. `create_folder`不带`folder_token`会失败（400错误）
2. 机器人无法在根目录创建任何内容
3. 机器人无法浏览未共享给它的文件夹

**变通方案**：
1. **用户先创建**：用户手动创建文件夹并共享给机器人
2. **子文件夹操作**：机器人在已共享的文件夹内创建子文件夹
3. **明确共享**：确保所有需要访问的文件夹都已明确共享给机器人应用

### 工作流示例

#### 场景：在共享文件夹中组织文件
```json
// 1. 用户已创建并共享文件夹 "fldcnSharedFolder"
// 2. 机器人在其中创建子文件夹
{
  "action": "create_folder",
  "name": "项目文档",
  "folder_token": "fldcnSharedFolder"
}

// 3. 列出共享文件夹内容
{
  "action": "list",
  "folder_token": "fldcnSharedFolder"
}

// 4. 移动文件到子文件夹
{
  "action": "move",
  "file_token": "doxcnDocument123",
  "type": "docx",
  "folder_token": "新创建的子文件夹token"
}
```

#### 场景：文件整理自动化
```json
// 1. 列出文件夹内容
{
  "action": "list",
  "folder_token": "fldcnInbox"
}

// 2. 根据文件类型分类
// 假设响应包含文件列表
const docs = files.filter(f => f.type === 'docx');
const sheets = files.filter(f => f.type === 'sheet');

// 3. 创建分类文件夹
{
  "action": "create_folder",
  "name": "文档",
  "folder_token": "fldcnInbox"
}
{
  "action": "create_folder",
  "name": "表格",
  "folder_token": "fldcnInbox"
}

// 4. 移动文件到对应文件夹
// （需要获取新创建文件夹的token，通常从create_folder响应获得）
```

## 反例（Anti-patterns）

**❌ 尝试在根目录创建文件夹**：
```json
{
  "action": "create_folder",
  "name": "新文件夹"
  // ❌ 缺少folder_token，机器人无法在根目录创建
}
```

**❌ 不指定文件类型**：
```json
{
  "action": "info",
  "file_token": "ABC123"
  // ❌ 缺少type参数，无法正确识别文件
}
```

**❌ 假设机器人有根目录访问**：
```json
{
  "action": "list"
  // ❌ 期望看到所有文件，但实际上只看到根目录中共享给机器人的内容
  // 可能返回空列表或权限错误
}
```

**❌ 不检查共享状态**：
```json
// 错误：尝试访问未共享的文件夹
{
  "action": "list",
  "folder_token": "fldcnPrivate"  // 未共享给机器人
}
// 结果：权限错误或空列表
```

**❌ 忽略分页**：
```json
// 错误：假设list返回所有内容
{
  "action": "list",
  "folder_token": "fldcnLargeFolder"
}
// 如果文件夹内容多，可能需要处理分页
```

**❌ 不安全的删除操作**：
```json
{
  "action": "delete",
  "file_token": "ABC123",
  "type": "docx"
  // ❌ 没有确认或备份机制
  // 应考虑先移动或确认重要性
}
```

## 适用场景

**适合使用此技能**：
- 浏览已共享的飞书云存储内容
- 在共享文件夹内创建子文件夹进行组织
- 移动文件到不同的文件夹进行分类
- 删除不需要的文件（谨慎使用）
- 获取文件信息（类型、大小、修改时间等）
- 自动化文件整理工作流

**不适合使用此技能**：
- 管理机器人自己的"我的空间"（不存在）
- 在根目录创建文件夹或文件
- 访问未共享给机器人的私人文件
- 复杂的权限管理（使用feishu_perm技能）
- 文档内容操作（使用feishu_doc技能）
- 知识库文件管理（使用feishu_wiki技能）

## 最佳实践

### 文件夹管理
1. **用户先创建**：重要文件夹由用户创建并共享
2. **子文件夹操作**：机器人在共享文件夹内创建子结构
3. **命名规范**：使用一致的文件夹命名约定
4. **定期清理**：建立文件归档和清理流程

### 文件操作
1. **类型检查**：操作前确认文件类型
2. **备份考虑**：重要文件删除前考虑备份
3. **批量操作**：类似文件批量处理提高效率
4. **错误处理**：处理权限错误和不存在错误

### 权限管理
1. **明确共享**：确保所需文件夹已共享给机器人
2. **权限级别**：根据需求设置适当权限（view/edit）
3. **定期审查**：定期审查共享设置和访问权限
4. **最小权限**：遵循最小权限原则

### 性能优化
1. **缓存列表**：频繁访问的文件夹列表可缓存
2. **分批处理**：大量文件操作分批进行
3. **异步操作**：长时间操作使用异步模式
4. **错误重试**：网络错误实现适当重试机制

## 常见用例

### 用例1：项目文件组织
```json
// 场景：组织项目相关文件
// 前提：用户已创建"项目A"文件夹并共享

// 1. 在项目文件夹中创建子文件夹
{
  "action": "create_folder",
  "name": "需求文档",
  "folder_token": "fldcnProjectA"
}
{
  "action": "create_folder",
  "name": "设计稿",
  "folder_token": "fldcnProjectA"
}
{
  "action": "create_folder",
  "name": "会议记录",
  "folder_token": "fldcnProjectA"
}

// 2. 列出项目文件夹内容
{
  "action": "list",
  "folder_token": "fldcnProjectA"
}

// 3. 根据文件类型移动到对应子文件夹
// （需要根据list响应和create_folder响应处理）
```

### 用例2：月度报告归档
```json
// 场景：将旧报告移动到归档文件夹
// 前提：已有"报告"和"归档"文件夹

// 1. 创建本月归档文件夹
{
  "action": "create_folder",
  "name": "2025-03",
  "folder_token": "fldcnArchive"
}

// 2. 列出报告文件夹中的旧报告
{
  "action": "list",
  "folder_token": "fldcnReports"
}

// 3. 移动上个月报告到归档
// 假设识别出2025-02的报告
{
  "action": "move",
  "file_token": "doxcnFebReport",
  "type": "docx",
  "folder_token": "新创建的2025-03归档文件夹token"
}
```

### 用例3：文件清理自动化
```json
// 场景：清理临时文件夹中的旧文件
// 前提：有"临时文件"文件夹

// 1. 列出临时文件夹内容
{
  "action": "list",
  "folder_token": "fldcnTemp"
}

// 2. 识别超过30天的文件
// （需要解析文件时间戳）
const oldFiles = files.filter(file => {
  const fileDate = new Date(file.created_time);
  const daysOld = (Date.now() - fileDate) / (1000 * 60 * 60 * 24);
  return daysOld > 30;
});

// 3. 删除旧文件（谨慎操作）
// {
//   "action": "delete",
//   "file_token": oldFile.token,
//   "type": oldFile.type
// }
// 或先移动到"待删除"文件夹由用户确认
```

### 用例4：文件信息收集
```json
// 场景：收集文件夹中文件信息生成报告
// 1. 列出文件夹内容
{
  "action": "list",
  "folder_token": "fldcnTarget"
}

// 2. 获取每个文件的详细信息
const fileDetails = [];
for (const file of files) {
  const info = await feishu_drive({
    action: "info",
    file_token: file.token,
    type: file.type
  });
  fileDetails.push({
    name: file.name,
    type: file.type,
    size: info.size,
    created: info.created_time,
    modified: info.modified_time
  });
}

// 3. 生成报告（使用feishu_doc创建文档）
```

## 错误处理指南

### 常见错误及处理

**错误：400 Bad Request**
- **可能原因**：缺少必要参数、参数格式错误、机器人尝试根目录操作
- **处理**：检查参数完整性，确保folder_token已提供，避免根目录操作

**错误：403 Forbidden**
- **可能原因**：权限不足、文件夹未共享给机器人
- **处理**：检查文件夹共享状态，确认有足够权限

**错误：404 Not Found**
- **可能原因**：文件或文件夹不存在、token无效
- **处理**：验证token正确性，确认文件/文件夹存在

**错误：429 Too Many Requests**
- **可能原因**：API调用频率超限
- **处理**：实现退避重试机制，降低调用频率

### 重试策略
```javascript
// 示例重试逻辑
async function withRetry(operation, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (error.status === 429 && attempt < maxRetries) {
        // 速率限制，指数退避
        const delay = Math.pow(2, attempt) * 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      throw error;
    }
  }
}

// 使用示例
const result = await withRetry(() => 
  feishu_drive({
    action: "list",
    folder_token: "fldcnTarget"
  })
);
```
