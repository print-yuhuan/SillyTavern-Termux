#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 2/8：包管理器更新函数库
# 职责：切换欧洲镜像源、执行 pkg update && pkg upgrade
# =========================================================================

install_step2_pkg_update() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 2/8：更新包管理器 ====${NC}"
    local mirror_source="$PREFIX/etc/termux/mirrors/europe/packages.termux.dev"
    local mirror_target="$PREFIX/etc/termux/chosen_mirrors"
    if [ -f "$mirror_source" ]; then
        mkdir -p "$(dirname "$mirror_target")"
        ln -sf "$mirror_source" "$mirror_target"
        echo -e "${GREEN}${BOLD}>> 已配置 Termux 官方镜像源。${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 未检测到官方镜像配置，保留当前镜像设置。${NC}"
    fi
    if ! pkg update; then
        echo -e "${RED}${BOLD}>> 软件包索引更新失败，请检查网络连接。${NC}"
        exit 1
    fi
    if ! pkg upgrade -y -o Dpkg::Options::="--force-confnew"; then
        echo -e "${RED}${BOLD}>> 软件包升级失败，请确认网络连接和磁盘空间。${NC}"
        exit 1
    fi
    echo -e "${GREEN}${BOLD}>> 步骤 2/8 完成：包管理器已更新。${NC}"
}
