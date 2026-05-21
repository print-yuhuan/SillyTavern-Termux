#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 统一入口
# 安装命令：curl -O https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/start.sh && bash start.sh
# 日常启动：bash ~/SillyTavern-Termux/start.sh
# =========================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ST_TERMUX_DIR="$HOME/SillyTavern-Termux"

# =========================================================================
# 引导阶段：以独立脚本方式运行时（config/ 不在同级目录），执行仓库克隆后移交
# =========================================================================
if [ ! -f "$SCRIPT_DIR/config/base.sh" ]; then

    # 内联颜色定义（模块尚未加载）
    RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'
    CYAN='\033[1;36m'; BOLD='\033[1m'; NC='\033[0m'

    # ==== 步骤 1/3：Termux 环境检测 ====
    echo -e "\n${CYAN}${BOLD}==== 步骤 1/3：环境检测 ====${NC}"
    if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
        echo -e "${RED}${BOLD}>> 检测到非 Termux 环境，请在 Termux 中执行此脚本！${NC}"
        exit 1
    fi
    _REQUIRED_VC=1022
    _REQUIRED_VN="v0.119.0-beta.3"
    _TERMUX_DL_URL="https://github.com/termux/termux-app/releases/tag/v0.119.0-beta.3"
    _CURRENT_VC="${TERMUX_APP__APP_VERSION_CODE}"
    if [ -z "$_CURRENT_VC" ] || [ "$_CURRENT_VC" != "$_REQUIRED_VC" ]; then
        if [ -z "$_CURRENT_VC" ]; then
            echo -e "${RED}${BOLD}>> 无法读取 Termux 版本号，当前版本可能过低或不兼容。${NC}"
        else
            echo -e "${RED}${BOLD}>> 当前 Termux 版本号：${_CURRENT_VC}，不符合要求。${NC}"
        fi
        echo -e "${YELLOW}${BOLD}>> 本脚本需要 Termux ${_REQUIRED_VN}（版本号：${_REQUIRED_VC}）。${NC}"
        echo -e "${CYAN}${BOLD}>> 按回车键前往下载页面并退出...${NC}"
        read -r
        termux-open-url "$_TERMUX_DL_URL"
        exit 1
    fi
    echo -e "${GREEN}${BOLD}>> 步骤 1/3 完成：环境检测通过。${NC}"

    # ==== 步骤 2/3：更新包管理器 ====
    echo -e "\n${CYAN}${BOLD}==== 步骤 2/3：更新包管理器 ====${NC}"
    _mirror_source="$PREFIX/etc/termux/mirrors/europe/packages.termux.dev"
    _mirror_target="$PREFIX/etc/termux/chosen_mirrors"
    if [ -f "$_mirror_source" ]; then
        mkdir -p "$(dirname "$_mirror_target")"
        ln -sf "$_mirror_source" "$_mirror_target"
        echo -e "${GREEN}${BOLD}>> 已配置 Termux 官方镜像源。${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 未检测到官方镜像配置，保留当前镜像设置。${NC}"
    fi
    if ! pkg update; then
        echo -e "${RED}${BOLD}>> 软件包索引更新失败，请检查网络连接。${NC}"
        exit 1
    fi
    if ! pkg upgrade -y -o Dpkg::Options::="--force-confnew"; then
        echo -e "${RED}${BOLD}>> 软件包升级失败，请确认网络连接和磁盘空间。${NC}"
        exit 1
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${YELLOW}${BOLD}>> 检测到 git 未安装，正在安装...${NC}"
        pkg install -y git \
            || { echo -e "${RED}${BOLD}>> git 安装失败，请检查网络连接。${NC}"; exit 1; }
        echo -e "${GREEN}${BOLD}>> git 安装成功。${NC}"
    else
        echo -e "${GREEN}${BOLD}>> git 已安装，跳过。${NC}"
    fi
    echo -e "${GREEN}${BOLD}>> 步骤 2/3 完成：包管理器已更新。${NC}"

    # ==== 步骤 3/3：克隆或更新管理脚本仓库 ====
    echo -e "\n${CYAN}${BOLD}==== 步骤 3/3：获取管理脚本 ====${NC}"
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
    echo -e "${GREEN}${BOLD}>> 步骤 3/3 完成：管理脚本已就绪。${NC}"

    echo -e "\n${GREEN}${BOLD}==== 引导完成！正在启动管理菜单 ====${NC}\n"
    exec bash "$ST_TERMUX_DIR/start.sh"
fi

# =========================================================================
# 正常启动阶段：从仓库目录运行，加载配置与函数库
# =========================================================================

# ==== 按顺序加载 config/ 下所有配置文件 ====
for _conf in "$SCRIPT_DIR/config/"*.sh; do
    [ -f "$_conf" ] && source "$_conf"
done

# ==== 加载用户本地配置（覆盖 config/base.sh 中的默认值，如 START_MODE）====
[ -f "$USER_CONF" ] && source "$USER_CONF"

# ==== 按顺序加载 lib/ 下所有函数库文件 ====
for _lib in "$SCRIPT_DIR/lib/"*.sh; do
    [ -f "$_lib" ] && source "$_lib"
done

# =========================================================================
# 部署检测：SillyTavern 未安装时自动执行完整安装流程
# =========================================================================
if [ ! -d "$SILLYTAVERN_DIR/.git" ]; then
    echo -e "${YELLOW}${BOLD}>> 未检测到 SillyTavern 项目，即将开始自动安装...${NC}\n"
    install_sillytavern
fi

# ==== 启动主菜单 ====
main_menu
