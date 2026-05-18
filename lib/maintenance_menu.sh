#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 系统维护菜单聚合函数库
# 职责：聚合依赖管理、备份导出/导入、版本切换等维护子菜单
# =========================================================================

# =========================================================================
# 5. 系统维护菜单
# =========================================================================
maintenance_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 系统维护 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${BLUE}${BOLD}1. 查看依赖版本${NC}"
        echo -e "${GREEN}${BOLD}2. 修复依赖环境${NC}"
        echo -e "${YELLOW}${BOLD}3. 导出酒馆数据${NC}"
        echo -e "${MAGENTA}${BOLD}4. 导出酒馆本体${NC}"
        echo -e "${GREEN}${BOLD}5. 导入酒馆数据${NC}"
        echo -e "${BLUE}${BOLD}6. 导入酒馆本体${NC}"
        echo -e "${CYAN}${BOLD}7. 酒馆版本切换${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-7）：${NC}"
        read -n1 sub_choice; echo
        case "$sub_choice" in
            0) break ;;
            1) show_dependencies ;;
            2) fix_dependencies ;;
            3) export_tavern_data ;;
            4) export_tavern_full ;;
            5) import_tavern_data ;;
            6) import_tavern_full ;;
            7) version_switch_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}
