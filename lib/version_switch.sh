#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 版本切换函数库
# 职责：执行版本切换（checkout 到指定 tag 并重装依赖）、版本切换菜单
# =========================================================================

# =========================================================================
# 5.7 酒馆版本切换 - 切换版本
# =========================================================================
switch_tavern_version() {
    echo -e "\n${CYAN}${BOLD}==== 切换酒馆版本 ====${NC}"

    # 检查 SillyTavern 目录
    if [ ! -d "$HOME/SillyTavern" ]; then
        echo -e "${RED}${BOLD}>> SillyTavern 目录不存在，无法切换版本。${NC}"
        press_any_key
        return
    fi

    cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> 进入 SillyTavern 目录失败。${NC}"; press_any_key; return; }

    # 检查 Git 仓库
    if [ ! -d ".git" ]; then
        echo -e "${RED}${BOLD}>> SillyTavern 目录不是有效的 Git 仓库。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 检查必要命令
    for cmd in node npm git; do
        if ! command -v $cmd >/dev/null 2>&1; then
            echo -e "${RED}${BOLD}>> 检测到缺失依赖：$cmd，请先修复依赖环境。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi
    done

    # 检查未提交的更改
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${YELLOW}${BOLD}>> 警告：检测到未提交的更改，切换版本将丢失这些更改！${NC}"
        echo -ne "${YELLOW}${BOLD}是否继续？(y/n)：${NC}"
        read -n1 confirm; echo
        if ! [[ "$confirm" =~ [yY] ]]; then
            echo -e "${YELLOW}${BOLD}>> 已取消版本切换。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi
    fi

    # 获取当前版本
    current_version=$(git describe --tags --exact-match 2>/dev/null || echo "release 分支")
    echo -e "${YELLOW}${BOLD}>> 当前版本：${current_version}${NC}\n"

    # 尝试更新标签列表
    echo -e "${CYAN}${BOLD}>> 正在获取最新版本标签...${NC}"
    git fetch --tags 2>/dev/null

    # 列出所有标签
    tag_count=$(git tag | wc -l)
    if [ "$tag_count" -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到任何版本标签，无法切换。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    echo -e "${CYAN}${BOLD}==== 可用版本标签列表 ====${NC}"
    git --no-pager tag --sort=creatordate --format='%(creatordate:short) %(color:bold green)%(refname:short)%(color:reset)' --color=always \
    | awk '{printf "\033[1;36m%2d\033[0m %s\n", NR, $0}'
    echo -e "${CYAN}${BOLD}============================${NC}"

    # 用户选择版本
    while true; do
        echo -ne "${CYAN}${BOLD}请输入版本序号后回车（或输入0返回）：${NC}"
        read -r input_number

        if [[ "$input_number" == "0" ]]; then
            echo -e "${YELLOW}${BOLD}>> 已取消版本切换。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        if ! [[ "$input_number" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "${RED}${BOLD}>> 输入无效，请输入有效的数字。${NC}"
            continue
        fi

        if [ "$input_number" -gt "$tag_count" ]; then
            echo -e "${RED}${BOLD}>> 序号超出范围，请重新输入。${NC}"
            continue
        fi

        break
    done

    # 获取选中的标签名
    selected_tag=$(git tag --sort=creatordate | sed -n "${input_number}p")

    if [ -z "$selected_tag" ]; then
        echo -e "${RED}${BOLD}>> 获取标签失败，请重试。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 二次确认
    echo -e "${YELLOW}${BOLD}>> 即将切换到版本：${selected_tag}${NC}"
    echo -ne "${YELLOW}${BOLD}确认切换？(y/n)：${NC}"
    read -n1 confirm; echo
    if ! [[ "$confirm" =~ [yY] ]]; then
        echo -e "${YELLOW}${BOLD}>> 已取消版本切换。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 执行版本切换
    echo -e "${CYAN}${BOLD}>> 正在切换到版本 ${selected_tag}...${NC}"
    if ! git checkout -f tags/${selected_tag} 2>&1; then
        echo -e "${RED}${BOLD}>> 版本切换失败，请检查错误信息。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    echo -e "${GREEN}${BOLD}>> 版本切换成功。${NC}"

    # 重新安装依赖
    echo -e "${CYAN}${BOLD}>> 正在重新安装依赖模块...${NC}"
    export NODE_ENV=production

    # 清理旧依赖
    [ -d node_modules ] && rm -rf node_modules
    [ -d "$HOME/.npm/_cacache" ] && npm cache clean --force

    # 依赖安装重试机制
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
        echo -e "${GREEN}${BOLD}>> 版本切换完成！当前版本：${selected_tag}${NC}"
        echo -e "${GREEN}${BOLD}>> 依赖已重新安装，可以正常使用。${NC}"
    else
        echo -e "${RED}${BOLD}>> 版本已切换，但依赖安装失败，已重试 $max_retries 次。${NC}"
        echo -e "${YELLOW}${BOLD}>> 请检查网络连接，或稍后在系统维护中选择"修复依赖环境"。${NC}"
    fi

    press_any_key
    cd "$HOME"
}

# =========================================================================
# 5.7 酒馆版本切换菜单
# =========================================================================
version_switch_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 酒馆版本切换 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 查看版本标签${NC}"
        echo -e "${BLUE}${BOLD}2. 切换酒馆版本${NC}"
        echo -e "${MAGENTA}${BOLD}3. 版本切换帮助${NC}"
        echo -e "${CYAN}${BOLD}======================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-3）：${NC}"
        read -n1 version_choice; echo

        case "$version_choice" in
            0) break ;;
            1) show_version_tags ;;
            2) switch_tavern_version ;;
            3) show_version_switch_help ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}
