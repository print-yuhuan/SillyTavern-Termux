#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 全局配置
# 集中管理：颜色常量、版本号、更新日志、远程资源地址
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
BRIGHT_BLUE='\033[1;94m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m'

# ==== 版本号 ====
INSTALL_VERSION=20251211
MENU_VERSION=20251211

# ==== 运行时默认配置 ====
START_MODE=1

# ==== 更新日志 ====
UPDATE_DATE="2025-12-11"
UPDATE_CONTENT="
===============================================
SillyTavern-Termux 更新日志 2025-12-11
===============================================

本次更新优化了依赖安装流程，增强了安装稳定性和可靠性。

───────────────────────────────────────────────
【功能优化】
───────────────────────────────────────────────
  ● 依赖安装流程优化
      - 统一清理策略：在依赖安装前强制清理缓存
      - 新增 npm cache clean --force 命令，确保使用最新依赖
      - 删除旧的 node_modules 目录
      - 重试等待时间延长到 3 秒，提高稳定性

  ● 受影响功能模块
      - 安装脚本 (Install.sh)：初次安装依赖时
      - 更新功能 (Menu.sh update_tavern)：更新酒馆时
      - 版本切换 (Menu.sh switch_tavern_version)：切换版本时

  ● 版本说明更新
      - 更新稳定版本示例到 1.13.4
      - 与官方最新稳定版本保持同步

───────────────────────────────────────────────
【问题修复】
───────────────────────────────────────────────
  ✓ 修复依赖安装可能因缓存问题导致的失败
  ✓ 修复版本切换时残留缓存导致的兼容性问题
  ✓ 优化重试机制，减少依赖安装失败率

───────────────────────────────────────────────
【技术细节】
───────────────────────────────────────────────
  ● 清理顺序
      1. 删除 node_modules 目录
      2. 清空 npm 缓存
      3. 重新安装依赖

  ● 适用场景
      - 首次安装 SillyTavern
      - 更新 SillyTavern 到最新版本
      - 在 release 和标签版本之间切换
      - 依赖安装失败需要重试时

───────────────────────────────────────────────
【注意事项】
───────────────────────────────────────────────
  ⚠️ 清理缓存会删除本地缓存的包文件，首次安装需要重新下载
  ⚠️ 在网络较差的环境下，依赖安装可能需要更长时间
  ⚠️ 建议在稳定网络环境下进行更新或版本切换操作

===============================================
"

# ==== 远程资源地址 ====
REMOTE_BASE_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/config/base.sh"

# ==== 社群链接 ====
DISCORD_DOWNLOAD="https://github.com/print-yuhuan/SillyTavern-Termux/releases/download/Discord_308.11-Stable/Discord.apk"
JIUGUAN_LINK="https://discord.gg/sillytavern"
LEINAO_LINK="https://discord.gg/odysseia"
LVCHENG_LINK="https://discord.gg/elysianhorizon"
YANTING_LINK="https://discord.gg/yPxfzutGrf"
TAOYUAN_LINK="https://discord.gg/54ZEDnEcwf"

# ==== 用户配置文件路径 ====
USER_CONF="$HOME/.sillytavern-termux.conf"

# ==== 安装路径配置 ====
SILLYTAVERN_DIR="$HOME/SillyTavern"
SILLYTAVERN_REPO="https://github.com/SillyTavern/SillyTavern"
ST_TERMUX_REPO="https://github.com/print-yuhuan/SillyTavern-Termux"
FONT_URL="https://github.com/print-yuhuan/SillyTavern-Termux/raw/refs/heads/main/MapleMono.ttf"
FONT_DIR="$HOME/.termux"
FONT_PATH="$HOME/.termux/font.ttf"
