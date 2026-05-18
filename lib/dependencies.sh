#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 依赖管理函数库
# 职责：查看依赖版本信息、修复依赖环境
# =========================================================================

# =========================================================================
# 5. 系统维护 - 查看依赖版本
# =========================================================================
show_dependencies() {
    echo -e "\n${CYAN}${BOLD}==== 依赖版本信息 ====${NC}"
    echo -ne "${BLUE}${BOLD}git:   ${NC}"; git --version
    echo -ne "${GREEN}${BOLD}node:  ${NC}"; node -v
    echo -ne "${MAGENTA}${BOLD}npm:   ${NC}"; command -v npm >/dev/null 2>&1 && npm -v || echo -e "${RED}${BOLD}未安装${NC}"
    echo -ne "${YELLOW}${BOLD}curl:  ${NC}"; command -v curl >/dev/null 2>&1 && curl --version | head -n1 || echo -e "${RED}${BOLD}未安装${NC}"
    echo -e "${CYAN}${BOLD}======================${NC}"
    press_any_key
}

# =========================================================================
# 5. 系统维护 - 修复依赖环境
# =========================================================================
fix_dependencies() {
    echo -e "\n${CYAN}${BOLD}==== 修复依赖环境 ====${NC}"
    ln -sf /data/data/com.termux/files/usr/etc/termux/mirrors/europe/packages.termux.dev /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
    pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    for dep in git curl unzip; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo -e "${YELLOW}${BOLD}>> 检测到未安装：$dep，正在安装...${NC}"
            pkg install -y $dep
        else
            echo -e "${GREEN}${BOLD}>> $dep 已安装，跳过。${NC}"
        fi
    done
    if ! command -v node >/dev/null 2>&1; then
        if pkg list-all | grep -q '^nodejs-lts/'; then
            echo -e "${MAGENTA}${BOLD}>> 检测到未安装：node，正在安装 nodejs-lts...${NC}"
            pkg install -y nodejs-lts || pkg install -y nodejs
        else
            echo -e "${MAGENTA}${BOLD}>> 检测到未安装：node，正在安装 nodejs...${NC}"
            pkg install -y nodejs
        fi
    else
        echo -e "${GREEN}${BOLD}>> node 已安装，跳过。${NC}"
    fi
    npm config set prefix $PREFIX
    echo -e "${GREEN}${BOLD}>> 依赖修复完成。${NC}"
    press_any_key
}
