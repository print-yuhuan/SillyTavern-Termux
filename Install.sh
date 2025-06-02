#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 安装脚本（Github）
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==== 版本号 ====
INSTALL_VERSION=20250602

# =========================================================================
# 步骤 1/8：环境检测
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 1/8：环境检测 ====${NC}"
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    echo -e "${RED}${BOLD}>> 本脚本仅适用于 Termux 环境，请在 Termux 中运行！${NC}"
    exit 1
fi

if ! command -v termux-setup-storage >/dev/null 2>&1; then
    echo -e "${YELLOW}${BOLD}>> 未检测到 termux-setup-storage，部分功能可能无法访问存储。${NC}"
else
    if [ ! -d "/storage/emulated/0" ]; then
        echo -e "${CYAN}${BOLD}>> 正在请求存储权限...${NC}"
        termux-setup-storage
        sleep 2
    fi
fi
echo -e "${GREEN}${BOLD}>> 步骤 1/8 完成：环境检测通过。${NC}"

# =========================================================================
# 步骤 2/8：更新包管理器
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 2/8：更新包管理器 ====${NC}"
pkg update -y && pkg upgrade -y
echo -e "${GREEN}${BOLD}>> 步骤 2/8 完成：包管理器已更新。${NC}"

# =========================================================================
# 步骤 3/8：安装依赖
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 3/8：安装依赖 ====${NC}"
for dep in git curl zip; do
    if ! command -v $dep >/dev/null 2>&1; then
        echo -e "${YELLOW}${BOLD}>> 检测到未安装：$dep，正在安装...${NC}"
        pkg install -y $dep
    else
        echo -e "${CYAN}${BOLD}>> $dep 已安装，跳过。${NC}"
    fi
done

if ! command -v node >/dev/null 2>&1; then
    if pkg list-all | grep -q '^nodejs-lts/'; then
        echo -e "${YELLOW}${BOLD}>> 检测到未安装：node，正在安装 nodejs-lts...${NC}"
        pkg install -y nodejs-lts || pkg install -y nodejs
    else
        echo -e "${YELLOW}${BOLD}>> 检测到未安装：node，正在安装 nodejs...${NC}"
        pkg install -y nodejs
    fi
else
    echo -e "${CYAN}${BOLD}>> node 已安装，跳过。${NC}"
fi

npm config set prefix "$PREFIX"
echo -e "${GREEN}${BOLD}>> 步骤 3/8 完成：依赖已安装。${NC}"

# =========================================================================
# 步骤 4/8：下载并配置终端字体
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 4/8：下载并配置终端字体 ====${NC}"
FONT_DIR="$HOME/.termux"
FONT_PATH="$FONT_DIR/font.ttf"
mkdir -p "$FONT_DIR"
if [ -f "$FONT_PATH" ]; then
    echo -e "${YELLOW}${BOLD}>> 字体文件已存在，跳过下载。${NC}"
else
    if curl -fsSL -o "$FONT_PATH" "https://github.com/print-yuhuan/SillyTavern-Termux/raw/refs/heads/main/MapleMono.ttf"; then
        echo -e "${GREEN}${BOLD}>> 字体已下载并保存为 .termux/font.ttf${NC}"
    else
        echo -e "${RED}${BOLD}>> 字体下载失败，请检查网络或稍后重试。${NC}"
        echo -e "${YELLOW}${BOLD}>> 步骤 4/8 跳过：字体未配置成功。${NC}"
    fi
fi

if [ -f "$FONT_PATH" ]; then
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings \
        && echo -e "${GREEN}${BOLD}>> 配置已自动刷新，字体已生效。${NC}" \
        || echo -e "${YELLOW}${BOLD}>> 尝试刷新配置失败，请手动重启 Termux。${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 未检测到 termux-reload-settings，请手动重启 Termux 使字体生效。${NC}"
    fi
    echo -e "${GREEN}${BOLD}>> 步骤 4/8 完成：终端字体已配置。${NC}"
fi

# =========================================================================
# 步骤 5/8：克隆 SillyTavern 主仓库
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 5/8：克隆 SillyTavern 仓库 ====${NC}"
if [ -d "$HOME/SillyTavern/.git" ]; then
    echo -e "${YELLOW}${BOLD}>> SillyTavern 仓库已存在，跳过克隆。${NC}"
    echo -e "${YELLOW}${BOLD}>> 步骤 5/8 跳过：仓库已存在。${NC}"
else
    rm -rf "$HOME/SillyTavern"
    if git clone https://github.com/SillyTavern/SillyTavern "$HOME/SillyTavern"; then
        echo -e "${GREEN}${BOLD}>> 步骤 5/8 完成：SillyTavern 仓库已克隆。${NC}"
    else
        echo -e "${RED}${BOLD}>> 仓库克隆失败，请检查网络连接。${NC}"
        exit 1
    fi
fi

# =========================================================================
# 步骤 6/8：下载菜单脚本与配置文件
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 6/8：下载菜单脚本与配置文件 ====${NC}"
MENU_PATH="$HOME/menu.sh"
ENV_PATH="$HOME/.env"
MENU_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/menu.sh"
ENV_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/.env"

if [ -f "$MENU_PATH" ]; then
    echo -e "${YELLOW}${BOLD}>> menu.sh 已存在，跳过下载。${NC}"
else
    curl -fsSL -o "$MENU_PATH" "$MENU_URL" && chmod +x "$MENU_PATH" \
    || { echo -e "${RED}${BOLD}>> menu.sh 下载失败！${NC}"; exit 1; }
fi

if [ -f "$ENV_PATH" ]; then
    echo -e "${YELLOW}${BOLD}>> .env 已存在，跳过下载。${NC}"
else
    curl -fsSL -o "$ENV_PATH" "$ENV_URL" \
    || { echo -e "${RED}${BOLD}>> .env 下载失败！${NC}"; exit 1; }
fi

source "$ENV_PATH"
echo -e "${GREEN}${BOLD}>> 步骤 6/8 完成：菜单脚本与配置文件已就绪。${NC}"

# =========================================================================
# 步骤 7/8：配置自动启动菜单
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 7/8：配置自动启动菜单 ====${NC}"
PROFILE_FILE=""
for pf in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$pf" ]; then
        PROFILE_FILE="$pf"
        break
    fi
done
if [ -z "$PROFILE_FILE" ]; then
    PROFILE_FILE="$HOME/.bashrc"
fi
touch "$PROFILE_FILE"
if ! grep -qE 'bash[ ]+\$HOME/menu\.sh' "$PROFILE_FILE"; then
    echo 'bash $HOME/menu.sh' >> "$PROFILE_FILE"
    echo -e "${GREEN}${BOLD}>> 步骤 7/8 完成：已配置自动启动菜单。${NC}"
else
    echo -e "${YELLOW}${BOLD}>> 自动启动菜单已配置，跳过。${NC}"
    echo -e "${YELLOW}${BOLD}>> 步骤 7/8 跳过：自动启动已存在。${NC}"
fi

# =========================================================================
# 步骤 8/8：安装 SillyTavern 依赖
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 8/8：安装 SillyTavern 依赖 ====${NC}"
cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> 进入 SillyTavern 目录失败！${NC}"; exit 1; }
rm -rf node_modules
export NODE_ENV=production
if ! npm install --no-audit --no-fund --loglevel=error --no-progress --omit=dev; then
    echo -e "${RED}${BOLD}>> 依赖安装失败，请检查网络连接或日志信息。${NC}"
    exit 1
fi
echo -e "${GREEN}${BOLD}>> 步骤 8/8 完成：SillyTavern 依赖已安装。${NC}"

# =========================================================================
# 安装完成，进入主菜单
# =========================================================================
echo -e "\n${GREEN}${BOLD}==== 安装完成！即将启动主菜单 ====${NC}\n"
echo -e "${CYAN}${BOLD}>> 按任意键进入主菜单...${NC}"
read -n1 -s
exec bash "$HOME/menu.sh"
