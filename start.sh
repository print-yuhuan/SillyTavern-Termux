#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 统一启动入口
# 唯一官方启动命令：bash ~/start.sh
# =========================================================================

# 获取本脚本所在目录（支持符号链接场景）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==== 按顺序加载 config/ 下所有配置文件 ====
for _conf in "$SCRIPT_DIR/config/"*.sh; do
    [ -f "$_conf" ] && source "$_conf"
done

# ==== 按顺序加载 lib/ 下所有函数库文件 ====
for _lib in "$SCRIPT_DIR/lib/"*.sh; do
    [ -f "$_lib" ] && source "$_lib"
done

# ==== 启动主菜单 ====
main_menu
