# SillyTavern-Termux

[![GitHub Stars](https://img.shields.io/github/stars/print-yuhuan/SillyTavern-Termux.svg?style=social&label=Star)](https://github.com/print-yuhuan/SillyTavern-Termux)
[![License](https://img.shields.io/badge/License-Custom-blue.svg)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/LICENSE)
[![Version](https://img.shields.io/badge/Version-2025.07.11-brightgreen.svg)](https://github.com/print-yuhuan/SillyTavern-Termux/blob/main/Menu.sh)
[![Platform](https://img.shields.io/badge/Platform-Termux%20(Android)-orange.svg)](#)
[![QQ Group](https://img.shields.io/badge/QQ交流群-807134015-blue)](https://qm.qq.com/q/Z1kk7tCrcG)

**SillyTavern-Termux** 是一款专为安卓设备打造的 **SillyTavern 一站式部署与管理解决方案**。它基于 Termux 环境，将繁琐的安装配置流程简化为一行命令，并提供功能强大的中文菜单，助您轻松、高效地在手机上享受完整的 SillyTavern 体验。

---

> ### 📢 重要通知：大陆版（Gitee）脚本停止维护及迁移指南
>
> 为了统一维护渠道、提供更及时的功能更新与技术支持，**大陆版脚本（Gitee）现已停止更新与维护**，不再新增功能或修复 Bug。
>
> 我们强烈建议所有用户（尤其是大陆版用户）尽快切换至功能更全面、持续更新的**国际版（GitHub）脚本**。
>
> #### **一键无缝切换**
>
> 我们为您准备了一键转换工具。请在 Termux 主界面执行以下命令，即可自动完成所有迁移工作：
>
> ```bash
> curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Switch.sh && bash Switch.sh
> ```
>
> 转换完成后，您将享受到国际版脚本带来的全部新功能与持续维护。

---

## ✨ 项目亮点

-   🚀 **极致自动化部署**
    -   **一键全流程**：从环境检测、依赖安装、字体美化到主程序配置，全程自动化，无需手动干预。
    -   **智能依赖修复**：自动检测并补全 `Node.js`、`Git`、`curl` 等核心依赖，一键修复环境问题。
    -   **开箱即用**：安装完成后，重启 Termux 即可自动进入管理菜单，告别繁琐命令。

-   🛠️ **全功能集成管理菜单**
    -   **核心管理**：轻松实现酒馆的启动、更新、配置（如一键开启局域网设备访问）。
    -   **数据无忧**：内置强大的数据管理工具，支持一键**导出/导入**酒馆的**用户数据**（角色、聊天记录等）或**整个酒馆应用**，备份恢复从未如此简单。
    -   **插件生态**：支持一键安装/卸载“酒馆助手”、“记忆表格”等社区热门插件，并提供详细介绍与安全提示。
    -   **脚本自维护**：支持在线检查并更新管理脚本、查看更新日志，或在需要时一键彻底卸载。

-   💖 **卓越用户体验**
    -   **中文交互**：所有菜单、提示信息均为中文，清晰易懂，符合国人使用习惯。
    -   **终端美化**：自动配置更适宜代码阅读的 `MapleMono` 字体，提升长时间使用的视觉舒适度。
    -   **便捷支持**：菜单内集成作者信息、交流群入口、反馈邮箱，可尝试自动跳转至相应应用。

---

## 🚀 快速开始

### **第 1 步：安装 Termux**

为确保脚本稳定运行，请务必使用官方推荐版本。 **强烈建议卸载 Google Play 商店版**。

-   **官方下载渠道 (二选一)**:
    -   [**GitHub Releases**](https://github.com/termux/termux-app/releases) (推荐 `0.118.3` 或 `0.119.0-beta.3` 版本)
    -   [**F-Droid**](https://f-droid.org/en/packages/com.termux)

> 💡 **提示**: 如果您无法从上述渠道下载，可**加入QQ交流群 `807134015`**，群文件已提供经过验证的 Termux 安装包。

### **第 2 步：执行一键部署命令**

打开 `Termux`，长按屏幕粘贴以下命令并回车执行：

```bash
curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh && bash Install.sh
```

### **第 3 步：跟随引导完成**

脚本将自动完成所有必要步骤。安装结束后，**重启 Termux** 即可进入主菜单，开始您的 SillyTavern 之旅！

---

## ⚙️ 菜单功能概览

| 选项   | 功能说明                                         |
| :----- | :----------------------------------------------- |
| `1. 启动酒馆` | 🚀 运行 `SillyTavern` 主程序                       |
| `2. 更新酒馆` | 🔄 从 `GitHub` 拉取 `SillyTavern` 的最新版本        |
| `3. 酒馆配置` | 🔧 快速开启/关闭局域网设备访问、恢复初始配置等         |
| `4. 酒馆插件` | 🧩 一键安装或卸载社区热门插件                      |
| `5. 系统维护` | 🛠️ **备份/恢复数据与本体**、检查并修复依赖环境      |
| `6. 脚本管理` | 📦 更新本脚本、查看日志、或一键彻底卸载        |
| `7. 关于脚本` | ℹ️ 查看作者信息、获取交流群号及反馈渠道          |

---

## 📌 重要提示

-   **网络环境**：执行一键部署脚本时，请保证网络通畅，以便顺利下载所需文件。
-   **存储权限**：脚本首次运行时会请求存储权限，请务必点击“允许”，这是确保数据备份、导入/导出等功能正常运作的前提。
-   **寻求帮助**：部署或使用过程中如遇任何问题，**强烈建议加入 QQ 交流群 `807134015`**，您将获得更及时的帮助与支持。

---

## ❓ 常见问题 (FAQ)

**Q: 为什么不能用 Play 商店的 Termux？**
**A:** Google Play 商店的版本因政策原因已停止更新，缺少大量必要组件，会导致脚本无法正常运行。

**Q: 脚本执行报错或下载失败怎么办？**
**A:** 首先，请确保您的网络连接稳定且能正常访问 `GitHub`。若问题持续，请截图报错信息并**加入QQ群 `807134015` 寻求帮助**。

**Q: 如何备份我的角色卡和聊天记录？**
**A:** 在主菜单中选择 `5. 系统维护` -> `3. 导出酒馆数据`。脚本会将您的数据打包成 `.zip` 文件，并保存到手机的“下载”(`Download`)文件夹中。

**Q: 如何恢复备份？**
**A:** 将备份文件（数据或本体的 `.zip` 包）放入手机的“下载”文件夹中，然后在主菜单 `5. 系统维护` 中选择对应的导入选项即可。

---

## 💬 联系与支持

-   **项目作者**: 欤歡
-   **反馈邮箱**: `print.yuhuan@gmail.com`
-   **QQ 交流群**: `807134015` ([点击链接可尝试自动加群](https://qm.qq.com/q/Z1kk7tCrcG))
-   **项目主页**: [**GitHub (https://github.com/print-yuhuan/SillyTavern-Termux)**](https://github.com/print-yuhuan/SillyTavern-Termux)

> 如果您觉得这个项目对您有帮助，请在 [GitHub](https://github.com/print-yuhuan/SillyTavern-Termux) 上点亮一颗 ⭐ Star，您的支持是作者更新的最大动力！

---

## 📄 许可协议

本项目采用“署名-非商业性使用”自定义协议。您可以自由使用、分发和修改本脚本，但**严禁用于任何商业目的**。如需商业授权，请通过邮件联系作者。详细条款见 `LICENSE` 文件。
