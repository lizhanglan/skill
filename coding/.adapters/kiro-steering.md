# Kiro Steering 接入模板

将此文件复制到项目的 `.kiro/steering/` 目录下。

---

## Skill 仓库

本项目开发者维护了一个个人 skill 仓库：https://github.com/lizhanglan/skill

### 工作方式

1. 对话开始时，读取 skill 仓库的 `README.md`，加载触发索引表
2. 每次回答前，用用户的问题匹配触发索引表中的触发词
3. 命中时，读取对应 skill 文档，严格遵守其中的核心原则和反例约束，再生成代码或回答
4. 未命中时，如果生成内容涉及某个领域（如缓存、认证、组件设计），仍应主动检查是否有对应 skill

### 规范优先级

skill 文档中的规范 > 通用最佳实践 > 默认行为

---

## 后端规范（摘要）

详见 `coding/backend/` 目录下各文件。

## 前端规范（摘要）

详见 `coding/frontend/` 目录下各文件。

## 通用规范（摘要）

详见 `coding/fullstack/` 目录下各文件。
