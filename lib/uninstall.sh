#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 卸载函数库
# 职责：删除 SillyTavern 目录、清理脚本文件及自启动配置
# =========================================================================

# =========================================================================
# 6. 脚本管理 - 一键卸载酒馆
# =========================================================================
uninstall_all() {
    echo -e "\n${CYAN}${BOLD}==== 卸载警告 ====${NC}"
    echo -e "${RED}${BOLD}>> 即将卸载 SillyTavern 及相关配置，操作不可逆！${NC}"
    echo -ne "${YELLOW}${BOLD}是否继续？(y/n)：${NC}"
    read -n1 confirm; echo
    if [[ "$confirm" =~ [yY] ]]; then
        if [ -d "$HOME/SillyTavern/.git" ]; then
            rm -rf "$HOME/SillyTavern"
        fi
        rm -f "$HOME/Menu.sh" "$USER_CONF" "$HOME/Install.sh"
        sed -i '/# SillyTavern-Termux 菜单自启动/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/# SillyTavern-Termux 菜单自启动/d' "$HOME/.bash_profile" 2>/dev/null
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.bash_profile" 2>/dev/null
        sed -i '/# SillyTavern-Termux 菜单自启动/d' "$HOME/.profile" 2>/dev/null
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.profile" 2>/dev/null
        echo -e "${GREEN}${BOLD}>> 卸载完成，已清理相关文件。${NC}"
        exit 0
    else
        echo -e "${YELLOW}${BOLD}>> 已取消卸载。${NC}"
        sleep 1
    fi
}
