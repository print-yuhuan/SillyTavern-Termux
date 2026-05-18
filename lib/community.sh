#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 社群链接函数库
# 职责：获取并展示酒馆社群 Discord 邀请链接、调用系统浏览器跳转
# =========================================================================

# =========================================================================
# 7.1.2 酒馆社群
# =========================================================================
community_links_menu() {
    TMP_ENV="$HOME/.env.remote"
    if ! curl -fsSL -o "$TMP_ENV" "$REMOTE_ENV_URL"; then
        echo -e "${RED}${BOLD}>> 远程配置文件获取失败，请检查网络。${NC}"
        press_any_key; return
    fi
    JIUGUAN_LINK=$(grep '^JIUGUAN_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    LEINAO_LINK=$(grep '^LEINAO_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    LVCHENG_LINK=$(grep '^LVCHENG_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    YANTING_LINK=$(grep '^YANTING_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    TAOYUAN_LINK=$(grep '^TAOYUAN_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    rm -f "$TMP_ENV"
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 酒馆社群 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 酒馆频道${NC}"
        echo -e "${BLUE}${BOLD}2. 类脑频道${NC}"
        echo -e "${MAGENTA}${BOLD}3. 旅程频道${NC}"
        echo -e "${CYAN}${BOLD}4. 言庭频道${NC}"
        echo -e "${YELLOW}${BOLD}5. 桃源频道${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-5）：${NC}"
        read -n1 link_choice; echo
        case "$link_choice" in
            0) break ;;
            1) open_link_menu "酒馆频道" "$JIUGUAN_LINK" ;;
            2) open_link_menu "类脑频道" "$LEINAO_LINK" ;;
            3) open_link_menu "旅程频道" "$LVCHENG_LINK" ;;
            4) open_link_menu "言庭频道" "$YANTING_LINK" ;;
            5) open_link_menu "桃源频道" "$TAOYUAN_LINK" ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

open_link_menu() {
    local name="$1"
    local url="$2"
    if [ -z "$url" ]; then
        echo -e "${YELLOW}${BOLD}>> $name 未配置链接，请稍后重试。${NC}"
        press_any_key; return
    fi
    echo -e "${CYAN}${BOLD}>> 即将打开 $name：$url${NC}"
    if command -v am >/dev/null 2>&1; then
        am start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 \
            && echo -e "${GREEN}${BOLD}>> 已调用系统浏览器打开。${NC}" \
            || echo -e "${YELLOW}${BOLD}>> 未能自动打开浏览器，请手动访问上方链接。${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 当前环境不支持自动打开浏览器，请手动访问上方链接。${NC}"
    fi
    press_any_key
}
