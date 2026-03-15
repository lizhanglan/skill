---
title: 飞书知识库导航
domain: coding/tools/feishu
keywords: [feishu-wiki, 飞书知识库, 知识库, wiki, 知识空间, 节点导航, 知识库创建, 页面管理, 知识库搜索, 文档组织]
triggers: [飞书知识库, wiki, 知识库导航, 创建知识页面, 管理知识库, 搜索知识库, 知识库节点, 知识空间, 文档组织]
scope: 飞书知识库的导航和操作，包括知识空间浏览、节点管理、页面创建和搜索
---

# 飞书知识库导航

## 核心原则

1. **令牌提取** - 从URL提取token：`https://xxx.feishu.cn/wiki/ABC123def` → `ABC123def`
2. **导航优先** - 使用`feishu_wiki`进行知识库导航，使用`feishu_doc`进行内容操作
3. **空间隔离** - 知识库按空间组织，操作需要指定正确的`space_id`
4. **类型明确** - 创建节点时明确指定对象类型（docx、sheet、bitable等）
5. **依赖管理** - 此工具依赖`feishu_doc`，需要同时启用两个工具

## 规范细则

### 基础操作

#### 列出知识空间
```json
{
  "action": "spaces"
}
```

**响应包含**：所有可访问的知识库空间列表，包含space_id、名称、描述等。

#### 列出节点
**空间根节点**：
```json
{
  "action": "nodes",
  "space_id": "7xxx"
}
```

**特定父节点下**：
```json
{
  "action": "nodes",
  "space_id": "7xxx",
  "parent_node_token": "wikcnXXX"
}
```

#### 获取节点详情
```json
{
  "action": "get",
  "token": "ABC123def"
}
```

**响应包含**：`node_token`、`obj_token`、`obj_type`等。使用`obj_token`配合`feishu_doc`读写文档内容。

#### 搜索知识库
```json
{
  "action": "search",
  "query": "搜索关键词",
  "space_id": "7xxx"  // 可选，限制在特定空间
}
```

#### 创建节点
**基本创建**：
```json
{
  "action": "create",
  "space_id": "7xxx",
  "title": "新页面"
}
```

**指定类型和父节点**：
```json
{
  "action": "create",
  "space_id": "7xxx",
  "title": "数据表格",
  "obj_type": "sheet",
  "parent_node_token": "wikcnXXX"
}
```

**支持的对象类型**：
- `docx`（默认）- 文档
- `sheet` - 电子表格
- `bitable` - 多维表格
- `mindnote` - 思维导图
- `file` - 文件
- `doc` - 旧格式文档
- `slides` - 幻灯片

#### 移动节点
**同一空间内移动**：
```json
{
  "action": "move",
  "space_id": "7xxx",
  "node_token": "wikcnXXX"
}
```

**跨空间移动**：
```json
{
  "action": "move",
  "space_id": "7xxx",
  "node_token": "wikcnXXX",
  "target_space_id": "7yyy",
  "target_parent_token": "wikcnYYY"
}
```

#### 重命名节点
```json
{
  "action": "rename",
  "space_id": "7xxx",
  "node_token": "wikcnXXX",
  "title": "新标题"
}
```

### Wiki-Doc 工作流

**编辑知识库页面的标准工作流**：

1. **获取节点**：
   ```json
   {
     "action": "get",
     "token": "wiki_token"
   }
   ```
   → 返回`obj_token`

2. **读取文档内容**：
   ```json
   {
     "action": "read",
     "doc_token": "obj_token"
   }
   ```

3. **写入文档内容**：
   ```json
   {
     "action": "write",
     "doc_token": "obj_token",
     "content": "新内容..."
   }
   ```

**完整示例**：
```json
// 1. 获取wiki页面信息
const wikiInfo = await feishu_wiki({
  action: "get",
  token: "wikcnPage123"
});

// 2. 读取页面内容
const pageContent = await feishu_doc({
  action: "read",
  doc_token: wikiInfo.obj_token
});

// 3. 更新页面内容
await feishu_doc({
  action: "write",
  doc_token: wikiInfo.obj_token,
  content: pageContent.content + "\n\n## 更新内容\n新增的更新..."
});
```

### 配置

**OpenClaw配置**：
```yaml
channels:
  feishu:
    tools:
      wiki: true  # 默认: true
      doc: true   # 必需 - wiki内容使用feishu_doc
```

**依赖**：此工具需要`feishu_doc`已启用。知识库页面本质上是文档，使用`feishu_wiki`进行导航，然后使用`feishu_doc`读写内容。

### 权限要求

所需权限：`wiki:wiki` 或 `wiki:wiki:readonly`

## 知识库结构管理

### 空间组织策略

**单空间简单组织**：
```
空间: 团队知识库
├── 📁 产品文档
│   ├── 📄 产品需求文档
│   ├── 📄 用户手册
│   └── 📄 更新日志
├── 📁 技术文档
│   ├── 📄 API文档
│   ├── 📄 架构设计
│   └── 📄 部署指南
└── 📁 团队资源
    ├── 📄 团队章程
    ├── 📄 会议记录
    └── 📄 学习资料
```

**多空间复杂组织**：
```
空间1: 产品知识库 (space_id: 7aaa)
空间2: 技术知识库 (space_id: 7bbb)  
空间3: 运营知识库 (space_id: 7ccc)
空间4: 客户知识库 (space_id: 7ddd)
```

### 节点创建模式

**创建文档页面**：
```json
{
  "action": "create",
  "space_id": "7xxx",
  "title": "新文档",
  "obj_type": "docx",
  "parent_node_token": "wikcnParent"
}
```

**创建数据表格**：
```json
{
  "action": "create",
  "space_id": "7xxx",
  "title": "项目跟踪表",
  "obj_type": "sheet",
  "parent_node_token": "wikcnProjects"
}
```

**创建多维表格**：
```json
{
  "action": "create",
  "space_id": "7xxx",
  "title": "任务看板",
  "obj_type": "bitable",
  "parent_node_token": "wikcnTasks"
}
```

### 批量操作示例

**批量创建文档结构**：
```json
// 创建季度报告结构
const quarter = "Q1-2025";
const sections = ["概述", "业绩分析", "问题与挑战", "下一步计划"];

// 创建季度文件夹
const folder = await feishu_wiki({
  action: "create",
  space_id: "7reports",
  title: quarter,
  obj_type: "docx",  // 文件夹也是docx类型
  parent_node_token: "wikcnReportsRoot"
});

for (const section of sections) {
  await feishu_wiki({
    action: "create",
    space_id: "7reports",
    title: `${quarter} - ${section}`,
    obj_type: "docx",
    parent_node_token: folder.node_token
  });
}
```

## 反例（Anti-patterns）

**❌ 不启用依赖工具**：
```yaml
# 错误：只启用wiki，不启用doc
channels:
  feishu:
    tools:
      wiki: true
      doc: false  # ❌ 必需的工具未启用
# 结果：无法读写页面内容
```

**❌ 混淆node_token和obj_token**：
```json
// 错误：使用node_token操作文档内容
{
  "action": "read",
  "doc_token": "wikcnXXX"  // ❌ 这是node_token，不是obj_token
}

// 正确：先获取obj_token
const wikiInfo = await feishu_wiki({ action: "get", token: "wikcnXXX" });
await feishu_doc({ action: "read", doc_token: wikiInfo.obj_token });
```

**❌ 不指定space_id**：
```json
{
  "action": "nodes"
  // ❌ 缺少space_id，无法确定操作哪个知识空间
}
```

**❌ 错误的obj_type**：
```json
{
  "action": "create",
  "space_id": "7xxx",
  "title": "新页面",
  "obj_type": "invalid_type"  // ❌ 不支持的类型
}
```

**❌ 忽略父节点上下文**：
```json
// 错误：在错误的位置创建页面
{
  "action": "create",
  "space_id": "7xxx",
  "title": "技术文档",
  "parent_node_token": "wikcnMarketing"  // ❌ 在营销文件夹创建技术文档
}
```

**❌ 不处理分页**：
```json
// 错误：假设nodes返回所有内容
{
  "action": "nodes",
  "space_id": "7large"
}
// 如果空间内容多，可能需要处理分页
```

## 适用场景

**适合使用此技能**：
- 浏览和导航飞书知识库结构
- 在知识库中创建新的文档页面
- 管理知识库的节点组织（移动、重命名）
- 搜索知识库内容
- 自动化知识库内容管理
- 批量创建知识库页面结构
- 知识库内容同步和备份

**不适合使用此技能**：
- 文档内容详细编辑（使用feishu_doc技能）
- 文件上传和管理（使用feishu_drive技能）
- 权限管理（使用feishu_perm技能）
- 复杂的文档格式化（使用飞书原生编辑器）
- 实时协作编辑（使用飞书客户端）

## 最佳实践

### 知识库设计
1. **清晰结构**：设计清晰的层次结构，便于导航
2. **命名规范**：使用一致的命名约定
3. **类型匹配**：根据内容类型选择合适的obj_type
4. **权限规划**：规划不同空间的访问权限

### 导航效率
1. **缓存空间信息**：频繁访问的空间信息可缓存
2. **渐进加载**：大空间内容分批加载
3. **搜索优化**：使用搜索功能快速定位内容
4. **书签管理**：重要页面添加书签或记录token

### 内容管理
1. **版本考虑**：重要文档考虑版本管理
2. **链接维护**：维护页面间的引用链接
3. **归档策略**：制定旧内容归档策略
4. **质量检查**：定期检查内容质量和更新状态

### 自动化工作流
1. **模板使用**：创建常用页面模板
2. **批量操作**：类似操作批量处理
3. **同步机制**：考虑与其他系统的内容同步
4. **备份策略**：重要知识库定期备份

## 常见用例

### 用例1：知识库内容检索
```json
// 场景：在知识库中搜索相关信息
// 1. 搜索关键词
{
  "action": "search",
  "query": "API文档 版本2.0",
  "space_id": "7tech"
}

// 2. 获取搜索结果详情
const results = response.results;
for (const result of results) {
  const nodeInfo = await feishu_wiki({
    action: "get",
    token: result.node_token
  });
  
  const content = await feishu_doc({
    action: "read",
    doc_token: nodeInfo.obj_token
  });
  
  console.log(`找到: ${result.title}`);
  console.log(`内容摘要: ${content.text.substring(0, 200)}...`);
}
```

### 用例2：月度报告自动化
```json
// 场景：自动创建月度报告结构
// 1. 获取当前月份
const now = new Date();
const year = now.getFullYear();
const month = now.getMonth() + 1;
const monthName = `${year}年${month}月`;

// 2. 在报告空间创建月份文件夹
const monthFolder = await feishu_wiki({
  action: "create",
  space_id: "7reports",
  title: monthName,
  obj_type: "docx",
  parent_node_token: "wikcnReportsRoot"
});

// 3. 创建周报子页面
const weeks = ["第一周", "第二周", "第三周", "第四周"];
for (const week of weeks) {
  const weekPage = await feishu_wiki({
    action: "create",
    space_id: "7reports",
    title: `${monthName}${week}报告`,
    obj_type: "docx",
    parent_node_token: monthFolder.node_token
  });
  
  // 4. 初始化周报内容
  await feishu_doc({
    action: "write",
    doc_token: weekPage.obj_token,
    content: `# ${monthName}${week}报告\n\n## 本周总结\n\n## 完成工作\n\n## 下周计划\n\n## 问题与风险`
  });
}

// 5. 创建月度总结页面
const summaryPage = await feishu_wiki({
  action: "create",
  space_id: "7reports",
  title: `${monthName}月度总结`,
  obj_type: "docx",
  parent_node_token: monthFolder.node_token
});

await feishu_doc({
  action: "write",
  doc_token: summaryPage.obj_token,
  content: `# ${monthName}月度总结\n\n## 月度概览\n\n## 关键成果\n\n## 数据分析\n\n## 下月计划`
});
```

### 用例3：知识库结构迁移
```json
// 场景：将文档从旧结构迁移到新结构
// 1. 获取旧结构中的文档
const oldNodes = await feishu_wiki({
  action: "nodes",
  space_id: "7old",
  parent_node_token: "wikcnOldRoot"
});

// 2. 在新结构中创建对应文件夹
const newFolder = await feishu_wiki({
  action: "create",
  space_id: "7new",
  title: "迁移文档",
  obj_type: "docx",
  parent_node_token: "wikcnNewRoot"
});

// 3. 移动或复制文档
for (const oldNode of oldNodes) {
  if (oldNode.obj_type === 'docx') {
    // 获取旧文档内容
    const oldContent = await feishu_doc({
      action: "read",
      doc_token: oldNode.obj_token
    });
    
    // 在新位置创建文档
    const newNode = await feishu_wiki({
      action: "create",
      space_id: "7new",
      title: oldNode.title,
      obj_type: "docx",
      parent_node_token: newFolder.node_token
    });
    
    // 写入内容
    await feishu_doc({
      action: "write",
      doc_token: newNode.obj_token,
      content: oldContent.content
    });
    
    // 可选：在旧文档中添加迁移说明
    await feishu_doc({
      action: "append",
      doc_token: oldNode.obj_token,
      content: `\n\n---\n*本文档已迁移到新知识库位置*`
    });
  }
}
```

### 用例4：知识库健康检查
```json
// 场景：定期检查知识库健康状况
// 1. 列出所有空间
const spaces = await feishu_wiki({ action: "spaces" });

const healthReport = {
  totalSpaces: spaces.length,
  spaces: []
};

// 2. 检查每个空间
for (const space of spaces) {
  const spaceInfo = {
    name: space.name,
    space_id: space.space_id,
    totalNodes: 0,
    emptyNodes: 0,
    outdatedNodes: 0
  };
  
  // 获取空间根节点
  const rootNodes = await feishu_wiki({
    action: "nodes",
    space_id: space.space_id
  });
  
  spaceInfo.totalNodes = rootNodes.length;
  
  // 检查每个节点（简化示例）
  for (const node of rootNodes) {
    if (node.obj_type === 'docx') {
      const content = await feishu_doc({
        action: "read",
        doc_token: node.obj_token
      });
      
      // 检查内容是否为空
      if (!content.text || content.text.trim().length < 50) {
        spaceInfo.emptyNodes++;
      }
      
      // 检查最后修改时间（假设超过90天为过时）
      const nodeDetail = await feishu_wiki({
        action: "get",
        token: node.node_token
      });
      
      const modifiedTime = new Date(nodeDetail.edit_uid_time * 1000);
      const daysSinceEdit = (Date.now() - modifiedTime) / (1000 * 60 * 60 * 24);
      
      if (daysSinceEdit > 90) {
        spaceInfo.outdatedNodes++;
      }
    }
  }
  
  healthReport.spaces.push(spaceInfo);
}

// 3. 生成健康报告
console.log("知识库健康检查报告");
console.log