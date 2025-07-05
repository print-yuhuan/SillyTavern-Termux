# SillyTavern-Termux

> 安卓 SillyTavern 一键部署与管理工具

---

## 项目简介

**SillyTavern-Termux** 是一套专为安卓端 SillyTavern 一键部署与管理脚本，基于 Termux 环境开发，集成了自动换源、依赖检测与修复、主程序与插件管理、终端美化等多项实用功能，帮助你在安卓设备上轻松、高效、安全地体验 SillyTavern。

---

## 一键部署命令

```bash
curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh && bash Install.sh
```

---

## 重要提示

- **Termux 推荐版本：0.118.3 / 0.119.0-beta.3**
- **强烈建议使用 [GitHub](https://github.com/termux/termux-app/releases) 或 [F-Droid](https://f-droid.org/en/packages/com.termux) 发布的 Termux，避免 Play 商店版。**
- Play 商店版功能受限，可能导致脚本无法正常运行。
- 保证网络畅通，否则依赖包下载、仓库克隆等操作可能失败。

---

## 功能亮点

- **一键自动部署**：全流程自动化，无需手动配置
- **清华镜像加速**：自动切换 Termux 源，下载速度飞快
- **依赖智能检测与修复**：自动检测 Node.js、Git、curl 等依赖，缺啥补啥
- **终端字体美化**：自动下载并配置更适合代码显示的字体
- **主程序与插件一站式管理**：支持 SillyTavern 主程序与第三方插件的安装、升级、卸载
- **菜单式交互**：操作简单，功能一目了然，支持自动启动
- **脚本自更新**：一键升级脚本，最新功能随时用
- **中文友好提示**：所有操作信息均为中文，交互体验极佳

---

## 使用方法

### 1. 安装推荐版本 Termux

- [GitHub 下载 Termux APK](https://github.com/termux/termux-app/releases)
- [F-Droid 下载 Termux APK](https://f-droid.org/en/packages/com.termux)

> 建议卸载 Play 商店版后安装推荐版本。

### 2. 复制“一键部署命令”到 Termux 运行

```bash
curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh && bash Install.sh
```

### 3. 按照脚本提示进行操作

- **自动换源、依赖安装、字体美化、主程序与插件管理** 全自动完成
- 安装完成后，重启 Termux 即可自动进入主菜单

### 4. 菜单主要功能

- 启动/更新 SillyTavern
- 系统维护（依赖检测与修复）
- 插件安装与卸载（如酒馆助手、记忆表格等）
- 脚本自更新与一键卸载
- 关于作者、加群交流、邮件反馈等

---

## 常见问题（FAQ）

**Q1：为什么不用 Play 商店版 Termux？**  
A1：Play 商店版部分功能被阉割，可能导致脚本无法正常运行，强烈推荐 GitHub 或 F-Droid 版本。

**Q2：脚本执行报错怎么办？**  
A2：请确保 Termux 已为推荐版本，保持网络畅通，如有问题欢迎加群或邮件反馈。

**Q3：支持哪些安卓版本？**  
A3：理论上支持 Android 7.0 及以上，具体以实际测试为准。

**Q4：如何安装/卸载插件？**  
A4：在主菜单选择“酒馆插件”即可一键安装/卸载第三方扩展。

**Q5：如何反馈问题或加入交流群？**  
A5：详见下方“联系方式”部分。

---

## 联系方式

- **作者：欤歡**
- **邮箱：print.yuhuan@gmail.com**
- **QQ群：807134015**
- **项目主页**：[https://github.com/print-yuhuan/SillyTavern-Termux](https://github.com/print-yuhuan/SillyTavern-Termux)

---

## 协议声明

本项目脚本采用自定义“署名-非商业性使用”协议，禁止任何商业用途。如需商业授权，请联系作者：print.yuhuan@gmail.com。详细条款见 LICENSE 文件。

---

如有建议或问题，欢迎提交 Issue、加群交流或邮件联系作者！
