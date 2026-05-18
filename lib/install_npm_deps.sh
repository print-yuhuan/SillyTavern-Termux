#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 8/8：SillyTavern npm 依赖安装函数库
# 职责：清理旧缓存，执行带重试机制的 npm install（最多重试 3 次）
# =========================================================================

install_step8_npm_deps() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 8/8：安装 SillyTavern 依赖 ====${NC}"
    cd "$SILLYTAVERN_DIR" || { echo -e "${RED}${BOLD}>> 进入 SillyTavern 目录失败！${NC}"; exit 1; }
    export NODE_ENV=production

    [ -d node_modules ] && rm -rf node_modules
    [ -d "$HOME/.npm/_cacache" ] && npm cache clean --force

    retry_count=0
    max_retries=3
    install_success=0

    while [ $retry_count -lt $max_retries ]; do
        if [ $retry_count -eq 0 ]; then
            echo -e "${CYAN}${BOLD}>> 正在安装 SillyTavern 依赖，请耐心等待…${NC}"
        else
            echo -e "${YELLOW}${BOLD}>> 重试安装依赖（第 $retry_count 次）…${NC}"
        fi

        if npm install --no-audit --no-fund --loglevel=error --omit=dev; then
            install_success=1
            break
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                echo -e "${YELLOW}${BOLD}>> 依赖安装失败，正在清理缓存并准备重试…${NC}"
                [ -d node_modules ] && rm -rf node_modules
                [ -d "$HOME/.npm/_cacache" ] && npm cache clean --force
                sleep 3
            fi
        fi
    done

    if [ $install_success -eq 1 ]; then
        echo -e "${GREEN}${BOLD}>> 步骤 8/8 完成：SillyTavern 依赖已安装。${NC}"
    else
        echo -e "${RED}${BOLD}>> 依赖安装失败，已重试 $max_retries 次，请检查网络连接或日志信息。${NC}"
        exit 1
    fi

    cd "$HOME"
}
