#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 安装引导脚本（向后兼容保留）
# 安装功能已集成到 start.sh，推荐直接使用：
#   curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/start.sh && bash start.sh
# =========================================================================

CYAN='\033[1;36m'; BOLD='\033[1m'; RED='\033[1;31m'; NC='\033[0m'
ST_TERMUX_START="$HOME/SillyTavern-Termux/start.sh"

if [ -f "$ST_TERMUX_START" ]; then
    exec bash "$ST_TERMUX_START"
fi

echo -e "${CYAN}${BOLD}>> 正在获取 start.sh...${NC}"
curl -fsSL -o "$HOME/.st_bootstrap.sh" \
    "https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/start.sh" \
    || { echo -e "${RED}${BOLD}>> 获取失败，请检查网络连接。${NC}"; exit 1; }
exec bash "$HOME/.st_bootstrap.sh"
