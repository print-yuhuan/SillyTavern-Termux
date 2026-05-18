#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 统一启动入口
# 唯一官方启动命令：bash ~/SillyTavern-Termux/start.sh
# 首次运行时自动检测部署状态，未安装则执行完整安装流程
# =========================================================================

# 获取本脚本所在目录（支持符号链接场景）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
