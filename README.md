<div align="center">

# SillyTavern-Termux

**安卓设备上的 SillyTavern 一站式部署与管理解决方案**

[![GitHub Stars](https://img.shields.io/github/stars/print-yuhuan/SillyTavern-Termux.svg?style=for-the-badge&logo=github)](https://github.com/print-yuhuan/SillyTavern-Termux)
[![License](https://img.shields.io/badge/License-Custom%20NC-blue.svg?style=for-the-badge)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/LICENSE)
[![Version](https://img.shields.io/badge/Version-2026.10.14-brightgreen.svg?style=for-the-badge)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/Menu.sh)
[![Platform](https://img.shields.io/badge/Platform-Termux%20(Android)-orange.svg?style=for-the-badge&logo=android)](https://termux.dev/cn/index.html)
[![QQ一群](https://img.shields.io/badge/QQ一群-807134015-blue?style=for-the-badge&logo=tencentqq)](https://qm.qq.com/q/Z1kk7tCrcG)
[![QQ二群](https://img.shields.io/badge/QQ二群-1039656113-blue?style=for-the-badge&logo=tencentqq)](https://qm.qq.com/q/jgakXZz3Xi)

[项目简介](#-项目简介) • [最近更新](#-最近更新) • [核心特性](#-核心特性) • [快速上手](#-快速上手) • [功能详解](#-功能详解) • [注意事项](#-注意事项) • [常见问题](#-常见问题) • [社区与支持](#-社区与支持)

</div>

---

## 📖 项目简介

**SillyTavern-Termux** 是专为安卓设备打造的 [SillyTavern](https://github.com/SillyTavern/SillyTavern) 一站式部署与管理解决方案。

基于原生 Termux 环境，只需一条命令即可完成自动化安装、配置与管理，并配备完善的中文交互菜单，让您在手机上也能享受完整而强大的 SillyTavern 体验。

### 什么是 SillyTavern？

[SillyTavern](https://github.com/SillyTavern/SillyTavern) 是一个强大的 LLM（大型语言模型）前端界面，为高级用户提供丰富的功能：

- 支持多种 AI 模型接口（OpenAI、Claude、Gemini、AI Horde 等）
- 完善的角色卡和聊天管理系统
- 强大的扩展插件生态
- 高度可定制的界面和功能

---

## 🆕 最近更新

> 当前版本 **v2026.10.14**，本次更新修复异常退出后的启动锁恢复，并更新 Discord 应用安装资源。

- 🔒 **启动恢复**：启动锁改用系统 `flock` 锁，相关进程结束后自动释放；升级前遗留的空锁目录会自动清理，仍在运行的服务会阻止重复启动
- 🔧 **依赖完善**：安装与依赖修复补齐 `util-linux`，提供 `flock` 命令；目录权限或系统锁错误会单独提示
- 📦 **Discord 更新**：[348.10 - Stable（348010）](https://github.com/print-yuhuan/SillyTavern-Termux/releases/tag/Discord_348.10-Stable)，安装包适用于 arm64-v8a 设备，最低要求 Android 7.0，脚本下载链接已同步更新

**v2026.10.13 更新内容：**

- 🛡️ **安装与恢复保护**：保留现有非 Git 安装，拒绝无效本体与符号链接备份，目录替换失败时整组回滚
- 🧪 **产物校验**：下载与自更新校验成功后才替换，备份打包或校验失败不会提示成功
- 🔧 **维护修复**：依赖修复接入酒馆模块安装，检查目标版本的 Node.js 要求，兼容带空格的备份文件名
- 🔗 **进程与网络**：仅清理本次启动会话的服务，下载统一设置超时、低速检测和重试
- 🧩 **插件与作者**：新增 [小白X](https://github.com/RT15548/LittleWhiteBox)、[柏宝书](https://github.com/baibai-git/ST-BaiBai-Book)、[提示词模板](https://github.com/zonde306/ST-Prompt-Template)，支持安装与卸载；[记忆表格](https://github.com/muyoou/st-memory-enhancement) 补齐木悠、LSR 两位开发作者，模型插件统一命名为“自定义模型”
- ✍️ **署名格式**：开发作者优先使用中文名，无中文名时保留英文，多位作者用顿号分隔；版权署名使用英文，项目与插件说明的版权年份统一为 © 2026
- 🎯 **酒馆社群**：[酒馆频道](https://discord.gg/sillytavern)、[类脑频道](https://discord.gg/odysseia)、[旅程频道](https://discord.gg/elysianhorizon)、[棱镜频道](https://discord.gg/prismairp)、[尾巴镇频道](https://discord.gg/puppyboo)、[喵喵电波频道](https://discord.gg/TvenmeVWKd)、[LOFI频道](https://discord.gg/kRxYXRcnJE)，共 7 项，输入频道编号后回车即可选择
- 💬 **加群交流**：现有群统一命名为 [QQ一群（807134015）](https://qm.qq.com/q/Z1kk7tCrcG)，新增 [QQ二群（1039656113）](https://qm.qq.com/q/jgakXZz3Xi)；作者信息展示两个群号，加群交流支持选择一群或二群，文档中的加群入口同步更新
- 🖌️ **字体致谢与许可**：感谢 [subframe7536](https://github.com/subframe7536) 提供 [Maple Mono](https://github.com/subframe7536/maple-font) 字体，作者信息中同步展示字体来源与许可；仓库附带上游原始许可证 [MapleMono-OFL.txt](./MapleMono-OFL.txt)，字体按 SIL Open Font License 1.1 分发

> 完整更新内容可在菜单 `6. 脚本管理` → `2. 查看更新日志` 查看。

---

## ✨ 核心特性

### 🚀 极致自动化部署

**一键安装，全自动配置**

- ✅ **零配置安装**：一条命令完成环境检测、依赖安装、字体配置、主程序部署
- ✅ **智能依赖管理**：自动检测并安装 Node.js、Git、curl 等核心依赖，失败自动重试
- ✅ **开箱即用**：安装完成后自动配置启动项，重启 Termux 即可进入管理菜单
- ✅ **容错机制**：依赖安装失败自动清理缓存并重试（最多 3 次），下载失败及时中止并提示

### 🛠️ 全功能管理菜单

**7 大功能模块，覆盖全生命周期管理**

| 功能模块 | 核心功能 |
|:--------|:--------|
| **🚀 启动酒馆** | 一键启动 SillyTavern 服务，智能检测依赖完整性 |
| **🔄 更新酒馆** | 智能检测远程更新，一键拉取最新代码并更新依赖 |
| **🔧 酒馆配置** | 局域网访问配置、内存限制设置、配置文件恢复 |
| **🧩 酒馆插件** | 社区热门插件一键安装/卸载，含详细说明与风险提示 |
| **💾 系统维护** | 数据备份/恢复、依赖修复、版本信息查看 |
| **📦 脚本管理** | 脚本在线升级、更新日志查看、一键彻底卸载 |
| **ℹ️ 关于脚本** | 作者信息、社群入口、资源下载、反馈渠道 |

### 💖 卓越用户体验

**专为中文用户打造的友好界面**

- 🎨 **全中文界面**：菜单、提示、帮助文档全面中文化，无语言障碍
- 🖌️ **终端美化**：自动配置 [Maple Mono](https://github.com/subframe7536/maple-font) 等宽字体（subframe7536 开发，SIL Open Font License 1.1），提升终端可读性
- 📱 **移动优化**：界面布局针对手机屏幕优化，操作流畅便捷
- 🔗 **智能跳转**：支持一键跳转 QQ一群、QQ二群、邮件客户端、Discord 频道

### 🌐 丰富资源生态

**连接社区，获取资源**

- 📦 **应用一键安装**：内置 [Discord 348.10 - Stable](https://github.com/print-yuhuan/SillyTavern-Termux/releases/tag/Discord_348.10-Stable) 下载器（arm64-v8a，Android 7.0+），下载后自动调用系统安装器（termux-open，兼容新版 Android）
- 🎯 **社群直达**：7 个 Discord 社群（酒馆频道、类脑频道、旅程频道、棱镜频道、尾巴镇频道、喵喵电波频道、LOFI频道）一键访问
- 🧩 **插件市场**：集成酒馆助手、记忆表格、自定义模型、小白X、柏宝书、提示词模板，支持安装与卸载
- 📚 **完善帮助**：详细的局域网配置指南、常见问题解答

### 🔒 数据安全保障

**完善的备份与恢复机制**

- 💾 **多层级备份**：支持用户数据独立备份和完整本体备份
- 📤 **便捷导出**：备份文件自动保存至手机「SillyTavern」专用文件夹
- 📥 **智能恢复**：自动检测存储权限，从备份目录智能识别文件，一键恢复
- 🧪 **完整性校验**：恢复前自动校验压缩包，先解压到临时目录、成功后才替换，损坏备份不会破坏现有数据
- ⚠️ **安全提示**：恢复操作前强制确认，避免误操作导致数据丢失
- 🔐 **权限管理**：导出/导入前自动检测并申请存储权限，确保操作顺利进行

---

## 🚀 快速上手

只需三步，即可在安卓设备上运行 SillyTavern！

### 步骤 1：安装 Termux

> ⚠️ **重要提示**：推荐使用官方 GitHub 或 F-Droid 发行版。Google Play 目前有面向 Android 11+ 的实验分支，与常用发行版存在功能差异，完整兼容性需要单独验证。

#### 📥 官方下载渠道

| 渠道 | 版本 | 推荐度 | 下载链接 |
|:---:|:---:|:---:|:---:|
| **GitHub** | v0.118.3（稳定版） | ⭐⭐⭐⭐⭐ | [下载 APK](https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_universal.apk) |
| **GitHub** | v0.119.0-beta.3 | ⭐⭐⭐⭐ | [下载 APK](https://github.com/termux/termux-app/releases/download/v0.119.0-beta.3/termux-app_v0.119.0-beta.3+apt-android-7-github-debug_universal.apk) |
| **F-Droid** | v0.118.3（稳定版） | ⭐⭐⭐⭐⭐ | [下载 APK](https://f-droid.org/repo/com.termux_1002.apk) |
| **F-Droid** | v0.119.0-beta.3 | ⭐⭐⭐⭐ | [下载 APK](https://f-droid.org/repo/com.termux_1022.apk) |

> 💡 **下载遇到问题？** 加入 [QQ一群（807134015）](https://qm.qq.com/q/Z1kk7tCrcG) 或 [QQ二群（1039656113）](https://qm.qq.com/q/jgakXZz3Xi)，群文件中提供 Termux 安装包备用下载。

---

### 步骤 2：一键安装脚本

打开 Termux，粘贴并执行以下命令：

```bash
curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh && bash Install.sh
```

**安装过程自动完成以下操作：**

1. ✅ 环境检测与存储权限配置
2. ✅ 更新包管理器
3. ✅ 安装核心依赖（Git、Node.js、curl 等）
4. ✅ 下载并配置终端字体
5. ✅ 克隆 SillyTavern 官方仓库
6. ✅ 下载管理菜单脚本
7. ✅ 配置菜单自启动
8. ✅ 安装 SillyTavern 依赖包

> ⏱️ **预计耗时**：首次安装约 5-15 分钟（视网络状况而定）

---

### 步骤 3：启动使用

安装完成后，**重启 Termux** 即可自动进入管理菜单。

**🎉 恭喜！现在您可以：**

- 选择 `1. 启动酒馆` 开始使用 SillyTavern
- 选择 `3. 酒馆配置` → `1. 局域网配置项` 设置局域网访问
- 选择 `4. 酒馆插件` 安装社区热门插件

---

## 📋 功能详解

### 📊 主菜单功能总览

| 序号 | 功能模块 | 详细说明 |
|:---:|:---------|:---------|
| **1** | **🚀 启动酒馆** | 一键启动 SillyTavern 服务，自动检测依赖完整性并启动 Node.js 服务器 |
| **2** | **🔄 更新酒馆** | 从官方仓库拉取最新代码，自动更新依赖包，支持版本比对和增量更新 |
| **3** | **🔧 酒馆配置** | 局域网访问开关、内存限制调整、**关联启动配置**、配置文件恢复 |
| **4** | **🧩 酒馆插件** | 社区插件一键安装/卸载，含详细功能介绍和安全提示 |
| **5** | **💾 系统维护** | 查看依赖版本、修复环境、备份/恢复用户数据和完整本体、**版本切换** |
| **6** | **📦 脚本管理** | 检测脚本更新、在线升级、查看更新日志、一键彻底卸载 |
| **7** | **ℹ️ 关于脚本** | 作者信息、QQ一群、QQ二群、邮件反馈、资源下载、社群链接 |

### 🔧 局域网配置详解

通过 `3. 酒馆配置` → `1. 局域网配置项` 可以：

- **开启/关闭网络监听**：允许局域网内其他设备访问 SillyTavern
- **获取内网地址**：自动检测并显示设备的局域网 IP 地址
- **查看连接帮助**：详细的局域网连接指南和常见问题解答

**支持的连接方式：**
1. 两台设备连接同一 WiFi 路由器
2. 其他设备连接本机开启的热点
3. 本机连接其他设备开启的热点

> 🔐 **安全提醒**：开启网络监听后，SillyTavern 默认用户没有密码，同一网络内的任何设备都可直接访问。请启动酒馆后在「用户设置 → 管理用户」中为账户设置密码。

### 🔗 关联启动配置详解

通过 `3. 酒馆配置` → `3. 关联启动配置` 可以：

- **开启/关闭关联启动**：控制启动酒馆时是否同时启动 Gemini-CLI-Termux 反代服务
- **查看反代日志**：实时查看反代服务的运行日志
- **智能日志管理**：超过 5MB 自动清理，防止占用过多空间

**支持的启动模式：**

| 模式 | 说明 | 启动命令 | 适用场景 |
|:---:|:-----|:---------|:---------|
| **模式 1** | 单独启动 SillyTavern | `bash start.sh` | 不需要本地反代的用户 |
| **模式 2** | 关联启动反代 + 酒馆 | `python run.py & bash start.sh` | 需要通过 Gemini-CLI-Termux 反代 API 的用户 |

**使用前提：**
- 模式 2 需要先安装 [Gemini-CLI-Termux](https://github.com/print-yuhuan/Gemini-CLI-Termux)
- 确保已安装 Python 环境（`pkg install python`）
- 反代服务将后台运行，日志保存在 `$HOME/setup.log`

**注意事项：**
- 退出酒馆（停止 SillyTavern）时会自动关闭本次会话的反代服务，避免后台进程残留
- 同一时间只允许一个脚本启动会话；启动锁由系统管理，相关进程结束后自动释放。划掉 Termux 后若全部服务已停止，可直接再次启动；若服务仍在后台运行，会提示先停止现有服务
- 升级前遗留的空 `$HOME/.st_run.lock` 目录会在确认没有现有服务后自动清理。新的 `$HOME/.st_run.flock` 是持久锁文件，文件存在不代表服务正在运行，无需手动删除
- 划掉后台不一定代表全部服务已停止，脚本会保留仍在运行会话的互斥保护，避免重复启动
- 可通过「查看反代日志」功能检查反代服务运行状态
- 日志文件超过 5MB 时，下次启动会自动清理

### 🧩 可用插件列表

| 插件名称 | 开发者 | 功能简介 | 使用须知 |
|:--------|:------|:--------|:-------:|
| [**酒馆助手**](https://github.com/N0VI028/JS-Slash-Runner) | KAKAA、青空莉想做舞台少女的狗 | 多功能扩展，支持渲染交互元素、jQuery DOM 操作、联动外部应用 | 仅运行来源可信的脚本 |
| [**记忆表格**](https://github.com/muyoou/st-memory-enhancement) | 木悠、LSR | 结构化长期记忆管理，支持角色设定、事件、物品等自定义表格 | 适用于聊天补全模式 |
| [**自定义模型**](https://github.com/LenAnderson/SillyTavern-CustomModels) | LenAnderson | 为 OpenAI、Claude、Gemini 连接添加自定义模型名称 | 按需添加模型名称 |
| [**小白X**](https://github.com/RT15548/LittleWhiteBox) | biex | 剧情记忆、状态管理、绘图、语音与应用面板 | 安装后按需配置各项功能 |
| [**柏宝书**](https://github.com/baibai-git/ST-BaiBai-Book) | 柏柏 | 剧情摘要、人物与物品记录、时间线管理、向量记忆召回 | SillyTavern 1.12.13+，安装后启用记忆引擎 |
| [**提示词模板**](https://github.com/zonde306/ST-Prompt-Template) | zonde306 | 为提示词、角色卡与世界书提供 EJS 模板、变量、条件和循环 | 仅使用来源可信的模板 |

> ⚠️ **安全提示**：酒馆助手与提示词模板支持执行 JavaScript，请仅运行来源可信、内容可控的脚本或模板。

### 💾 备份与恢复

**支持两种备份模式：**

| 备份类型 | 包含内容 | 使用场景 |
|:--------|:--------|:--------|
| **用户数据备份** | 角色卡、聊天记录、配置文件（`data` 和 `public` 目录） | 日常备份、数据迁移、设备更换 |
| **完整本体备份** | 整个 SillyTavern 目录（含插件与自定义修改，不含 node_modules 依赖） | 系统完整备份、环境迁移 |

**备份文件存储位置**：`/storage/emulated/0/SillyTavern/`（手机「SillyTavern」文件夹）

**安全恢复机制：**
- 🧪 恢复前自动校验压缩包完整性，损坏备份直接中止
- 📦 先解压到临时目录并验证目录结构；替换失败时整组回滚，回滚失败会保留副本并显示位置
- 💡 本体备份不含依赖，恢复后首次启动会自动安装（需联网）
- 📌 恢复过程会临时占用与备份相当的额外存储空间

**智能权限管理：**
- 📂 导出前自动检测存储权限，未授权时自动申请
- 📁 备份目录不存在时自动创建
- 🔍 导入前验证备份目录和文件，提供清晰提示

### 🔄 版本切换

通过 `5. 系统维护` → `7. 酒馆版本切换`，可在 SillyTavern 各发布版本间自由切换：

**核心功能：**
- 🏷️ **查看版本标签**：列出所有可用的 Git 标签版本，显示发布日期和当前版本
- 🔀 **切换酒馆版本**：切换到任意已发布的标签版本，自动重新安装对应依赖
- 📖 **版本切换帮助**：详细的使用指南、注意事项和常见问题解答

**使用场景：**

| 场景类型 | 适用情况 | 操作建议 |
|:--------|:--------|:--------|
| **稳定性需求** | 最新版本遇到问题 | 回退到上一个稳定版本 |
| **兼容性测试** | 验证插件兼容性 | 切换到不同版本进行测试 |
| **版本体验** | 体验历史功能 | 切换到特定版本探索 |

**安全保障：**
- ⚠️ 切换前自动检测未提交的更改
- 🔒 二次确认机制防止误操作
- 💾 建议切换前先备份数据
- 🔄 支持通过「更新酒馆」回到最新 release 分支

**智能依赖管理：**
- 🔧 版本切换后自动清理旧依赖
- ♻️ 三次重试机制确保依赖安装成功
- 📦 失败时提供修复建议和指引

---

## 📌 注意事项

### 系统要求

- ✅ **操作系统**：Android 7.0 及以上版本
- ✅ **Termux 版本**：v0.118.3 或更高（请使用官方渠道下载）
- ✅ **存储空间**：至少 500MB 可用空间（推荐 1GB 以上）
- ✅ **网络连接**：稳定的网络环境（首次安装需下载约 200MB 数据）
- ✅ **Node.js 版本**：当前 SillyTavern release 要求 20.x 或更高，具体以目标版本 `package.json` 中的 `engines.node` 为准（脚本安装依赖时会检查兼容性）

### 权限要求

首次运行脚本时，需要授予以下权限：

- 📂 **存储权限**：用于备份/恢复数据、访问「SillyTavern」备份文件夹
- 🌐 **网络权限**：用于下载依赖、更新程序和访问 AI 服务

> ⚠️ 请务必在弹窗提示时点击「允许」，否则部分功能将无法正常使用。

**权限说明：**
- 安装脚本和菜单脚本会在需要时自动申请存储权限
- 存储权限用于在 `/storage/emulated/0/SillyTavern/` 目录中读写备份文件
- 如果权限申请失败，相关备份/恢复功能将无法使用

### 使用建议

- 📶 **网络环境**：建议在 WiFi 环境下进行首次安装和大版本更新
- 🔄 **定期备份**：建议每周备份一次用户数据，避免意外丢失
- 📱 **设备性能**：推荐使用内存 4GB 及以上的设备，以获得更流畅的体验
- 🔋 **后台运行**：启动酒馆时脚本会自动启用唤醒锁（termux-wake-lock）并在退出时解除；使用期间仍建议尽量保持 Termux 前台运行，防止系统杀后台

---

## ❓ 常见问题

### 🧰 安装与环境

<details>
<summary><b>Q1：应该选择哪个 Termux 下载渠道？</b></summary>

**A：** Google Play 目前提供面向 Android 11+ 的实验分支，与 GitHub/F-Droid 发行版存在功能和兼容性差异。为了获得本项目推荐的运行环境，建议从 [GitHub Releases](https://github.com/termux/termux-app/releases) 或 [F-Droid](https://f-droid.org/packages/com.termux/) 下载；实验分支的完整兼容性需要单独验证。详情请参阅 [Termux 官方安装说明](https://github.com/termux/termux-app#google-play-store-experimental-branch)。
</details>

<details>
<summary><b>Q2：安装过程中出现网络错误或下载失败怎么办？</b></summary>

**A：** 可尝试以下解决方案：
1. 检查网络连接是否稳定，建议切换至 WiFi 环境
2. 确认能否访问 GitHub（可在浏览器中打开 github.com 测试；部分网络禁 ping，ping 不通不代表网络不可用）
3. 如果多次失败，可尝试更换镜像源或使用代理
4. 加入 [QQ一群（807134015）](https://qm.qq.com/q/Z1kk7tCrcG) 或 [QQ二群（1039656113）](https://qm.qq.com/q/jgakXZz3Xi) 寻求技术支持

**常见错误代码：**
- `curl: (6)` - DNS 解析失败，检查网络连接
- `curl: (7)` - 无法连接到服务器，检查防火墙或代理设置
- `curl: (28)` - 连接超时，网络不稳定或服务器繁忙
</details>

### 💾 备份与数据

<details>
<summary><b>Q3：如何备份我的角色卡和聊天记录？</b></summary>

**A：** 按照以下步骤操作：
1. 进入主菜单，选择 `5. 系统维护`
2. 选择 `3. 导出酒馆数据`
3. 脚本会自动检测存储权限（如未授权会弹窗申请）
4. 自动将 `data` 和 `public` 目录打包为 ZIP 文件
5. 备份文件保存在手机的「SillyTavern」文件夹（`/storage/emulated/0/SillyTavern/`）
6. 文件命名格式：`SillyTavern-Data_YYYYMMDD_HHMMSS.zip`

**建议备份频率**：每周一次或重要对话后立即备份。

**注意事项**：
- 首次备份时请在弹窗中点击「允许」授予存储权限
- 备份目录不存在时会自动创建
</details>

<details>
<summary><b>Q4：如何恢复之前的备份？</b></summary>

**A：** 恢复步骤：
1. 将备份的 `.zip` 文件放入手机的「SillyTavern」文件夹（`/storage/emulated/0/SillyTavern/`）
2. 进入主菜单，选择 `5. 系统维护`
3. 选择 `5. 导入酒馆数据`
4. 脚本会自动检测存储权限（如未授权会弹窗申请）
5. 从列表中选择要恢复的备份文件
6. 确认覆盖警告后，脚本会自动解压并恢复数据

⚠️ **重要提示**：
- 恢复操作会覆盖当前所有数据，请谨慎操作！
- 恢复前会自动校验备份完整性并先解压到临时目录，损坏的备份会被拒绝且不影响现有数据
- 如果看不到备份文件列表，请确认文件已放入正确的目录
- 首次恢复时请在弹窗中点击「允许」授予存储权限
</details>

### 🌐 配置与使用

<details>
<summary><b>Q5：如何在其他设备上访问 SillyTavern？</b></summary>

**A：** 按照以下步骤配置局域网访问：
1. 进入主菜单，选择 `3. 酒馆配置` → `1. 局域网配置项`
2. 选择 `1. 开启网络监听`
3. 选择 `3. 获取内网地址`，记下显示的 IP 地址
4. 确保两台设备连接同一局域网（WiFi 或热点）
5. 在其他设备的浏览器中访问 `http://内网IP:8000/`

**示例**：如果获取到的 IP 是 `192.168.1.100`，则访问 `http://192.168.1.100:8000/`

> 🔐 **安全提醒**：开启监听后默认用户没有密码，请在酒馆「用户设置 → 管理用户」中设置密码，避免同网络内他人访问你的聊天记录与 API 密钥。
</details>

<details>
<summary><b>Q6：安装后无法启动 SillyTavern，显示依赖错误？</b></summary>

**A：** 尝试修复依赖环境：
1. 进入主菜单，选择 `5. 系统维护`
2. 选择 `2. 修复依赖环境`
3. 脚本会自动重新安装所有必要的依赖包
4. 修复完成后，重新尝试启动 SillyTavern

如果问题仍未解决，请加入 [QQ一群（807134015）](https://qm.qq.com/q/Z1kk7tCrcG) 或 [QQ二群（1039656113）](https://qm.qq.com/q/jgakXZz3Xi)，并提供详细的错误信息。
</details>

<details>
<summary><b>Q7：可以同时运行多个插件吗？</b></summary>

**A：** 可以。SillyTavern 支持同时加载多个插件，但请注意：
- 部分插件可能存在功能冲突
- 过多插件会增加内存占用，影响性能
- 建议根据实际需求选择性安装必要的插件
</details>

<details>
<summary><b>Q8：如何完全卸载 SillyTavern-Termux？</b></summary>

**A：** 完全卸载步骤：
1. **备份重要数据**（如需保留）
2. 进入主菜单，选择 `6. 脚本管理`
3. 选择 `3. 一键卸载酒馆`
4. 确认操作后，脚本会自动清理所有相关文件
5. 卸载 Termux 应用（可选）

⚠️ **注意**：卸载操作不可逆，请务必先备份重要数据！
</details>

### 🔄 更新与版本

<details>
<summary><b>Q9：更新 SillyTavern 会丢失我的数据吗？</b></summary>

**A：** 不会。更新操作仅更新程序代码和依赖包，不会影响 `data` 目录中的用户数据（角色卡、聊天记录、配置文件等）。但为了安全起见，建议在大版本更新前进行一次备份。
</details>

<details>
<summary><b>Q10：如何切换到旧版本的 SillyTavern？</b></summary>

**A：** 使用版本切换功能：
1. 进入主菜单，选择 `5. 系统维护`
2. 选择 `7. 酒馆版本切换`
3. 选择 `1. 查看版本标签` 浏览可用版本
4. 选择 `2. 切换酒馆版本`，输入要切换的版本序号
5. 确认后会自动切换版本并重新安装依赖

⚠️ **注意事项**：
- 切换前建议先备份数据
- 切换版本会丢失未提交的文件修改
- 需要良好的网络连接以安装依赖
- 如需回到最新版本，使用「更新酒馆」功能
</details>

<details>
<summary><b>Q11：版本切换后无法启动怎么办？</b></summary>

**A：** 可能是依赖安装失败，尝试以下解决方案：
1. 检查依赖是否安装成功（查看切换时的提示信息）
2. 进入主菜单，选择 `5. 系统维护` → `2. 修复依赖环境`
3. 修复完成后重新尝试启动
4. 如果问题仍然存在，可以切换回其他稳定版本

**预防措施**：
- 切换版本前确保网络连接稳定
- 耐心等待依赖安装完成，不要中断过程
</details>

### 🔗 关联启动

<details>
<summary><b>Q12：如何使用关联启动功能？</b></summary>

**A：** 关联启动功能可让您在启动酒馆时同时启动 Gemini-CLI-Termux 反代服务。

**配置步骤：**
1. 确保已安装 [Gemini-CLI-Termux](https://github.com/print-yuhuan/Gemini-CLI-Termux)
2. 确保已安装 Python（`pkg install python`）
3. 进入主菜单，选择 `3. 酒馆配置` → `3. 关联启动配置`
4. 选择 `1. 开启关联启动`
5. 重新启动酒馆，反代服务将自动在后台运行

**查看日志：**
- 反代服务日志保存在 `$HOME/setup.log`
- 通过「关联启动配置 → 查看反代日志」查看最后 50 行日志
- 日志文件超过 5MB 时，下次启动会自动清理

**关闭关联启动：**
- 选择 `2. 关闭关联启动` 即可恢复为单独启动模式
</details>

<details>
<summary><b>Q13：关联启动后无法启动，提示找不到 Gemini-CLI-Termux？</b></summary>

**A：** 这是因为您开启了关联启动但未安装 Gemini-CLI-Termux。

**方案一：安装所需依赖**
1. 安装 Gemini-CLI-Termux：访问 [Gemini-CLI-Termux 项目页](https://github.com/print-yuhuan/Gemini-CLI-Termux)
2. 确保安装 Python：`pkg install python`
3. 重新启动酒馆

**方案二：关闭关联启动**
1. 进入主菜单，选择 `3. 酒馆配置` → `3. 关联启动配置`
2. 选择 `2. 关闭关联启动`
3. 重新启动酒馆
</details>

<details>
<summary><b>Q14：如何查看反代服务是否正常运行？</b></summary>

**A：** 可通过以下方式检查反代服务状态：

**方法一：查看日志**
1. 进入主菜单，选择 `3. 酒馆配置` → `3. 关联启动配置`
2. 选择 `3. 查看反代日志`
3. 查看日志输出是否有错误信息

**方法二：检查进程**
在 Termux 中执行：`pgrep -f "python.*run.py"`
- 如果有输出进程 ID，说明反代服务正在运行
- 如果无输出，说明反代服务未运行或已崩溃

**方法三：测试连接**
根据 Gemini-CLI-Termux 的配置测试反代 API 是否可访问
</details>

### ⚙️ 脚本与自定义

<details>
<summary><b>Q15：脚本是否支持自定义配置？</b></summary>

**A：** 支持。高级用户可以通过以下方式自定义：
- 编辑 `$HOME/.env` 文件修改环境变量
- 编辑 `$HOME/SillyTavern/config.yaml` 自定义 SillyTavern 配置
- 修改 `$HOME/Menu.sh` 添加自定义菜单选项

建议在修改前备份原始文件。
</details>

<details>
<summary><b>Q16：更新脚本会影响我的本地配置吗？</b></summary>

**A：** 不会。脚本更新机制已重构：

- 更新只替换 `Install.sh` 和 `Menu.sh` 脚本文件，**不再覆盖 `$HOME/.env`**，关联启动（START_MODE）等本地配置会完整保留
- 版本号以脚本文件本体为准：某个脚本下载失败时不会误标记为已更新，下次检查会自动重试
- 脚本采用「临时文件 + 原子替换」方式自更新，不会出现更新到一半损坏脚本的情况
</details>

---

## 🔗 相关链接

### SillyTavern 官方资源

- 📦 **官方仓库**：[SillyTavern/SillyTavern](https://github.com/SillyTavern/SillyTavern)
- 📖 **官方文档**：[docs.sillytavern.app](https://docs.sillytavern.app/)
- 💬 **Discord 服务器**：[discord.gg/sillytavern](https://discord.gg/sillytavern)
- 🗣️ **Reddit 社区**：[r/SillyTavernAI](https://reddit.com/r/SillyTavernAI)

### 本项目资源

- 🏠 **项目主页**：[github.com/print-yuhuan/SillyTavern-Termux](https://github.com/print-yuhuan/SillyTavern-Termux)
- 📋 **问题反馈**：[提交 Issue](https://github.com/print-yuhuan/SillyTavern-Termux/issues)
- 📝 **更新日志**：[查看 Releases](https://github.com/print-yuhuan/SillyTavern-Termux/releases)

---

## 💬 社区与支持

### 获取帮助的多种方式

<table>
<tr>
<td align="center" width="33%">
<img src="https://img.shields.io/badge/QQ一群-807134015-blue?style=for-the-badge&logo=tencentqq" alt="QQ一群"/>
<br><br>
<b>QQ一群</b>
<br>
<a href="https://qm.qq.com/q/Z1kk7tCrcG">点击加入 QQ一群</a>
<br><br>
<img src="https://img.shields.io/badge/QQ二群-1039656113-blue?style=for-the-badge&logo=tencentqq" alt="QQ二群"/>
<br><br>
<b>QQ二群</b>
<br>
<a href="https://qm.qq.com/q/jgakXZz3Xi">点击加入 QQ二群</a>
<br><br>
实时在线交流<br>快速获取帮助<br>分享使用经验
</td>
<td align="center" width="33%">
<img src="https://img.shields.io/badge/Email-print.yuhuan@gmail.com-red?style=for-the-badge&logo=gmail" alt="Email"/>
<br><br>
<b>邮件反馈</b>
<br>
<a href="mailto:print.yuhuan@gmail.com">发送邮件</a>
<br><br>
详细问题描述<br>功能建议提交<br>商业授权咨询
</td>
<td align="center" width="33%">
<img src="https://img.shields.io/badge/GitHub-Issues-black?style=for-the-badge&logo=github" alt="GitHub Issues"/>
<br><br>
<b>GitHub Issues</b>
<br>
<a href="https://github.com/print-yuhuan/SillyTavern-Termux/issues">提交反馈</a>
<br><br>
Bug 报告<br>功能请求<br>公开讨论
</td>
</tr>
</table>

### 反馈时请提供

为了更快地解决问题，请在反馈时提供以下信息：

- 📱 **设备信息**：手机型号、Android 版本
- 📦 **软件版本**：Termux 版本、脚本版本
- 📋 **问题描述**：详细的错误信息或截图
- 🔄 **复现步骤**：如何触发该问题

---

## 🤝 贡献指南

欢迎为本项目贡献代码或建议！

### 如何贡献

1. **Fork 本仓库**到您的 GitHub 账户
2. **克隆仓库**到本地：`git clone https://github.com/your-username/SillyTavern-Termux.git`
3. **创建分支**：`git checkout -b feature/your-feature-name`
4. **提交更改**：`git commit -m "Add: your feature description"`
5. **推送到 GitHub**：`git push origin feature/your-feature-name`
6. **提交 Pull Request**，描述您的更改

### 贡献类型

- 🐛 **Bug 修复**：修复已知问题
- ✨ **新功能**：添加实用的新功能
- 📝 **文档改进**：完善 README、添加使用指南
- 🌍 **国际化**：翻译成其他语言
- 🎨 **界面优化**：改进菜单布局和交互体验

### 代码规范

- 使用清晰的变量和函数命名
- 添加必要的注释说明
- 保持与现有代码风格一致
- 测试您的更改确保功能正常

---

## 📄 开源协议

### 本项目许可

本项目采用 **自定义非商业许可协议**（基于 CC BY-NC 4.0），主要条款：

- ✅ **允许**：个人使用、学习、修改、分发
- ❌ **禁止**：商业用途、出售、集成到付费产品
- 📝 **要求**：署名原作者、包含许可协议文本

### SillyTavern 许可

本项目部署的 [SillyTavern](https://github.com/SillyTavern/SillyTavern) 采用 **AGPL-3.0** 许可协议。

### Maple Mono 字体许可

仓库内的 `MapleMono.ttf` 为 **Maple Mono NF CN** 字体，来源于 [subframe7536/maple-font](https://github.com/subframe7536/maple-font)，由 **subframe7536** 开发。

该字体采用 **SIL Open Font License 1.1**，字体的原始版权与许可声明完整保存在 [MapleMono-OFL.txt](./MapleMono-OFL.txt)，字体资源按该许可证分发。

### 商业授权

本项目禁止用于商业用途，请通过以下方式联系作者：

- 📧 邮件：print.yuhuan@gmail.com
- 💬 [QQ一群：807134015](https://qm.qq.com/q/Z1kk7tCrcG)
- 💬 [QQ二群：1039656113](https://qm.qq.com/q/jgakXZz3Xi)

详细许可条款请查看 [LICENSE](./LICENSE) 文件。

---

## ⭐ 致谢

### 特别感谢

- 💖 **[SillyTavern](https://github.com/SillyTavern/SillyTavern)** 项目及其开发团队
- 💖 **[Termux](https://termux.dev/)** 项目，为安卓提供了强大的 Linux 环境
- 💖 **[Maple Mono](https://github.com/subframe7536/maple-font)** 项目及开发者 **subframe7536**，为本项目提供终端等宽字体资源
- 💖 所有社区插件开发者（KAKAA、青空莉想做舞台少女的狗、木悠、LSR、LenAnderson、biex、柏柏、zonde306 等）
- 💖 为本项目提供反馈和建议的所有用户

### 支持本项目

如果本项目对您有帮助，欢迎通过以下方式支持：

- ⭐ 在 [GitHub](https://github.com/print-yuhuan/SillyTavern-Termux) 点亮 Star
- 🔀 Fork 本项目并提交改进
- 📢 分享给更多需要的朋友
- 💬 加入 [QQ一群（807134015）](https://qm.qq.com/q/Z1kk7tCrcG) 或 [QQ二群（1039656113）](https://qm.qq.com/q/jgakXZz3Xi) 参与社区建设

**您的支持是项目持续维护的最大动力！**

---

<div align="center">

**Made with ❤️ by 欤歡**

[⬆ 回到顶部](#sillytavern-termux)

</div>
