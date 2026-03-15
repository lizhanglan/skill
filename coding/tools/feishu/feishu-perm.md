---
title: 飞书权限管理
domain: coding/tools/feishu
keywords: [feishu-perm, 飞书权限, 文档共享, 权限管理, 协作者, 添加协作者, 移除协作者, 权限级别, 共享设置, 访问控制]
triggers: [飞书权限, 文档共享, 添加协作者, 移除协作者, 权限管理, 共享设置, 访问控制, 协作权限, 文档分享]
scope: 飞书文档和文件的权限管理操作，包括协作者列表、添加协作者和移除协作者
---

# 飞书权限管理

## 核心原则

1. **敏感操作** - 权限管理是敏感操作，默认禁用，需要显式启用
2. **类型准确** - 准确指定文件类型（docx、sheet、folder等）进行权限操作
3. **成员识别** - 正确使用成员类型（email、openid、userid等）标识用户
4. **权限分级** - 根据需求设置适当权限级别（view、edit、full_access）
5. **最小权限** - 遵循最小权限原则，只授予必要的访问权限

## 规范细则

### 基础操作

#### 列出协作者
```json
{
  "action": "list",
  "token": "ABC123",
  "type": "docx"
}
```

**响应包含**：
- 成员列表，包含member_type、member_id、perm、name
- 当前文件的权限设置信息

#### 添加协作者
```json
{
  "action": "add",
  "token": "ABC123",
  "type": "docx",
  "member_type": "email",
  "member_id": "user@example.com",
  "perm": "edit"
}
```

#### 移除协作者
```json
{
  "action": "remove",
  "token": "ABC123",
  "type": "docx",
  "member_type": "email",
  "member_id": "user@example.com"
}
```

### 令牌类型参考

| 类型 | 描述 |
|------|------|
| `doc` | 旧格式文档 |
| `docx` | 新格式文档 |
| `sheet` | 电子表格 |
| `bitable` | 多维表格 |
| `folder` | 文件夹 |
| `file` | 上传的文件 |
| `wiki` | 知识库节点 |
| `mindnote` | 思维导图 |

### 成员类型参考

| 类型 | 描述 | 示例 |
|------|------|------|
| `email` | 邮箱地址 | `"user@company.com"` |
| `openid` | 用户open_id | `"ou_xxx"` |
| `userid` | 用户user_id | `"u_xxx"` |
| `unionid` | 用户union_id | `"on_xxx"` |
| `openchat` | 群聊open_id | `"oc_xxx"` |
| `opendepartmentid` | 部门open_id | `"od_xxx"` |

### 权限级别参考

| 权限 | 描述 |
|------|------|
| `view` | 仅查看，不能编辑 |
| `edit` | 可以编辑内容 |
| `full_access` | 完全访问，可以管理权限 |

### 配置

**OpenClaw配置**：
```yaml
channels:
  feishu:
    tools:
      perm: true  # 默认: false（禁用）
```

**重要**：此工具默认禁用，因为权限管理是敏感操作。需要时显式启用。

### 权限要求

所需权限：`drive:permission`

## 示例

### 示例1：通过邮箱共享文档
```json
{
  "action": "add",
  "token": "doxcnXXX",
  "type": "docx",
  "member_type": "email",
  "member_id": "alice@company.com",
  "perm": "edit"
}
```

### 示例2：共享文件夹给群组
```json
{
  "action": "add",
  "token": "fldcnXXX",
  "type": "folder",
  "member_type": "openchat",
  "member_id": "oc_xxx",
  "perm": "view"
}
```

### 示例3：使用open_id共享
```json
{
  "action": "add",
  "token": "shtcnXXX",
  "type": "sheet",
  "member_type": "openid",
  "member_id": "ou_xxx",
  "perm": "edit"
}
```

### 示例4：查看文档权限
```json
// 1. 查看当前协作者
{
  "action": "list",
  "token": "doxcnXXX",
  "type": "docx"
}

// 响应示例：
// {
//   "members": [
//     {
//       "member_type": "openid",
//       "member_id": "ou_creator",
//       "perm": "full_access",
//       "name": "创建者"
//     },
//     {
//       "member_type": "email", 
//       "member_id": "bob@company.com",
//       "perm": "edit",
//       "name": "Bob"
//     }
//   ]
// }

// 2. 移除特定协作者
{
  "action": "remove",
  "token": "doxcnXXX",
  "type": "docx",
  "member_type": "email",
  "member_id": "bob@company.com"
}
```

## 工作流指南

### 共享工作流

**标准共享流程**：
1. 确定要共享的文件/文件夹token和类型
2. 确定目标用户的标识方式（邮箱、openid等）
3. 确定适当的权限级别
4. 执行添加协作者操作
5. 验证共享成功（可选）

**批量共享示例**：
```json
// 共享给多个用户
const users = [
  { type: "email", id: "alice@company.com", perm: "edit" },
  { type: "email", id: "bob@company.com", perm: "view" },
  { type: "openchat", id: "oc_team", perm: "edit" }
];

for (const user of users) {
  await feishu_perm({
    action: "add",
    token: "doxcnXXX",
    type: "docx",
    member_type: user.type,
    member_id: user.id,
    perm: user.perm
  });
}
```

### 权限审查工作流

**定期权限审查**：
1. 列出所有协作者
2. 分析权限设置是否合理
3. 移除不再需要的访问权限
4. 调整不适当的权限级别
5. 记录权限变更

**自动化审查脚本思路**：
```javascript
// 1. 获取协作者列表
const collaborators = await feishu_perm({
  action: "list",
  token: fileToken,
  type: fileType
});

// 2. 分析权限
const analysis = {
  total: collaborators.members.length,
  fullAccess: collaborators.members.filter(m => m.perm === 'full_access').length,
  edit: collaborators.members.filter(m => m.perm === 'edit').length,
  view: collaborators.members.filter(m => m.perm === 'view').length,
  external: collaborators.members.filter(m => m.member_type === 'email' && !m.email.endsWith('@company.com')).length
};

// 3. 生成报告和建议
if (analysis.external > 0) {
  console.log(`警告：有${analysis.external}个外部协作者`);
}
if (analysis.fullAccess > 3) {
  console.log(`建议：${analysis.fullAccess}个用户有完全访问权限，考虑减少`);
}
```

### 权限迁移工作流

**场景**：将权限从个人转移到群组
```json
// 1. 查看当前个人权限
{
  "action": "list",
  "token": "doxcnXXX",
  "type": "docx"
}

// 2. 添加群组权限
{
  "action": "add",
  "token": "doxcnXXX",
  "type": "docx",
  "member_type": "openchat",
  "member_id": "oc_team",
  "perm": "edit"
}

// 3. 移除个人权限（如果需要）
// {
//   "action": "remove",
//   "token": "doxcnXXX",
//   "type": "docx",
//   "member_type": "openid",
//   "member_id": "ou_individual"
// }
```

## 反例（Anti-patterns）

**❌ 使用默认配置（未启用perm工具）**：
```yaml
# 错误：尝试使用未启用的工具
channels:
  feishu:
    tools:
      perm: false  # 默认值，工具未启用
# 结果：权限操作失败
```

**❌ 不指定文件类型**：
```json
{
  "action": "add",
  "token": "ABC123",
  "member_type": "email",
  "member_id": "user@example.com",
  "perm": "edit"
  // ❌ 缺少type参数
}
```

**❌ 使用错误的成员类型**：
```json
{
  "action": "add",
  "token": "doxcnXXX",
  "type": "docx",
  "member_type": "email",
  "member_id": "ou_xxx"  // ❌ 邮箱类型但提供了openid
  "perm": "edit"
}
```

**❌ 授予过高权限**：
```json
{
  "action": "add",
  "token": "doxcnXXX",
  "type": "docx",
  "member_type": "email",
  "member_id": "external@other-company.com",
  "perm": "full_access"  // ❌ 给外部用户完全访问权限
}
```

**❌ 不审查现有权限就添加**：
```json
// 错误：直接添加而不检查是否已存在
{
  "action": "add",
  "token": "doxcnXXX",
  "type": "docx",
  "member_type": "email",
  "member_id": "user@company.com",
  "perm": "edit"
}
// 可能造成重复权限或权限冲突
```

**❌ 忽略权限继承**：
```json
// 错误：在文件夹设置权限，但忽略子文件
// 文件夹权限可能不会自动继承到所有子文件
// 需要单独处理重要文件的权限
```

## 适用场景

**适合使用此技能**：
- 共享飞书文档给同事或团队成员
- 管理文档的访问权限（添加/移除协作者）
- 定期审查和清理文档权限
- 批量修改多个文件的权限设置
- 将个人权限迁移到群组权限
- 设置适当的权限级别（view/edit/full_access）

**不适合使用此技能**：
- 复杂的组织架构权限管理（使用飞书管理后台）
- 审计日志和合规性报告（需要更全面的审计工具）
- 实时权限同步（使用飞书原生同步机制）
- 文档内容操作（使用feishu_doc技能）
- 文件管理（使用feishu_drive技能）

## 最佳实践

### 权限设计原则
1. **最小权限**：只授予完成工作所需的最小权限
2. **角色分离**：区分查看者、编辑者、管理者角色
3. **定期审查**：定期审查和清理不必要的权限
4. **文档记录**：记录重要的权限变更和原因

### 共享策略
1. **优先群组**：优先共享给群组而非个人，便于管理
2. **外部限制**：对外部用户使用更严格的权限控制
3. **时间限制**：考虑临时权限需求，定期清理
4. **继承考虑**：理解文件夹权限的继承行为

### 安全考虑
1. **敏感文件**：对敏感文件使用更严格的权限控制
2. **离职处理**：员工离职时及时移除权限
3. **变更监控**：监控重要的权限变更
4. **备份权限**：重要权限设置定期备份

### 错误处理
1. **验证输入**：操作前验证所有参数的正确性
2. **检查存在**：添加前检查是否已有权限
3. **处理冲突**：处理权限冲突和重复问题
4. **记录失败**：记录权限操作失败的原因

## 常见用例

### 用例1：项目文档共享
```json
// 场景：共享项目文档给项目团队
// 1. 共享给项目群组
{
  "action": "add",
  "token": "doxcnProjectDoc",
  "type": "docx",
  "member_type": "openchat",
  "member_id": "oc_project_team",
  "perm": "edit"
}

// 2. 共享给相关干系人（只读）
{
  "action": "add",
  "token": "doxcnProjectDoc",
  "type": "docx",
  "member_type": "email",
  "member_id": "stakeholder@company.com",
  "perm": "view"
}

// 3. 共享给外部顾问（有限权限）
{
  "action": "add",
  "token": "doxcnProjectDoc",
  "type": "docx",
  "member_type": "email",
  "member_id": "consultant@partner.com",
  "perm": "view"  // 只读，非编辑
}
```

### 用例2：权限定期清理
```json
// 场景：每月清理文档权限
// 1. 列出所有协作者
{
  "action": "list",
  "token": "doxcnMonthlyReport",
  "type": "docx"
}

// 2. 识别需要移除的协作者
// 规则示例：
// - 外部邮箱超过90天未访问
// - 已离职员工
// - 临时协作者超过有效期

// 3. 移除符合条件的协作者
{
  "action": "remove",
  "token": "doxcnMonthlyReport",
  "type": "docx",
  "member_type": "email",
  "member_id": "former_employee@company.com"
}
```

### 用例3：批量文件权限设置
```json
// 场景：为新项目批量设置文件权限
const projectFiles = [
  { token: "doxcnSpec", type: "docx" },
  { token: "shtcnPlan", type: "sheet" },
  { token: "basnTasks", type: "bitable" },
  { token: "fldcnDocs", type: "folder" }
];

const teamMembers = [
  { type: "openid", id: "ou_lead", perm: "full_access" },
  { type: "openid", id: "ou_dev1", perm: "edit" },
  { type: "openid", id: "ou_dev2", perm: "edit" },
  { type: "openchat", id: "oc_qa", perm: "view" }
];

// 为每个文件设置团队权限
for (const file of projectFiles) {
  for (const member of teamMembers) {
    await feishu_perm({
      action: "add",
      token: file.token,
      type: file.type,
      member_type: member.type,
      member_id: member.id,
      perm: member.perm
    });
  }
}
```

### 用例4：权限审计报告
```json
// 场景：生成文档权限审计报告
// 1. 获取文档列表（通过feishu_drive）
{
  "action": "list",
  "folder_token": "fldcnImportant"
}

// 2. 为每个文档获取权限信息
const auditResults = [];
for (const file of files) {
  const permissions = await feishu_perm({
    action: "list",
    token: file.token,
    type: file.type
  });
  
  auditResults.push({
    name: file.name,
    type: file.type,
    totalCollaborators: permissions.members.length,
    externalCollaborators: permissions.members.filter(m => 
      m.member_type === 'email' && !m.email.endsWith('@company.com')
    ).length,
    fullAccessCount: permissions.members.filter(m => m.perm === 'full_access').length,
    collaborators: permissions.members.map(m => ({
      name: m.name,
      type: m.member_type,
      permission: m.perm
    }))
  });
}

// 3. 生成审计报告（使用feishu_doc）
// 包含：文件列表、权限统计、异常情况、改进建议
```

## 错误处理指南

### 常见错误及处理

**错误：403 Forbidden**
- **可能原因**：权限不足、perm工具未启用
- **处理**：检查配置中`perm: true`，确认有`drive:permission`权限

**错误：400 Bad Request**
- **可能原因**：参数错误、不支持的成员类型、无效的权限值
- **处理**：检查参数格式，验证成员类型和权限值有效性

**错误：404 Not Found**
- **可能原因**：文件不存在、token无效
- **处理**：验证文件存在性和token正确性

**错误：409 Conflict**
- **可能原因**：权限已存在、权限冲突
- **处理**：先检查现有权限，避免重复添加

### 安全注意事项

1. **操作确认**：重要权限变更前要求用户确认
2. **变更日志**：记录所有权限变更操作
3. **回滚计划**：重要权限设置考虑回滚方案
4. **测试环境**：在生产环境操作前在测试环境验证

### 速率限制考虑
```javascript
// 权限操作可能有速率限制，实现适当的延迟
async function addCollaboratorWithDelay(params, delayMs = 1000) {
  await feishu_perm(params);
  await new Promise(resolve => setTimeout(resolve, delayMs));
}

// 批量操作时