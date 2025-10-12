<div align="center">

# SillyTavern-Termux

**安卓设备上的 SillyTavern 一站式部署与管理解决方案**

[![GitHub Stars](https://img.shields.io/github/stars/print-yuhuan/SillyTavern-Termux.svg?style=for-the-badge&logo=github)](https://github.com/print-yuhuan/SillyTavern-Termux)
[![License](https://img.shields.io/badge/License-Custom%20NC-blue.svg?style=for-the-badge)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/LICENSE)
[![Version](https://img.shields.io/badge/Version-2025.10.12-brightgreen.svg?style=for-the-badge)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/Menu.sh)
[![Platform](https://img.shields.io/badge/Platform-Termux%20(Android)-orange.svg?style=for-the-badge&logo=android)](https://termux.dev/cn/index.html)
[![QQ Group](https://img.shields.io/badge/QQ交流群-807134015-blue?style=for-the-badge&logo=tencentqq)](https://qm.qq.com/q/Z1kk7tCrcG)

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

## ✨ 核心特性

### 🚀 极致自动化部署

**一键安装，全自动配置**

- ✅ **零配置安装**：一条命令完成环境检测、依赖安装、字体配置、主程序部署
- ✅ **智能依赖管理**：自动检测并安装 Node.js、Git、curl 等核心依赖，失败自动重试
- ✅ **开箱即用**：安装完成后自动配置启动项，重启 Termux 即可进入管理菜单
- ✅ **容错机制**：网络中断自动恢复，安装失败智能回退

### 🛠️ 全功能管理菜单

**7大功能模块，覆盖全生命周期管理**

| 功能模块 | 核心功能 |
|---------|---------|
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
- 🖌️ **终端美化**：自动配置 MapleMono 等宽字体，提升终端可读性
- 📱 **移动优化**：界面布局针对手机屏幕优化，操作流畅便捷
- 🔗 **智能跳转**：支持一键跳转 QQ 群、邮件客户端、Discord 频道

### 🌐 丰富资源生态

**连接社区，获取资源**

- 📦 **应用一键安装**：内置 Discord 等应用下载器，支持断点续传
- 🎯 **社群直达**：五大 Discord 频道（酒馆官方、类脑、旅程、言庭、桃源）一键访问
- 🧩 **插件市场**：集成热门社区插件（酒馆助手、记忆表格、自定模型等）
- 📚 **完善帮助**：详细的局域网配置指南、常见问题解答

### 🔒 数据安全保障

**完善的备份与恢复机制**

- 💾 **多层级备份**：支持用户数据独立备份和完整本体备份
- 📤 **便捷导出**：备份文件自动保存至手机"SillyTavern"专用文件夹
- 📥 **智能恢复**：自动检测存储权限，从备份目录智能识别文件，一键恢复
- ⚠️ **安全提示**：恢复操作前强制确认，避免误操作导致数据丢失
- 🔐 **权限管理**：导出/导入前自动检测并申请存储权限，确保操作顺利进行

---

## 🚀 快速上手

只需三步，即可在安卓设备上运行 SillyTavern！

### 步骤 1：安装 Termux

> ⚠️ **重要提示**：请务必使用官方渠道下载的 Termux，**切勿使用 Google Play 商店版本**（已停止维护，缺失核心组件）！

#### 📥 官方下载渠道

| 渠道 | 版本 | 推荐度 | 下载链接 |
|:---:|:---:|:---:|:---:|
| **GitHub** | v0.118.3 (稳定版) | ⭐⭐⭐⭐⭐ | [下载 APK](https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_universal.apk) |
| **GitHub** | v0.119.0-beta.3 | ⭐⭐⭐⭐ | [下载 APK](https://github.com/termux/termux-app/releases/download/v0.119.0-beta.3/termux-app_v0.119.0-beta.3+apt-android-7-github-debug_universal.apk) |
| **F-Droid** | v0.118.3 (稳定版) | ⭐⭐⭐⭐⭐ | [下载 APK](https://f-droid.org/repo/com.termux_1002.apk) |
| **F-Droid** | v0.119.0-beta.3 | ⭐⭐⭐⭐ | [下载 APK](https://f-droid.org/repo/com.termux_1022.apk) |

> 💡 **下载遇到问题？** 加入 QQ 交流群 **807134015**，群文件中提供 Termux 安装包备用下载。

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

### 主菜单功能总览

| 序号 | 功能模块 | 详细说明 |
|:---:|:---------|:---------|
| **1** | **🚀 启动酒馆** | 一键启动 SillyTavern 服务，自动检测依赖完整性并启动 Node.js 服务器 |
| **2** | **🔄 更新酒馆** | 从官方仓库拉取最新代码，自动更新依赖包，支持版本比对和增量更新 |
| **3** | **🔧 酒馆配置** | 局域网访问开关、内存限制调整、获取内网 IP、配置文件恢复 |
| **4** | **🧩 酒馆插件** | 社区插件一键安装/卸载，含详细功能介绍和安全提示 |
| **5** | **💾 系统维护** | 查看依赖版本、修复环境、备份/恢复用户数据和完整本体 |
| **6** | **📦 脚本管理** | 检测脚本更新、在线升级、查看更新日志、一键彻底卸载 |
| **7** | **ℹ️ 关于脚本** | 作者信息、QQ 群、邮件反馈、资源下载、社群链接 |

### 🔧 局域网配置详解

通过 `3. 酒馆配置` → `1. 局域网配置项` 可以：

- **开启/关闭网络监听**：允许局域网内其他设备访问 SillyTavern
- **获取内网地址**：自动检测并显示设备的局域网 IP 地址
- **查看连接帮助**：详细的局域网连接指南和常见问题解答

**支持的连接方式：**
1. 两台设备连接同一 WiFi 路由器
2. 其他设备连接本机开启的热点
3. 本机连接其他设备开启的热点

### 🧩 可用插件列表

| 插件名称 | 开发者 | 功能简介 | 安全等级 |
|:--------|:------|:--------|:-------:|
| **酒馆助手** | KAKAA / 青空莉想 | 多功能扩展，支持渲染交互元素、jQuery DOM 操作、联动外部应用 | ⚠️ 中风险 |
| **记忆表格** | 木悠 | 结构化长期记忆管理，支持角色设定、事件、物品等自定义表格 | ✅ 低风险 |
| **自定模型** | LenAnderson | 为 OpenAI、Claude、Gemini 连接添加自定义模型名称 | ✅ 低风险 |

> ⚠️ **安全提示**：酒馆助手插件支持执行自定义 JavaScript 脚本，请仅运行来源可信的代码。

### 💾 备份与恢复

**支持两种备份模式：**

| 备份类型 | 包含内容 | 使用场景 |
|:--------|:--------|:--------|
| **用户数据备份** | 角色卡、聊天记录、配置文件（`data` 目录） | 日常备份、数据迁移、设备更换 |
| **完整本体备份** | 整个 SillyTavern 目录（含插件和自定义修改） | 系统完整备份、环境迁移 |

**备份文件存储位置**：`/storage/emulated/0/SillyTavern/`（手机"SillyTavern"文件夹）

**智能权限管理：**
- 📂 导出前自动检测存储权限，未授权时自动申请
- 📁 备份目录不存在时自动创建
- 🔍 导入前验证备份目录和文件，提供清晰提示

---

## 📌 注意事项

### 系统要求

- ✅ **操作系统**：Android 7.0 及以上版本
- ✅ **Termux 版本**：v0.118.3 或更高（请使用官方渠道下载）
- ✅ **存储空间**：至少 500MB 可用空间（推荐 1GB 以上）
- ✅ **网络连接**：稳定的网络环境（首次安装需下载约 200MB 数据）
- ✅ **Node.js 版本**：18.x 或更高（脚本自动安装）

### 权限要求

首次运行脚本时，需要授予以下权限：

- 📂 **存储权限**：用于备份/恢复数据、访问"SillyTavern"备份文件夹
- 🌐 **网络权限**：用于下载依赖、更新程序和访问 AI 服务

> ⚠️ 请务必在弹窗提示时点击"允许"，否则部分功能将无法正常使用。

**权限说明：**
- 安装脚本和菜单脚本会在需要时自动申请存储权限
- 存储权限用于在 `/storage/emulated/0/SillyTavern/` 目录中读写备份文件
- 如果权限申请失败，相关备份/恢复功能将无法使用

### 使用建议

- 📶 **网络环境**：建议在 WiFi 环境下进行首次安装和大版本更新
- 🔄 **定期备份**：建议每周备份一次用户数据，避免意外丢失
- 📱 **设备性能**：推荐使用内存 4GB 及以上的设备，以获得更流畅的体验
- 🔋 **后台运行**：使用 SillyTavern 时，请保持 Termux 在前台或使用 `termux-wake-lock` 防止系统杀后台

---

## ❓ 常见问题

<details>
<summary><b>Q1：为什么不能使用 Google Play 商店的 Termux？</b></summary>

**A：** Google Play 版本的 Termux 已于 2020 年停止维护，缺失许多核心组件和功能更新，无法正常运行本项目所需的环境。请务必从 [GitHub Releases](https://github.com/termux/termux-app/releases) 或 [F-Droid](https://f-droid.org/packages/com.termux/) 下载官方维护的版本。
</details>

<details>
<summary><b>Q2：安装过程中出现网络错误或下载失败怎么办？</b></summary>

**A：** 可尝试以下解决方案：
1. 检查网络连接是否稳定，建议切换至 WiFi 环境
2. 确认能否访问 GitHub（`ping github.com`）
3. 如果多次失败，可尝试更换镜像源或使用代理
4. 加入 QQ 群 **807134015** 寻求技术支持

**常见错误代码：**
- `curl: (6)` - DNS 解析失败，检查网络连接
- `curl: (7)` - 无法连接到服务器，检查防火墙或代理设置
- `curl: (28)` - 连接超时，网络不稳定或服务器繁忙
</details>

<details>
<summary><b>Q3：如何备份我的角色卡和聊天记录？</b></summary>

**A：** 按照以下步骤操作：
1. 进入主菜单，选择 `5. 系统维护`
2. 选择 `3. 导出酒馆数据`
3. 脚本会自动检测存储权限（如未授权会弹窗申请）
4. 自动将 `data` 目录打包为 ZIP 文件
5. 备份文件保存在手机的"SillyTavern"文件夹（`/storage/emulated/0/SillyTavern/`）
6. 文件命名格式：`SillyTavern-Data_YYYYMMDD_HHMMSS.zip`

**建议备份频率**：每周一次或重要对话后立即备份。

**注意事项**：
- 首次备份时请在弹窗中点击"允许"授予存储权限
- 备份目录不存在时会自动创建
</details>

<details>
<summary><b>Q4：如何恢复之前的备份？</b></summary>

**A：** 恢复步骤：
1. 将备份的 `.zip` 文件放入手机的"SillyTavern"文件夹（`/storage/emulated/0/SillyTavern/`）
2. 进入主菜单，选择 `5. 系统维护`
3. 选择 `5. 导入酒馆数据`
4. 脚本会自动检测存储权限（如未授权会弹窗申请）
5. 从列表中选择要恢复的备份文件
6. 确认覆盖警告后，脚本会自动解压并恢复数据

⚠️ **重要提示**：
- 恢复操作会覆盖当前所有数据，请谨慎操作！
- 如果看不到备份文件列表，请确认文件已放入正确的目录
- 首次恢复时请在弹窗中点击"允许"授予存储权限
</details>

<details>
<summary><b>Q5：如何在其他设备上访问 SillyTavern？</b></summary>

**A：** 按照以下步骤配置局域网访问：
1. 进入主菜单，选择 `3. 酒馆配置` → `1. 局域网配置项`
2. 选择 `1. 开启网络监听`
3. 选择 `3. 获取内网地址`，记下显示的 IP 地址
4. 确保两台设备连接同一局域网（WiFi 或热点）
5. 在其他设备的浏览器中访问 `http://内网IP:8000/`

**示例**：如果获取到的 IP 是 `192.168.1.100`，则访问 `http://192.168.1.100:8000/`
</details>

<details>
<summary><b>Q6：安装后无法启动 SillyTavern，显示依赖错误？</b></summary>

**A：** 尝试修复依赖环境：
1. 进入主菜单，选择 `5. 系统维护`
2. 选择 `2. 修复依赖环境`
3. 脚本会自动重新安装所有必要的依赖包
4. 修复完成后，重新尝试启动 SillyTavern

如果问题仍未解决，请加入 QQ 群并提供详细的错误信息。
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

<details>
<summary><b>Q9：更新 SillyTavern 会丢失我的数据吗？</b></summary>

**A：** 不会。更新操作仅更新程序代码和依赖包，不会影响 `data` 目录中的用户数据（角色卡、聊天记录、配置文件等）。但为了安全起见，建议在大版本更新前进行一次备份。
</details>

<details>
<summary><b>Q10：脚本是否支持自定义配置？</b></summary>

**A：** 支持。高级用户可以通过以下方式自定义：
- 编辑 `$HOME/.env` 文件修改环境变量
- 编辑 `$HOME/SillyTavern/config.yaml` 自定义 SillyTavern 配置
- 修改 `$HOME/Menu.sh` 添加自定义菜单选项

建议在修改前备份原始文件。
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
<img src="https://img.shields.io/badge/QQ群-807134015-blue?style=for-the-badge&logo=tencentqq" alt="QQ Group"/>
<br><br>
<b>QQ 交流群</b>
<br>
<a href="https://qm.qq.com/q/Z1kk7tCrcG">点击加入</a>
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

1. **Fork 本仓库**到你的 GitHub 账户
2. **克隆仓库**到本地：`git clone https://github.com/your-username/SillyTavern-Termux.git`
3. **创建分支**：`git checkout -b feature/your-feature-name`
4. **提交更改**：`git commit -m "Add: your feature description"`
5. **推送到 GitHub**：`git push origin feature/your-feature-name`
6. **提交 Pull Request**，描述你的更改

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
- 测试你的更改确保功能正常

---

## 📄 开源协议

### 本项目许可

本项目采用 **自定义非商业许可协议**（基于 CC BY-NC 4.0），主要条款：

- ✅ **允许**：个人使用、学习、修改、分发
- ❌ **禁止**：商业用途、出售、集成到付费产品
- 📝 **要求**：署名原作者、包含许可协议文本

### SillyTavern 许可

本项目部署的 [SillyTavern](https://github.com/SillyTavern/SillyTavern) 采用 **AGPL-3.0** 许可协议。

### 商业授权

如需将本项目用于商业用途，请通过以下方式联系作者获取商业授权：

- 📧 邮件：print.yuhuan@gmail.com
- 💬 QQ 群：807134015

详细许可条款请查看 [LICENSE](./LICENSE) 文件。

---

## ⭐ 致谢

### 特别感谢

- 💖 **[SillyTavern](https://github.com/SillyTavern/SillyTavern)** 项目及其开发团队
- 💖 **[Termux](https://termux.dev/)** 项目，为安卓提供了强大的 Linux 环境
- 💖 所有社区插件开发者（KAKAA、青空莉想、木悠、LenAnderson 等）
- 💖 为本项目提供反馈和建议的所有用户

### 支持本项目

如果本项目对你有帮助，欢迎通过以下方式支持：

- ⭐ 在 [GitHub](https://github.com/print-yuhuan/SillyTavern-Termux) 点亮 Star
- 🔀 Fork 本项目并提交改进
- 📢 分享给更多需要的朋友
- 💬 加入 QQ 群参与社区建设

**你的支持是项目持续维护的最大动力！**

---

<div align="center">

**Made with ❤️ by 欤歡**

[⬆ 回到顶部](#sillytavern-termux)

</div>
