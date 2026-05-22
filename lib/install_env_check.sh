#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 1/8：环境检测函数库
# 职责：检测 Termux 环境合法性、请求并等待存储权限
# =========================================================================

install_step1_env_check() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 1/8：环境检测 ====${NC}"
    if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
        echo -e "${RED}${BOLD}>> 检测到非 Termux 环境，请在 Termux 中执行此脚本！${NC}"
        exit 1
    fi
    STORAGE_DIR="$HOME/storage/shared"
    if [ ! -d "$STORAGE_DIR" ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到存储权限，尝试自动获取...${NC}"
        if ! command -v termux-setup-storage >/dev/null 2>&1; then
            echo -e "${YELLOW}${BOLD}>> 警告：'termux-setup-storage' 命令不存在，部分功能可能无法访问存储。${NC}"
        else
            termux-setup-storage
            echo -e "${CYAN}${BOLD}>> 请在弹出的窗口中点击"允许"授权，正在等待授权结果...${NC}"
            max_wait_time=15
            for ((i=0; i<max_wait_time; i++)); do
                [ -d "$STORAGE_DIR" ] && break
                sleep 1
            done
            if [ ! -d "$STORAGE_DIR" ]; then
                echo -e "${YELLOW}${BOLD}>> 警告：存储权限获取超时或被拒绝，部分功能可能受限。${NC}"
            else
                echo -e "${GREEN}${BOLD}>> 存储权限已成功获取。${NC}"
            fi
        fi
    else
        echo -e "${GREEN}${BOLD}>> 存储权限已配置。${NC}"
    fi
    echo -e "${GREEN}${BOLD}>> 步骤 1/8 完成：环境检测通过。${NC}"
}
