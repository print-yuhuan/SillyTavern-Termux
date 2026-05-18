#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 主菜单函数库
# 职责：主菜单循环，整合所有一级功能入口
# =========================================================================

# =========================================================================
# 主菜单循环
# =========================================================================
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== SillyTavern Termux 菜单 ====${NC}"
        echo -e "${RED}${BOLD}0. 退出脚本${NC}"
        echo -e "${GREEN}${BOLD}1. 启动酒馆${NC}"
        echo -e "${BLUE}${BOLD}2. 更新酒馆${NC}"
        echo -e "${YELLOW}${BOLD}3. 酒馆配置${NC}"
        echo -e "${MAGENTA}${BOLD}4. 酒馆插件${NC}"
        echo -e "${CYAN}${BOLD}5. 系统维护${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}6. 脚本管理${NC}"
        echo -e "${BRIGHT_MAGENTA}${BOLD}7. 关于脚本${NC}"
        echo -e "${CYAN}${BOLD}=================================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-7）：${NC}"
        read -n1 choice; echo
        case "$choice" in
            0) echo -e "${RED}${BOLD}>> 脚本已退出，欢迎再次使用。${NC}"; sleep 0.5; clear; exit 0 ;;
            1) start_tavern ;;
            2) update_tavern ;;
            3) tavern_config_menu ;;
            4) plugin_menu ;;
            5) maintenance_menu ;;
            6) script_manage_menu ;;
            7) about_script_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}
