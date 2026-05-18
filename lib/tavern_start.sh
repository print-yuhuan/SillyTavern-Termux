#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 酒馆启动函数库
# 职责：启动 SillyTavern（单独启动 / 关联启动两种模式）
# =========================================================================

# =========================================================================
# 1. 启动酒馆
# =========================================================================
start_tavern() {
    echo -e "\n${CYAN}${BOLD}==== 启动 SillyTavern ====${NC}"

    # 依赖检测
    for dep in node npm git; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo -e "${RED}${BOLD}>> 检测到缺失依赖：$dep，请先修复依赖环境。${NC}"
            press_any_key; return
        fi
    done

    # 读取 START_MODE 变量
    if [ -f "$HOME/.env" ]; then
        source "$HOME/.env"
    else
        echo -e "${RED}${BOLD}>> [错误] 未找到 .env 配置文件。${NC}"
        press_any_key; return
    fi

    # 验证 START_MODE 值
    if [ -z "$START_MODE" ]; then
        echo -e "${RED}${BOLD}>> [错误] START_MODE 变量未定义，请检查 .env 文件。${NC}"
        press_any_key; return
    fi

    if [ "$START_MODE" != "1" ] && [ "$START_MODE" != "2" ]; then
        echo -e "${RED}${BOLD}>> [错误] START_MODE 变量值无效: $START_MODE${NC}"
        echo -e "${YELLOW}${BOLD}>> 有效值为: 1 (单独启动) 或 2 (关联启动)${NC}"
        echo -e "${YELLOW}${BOLD}>> 请通过「酒馆配置 -> 关联启动配置」修改设置。${NC}"
        press_any_key; return
    fi

    # 检测并清理大型日志文件
    LOG_FILE="$HOME/setup.log"
    if [ -f "$LOG_FILE" ]; then
        LOG_SIZE=$(stat -c%s "$LOG_FILE" 2>/dev/null || stat -f%z "$LOG_FILE" 2>/dev/null)
        if [ "$LOG_SIZE" -gt 5242880 ]; then  # 5MB = 5*1024*1024
            echo -e "${YELLOW}${BOLD}>> 检测到日志文件超过 5MB，正在清理...${NC}"
            rm -f "$LOG_FILE"
            touch "$LOG_FILE"
            echo -e "${GREEN}${BOLD}>> 日志文件已重置。${NC}"
        fi
    fi

	# 启用唤醒锁，防止设备在服务运行期间休眠
    if command -v termux-wake-lock >/dev/null 2>&1; then
        termux-wake-lock
		# 设置 trap 确保函数退出时自动解除唤醒锁
        trap 'command -v termux-wake-unlock >/dev/null 2>&1 && termux-wake-unlock' RETURN
    fi

    # SillyTavern 目录检测
    if [ -d "$HOME/SillyTavern" ]; then
        cd "$HOME/SillyTavern"

        # 根据 START_MODE 执行不同启动命令
        if [ "$START_MODE" = "1" ]; then
            echo -e "${CYAN}${BOLD}>> 启动模式: 单独启动 SillyTavern${NC}"
            pkill -f 'node.*server.js'
            if [ -f "start.sh" ]; then
                bash start.sh
            else
                npm start
            fi
        elif [ "$START_MODE" = "2" ]; then
            echo -e "${CYAN}${BOLD}>> 启动模式: 关联启动 (反代服务 + SillyTavern)${NC}"

            # 检测 Gemini-CLI-Termux 是否存在
            if [ ! -d "$HOME/Gemini-CLI-Termux" ]; then
                echo -e "${RED}${BOLD}>> [错误] 未检测到 Gemini-CLI-Termux 目录。${NC}"
                echo -e "${YELLOW}${BOLD}>> 请先安装 Gemini-CLI-Termux 或切换到模式1启动。${NC}"
                press_any_key; cd "$HOME"; return
            fi

            # 检测 run.py 是否存在
            if [ ! -f "$HOME/Gemini-CLI-Termux/run.py" ]; then
                echo -e "${RED}${BOLD}>> [错误] 未找到 Gemini-CLI-Termux/run.py 文件。${NC}"
                echo -e "${YELLOW}${BOLD}>> 请检查 Gemini-CLI-Termux 安装是否完整。${NC}"
                press_any_key; cd "$HOME"; return
            fi

            # 检测 Python 是否安装
            if ! command -v python >/dev/null 2>&1; then
                echo -e "${RED}${BOLD}>> [错误] 未检测到 Python，无法启动反代服务。${NC}"
                echo -e "${YELLOW}${BOLD}>> 请先安装 Python: pkg install python${NC}"
                press_any_key; cd "$HOME"; return
            fi

            # 杀死可能存在的旧进程
            pkill -f 'python.*run.py'
            pkill -f 'node.*server.js'

            # 启动反代服务(后台运行，输出到日志)
            echo -e "${CYAN}${BOLD}>> 正在启动 Gemini-CLI-Termux 反代服务...${NC}"
            python "$HOME/Gemini-CLI-Termux/run.py" > "$LOG_FILE" 2>&1 &

            # 等待反代服务启动
            sleep 2

            # 检测反代服务是否成功启动
            if pgrep -f "python.*run.py" >/dev/null; then
                echo -e "${GREEN}${BOLD}>> 反代服务已启动。${NC}"
            else
                echo -e "${YELLOW}${BOLD}>> 反代服务启动状态未知，请通过「关联启动配置 -> 查看反代日志」检查。${NC}"
            fi

            # 启动 SillyTavern
            echo -e "${CYAN}${BOLD}>> 正在启动 SillyTavern...${NC}"
            if [ -f "start.sh" ]; then
                bash start.sh
            else
                npm start
            fi
        fi

        press_any_key
        cd "$HOME"
    else
        echo -e "${RED}${BOLD}>> 未检测到 SillyTavern 目录。${NC}"
        sleep 2
    fi
}
