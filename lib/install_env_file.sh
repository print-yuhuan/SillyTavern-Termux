#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 6/8：运行时配置文件下载函数库
# 职责：下载 .env 到 ~/.env 并加载（包含 START_MODE、社群链接等运行时配置）
# =========================================================================

install_step6_env_file() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 6/8：下载配置文件 ====${NC}"
    local ENV_PATH="$HOME/.env"

    if [ -f "$ENV_PATH" ]; then
        echo -e "${YELLOW}${BOLD}>> .env 已存在，跳过下载。${NC}"
    else
        curl -fsSL -o "$ENV_PATH" "$REMOTE_ENV_URL" \
        || { echo -e "${RED}${BOLD}>> .env 下载失败！${NC}"; exit 1; }
    fi

    source "$ENV_PATH"
    echo -e "${GREEN}${BOLD}>> 步骤 6/8 完成：配置文件已就绪。${NC}"
}
