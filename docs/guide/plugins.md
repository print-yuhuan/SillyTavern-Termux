---
sidebar:
  - text: 快速开始
    link: /guide/quickstart
  - text: 功能详解
    link: /guide/menu
  - text: 插件与扩展
    link: /guide/plugins
  - text: 常见问题
    link: /faq
  - text: 关于作者
    link: /about
---

# 插件与扩展

## 插件管理入口

主菜单 `4. 酒馆插件`，支持安装与卸载主流社区插件。

---

## 推荐插件详解

### 1. 酒馆助手（JS-Slash-Runner）

- **仓库地址**：[N0VI028/JS-Slash-Runner](https://github.com/N0VI028/JS-Slash-Runner)
- **功能简介**：
  - 为 SillyTavern 增强交互能力，支持对话中渲染前端界面、小游戏等。
  - 可实现与外部应用的数据流通，极大拓展原生功能。
- **主要特性**：
  - 支持自定义按钮、界面、脚本。
  - 可以用 jQuery 直接操作 SillyTavern 页面元素。
  - 支持 iframe 隔离运行，突破原有限制。
- **安全提示**：允许自定义 JS，**请务必核查来源，防止敏感信息泄漏。**

---

### 2. 记忆表格（st-memory-enhancement）

- **仓库地址**：[muyoou/st-memory-enhancement](https://github.com/muyoou/st-memory-enhancement)
- **功能简介**：
  - 赋予 SillyTavern 结构化长期记忆，支持角色设定、世界观等内容管理。
- **主要特性**：
  - 可视化表格管理记忆，支持导出/分享。
  - 内置节点编辑、模板管理、API 智能分配等高级功能（部分即将上线）。
  - 支持将记忆内容推送到聊天界面，便于上下文贯穿。
- **使用说明**：需在“聊天补全模式”下启用。

---

### 插件安装&卸载

- 安装：菜单选择对应插件，确认后自动下载安装。
- 卸载：支持交互式选择并彻底删除插件目录。

---

如需扩展更多插件，欢迎至 [GitHub 项目主页](https://github.com/print-yuhuan/SillyTavern-Termux) 咨询或提交建议。
