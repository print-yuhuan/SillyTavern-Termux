#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 脚本更新函数库
# 职责：检测并下载最新版本的 Install.sh / Menu.sh、显示更新日志
# =========================================================================

# =========================================================================
# 6. 脚本管理 - 检查脚本更新
# =========================================================================
check_update() {
    TMP_ENV="$HOME/.env.remote"
    echo -e "\n${CYAN}${BOLD}==== 检查脚本更新 ====${NC}"
    if ! ping -c 1 -W 1 github.com >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 网络不可用，请检查网络连接。${NC}"
        press_any_key; return
    fi
    if ! curl -fsSL -o "$TMP_ENV" "$REMOTE_ENV_URL"; then
        echo -e "${RED}${BOLD}>> 无法获取远程版本信息，请检查网络。${NC}"
        rm -f "$TMP_ENV"; press_any_key; return
    fi
    if [ ! -f "$HOME/.env" ]; then
        echo -e "${RED}${BOLD}>> 本地 .env 文件不存在，无法检测更新。${NC}"
        rm -f "$TMP_ENV"; press_any_key; return
    fi
    LOCAL_INSTALL_VERSION=$(get_version "$HOME/.env" "INSTALL_VERSION")
    LOCAL_MENU_VERSION=$(get_version "$HOME/.env" "MENU_VERSION")
    REMOTE_INSTALL_VERSION=$(get_version "$TMP_ENV" "INSTALL_VERSION")
    REMOTE_MENU_VERSION=$(get_version "$TMP_ENV" "MENU_VERSION")
    echo -e "${YELLOW}${BOLD}>> 本地 Install.sh 版本：${LOCAL_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程 Install.sh 版本：${REMOTE_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 本地 Menu.sh 版本：${LOCAL_MENU_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程 Menu.sh 版本：${REMOTE_MENU_VERSION}${NC}"
    if [ -z "$LOCAL_INSTALL_VERSION" ] || [ -z "$LOCAL_MENU_VERSION" ] || [ -z "$REMOTE_INSTALL_VERSION" ] || [ -z "$REMOTE_MENU_VERSION" ]; then
        echo -e "${RED}${BOLD}>> 版本号读取失败，请检查 .env 文件格式。${NC}"
        rm -f "$TMP_ENV"; press_any_key; return
    fi
    updated=0
    if [ "$LOCAL_INSTALL_VERSION" -lt "$REMOTE_INSTALL_VERSION" ]; then
        echo -e "${MAGENTA}${BOLD}>> 检测到 Install.sh 有新版本，正在更新...${NC}"
        if curl -fsSL -o "$HOME/Install.sh" "$REMOTE_INSTALL_URL"; then
            chmod +x "$HOME/Install.sh"
            echo -e "${GREEN}${BOLD}>> Install.sh 已更新。${NC}"
            updated=1
        else
            echo -e "${RED}${BOLD}>> Install.sh 更新失败。${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}>> Install.sh 已是最新版本。${NC}"
    fi
    if [ "$LOCAL_MENU_VERSION" -lt "$REMOTE_MENU_VERSION" ]; then
        echo -e "${BLUE}${BOLD}>> 检测到 Menu.sh 有新版本，正在更新...${NC}"
        if curl -fsSL -o "$HOME/Menu.sh" "$REMOTE_MENU_URL"; then
            chmod +x "$HOME/Menu.sh"
            echo -e "${GREEN}${BOLD}>> Menu.sh 已更新。${NC}"
            updated=1
        else
            echo -e "${RED}${BOLD}>> Menu.sh 更新失败。${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}>> Menu.sh 已是最新版本。${NC}"
    fi
    if [ $updated -eq 1 ]; then
        mv "$TMP_ENV" "$HOME/.env"
        echo -e "${GREEN}${BOLD}>> 本地版本号已同步更新。${NC}"
        echo -e "${CYAN}${BOLD}>> 脚本已更新，将自动重启菜单...${NC}"
        sleep 2
        exec bash "$HOME/start.sh"
    else
        rm -f "$TMP_ENV"
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
