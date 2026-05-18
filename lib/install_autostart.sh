#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 7/8：自启动配置函数库
# 职责：向 Shell profile 写入 start.sh 自启动条目，并清理旧版 Menu.sh 条目
# =========================================================================

install_step7_autostart() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 7/8：配置菜单自启动 ====${NC}"

    # 使用 SCRIPT_DIR（由 start.sh 设置）构造自启动命令，确保路径与实际位置一致
    local AUTOSTART_CMD="bash $SCRIPT_DIR/start.sh"
    local AUTOSTART_MARKER="# SillyTavern-Termux 菜单自启动"

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

    # 清理旧版 Menu.sh 自启动条目（从旧版迁移时避免重复或冲突）
    sed -i '/# SillyTavern-Termux 菜单自启动/d' "$PROFILE_FILE" 2>/dev/null
    sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$PROFILE_FILE" 2>/dev/null

    if ! grep -qF "$SCRIPT_DIR/start.sh" "$PROFILE_FILE"; then
        if [ -s "$PROFILE_FILE" ]; then
            echo '' >> "$PROFILE_FILE"
        fi
        echo "$AUTOSTART_MARKER" >> "$PROFILE_FILE"
        echo "$AUTOSTART_CMD" >> "$PROFILE_FILE"
        echo -e "${GREEN}${BOLD}>> 步骤 7/8 完成：已配置菜单自启动。${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 菜单自启动已配置，跳过。${NC}"
        echo -e "${YELLOW}${BOLD}>> 步骤 7/8 跳过：菜单自启动已存在。${NC}"
    fi
}
