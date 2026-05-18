#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 局域网配置函数库
# 职责：开启/关闭网络监听、获取内网地址、局域网连接帮助
# =========================================================================

lan_config_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 局域网配置项 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 开启网络监听${NC}"
        echo -e "${RED}${BOLD}2. 关闭网络监听${NC}"
        echo -e "${BLUE}${BOLD}3. 获取内网地址${NC}"
        echo -e "${MAGENTA}${BOLD}4. 内网连接帮助${NC}"
        echo -e "${CYAN}${BOLD}======================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-4）：${NC}"
        read -n1 lan_choice; echo
        case "$lan_choice" in
            0) break ;;
            1)
                cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录，无法操作。${NC}"; press_any_key; continue; }
                if [ ! -f config.yaml ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 config.yaml 文件，无法开启监听。${NC}"
                    press_any_key; continue
                fi
                [ ! -f config.yaml.bak ] && cp config.yaml config.yaml.bak
                sed -i 's/^listen: false$/listen: true/' config.yaml
                sed -i 's/^enableUserAccounts: false$/enableUserAccounts: true/' config.yaml
                sed -i 's/^enableDiscreetLogin: false$/enableDiscreetLogin: true/' config.yaml
                sed -i 's/^  - 127\.0\.0\.1$/  - 0.0.0.0\/0/' config.yaml
                echo -e "${GREEN}${BOLD}>> 网络监听已开启，允许外部设备访问。${NC}"
                press_any_key
                ;;
            2)
                cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录，无法操作。${NC}"; press_any_key; continue; }
                if [ ! -f config.yaml ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 config.yaml 文件，无法关闭监听。${NC}"
                    press_any_key; continue
                fi
                [ ! -f config.yaml.bak ] && cp config.yaml config.yaml.bak
                sed -i 's/^listen: true$/listen: false/' config.yaml
                sed -i 's/^enableUserAccounts: true$/enableUserAccounts: false/' config.yaml
                sed -i 's/^enableDiscreetLogin: true$/enableDiscreetLogin: false/' config.yaml
                sed -i 's/^  - 0\.0\.0\.0\/0$/  - 127.0.0.1/' config.yaml
                echo -e "${RED}${BOLD}>> 网络监听已关闭，仅限本机访问。${NC}"
                press_any_key
                ;;
            3)
                ip=$(get_lan_ipv4)
                if [ -n "$ip" ]; then
                    echo -e "${CYAN}=================================================${NC}"
                    echo -e "请在局域网内的其他设备浏览器中访问："
                    echo -e "${GREEN}${BOLD}http://$ip:8000/${NC}"
                    echo -e "${CYAN}=================================================${NC}"
                else
                    echo -e "${YELLOW}${BOLD}>> 未检测到可用的局域网地址。${NC}"
                    echo -e "${RED}${BOLD}>> 请确保本机已连接WiFi，并重试。${NC}"
                fi
                press_any_key
                ;;
            4)
                # 获取当前实际IP地址
                local current_ip=$(get_lan_ipv4)
                local ip_display
                if [ -n "$current_ip" ]; then
                    ip_display="${GREEN}${BOLD}http://$current_ip:8000/${NC}"
                else
                    ip_display="http://内网IP:8000/ ${YELLOW}${BOLD}(当前未检测到IP)${NC}"
                fi

                echo -e "${CYAN}${BOLD}==================================================${NC}"
                echo -e "${CYAN}${BOLD}SillyTavern 局域网连接指南${NC}"
                echo -e "${CYAN}${BOLD}==================================================${NC}\n"

                echo -e "${CYAN}${BOLD}一、准备工作${NC}"
                echo -e "  1. 确保 SillyTavern 已正确安装。"
                echo -e "  2. 本机（运行 SillyTavern）和其它访问设备（手机、电脑、平板等）需连接同一局域网（如同一个WiFi或一个热点）。\n"

                echo -e "${CYAN}${BOLD}二、操作顺序建议${NC}"
                echo -e "  ${BOLD}1. 开启网络监听（如已开启可跳过）${NC}"
                echo -e "    - 仅首次设置或曾关闭时需执行。\n"
                echo -e "  ${BOLD}2. 获取内网地址（如已知且无变动可跳过）${NC}"
                echo -e "    - 若设备重启、WiFi重连、网络切换，内网IP可能变动，需重新获取。\n"
                echo -e "  ${BOLD}3. 启动酒馆服务${NC}"
                echo -e "    - 返回主菜单，选择"启动酒馆"，务必保持终端窗口运行。\n"
                echo -e "  ${BOLD}4. 其他设备访问${NC}"
                echo -e "    - 在同网络下的手机、电脑等浏览器输入上一步获取的网址访问 SillyTavern。\n"

                echo -e "${CYAN}${BOLD}三、常见连接方式${NC}"
                echo -e "${CYAN}--------------------------------------------------${NC}"
                echo -e "${CYAN}${BOLD}方式一：两台设备连接同一WiFi/路由器${NC}"
                echo -e "  - 本机和目标设备都连同一WiFi路由器。"
                echo -e "  - 直接在浏览器输入 $ip_display 访问。\n"
                echo -e "${CYAN}${BOLD}方式二：目标设备连接本机热点${NC}"
                echo -e "  - 本机开启"个人热点"，目标设备连接该热点。"
                echo -e "  - 浏览器输入 $ip_display 访问。\n"
                echo -e "${CYAN}${BOLD}方式三：本机连接目标设备热点${NC}"
                echo -e "  - 目标设备开启热点，本机连接该热点。"
                echo -e "  - 浏览器输入 $ip_display 访问。\n"

                echo -e "${CYAN}${BOLD}四、常见问题与提示${NC}"
                echo -e "  · ${BOLD}获取不到内网IP：${NC} 请确认本机WiFi/热点已连接，可尝试断开重连。"
                echo -e "  · ${BOLD}外部设备无法访问：${NC} 请确保网络监听已开启，且两台设备在同一局域网/热点。"
                echo -e "  · ${BOLD}设备重启或网络切换：${NC} 需重新获取内网IP并用新地址访问。\n"

                echo -e "${CYAN}${BOLD}==================================================${NC}"
                press_any_key
                ;;
            *)
                echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1
                ;;
        esac
    done
}
