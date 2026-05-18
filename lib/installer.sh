#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装总编排函数库
# 职责：按顺序调用 8 个安装步骤函数，完成完整的部署流程
# =========================================================================

# =========================================================================
# 安装主流程（由 start.sh 在检测到未部署时自动调用）
# =========================================================================
install_sillytavern() {
    install_step1_env_check
    install_step2_pkg_update
    install_step3_dependencies
    install_step4_font
    install_step5_clone
    install_step6_env_file
    install_step7_autostart
    install_step8_npm_deps

    echo -e "\n${GREEN}${BOLD}==== 安装完成！即将启动主菜单 ====${NC}\n"
    echo -e "${CYAN}${BOLD}>> 按任意键进入主菜单...${NC}"
    read -n1 -s
}
