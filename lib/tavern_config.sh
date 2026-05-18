#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 酒馆配置菜单函数库
# 职责：管理内存限制、恢复启动文件、恢复配置文件（子菜单聚合）
# =========================================================================

# =========================================================================
# 3. 酒馆配置
# =========================================================================
tavern_config_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}===== 酒馆配置 =====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 局域网配置项${NC}"
        echo -e "${BLUE}${BOLD}2. 修改内存限制${NC}"
        echo -e "${MAGENTA}${BOLD}3. 关联启动配置${NC}"
        echo -e "${CYAN}${BOLD}4. 恢复启动文件${NC}"
        echo -e "${RED}${BOLD}5. 恢复配置文件${NC}"
        echo -e "${CYAN}${BOLD}====================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-5）：${NC}"
        read -n1 config_choice; echo

        case "$config_choice" in
            0) break ;;
            1) lan_config_menu ;;
            2)
                cd "$HOME/SillyTavern" 2>/dev/null || { echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录。${NC}"; press_any_key; continue; }
                if [ ! -f start.sh ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 start.sh 文件，无法修改内存限制。${NC}"
                    press_any_key; continue
                fi
                [ ! -f start.sh.bak ] && cp start.sh start.sh.bak

                local error_msg=""
                while true; do
                    echo -ne "${CYAN}${BOLD}请输入新的内存限制（MB，范围1024-8192）：${NC}"
                    read mem_limit

                    if [ -z "$mem_limit" ]; then
                        error_msg=">> 输入不能为空，请输入有效的数字。"
                    elif ! [[ "$mem_limit" =~ ^[0-9]+$ ]]; then
                        error_msg=">> 请输入有效的数字。"
                    elif [ "$mem_limit" -lt 1024 ] || [ "$mem_limit" -gt 8192 ]; then
                        error_msg=">> 请输入 1024-8192 范围内的数值。"
                    else
                        error_msg=""
                        break
                    fi

                    echo -e "${RED}${BOLD}$error_msg${NC}"
                done

                if grep -q 'node --max-old-space-size=[0-9]\+ "server.js" "\$@"' start.sh; then
                    sed -i "s/node --max-old-space-size=[0-9]\+ \"server.js\" \"\\\$@\"/node --max-old-space-size=${mem_limit} \"server.js\" \"\\\$@\"/" start.sh
                    echo -e "${GREEN}${BOLD}>> 内存限制已设置为 ${mem_limit} MB。${NC}"
                elif grep -q 'node "server.js" "\$@"' start.sh; then
                    sed -i "s/node \"server.js\" \"\\\$@\"/node --max-old-space-size=${mem_limit} \"server.js\" \"\\\$@\"/" start.sh
                    echo -e "${GREEN}${BOLD}>> 已插入内存限制参数，现为 ${mem_limit} MB。${NC}"
                else
                    echo -e "${CYAN}${BOLD}>> 未检测到标准 node 启动命令，未做更改。${NC}"
                    press_any_key; continue
                fi
                press_any_key
                ;;
            3) startup_association_menu ;;
            4)
                cd "$HOME/SillyTavern" 2>/dev/null || { echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录。${NC}"; press_any_key; continue; }
                if [ ! -f start.sh.bak ]; then
                    echo -e "${MAGENTA}${BOLD}>> 未找到 start.sh.bak 备份文件，无法恢复。${NC}"
                    press_any_key; continue
                fi
                cp start.sh.bak start.sh
                echo -e "${YELLOW}${BOLD}>> 启动文件已恢复为初始版本。${NC}"
                press_any_key
                ;;
            5)
                cd "$HOME/SillyTavern" 2>/dev/null || { echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录。${NC}"; press_any_key; continue; }
                if [ ! -f config.yaml.bak ]; then
                    echo -e "${BRIGHT_MAGENTA}${BOLD}>> 未找到 config.yaml.bak 备份文件，无法恢复。${NC}"
                    press_any_key; continue
                fi
                cp config.yaml.bak config.yaml
                echo -e "${YELLOW}${BOLD}>> 配置文件已恢复为初始状态。${NC}"
                press_any_key
                ;;
            *)
                echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1
                ;;
        esac
    done
}
