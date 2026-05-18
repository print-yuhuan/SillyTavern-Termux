#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 关联启动配置函数库
# 职责：配置 START_MODE（单独启动 / 关联启动）、查看反代日志
# =========================================================================

# =========================================================================
# 关联启动配置菜单
# =========================================================================
startup_association_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 关联启动配置 ====${NC}"

        # 显示当前配置状态
        if [ "$START_MODE" = "1" ]; then
            echo -e "${YELLOW}${BOLD}当前状态: 单独启动模式${NC}"
        elif [ "$START_MODE" = "2" ]; then
            echo -e "${GREEN}${BOLD}当前状态: 关联启动模式${NC}"
        else
            echo -e "${RED}${BOLD}当前状态: 配置异常 (START_MODE=$START_MODE)${NC}"
        fi

        echo ""
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 开启关联启动${NC}"
        echo -e "${RED}${BOLD}2. 关闭关联启动${NC}"
        echo -e "${BLUE}${BOLD}3. 查看反代日志${NC}"
        echo -e "${CYAN}${BOLD}======================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-3）：${NC}"
        read -n1 assoc_choice; echo

        case "$assoc_choice" in
            0) break ;;
            1)
                # 开启关联启动
                echo -e "\n${CYAN}${BOLD}==== 开启关联启动 ====${NC}"

                # 检测 Gemini-CLI-Termux 是否存在
                if [ ! -d "$HOME/Gemini-CLI-Termux" ]; then
                    echo -e "${YELLOW}${BOLD}>> [警告] 未检测到 Gemini-CLI-Termux 目录。${NC}"
                    echo -e "${YELLOW}${BOLD}>> 启用关联启动后，如果该目录不存在，启动将会失败。${NC}"
                    echo -ne "${CYAN}${BOLD}>> 是否仍要开启关联启动? (y/n): ${NC}"
                    read -n1 confirm; echo
                    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
                        echo -e "${YELLOW}${BOLD}>> 已取消操作。${NC}"
                        press_any_key; continue
                    fi
                fi

                # 修改 START_MODE 为 2
                if [ -f "$USER_CONF" ] && grep -q "^START_MODE=" "$USER_CONF"; then
                    sed -i 's/^START_MODE=.*/START_MODE=2/' "$USER_CONF"
                else
                    echo "START_MODE=2" >> "$USER_CONF"
                fi
                START_MODE=2
                echo -e "${GREEN}${BOLD}>> 关联启动已开启。${NC}"
                echo -e "${CYAN}${BOLD}>> 下次启动酒馆时将同时启动 Gemini-CLI-Termux 反代服务。${NC}"
                press_any_key
                ;;
            2)
                # 关闭关联启动
                echo -e "\n${CYAN}${BOLD}==== 关闭关联启动 ====${NC}"

                # 修改 START_MODE 为 1
                if [ -f "$USER_CONF" ] && grep -q "^START_MODE=" "$USER_CONF"; then
                    sed -i 's/^START_MODE=.*/START_MODE=1/' "$USER_CONF"
                else
                    echo "START_MODE=1" >> "$USER_CONF"
                fi
                START_MODE=1
                echo -e "${GREEN}${BOLD}>> 关联启动已关闭。${NC}"
                echo -e "${CYAN}${BOLD}>> 下次启动酒馆时将只启动 SillyTavern。${NC}"
                press_any_key
                ;;
            3)
                # 查看反代日志
                echo -e "\n${CYAN}${BOLD}==== 查看反代日志 ====${NC}"

                LOG_FILE="$HOME/setup.log"
                if [ ! -f "$LOG_FILE" ]; then
                    echo -e "${YELLOW}${BOLD}>> 日志文件不存在。${NC}"
                    echo -e "${CYAN}${BOLD}>> 日志文件将在首次使用关联启动后生成。${NC}"
                    press_any_key; continue
                fi

                # 检测日志文件是否为空
                if [ ! -s "$LOG_FILE" ]; then
                    echo -e "${YELLOW}${BOLD}>> 日志文件为空。${NC}"
                    press_any_key; continue
                fi

                # 显示日志文件内容
                echo -e "${CYAN}${BOLD}>> 日志文件路径: $LOG_FILE${NC}"
                echo -e "${CYAN}${BOLD}>> 正在显示最后 50 行日志...${NC}\n"
                echo -e "${GREEN}${BOLD}========== 日志内容开始 ==========${NC}"
                tail -n 50 "$LOG_FILE"
                echo -e "${GREEN}${BOLD}========== 日志内容结束 ==========${NC}\n"

                # 显示日志文件大小
                LOG_SIZE=$(stat -c%s "$LOG_FILE" 2>/dev/null || stat -f%z "$LOG_FILE" 2>/dev/null)
                LOG_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $LOG_SIZE/1024/1024}")
                echo -e "${CYAN}${BOLD}>> 日志文件大小: ${LOG_SIZE_MB} MB${NC}"
                if [ "$LOG_SIZE" -gt 5242880 ]; then
                    echo -e "${YELLOW}${BOLD}>> 日志文件已超过 5MB，下次启动时将自动清理。${NC}"
                fi

                press_any_key
                ;;
            *)
                echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1
                ;;
        esac
    done
}
