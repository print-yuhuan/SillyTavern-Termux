#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 版本标签函数库
# 职责：列出可用版本标签、显示版本切换帮助文档
# =========================================================================

# =========================================================================
# 5.7 酒馆版本切换 - 查看版本标签
# =========================================================================
show_version_tags() {
    echo -e "\n${CYAN}${BOLD}==== 查看版本标签 ====${NC}"

    # 检查 SillyTavern 目录
    if [ ! -d "$HOME/SillyTavern" ]; then
        echo -e "${RED}${BOLD}>> SillyTavern 目录不存在，无法查看版本标签。${NC}"
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

    # 检查 git 命令
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 检测到 git 命令不可用，请先修复依赖环境。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 获取当前版本
    current_version=$(git describe --tags --exact-match 2>/dev/null || echo "release 分支")
    echo -e "${YELLOW}${BOLD}>> 当前版本：${current_version}${NC}\n"

    # 尝试更新标签列表
    echo -e "${CYAN}${BOLD}>> 正在获取最新版本标签...${NC}"
    if git fetch --tags 2>/dev/null; then
        echo -e "${GREEN}${BOLD}>> 标签列表已更新。${NC}\n"
    else
        echo -e "${YELLOW}${BOLD}>> 无法连接到远程仓库，显示本地标签。${NC}\n"
    fi

    # 列出所有标签
    tag_count=$(git tag | wc -l)
    if [ "$tag_count" -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到任何版本标签。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    echo -e "${CYAN}${BOLD}==== 可用版本标签列表 ====${NC}"
    git --no-pager tag --sort=creatordate --format='%(creatordate:short) %(color:bold green)%(refname:short)%(color:reset)' --color=always \
    | awk '{printf "\033[1;36m%2d\033[0m %s\n", NR, $0}'
    echo -e "${CYAN}${BOLD}============================${NC}"

    press_any_key
    cd "$HOME"
}

# =========================================================================
# 5.7 酒馆版本切换 - 帮助文档
# =========================================================================
show_version_switch_help() {
    echo -e "${CYAN}${BOLD}==================================================${NC}"
    echo -e "${CYAN}${BOLD}SillyTavern 版本切换指南${NC}"
    echo -e "${CYAN}${BOLD}==================================================${NC}\n"

    echo -e "${CYAN}${BOLD}一、功能说明${NC}"
    echo -e "  SillyTavern 采用 Git 版本管理，项目维护者会为稳定版本打上标签。"
    echo -e "  本功能允许您在不同版本间自由切换，方便测试或回退到稳定版本。\n"

    echo -e "${CYAN}${BOLD}二、操作流程${NC}"
    echo -e "  ${BOLD}1. 查看版本标签${NC}"
    echo -e "    - 列出所有可用的版本标签及发布日期"
    echo -e "    - 序号标记方便快速选择"
    echo -e "    - 显示当前所在版本\n"

    echo -e "  ${BOLD}2. 切换酒馆版本${NC}"
    echo -e "    - 输入对应序号切换到目标版本"
    echo -e "    - 自动重新安装该版本的依赖"
    echo -e "    - 支持二次确认，避免误操作\n"

    echo -e "${CYAN}${BOLD}三、版本说明${NC}"
    echo -e "${CYAN}--------------------------------------------------${NC}"
    echo -e "  ${BOLD}标签版本：${NC}"
    echo -e "    - 由项目维护者发布的稳定版本（如 1.13.4）"
    echo -e "    - 适合日常使用，稳定性较好\n"

    echo -e "  ${BOLD}release 分支：${NC}"
    echo -e "    - 项目的主要开发分支"
    echo -e "    - 包含最新功能和修复，但可能存在不稳定因素"
    echo -e "    - 通过"更新酒馆"功能可切换回该分支\n"

    echo -e "${CYAN}${BOLD}四、注意事项${NC}"
    echo -e "  · ${BOLD}版本切换前：${NC} 建议先备份酒馆数据（系统维护 → 导出酒馆数据）"
    echo -e "  · ${BOLD}未提交更改：${NC} 切换版本会丢失未提交的文件修改，请注意保存"
    echo -e "  · ${BOLD}依赖安装：${NC} 切换版本后会自动重新安装依赖，需要良好的网络连接"
    echo -e "  · ${BOLD}依赖失败：${NC} 若依赖安装失败，可在系统维护中选择"修复依赖环境""
    echo -e "  · ${BOLD}回到最新：${NC} 如需回到最新版本，使用主菜单的"更新酒馆"功能\n"

    echo -e "${CYAN}${BOLD}五、常见问题${NC}"
    echo -e "  ${BOLD}Q：版本切换后启动失败怎么办？${NC}"
    echo -e "  A：检查依赖是否安装成功，可尝试"系统维护 → 修复依赖环境"。\n"

    echo -e "  ${BOLD}Q：如何回到最新的 release 分支？${NC}"
    echo -e "  A：使用主菜单的"更新酒馆"功能，会自动切换到 release 分支。\n"

    echo -e "  ${BOLD}Q：切换版本会影响我的数据吗？${NC}"
    echo -e "  A：不会，用户数据存储在 data 目录，版本切换不影响该目录。\n"

    echo -e "${CYAN}${BOLD}==================================================${NC}"
    press_any_key
}
