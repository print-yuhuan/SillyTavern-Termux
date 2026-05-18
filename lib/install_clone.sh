#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 5/8：SillyTavern 仓库克隆函数库
# 职责：检测并克隆 SillyTavern 主游戏仓库到 ~/SillyTavern
# =========================================================================

install_step5_clone() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 5/8：克隆 SillyTavern 仓库 ====${NC}"
    if [ -d "$SILLYTAVERN_DIR/.git" ]; then
        echo -e "${YELLOW}${BOLD}>> SillyTavern 仓库已存在，跳过克隆。${NC}"
        echo -e "${YELLOW}${BOLD}>> 步骤 5/8 跳过：仓库已存在。${NC}"
    else
        rm -rf "$SILLYTAVERN_DIR"
        if git clone "$SILLYTAVERN_REPO" "$SILLYTAVERN_DIR"; then
            echo -e "${GREEN}${BOLD}>> 步骤 5/8 完成：SillyTavern 仓库已克隆。${NC}"
        else
            echo -e "${RED}${BOLD}>> 仓库克隆失败，请检查网络连接。${NC}"
            exit 1
        fi
    fi
}
