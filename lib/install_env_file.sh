#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 6/8：用户配置文件初始化函数库
# 职责：创建 ~/.sillytavern-termux.conf 并写入默认 START_MODE
# =========================================================================

install_step6_env_file() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 6/8：初始化用户配置 ====${NC}"

    if [ -f "$USER_CONF" ]; then
        echo -e "${YELLOW}${BOLD}>> 用户配置已存在，跳过。${NC}"
    else
        echo "START_MODE=1" > "$USER_CONF"
        echo -e "${GREEN}${BOLD}>> 已创建用户配置文件：$USER_CONF${NC}"
    fi

    source "$USER_CONF"
    echo -e "${GREEN}${BOLD}>> 步骤 6/8 完成：用户配置已就绪。${NC}"
}
