# SillyTavern-Termux

[![GitHub Stars](https://img.shields.io/github/stars/print-yuhuan/SillyTavern-Termux.svg?style=social&label=Star)](https://github.com/print-yuhuan/SillyTavern-Termux)
[![License](https://img.shields.io/badge/License-Custom-blue.svg)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/LICENSE)
[![Version](https://img.shields.io/badge/Version-2025.07.31-brightgreen.svg)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/Menu.sh)
[![Platform](https://img.shields.io/badge/Platform-Termux%20(Android)-orange.svg)](https://termux.dev/cn/index.html)
[![QQ Group](https://img.shields.io/badge/QQ交流群-807134015-blue)](https://qm.qq.com/q/Z1kk7tCrcG)

---

**SillyTavern-Termux** 是专为安卓设备打造的 **SillyTavern 一站式部署与管理解决方案**。  
基于原生 Termux 环境，一条命令即可完成自动化安装、配置与管理，并配备完善的中文菜单，助您高效畅享手机端完整的 SillyTavern 体验。

---

## ✨ 特色亮点

### 🚀 极致自动化体验
- **全流程一键化**：涵盖环境检测、依赖安装、字体美化、主程序配置，全程自动，无需手动干预。
- **智能依赖修复**：自动检测并补全 `Node.js`、`Git`、`curl` 等关键依赖，环境自愈。
- **开箱即用**：完成安装后，重启 Termux 即自动进入管理菜单，远离繁琐命令。

### 🛠️ 全功能管理菜单
- **启动/更新/配置**：便捷启动 SillyTavern，快速更新，支持一键启用局域网访问等高级设置。
- **数据无忧**：支持一键备份/恢复用户数据和完整本体，数据转移轻松无忧。
- **插件生态**：支持一键安装/卸载“酒馆助手”“记忆表格”等热门社区插件，配有详细介绍及风险提示。
- **脚本自维护**：内置脚本自检与在线升级，查看更新日志，支持一键彻底卸载环境。

### 💖 优质用户体验
- **全中文交互**：菜单及提示信息全中文，友好直观。
- **终端美化**：自动配置 `MapleMono` 字体，让终端阅读更舒适。
- **便捷支持**：内嵌作者信息、QQ群、反馈邮箱，可自动跳转相关应用。

### 🌐 资源获取与社群直达（新增）
- **一键应用安装**：内置“资源获取”子菜单，支持一键下载安装 Discord 客户端，支持断点续传与进度提示。
- **社群直达入口**：一键直通五大 Discord 社群频道（酒馆、类脑、旅程、言庭、桃源），随时加入官方和社区交流。

---

## 🚀 快速上手指南

### 1. 安装 Termux

为保障脚本兼容性，请务必选用下述官方推荐渠道。**请勿使用 Google Play 商店版！**

> 💡 如遇下载困难，可加入 QQ 群 `807134015` 获取群文件中的 Termux 安装包。

#### Termux 官方下载直链

| 发布渠道     | 版本名称            | 下载链接 |
|----------|---------------------|:-----------------------------------------------------------------------------------------:|
| GitHub   | v0.118.3     | [点击下载](https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_universal.apk) |
| GitHub   | v0.119.0-beta.3| [点击下载](https://github.com/termux/termux-app/releases/download/v0.119.0-beta.3/termux-app_v0.119.0-beta.3+apt-android-7-github-debug_universal.apk) |
| F-Droid  | v0.118.3     | [点击下载](https://f-droid.org/repo/com.termux_1002.apk)              |
| F-Droid  | v0.119.0-beta.3| [点击下载](https://f-droid.org/repo/com.termux_1022.apk)         |

---

### 2. 一键部署 SillyTavern-Termux

打开 Termux，粘贴并执行下方命令：

```bash
curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh && bash Install.sh
```

---

### 3. 根据提示完成安装

安装脚本会自动引导完成所有步骤。安装结束后，**重启 Termux** 即可进入主菜单，开启 SillyTavern 之旅！

---

## 🗂 功能菜单一览

| 选项编号 | 功能简介                                    |
|:--------:|:------------------------------------------- |
| 1        | 🚀 启动 SillyTavern 主程序                   |
| 2        | 🔄 更新 SillyTavern 至最新版                 |
| 3        | 🔧 快速配置（如开启局域网访问、恢复初始配置） |
| 4        | 🧩 插件管理（安装/卸载社区热门插件）          |
| 5        | 🛠️ 数据与系统维护（备份/恢复/依赖修复）       |
| 6        | 📦 脚本管理（自检升级、日志、彻底卸载）        |
| 7        | ℹ️ 关于脚本（作者信息、交流群、反馈、资源获取）  |

#### 资源获取（7. 关于脚本 → 资源获取）

- **应用安装**：一键下载并自动安装 Discord 客户端，支持断点续传、可视化进度。
- **社群直达**：一键加入五大 Discord 社群频道，官方/社区动态不错过。

---

## 📌 温馨提示

- **网络要求**：请确保网络连接畅通，以便顺利下载安装和升级。
- **存储权限**：首次运行脚本需授权存储权限，请务必允许，以保障数据备份、导入/导出等功能正常运作。
- **遇到问题？** 强烈建议加入 QQ 群 `807134015`，获取高效技术支持与交流。

---

## ❓ 常见问题（FAQ）

**Q1：为什么不能用 Play 商店的 Termux？**  
A：Google Play 版本已停止维护，缺失部分核心组件，导致本项目无法正常运行。

**Q2：脚本报错或下载失败怎么办？**  
A：请先检查网络和 GitHub 访问。如持续报错，欢迎截图报错信息并加入群 `807134015` 寻求帮助。

**Q3：如何备份角色卡和聊天记录？**  
A：主菜单 `5. 系统维护` → `3. 导出酒馆数据`，自动打包至“下载”(Download)文件夹。

**Q4：如何恢复备份？**  
A：将 `.zip` 备份包放入手机“下载”文件夹，在主菜单 `5. 系统维护` 选择对应导入即可。

---

## 💬 联系与支持

- **项目作者**：欤歡  
- **反馈邮箱**：print.yuhuan@gmail.com  
- **QQ 交流群**：[807134015](https://qm.qq.com/q/Z1kk7tCrcG)  
- **项目主页**：[GitHub 仓库](https://github.com/print-yuhuan/SillyTavern-Termux)

> 如果本项目对你有帮助，欢迎在 [GitHub](https://github.com/print-yuhuan/SillyTavern-Termux) 点亮一颗 ⭐，你的支持是持续维护的最大动力！

---

## 📄 许可协议

本项目采用“署名-非商业性使用”自定义协议。您可以自由使用、分发和修改本脚本，但**严禁商业用途**。如需商业授权，请联系作者。详细条款见 [LICENSE](./LICENSE) 文件。
