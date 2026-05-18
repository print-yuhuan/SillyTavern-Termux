#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 插件菜单聚合函数库
# 职责：整合安装与卸载子菜单，提供二级插件管理入口
# =========================================================================

plugin_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 酒馆插件 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 安装插件${NC}"
        echo -e "${RED}${BOLD}2. 卸载插件${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-2）：${NC}"
        read -n1 sub_choice; echo
        case "$sub_choice" in
            0) break ;;
            1) plugin_install_menu ;;
            2) plugin_uninstall_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}
