#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 备份导出函数库
# 职责：导出酒馆数据（data/public 目录）、导出酒馆本体（完整目录）
# =========================================================================

# =========================================================================
# 5. 系统维护 - 导出酒馆数据
# =========================================================================
export_tavern_data() {
    echo -e "\n${CYAN}${BOLD}==== 导出酒馆数据 ====${NC}"

    # 检测存储权限
    if ! check_storage_permission; then
        press_any_key
        return
    fi

    # 检查并创建备份目录
    BACKUP_DIR="/storage/emulated/0/SillyTavern"
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}${BOLD}>> 备份目录不存在，正在创建...${NC}"
        if mkdir -p "$BACKUP_DIR" 2>/dev/null; then
            echo -e "${GREEN}${BOLD}>> 备份目录创建成功。${NC}"
        else
            echo -e "${RED}${BOLD}>> 备份目录创建失败，请检查存储权限。${NC}"
            press_any_key
            return
        fi
    fi

    cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> SillyTavern 目录不存在，无法导出。${NC}"; press_any_key; return; }
    now=$(date +%Y%m%d_%H%M%S)

    # 检查 data 和 public 目录是否存在
    has_data=0
    has_public=0
    [ -d data ] && has_data=1
    [ -d public ] && has_public=1

    if [ $has_data -eq 0 ] && [ $has_public -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到 data 或 public 目录，无数据可导出。${NC}"
        press_any_key
        return
    fi

    # 同时压缩 data 和 public 目录
    if [ $has_data -eq 1 ] && [ $has_public -eq 1 ]; then
        echo -e "${CYAN}${BOLD}>> 正在打包 data 和 public 目录...${NC}"
        zip -r "SillyTavern-Data_${now}.zip" data public
    elif [ $has_data -eq 1 ]; then
        echo -e "${YELLOW}${BOLD}>> 仅检测到 data 目录，正在打包...${NC}"
        zip -r "SillyTavern-Data_${now}.zip" data
    else
        echo -e "${YELLOW}${BOLD}>> 仅检测到 public 目录，正在打包...${NC}"
        zip -r "SillyTavern-Data_${now}.zip" public
    fi

    mv "SillyTavern-Data_${now}.zip" "$BACKUP_DIR/" 2>/dev/null \
        && echo -e "${GREEN}${BOLD}>> 导出完成，已保存到 SillyTavern 文件夹。${NC}" \
        || echo -e "${RED}${BOLD}>> 移动压缩包失败，请手动查找。${NC}"
    press_any_key
}

# =========================================================================
# 5. 系统维护 - 导出酒馆本体
# =========================================================================
export_tavern_full() {
    echo -e "\n${CYAN}${BOLD}==== 导出酒馆本体 ====${NC}"

    # 检测存储权限
    if ! check_storage_permission; then
        press_any_key
        return
    fi

    # 检查并创建备份目录
    BACKUP_DIR="/storage/emulated/0/SillyTavern"
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}${BOLD}>> 备份目录不存在，正在创建...${NC}"
        if mkdir -p "$BACKUP_DIR" 2>/dev/null; then
            echo -e "${GREEN}${BOLD}>> 备份目录创建成功。${NC}"
        else
            echo -e "${RED}${BOLD}>> 备份目录创建失败，请检查存储权限。${NC}"
            press_any_key
            return
        fi
    fi

    cd "$HOME" || { echo -e "${RED}${BOLD}>> HOME 目录不存在，无法导出。${NC}"; press_any_key; return; }
    if [ ! -d SillyTavern ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到 SillyTavern 目录，无本体可导出。${NC}"
        press_any_key
        return
    fi
    now=$(date +%Y%m%d_%H%M%S)
    zip -r "SillyTavern_${now}.zip" SillyTavern
    mv "SillyTavern_${now}.zip" "$BACKUP_DIR/" 2>/dev/null \
        && echo -e "${GREEN}${BOLD}>> 导出完成，已保存到 SillyTavern 文件夹。${NC}" \
        || echo -e "${RED}${BOLD}>> 移动压缩包失败，请手动查找。${NC}"
    press_any_key
}
