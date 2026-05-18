#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 3/8：系统依赖安装函数库
# 职责：检测并安装 git/curl/zip/unzip/nodejs，配置 npm prefix
# =========================================================================

install_step3_dependencies() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 3/8：安装依赖 ====${NC}"
    for dep in git curl zip unzip; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo -e "${YELLOW}${BOLD}>> 检测到未安装：$dep，正在安装...${NC}"
            pkg install -y $dep
        else
            echo -e "${CYAN}${BOLD}>> $dep 已安装，跳过。${NC}"
        fi
    done

    if ! command -v node >/dev/null 2>&1; then
        if pkg list-all | grep -q '^nodejs-lts/'; then
            echo -e "${YELLOW}${BOLD}>> 检测到未安装：node，正在安装 nodejs-lts...${NC}"
            pkg install -y nodejs-lts || pkg install -y nodejs
        else
            echo -e "${YELLOW}${BOLD}>> 检测到未安装：node，正在安装 nodejs...${NC}"
            pkg install -y nodejs
        fi
    else
        echo -e "${CYAN}${BOLD}>> node 已安装，跳过。${NC}"
    fi

    npm config set prefix "$PREFIX"
    echo -e "${GREEN}${BOLD}>> 步骤 3/8 完成：依赖已安装。${NC}"
}
