#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 存储权限函数库
# 职责：检测并获取 Termux 存储权限
# =========================================================================

# ==== 存储权限检测函数 ====
check_storage_permission() {
    STORAGE_DIR="$HOME/storage/shared"
    if [ ! -d "$STORAGE_DIR" ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到存储权限，尝试自动获取...${NC}"
        if ! command -v termux-setup-storage >/dev/null 2>&1; then
            echo -e "${RED}${BOLD}>> 错误：'termux-setup-storage' 命令不存在，无法获取存储权限。${NC}"
            return 1
        else
            termux-setup-storage
            echo -e "${CYAN}${BOLD}>> 请在弹出的窗口中点击"允许"授权，正在等待授权结果...${NC}"
            max_wait_time=15
            for ((i=0; i<max_wait_time; i++)); do
                [ -d "$STORAGE_DIR" ] && break
                sleep 1
            done
            if [ ! -d "$STORAGE_DIR" ]; then
                echo -e "${RED}${BOLD}>> 错误：存储权限获取超时或被拒绝，无法继续操作。${NC}"
                return 1
            else
                echo -e "${GREEN}${BOLD}>> 存储权限已成功获取。${NC}"
                return 0
            fi
        fi
    else
        return 0
    fi
}
