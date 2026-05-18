#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 安装引导脚本（Github）
# 职责：拉取 SillyTavern-Termux 管理仓库，移交给 start.sh 执行后续全流程
# =========================================================================

# ==== 彩色输出定义（内联，此时模块尚未加载）====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==== 版本号 ====
INSTALL_VERSION=20251211

# =========================================================================
# 步骤 1/3：Termux 环境检测
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 1/3：环境检测 ====${NC}"
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    echo -e "${RED}${BOLD}>> 检测到非 Termux 环境，请在 Termux 中执行此脚本！${NC}"
    exit 1
fi
echo -e "${GREEN}${BOLD}>> 步骤 1/3 完成：环境检测通过。${NC}"

# =========================================================================
# 步骤 2/3：确保 git 可用（克隆管理仓库的前提）
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 2/3：检测 git ====${NC}"
if ! command -v git >/dev/null 2>&1; then
    echo -e "${YELLOW}${BOLD}>> 检测到 git 未安装，正在安装...${NC}"
    pkg update -y && pkg install -y git \
        || { echo -e "${RED}${BOLD}>> git 安装失败，请检查网络连接。${NC}"; exit 1; }
    echo -e "${GREEN}${BOLD}>> git 安装成功。${NC}"
else
    echo -e "${GREEN}${BOLD}>> git 已安装，跳过。${NC}"
fi
echo -e "${GREEN}${BOLD}>> 步骤 2/3 完成：git 已就绪。${NC}"

# =========================================================================
# 步骤 3/3：克隆 SillyTavern-Termux 管理脚本仓库
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 3/3：获取管理脚本 ====${NC}"

ST_TERMUX_DIR="$HOME/SillyTavern-Termux"
ST_TERMUX_REPO="https://github.com/print-yuhuan/SillyTavern-Termux"

if [ -d "$ST_TERMUX_DIR/.git" ]; then
    echo -e "${YELLOW}${BOLD}>> 管理脚本仓库已存在，正在更新到最新版本...${NC}"
    git -C "$ST_TERMUX_DIR" pull origin main \
        && echo -e "${GREEN}${BOLD}>> 管理脚本已更新。${NC}" \
        || echo -e "${YELLOW}${BOLD}>> 更新失败，将使用现有版本继续。${NC}"
else
    echo -e "${CYAN}${BOLD}>> 正在克隆 SillyTavern-Termux 管理脚本...${NC}"
    if git clone "$ST_TERMUX_REPO" "$ST_TERMUX_DIR"; then
        echo -e "${GREEN}${BOLD}>> 管理脚本已克隆到 $ST_TERMUX_DIR${NC}"
    else
        echo -e "${RED}${BOLD}>> 克隆失败，请检查网络连接。${NC}"
        exit 1
    fi
fi

chmod +x "$ST_TERMUX_DIR/start.sh" 2>/dev/null

echo -e "${GREEN}${BOLD}>> 步骤 3/3 完成：管理脚本已就绪。${NC}"

# =========================================================================
# 引导完成，移交给 start.sh（含部署检测 + 安装流程 + 主菜单）
# =========================================================================
echo -e "\n${GREEN}${BOLD}==== 引导完成！正在启动 start.sh ====${NC}\n"
exec bash "$ST_TERMUX_DIR/start.sh"
