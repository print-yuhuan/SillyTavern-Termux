#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 资源获取函数库
# 职责：资源获取菜单、应用安装菜单、Discord APK 下载与安装
# =========================================================================

# =========================================================================
# 7.1 资源获取
# =========================================================================
resource_links_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 资源获取 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 应用安装${NC}"
        echo -e "${BLUE}${BOLD}2. 酒馆社群${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-2）：${NC}"
        read -n1 res_choice; echo
        case "$res_choice" in
            0) break ;;
            1) install_app_menu ;;
            2) community_links_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

# =========================================================================
# 7.1.1 应用安装
# =========================================================================
install_app_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 应用安装 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${MAGENTA}${BOLD}1. 安装Discord${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-1）：${NC}"
        read -n1 app_choice; echo
        case "$app_choice" in
            0) break ;;
            1) install_discord_app ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

install_discord_app() {
    DISCORD_URL="$DISCORD_DOWNLOAD"
    if [ -z "$DISCORD_URL" ]; then
        echo -e "${YELLOW}${BOLD}>> 未配置 Discord 下载链接，请稍后重试。${NC}"
        press_any_key; return
    fi
    if ! echo "$DISCORD_URL" | grep -q '^https\?://'; then
        echo -e "${YELLOW}${BOLD}>> Discord 下载链接格式错误：$DISCORD_URL${NC}"
        press_any_key; return
    fi
    FILENAME="Discord.apk"
    DEST="/storage/emulated/0/Download/$FILENAME"
    echo -e "${CYAN}${BOLD}>> 开始下载 Discord 应用...${NC}"
    if curl -Lf --progress-bar -o "$DEST" "$DISCORD_URL"; then
        if [ -s "$DEST" ]; then
            echo -e "${GREEN}${BOLD}>> 下载完成，已保存到: $DEST${NC}"
            if command -v am >/dev/null 2>&1; then
                am start -a android.intent.action.VIEW -d "file://$DEST" -t "application/vnd.android.package-archive" >/dev/null 2>&1 \
                    && echo -e "${GREEN}${BOLD}>> 已调用系统安装管理器安装 Discord。${NC}" \
                    || echo -e "${YELLOW}${BOLD}>> 未能自动调用安装管理器，请手动在文件管理中安装 Discord。${NC}"
            else
                echo -e "${YELLOW}${BOLD}>> 当前环境不支持自动安装，请手动在文件管理中安装 Discord。${NC}"
            fi
        else
            echo -e "${RED}${BOLD}>> 下载失败，文件为空，请检查网络或存储权限。${NC}"
            rm -f "$DEST"
        fi
    else
        echo -e "${RED}${BOLD}>> 下载失败，请检查网络或存储权限。${NC}"
        rm -f "$DEST"
    fi
    press_any_key
}
