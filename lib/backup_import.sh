#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 备份导入函数库
# 职责：从存储目录选择备份文件并还原（数据目录 / 完整本体）
# =========================================================================

# =========================================================================
# 5. 系统维护 - 导入酒馆数据
# =========================================================================
import_tavern_data() {
    echo -e "\n${CYAN}${BOLD}==== 导入酒馆数据 ====${NC}"

    # 检测存储权限
    if ! check_storage_permission; then
        press_any_key
        return
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 检测到 unzip 未安装，请执行 pkg install unzip 后重试。${NC}"
        press_any_key; return
    fi

    BACKUP_DIR="/storage/emulated/0/SillyTavern"
    # 检查备份目录是否存在
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}${BOLD}>> 备份目录不存在。${NC}"
        echo -e "${YELLOW}${BOLD}>> 提示：请先将备份文件放入 /storage/emulated/0/SillyTavern/ 目录。${NC}"
        press_any_key
        return
    fi

    PATTERN="SillyTavern-Data_*.zip"
    mapfile -t backup_files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "$PATTERN" 2>/dev/null | xargs -r ls -t 2>/dev/null)
    if [ ${#backup_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未在 SillyTavern 目录中检测到可用的备份文件。${NC}"
        press_any_key; return
    fi
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 导入酒馆数据 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        for i in "${!backup_files[@]}"; do
            fname=$(basename "${backup_files[$i]}")
            echo -e "${GREEN}${BOLD}$((i+1)). $fname${NC}"
        done
        echo -e "${CYAN}${BOLD}======================${NC}"
        echo -ne "${CYAN}${BOLD}请输入要恢复的备份文件序号（或0返回）：${NC}"
        read -r idx
        if [[ "$idx" == "0" ]]; then
            return
        fi
        if [[ "$idx" =~ ^[1-9][0-9]*$ ]] && [ "$idx" -le "${#backup_files[@]}" ]; then
            selected_file="${backup_files[$((idx-1))]}"
            if [ ! -d "$HOME/SillyTavern" ]; then
                echo -e "${YELLOW}${BOLD}>> 未检测到 SillyTavern 主目录，请先恢复酒馆本体。${NC}"
                press_any_key; return
            fi

            # 检查备份文件中包含哪些目录
            has_data_in_zip=$(unzip -l "$selected_file" 2>/dev/null | grep -c '^.*data/' || echo 0)
            has_public_in_zip=$(unzip -l "$selected_file" 2>/dev/null | grep -c '^.*public/' || echo 0)

            # 准备删除和恢复的目录列表
            dirs_to_remove=""
            dirs_info=""

            if [ "$has_data_in_zip" -gt 0 ]; then
                TARGET_DATA_DIR="$HOME/SillyTavern/data"
                if [ -d "$TARGET_DATA_DIR" ]; then
                    dirs_to_remove="$dirs_to_remove $TARGET_DATA_DIR"
                fi
                dirs_info="${dirs_info}data "
            fi

            if [ "$has_public_in_zip" -gt 0 ]; then
                TARGET_PUBLIC_DIR="$HOME/SillyTavern/public"
                if [ -d "$TARGET_PUBLIC_DIR" ]; then
                    dirs_to_remove="$dirs_to_remove $TARGET_PUBLIC_DIR"
                fi
                dirs_info="${dirs_info}public "
            fi

            if [ "$has_data_in_zip" -eq 0 ] && [ "$has_public_in_zip" -eq 0 ]; then
                echo -e "${YELLOW}${BOLD}>> 警告：备份文件中未检测到 data 或 public 目录。${NC}"
                press_any_key; return
            fi

            # 如果有目录需要覆盖，则提示用户确认
            if [ -n "$dirs_to_remove" ]; then
                echo -e "${YELLOW}${BOLD}>> 警告：将要覆盖以下目录：${dirs_info}${NC}"
                echo -e "${YELLOW}${BOLD}>> 继续操作将彻底删除这些目录及其所有内容，然后从备份恢复。${NC}"
                echo -e "${YELLOW}${BOLD}>> 此操作不可撤销！是否确认覆盖？(y/n)：${NC}\c"
                read -n1 confirm; echo
                if ! [[ "$confirm" =~ [yY] ]]; then
                    echo -e "${YELLOW}${BOLD}>> 已取消恢复操作。${NC}"
                    press_any_key; return
                fi
                # 删除要覆盖的目录
                for dir in $dirs_to_remove; do
                    rm -rf "$dir"
                done
            fi

            echo -e "${CYAN}${BOLD}>> 正在从 $(basename "$selected_file") 恢复 ${dirs_info}目录...${NC}"
            mkdir -p "$HOME/SillyTavern"
            if unzip -o "$selected_file" -d "$HOME/SillyTavern/" >/dev/null 2>&1; then
                echo -e "${GREEN}${BOLD}>> 恢复成功！建议重启 SillyTavern 以应用更改。${NC}"
            else
                echo -e "${RED}${BOLD}>> 恢复失败，请检查压缩包是否完整或存储权限。${NC}"
            fi
            press_any_key; return
        else
            echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"
            sleep 1
        fi
    done
}

# =========================================================================
# 5. 系统维护 - 导入酒馆本体
# =========================================================================
import_tavern_full() {
    echo -e "\n${CYAN}${BOLD}==== 导入酒馆本体 ====${NC}"

    # 检测存储权限
    if ! check_storage_permission; then
        press_any_key
        return
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 检测到 unzip 未安装，请执行 pkg install unzip 后重试。${NC}"
        press_any_key; return
    fi

    BACKUP_DIR="/storage/emulated/0/SillyTavern"
    # 检查备份目录是否存在
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}${BOLD}>> 备份目录不存在。${NC}"
        echo -e "${YELLOW}${BOLD}>> 提示：请先将备份文件放入 /storage/emulated/0/SillyTavern/ 目录。${NC}"
        press_any_key
        return
    fi

    PATTERN="SillyTavern_*.zip"
    mapfile -t backup_files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "$PATTERN" 2>/dev/null | xargs -r ls -t 2>/dev/null)
    if [ ${#backup_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未在 SillyTavern 目录中检测到可用的备份文件。${NC}"
        press_any_key; return
    fi
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 导入酒馆本体 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        for i in "${!backup_files[@]}"; do
            fname=$(basename "${backup_files[$i]}")
            echo -e "${GREEN}${BOLD}$((i+1)). $fname${NC}"
        done
        echo -e "${CYAN}${BOLD}======================${NC}"
        echo -ne "${CYAN}${BOLD}请输入要恢复的备份文件序号（或0返回）：${NC}"
        read -r idx
        if [[ "$idx" == "0" ]]; then
            return
        fi
        if [[ "$idx" =~ ^[1-9][0-9]*$ ]] && [ "$idx" -le "${#backup_files[@]}" ]; then
            selected_file="${backup_files[$((idx-1))]}"
            TARGET_DIR="$HOME/SillyTavern"
            if [ -d "$TARGET_DIR" ]; then
                echo -e "${YELLOW}${BOLD}>> 警告：目标目录 ${TARGET_DIR} 已存在。"
                echo -e ">> 继续操作将彻底删除该目录及其所有内容，然后从备份恢复。"
                echo -e ">> 此操作不可撤销！是否确认覆盖？(y/n)：${NC}\c"
                read -n1 confirm; echo
                if ! [[ "$confirm" =~ [yY] ]]; then
                    echo -e "${YELLOW}${BOLD}>> 已取消恢复操作。${NC}"
                    press_any_key; return
                fi
                rm -rf "$TARGET_DIR"
            fi
            echo -e "${CYAN}${BOLD}>> 正在从 $(basename "$selected_file") 恢复至 $TARGET_DIR ...${NC}"
            mkdir -p "$HOME"
            if unzip -o "$selected_file" -d "$HOME/" >/dev/null 2>&1; then
                echo -e "${GREEN}${BOLD}>> 恢复成功！建议重启 SillyTavern 以应用更改。${NC}"
            else
                echo -e "${RED}${BOLD}>> 恢复失败，请检查压缩包是否完整或存储权限。${NC}"
            fi
            press_any_key; return
        else
            echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"
            sleep 1
        fi
    done
}
