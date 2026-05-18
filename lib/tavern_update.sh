#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 酒馆更新函数库
# 职责：拉取最新代码并重新安装依赖
# =========================================================================

# =========================================================================
# 2. 更新酒馆
# =========================================================================
update_tavern() {
    echo -e "\n${CYAN}${BOLD}==== 更新 SillyTavern ====${NC}"
    if [ -d "$HOME/SillyTavern" ]; then
        cd "$HOME/SillyTavern"

        if [ ! -d ".git" ]; then
            echo -e "${RED}${BOLD}>> SillyTavern 目录不是有效的 Git 仓库。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        echo -e "${CYAN}${BOLD}>> 正在检查远程更新...${NC}"

        local_commit=$(git rev-parse HEAD 2>/dev/null)

        if ! git fetch origin 2>/dev/null; then
            echo -e "${RED}${BOLD}>> 无法连接到远程仓库，请检查网络连接。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        remote_commit=$(git rev-parse origin/release 2>/dev/null)

        if [ "$local_commit" = "$remote_commit" ]; then
            echo -e "${GREEN}${BOLD}>> SillyTavern 已是最新版本，无需更新。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        commit_count=$(git rev-list --count HEAD..origin/release 2>/dev/null)
        if [ -n "$commit_count" ] && [ "$commit_count" -gt 0 ]; then
            echo -e "${YELLOW}${BOLD}>> 发现 $commit_count 个新提交，准备更新...${NC}"
        fi

        echo -e "${CYAN}${BOLD}>> 正在拉取最新代码...${NC}"
        git reset --hard origin/release

        echo -e "${CYAN}${BOLD}>> 正在更新依赖模块...${NC}"
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
            echo -e "${GREEN}${BOLD}>> SillyTavern 更新完成，代码和依赖均已更新。${NC}"
        else
            echo -e "${RED}${BOLD}>> 代码更新成功，但依赖安装失败，已重试 $max_retries 次。${NC}"
            echo -e "${YELLOW}${BOLD}>> 请检查网络连接后，手动执行依赖安装或重新尝试更新。${NC}"
        fi

        press_any_key
        cd "$HOME"
    else
        echo -e "${RED}${BOLD}>> 未检测到 SillyTavern 目录。${NC}"
        sleep 2
    fi
}
