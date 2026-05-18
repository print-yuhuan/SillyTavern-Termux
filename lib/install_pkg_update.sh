#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 2/8：包管理器更新函数库
# 职责：切换欧洲镜像源、执行 pkg update && pkg upgrade
# =========================================================================

install_step2_pkg_update() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 2/8：更新包管理器 ====${NC}"
    ln -sf /data/data/com.termux/files/usr/etc/termux/mirrors/europe/packages.termux.dev /data/data/com.termux/files/usr/etc/termux/chosen_mirrors
    pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    echo -e "${GREEN}${BOLD}>> 步骤 2/8 完成：包管理器已更新。${NC}"
}
