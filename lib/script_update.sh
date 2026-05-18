#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 脚本更新函数库
# 职责：获取远程版本号，通过 git pull 更新管理脚本、显示更新日志
# =========================================================================

# =========================================================================
# 6. 脚本管理 - 检查脚本更新
# =========================================================================
check_update() {
    TMP_BASE="$HOME/.sillytavern-termux.remote"
    echo -e "\n${CYAN}${BOLD}==== 检查脚本更新 ====${NC}"
    if ! ping -c 1 -W 1 github.com >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 网络不可用，请检查网络连接。${NC}"
        press_any_key; return
    fi
    if ! curl -fsSL -o "$TMP_BASE" "$REMOTE_BASE_URL"; then
        echo -e "${RED}${BOLD}>> 无法获取远程版本信息，请检查网络。${NC}"
        rm -f "$TMP_BASE"; press_any_key; return
    fi
    LOCAL_INSTALL_VERSION="$INSTALL_VERSION"
    LOCAL_MENU_VERSION="$MENU_VERSION"
    REMOTE_INSTALL_VERSION=$(get_version "$TMP_BASE" "INSTALL_VERSION")
    REMOTE_MENU_VERSION=$(get_version "$TMP_BASE" "MENU_VERSION")
    rm -f "$TMP_BASE"
    echo -e "${YELLOW}${BOLD}>> 本地 Install.sh 版本：${LOCAL_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程 Install.sh 版本：${REMOTE_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 本地管理脚本版本：${LOCAL_MENU_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程管理脚本版本：${REMOTE_MENU_VERSION}${NC}"
    if [ -z "$LOCAL_INSTALL_VERSION" ] || [ -z "$LOCAL_MENU_VERSION" ] || [ -z "$REMOTE_INSTALL_VERSION" ] || [ -z "$REMOTE_MENU_VERSION" ]; then
        echo -e "${RED}${BOLD}>> 版本号读取失败，请检查网络或配置。${NC}"
        press_any_key; return
    fi
    updated=0
    if [ "$LOCAL_INSTALL_VERSION" -lt "$REMOTE_INSTALL_VERSION" ] || [ "$LOCAL_MENU_VERSION" -lt "$REMOTE_MENU_VERSION" ]; then
        echo -e "${MAGENTA}${BOLD}>> 检测到新版本，正在更新管理脚本...${NC}"
        if git -C "$SCRIPT_DIR" pull origin main; then
            echo -e "${GREEN}${BOLD}>> 管理脚本已更新。${NC}"
            updated=1
        else
            echo -e "${RED}${BOLD}>> 更新失败，请检查网络连接。${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}>> 脚本已是最新版本。${NC}"
    fi
    if [ $updated -eq 1 ]; then
        echo -e "${CYAN}${BOLD}>> 脚本已更新，将自动重启菜单...${NC}"
        sleep 2
        exec bash "$SCRIPT_DIR/start.sh"
    fi
    press_any_key
}

# =========================================================================
# 6. 脚本管理 - 查看更新日志
# =========================================================================
show_update_log() {
    echo -e "\n${CYAN}${BOLD}==== 更新日志 ====${NC}"
    echo -e "${MAGENTA}${BOLD}脚本更新日期：${YELLOW}${BOLD}${UPDATE_DATE}${NC}"
    echo -e "${CYAN}${BOLD}更新内容：${NC}${UPDATE_CONTENT}"
    echo -e "${CYAN}${BOLD}==================${NC}"
    press_any_key
}
