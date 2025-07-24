#!/data/data/com.termux/files/usr/bin/bash
# ===============================================================
# SillyTavern-Termux 大陆版切换国际版工具（Github）
# ===============================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==== 文件与仓库映射 ====
HOME_DIR="$HOME"
declare -A FILE_URLS=(
    [".env"]="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/.env"
    ["Install.sh"]="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh"
    ["Menu.sh"]="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Menu.sh"
)

declare -A CONFIG_REPOS=(
    ["$HOME_DIR/SillyTavern/.git/config"]="https://dgithub.xyz/SillyTavern/SillyTavern|https://github.com/SillyTavern/SillyTavern"
    ["$HOME_DIR/SillyTavern/public/scripts/extensions/third-party/JS-Slash-Runner/.git/config"]="https://dgithub.xyz/N0VI028/JS-Slash-Runner|https://github.com/N0VI028/JS-Slash-Runner"
    ["$HOME_DIR/SillyTavern/public/scripts/extensions/third-party/st-memory-enhancement/.git/config"]="https://dgithub.xyz/muyoou/st-memory-enhancement|https://github.com/muyoou/st-memory-enhancement"
)

# ==== 通用函数 ====
press_any_key() { echo -e "${CYAN}${BOLD}>> 按任意键继续...${NC}"; read -n1 -s; }

# ===============================================================
# 0. 脚本说明和二次确认
# ===============================================================
clear
echo -e "${CYAN}${BOLD}================================================${NC}"
echo -e "${CYAN}${BOLD} SillyTavern-Termux 大陆版一键切换国际版工具${NC}"
echo -e "${CYAN}${BOLD} 本操作将自动替换脚本为国际版（Github），并修正仓库地址${NC}"
echo -e "${CYAN}${BOLD}================================================${NC}"
echo -e "${YELLOW}${BOLD}注意：${NC}切换过程会覆盖本地 .env、Install.sh、Menu.sh 文件。"
echo -e "${YELLOW}${BOLD}大陆版脚本即将停止维护，请尽快完成切换。${NC}"
echo -e "${CYAN}${BOLD}------------------------------------------------${NC}"
echo -ne "${YELLOW}${BOLD}是否继续切换为国际版？(y/n)：${NC}"
read -n1 confirm; echo
if ! [[ "$confirm" =~ [yY] ]]; then
    echo -e "${YELLOW}${BOLD}>> 已取消切换操作。${NC}"; exit 0
fi

# ===============================================================
# 1. 下载并替换主文件
# ===============================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 1/2：下载并替换脚本文件 ====${NC}"
cd "$HOME_DIR" || { echo -e "${RED}${BOLD}>> 切换到主目录失败！${NC}"; exit 1; }
for fname in "${!FILE_URLS[@]}"; do
    url="${FILE_URLS[$fname]}"
    [ -f "$fname" ] && { echo -e "${YELLOW}${BOLD}>> 检测到已存在 $fname，正在删除旧文件...${NC}"; rm -f "$fname"; }
    echo -e "${BLUE}${BOLD}>> 正在下载国际版文件：$fname${NC}"
    if curl -fsSL -o "$fname" "$url"; then
        chmod +x "$fname"
        echo -e "${GREEN}${BOLD}>> 已下载并替换：$fname${NC}"
    else
        echo -e "${RED}${BOLD}>> 下载失败：$fname，请检查网络连接。${NC}"
        echo -e "${RED}${BOLD}>> 切换中断，请重试。${NC}"; exit 1
    fi
done

# ===============================================================
# 2. 修正本地仓库地址为 Github
# ===============================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 2/2：修正仓库地址 ====${NC}"
for config in "${!CONFIG_REPOS[@]}"; do
    pair="${CONFIG_REPOS[$config]}"
    old_url="${pair%%|*}"
    new_url="${pair##*|}"
    if [ -f "$config" ]; then
        if grep -q "$old_url" "$config"; then
            sed -i "s#${old_url}#${new_url}#g" "$config"
            echo -e "${GREEN}${BOLD}>> 已修正仓库地址：$config${NC}"
        else
            echo -e "${YELLOW}${BOLD}>> 仓库地址已为国际版，无需更改：$config${NC}"
        fi
    else
        echo -e "${YELLOW}${BOLD}>> 未找到配置文件：$config，跳过。${NC}"
    fi
done

# ===============================================================
# 3. 清理遗留大陆版脚本
# ===============================================================
if [ -f "$HOME_DIR/Menu.sh" ]; then
    echo -e "${YELLOW}${BOLD}>> 检测到旧版 Menu.sh，正在删除...${NC}"
    rm -f "$HOME_DIR/Menu.sh"
fi

# ===============================================================
# 4. 完成提示
# ===============================================================
echo -e "\n${CYAN}${BOLD}------------------------------------------------${NC}"
echo -e "${GREEN}${BOLD}>> 脚本已成功切换为国际版，建议重新启动 Termux。${NC}"
echo -e "${RED}${BOLD}>> 大陆版脚本即将停止维护，不再提供功能更新或修复。${NC}"
echo -e "${CYAN}${BOLD}------------------------------------------------${NC}"
press_any_key
clear
bash "$HOME_DIR/Menu.sh"
