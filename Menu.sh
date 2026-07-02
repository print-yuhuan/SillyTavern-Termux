#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 菜单主脚本（Github）
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
BRIGHT_BLUE='\033[1;94m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m'

# ==== 版本与远程资源 ====
MENU_VERSION=20260702
UPDATE_DATE="2026-07-02"
UPDATE_CONTENT="
===============================================
SillyTavern-Termux 更新日志 2026-07-02
===============================================

本次更新围绕数据安全与稳定性进行全面加固。

───────────────────────────────────────────────
【数据安全】
───────────────────────────────────────────────
  ● 导入酒馆数据/本体流程重构
      - 先校验压缩包完整性，再解压到临时目录
      - 全部成功后才替换现有数据，损坏备份不再导致数据丢失
  ● 导出酒馆本体不再打包 node_modules
      - 导出更快、体积更小
      - 导入后首次启动会自动安装依赖

───────────────────────────────────────────────
【更新机制】
───────────────────────────────────────────────
  ● 版本号以脚本文件本体为准，更新失败不再误判为最新
  ● 脚本更新不再覆盖 .env，关联启动等本地配置不会丢失
  ● 自更新改为临时文件 + 原子替换，避免自我覆盖风险
  ● 移除 ping 网络检测，禁 ICMP 的网络也能正常检查更新

───────────────────────────────────────────────
【问题修复】
───────────────────────────────────────────────
  ✓ 字体下载增加 HTTP 错误检测，错误页面不再存为字体文件
  ✓ 修复依赖环境：镜像配置先检查后链接，并补装 zip
  ✓ 更新酒馆：远程分支缺失或代码更新失败时及时中止
  ✓ 关联启动：退出酒馆后自动关闭后台反代进程
  ✓ 安装 Discord 改用 termux-open，兼容新版 Android
  ✓ 修正多处提示文案中引号无法显示的问题

───────────────────────────────────────────────
【功能优化】
───────────────────────────────────────────────
  ● 依赖安装重试逻辑统一为公共函数
      - 首次安装不再强制清空 npm 缓存，失败重试时才清理
      - 安装参数增加 --prefer-offline，弱网环境更稳定
  ● 开启网络监听后增加设置密码的安全提醒
  ● 获取内网地址不再误返回移动数据 IP
  ● 配置类菜单操作改用绝对路径，不再改变当前工作目录

───────────────────────────────────────────────
【注意事项】
───────────────────────────────────────────────
  ⚠️ 导入备份时会临时占用与备份相当的额外存储空间
  ⚠️ 本体备份若不含依赖，恢复后首次启动需联网安装

===============================================
"
REMOTE_ENV_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/.env"
REMOTE_INSTALL_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh"
REMOTE_MENU_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Menu.sh"

# ==== 通用函数 ====
get_version() { [ -f "$1" ] && grep -E "^$2=" "$1" | head -n1 | cut -d'=' -f2 | tr -d '\r'; }
get_env_value() { [ -f "$1" ] && grep -E "^$2=" "$1" | head -n1 | cut -d'=' -f2- | tr -d '\r' | xargs; }
press_any_key() { echo -e "${CYAN}${BOLD}>> 按任意键返回菜单...${NC}"; read -n1 -s; }

# 获取局域网 IPv4 地址(优先 WiFi/以太网，排除 VPN 和回环地址)
get_lan_ipv4() {
    local ip iface

    # 检测是否支持 ip 命令
    if command -v ip >/dev/null 2>&1; then
        # 优先获取 WiFi/以太网接口地址，排除 VPN(tun) 地址
        while IFS= read -r iface; do
            case "$iface" in
                wlan*|eth*|en*)
                    ip=$(ip -4 -o addr show dev "$iface" scope global 2>/dev/null | awk '{print $4}' | cut -d'/' -f1 | head -n1)
                    if [ -n "$ip" ]; then
                        echo "$ip"
                        return 0
                    fi
                    ;;
            esac
        done < <(ip -4 -o addr show scope global 2>/dev/null | awk '{print $2}' | uniq)

        # 备用方案：获取任意非回环/VPN/蜂窝接口的地址（排除移动数据 IP）
        ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '!/ (lo|tun|ppp|rmnet|ccmni|usb)/ {print $4}' | cut -d'/' -f1 | head -n1)
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
    fi

    # 如果 ip 命令不可用或未找到地址，使用 ifconfig
    if command -v ifconfig >/dev/null 2>&1; then
        # 遍历 wlan0-wlan5 接口
        for i in $(seq 0 5); do
            ip=$(ifconfig 2>/dev/null | grep -A 1 "wlan$i" | grep "inet " | awk '{print $2}' | head -n1)
            if [ -n "$ip" ]; then
                echo "$ip"
                return 0
            fi
        done

        # 获取第一个非回环、非 tun 接口的地址
        ip=$(ifconfig 2>/dev/null | awk '
            /^[a-zA-Z0-9]+:/ {
                iface=$1
                sub(":", "", iface)
            }
            /inet / && $2 != "127.0.0.1" && iface !~ /^tun/ {
                print $2
                exit
            }')
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
    fi
    return 1
}

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
            echo -e "${CYAN}${BOLD}>> 请在弹出的窗口中点击“允许”授权，正在等待授权结果...${NC}"
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

# ==== SillyTavern 依赖安装（需在 SillyTavern 目录下调用）====
install_st_deps() {
    export NODE_ENV=production
    local retry_count=0 max_retries=3
    while [ $retry_count -lt $max_retries ]; do
        if [ $retry_count -eq 0 ]; then
            echo -e "${CYAN}${BOLD}>> 正在安装 SillyTavern 依赖，请耐心等待…${NC}"
        else
            echo -e "${YELLOW}${BOLD}>> 重试安装依赖（第 $retry_count 次）…${NC}"
        fi
        if npm install --no-audit --no-fund --loglevel=error --omit=dev --prefer-offline; then
            return 0
        fi
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo -e "${YELLOW}${BOLD}>> 依赖安装失败，正在清理缓存并准备重试…${NC}"
            [ -d node_modules ] && rm -rf node_modules
            [ -d "$HOME/.npm/_cacache" ] && npm cache clean --force
            sleep 3
        fi
    done
    return 1
}

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

            # SillyTavern 退出后同步关闭后台反代服务，避免进程残留
            echo -e "${CYAN}${BOLD}>> SillyTavern 已停止，正在关闭反代服务...${NC}"
            pkill -f 'python.*run.py' 2>/dev/null
        fi

        press_any_key
        cd "$HOME"
    else
        echo -e "${RED}${BOLD}>> 未检测到 SillyTavern 目录。${NC}"
        sleep 2
    fi
}

# =========================================================================
# 2. 更新酒馆
# =========================================================================
update_tavern() {
    echo -e "\n${CYAN}${BOLD}==== 更新 SillyTavern ====${NC}"
    if [ -d "$HOME/SillyTavern" ]; then
        cd "$HOME/SillyTavern"

        if [ ! -d ".git" ]; then
            echo -e "${RED}${BOLD}>> SillyTavern 目录不是有效的 Git 仓库。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        echo -e "${CYAN}${BOLD}>> 正在检查远程更新...${NC}"

        local_commit=$(git rev-parse HEAD 2>/dev/null)

        if ! git fetch origin 2>/dev/null; then
            echo -e "${RED}${BOLD}>> 无法连接到远程仓库，请检查网络连接。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        remote_commit=$(git rev-parse origin/release 2>/dev/null)

        if [ -z "$remote_commit" ]; then
            echo -e "${RED}${BOLD}>> 未找到远程 release 分支，请检查仓库状态。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        if [ "$local_commit" = "$remote_commit" ]; then
            echo -e "${GREEN}${BOLD}>> SillyTavern 已是最新版本，无需更新。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        commit_count=$(git rev-list --count HEAD..origin/release 2>/dev/null)
        if [ -n "$commit_count" ] && [ "$commit_count" -gt 0 ]; then
            echo -e "${YELLOW}${BOLD}>> 发现 $commit_count 个新提交，准备更新...${NC}"
        fi

        echo -e "${CYAN}${BOLD}>> 正在拉取最新代码...${NC}"
        if ! git reset --hard origin/release; then
            echo -e "${RED}${BOLD}>> 代码更新失败，已中止依赖重装。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        echo -e "${CYAN}${BOLD}>> 正在更新依赖模块...${NC}"
        export NODE_ENV=production
		
        if install_st_deps; then
            echo -e "${GREEN}${BOLD}>> SillyTavern 更新完成，代码和依赖均已更新。${NC}"
        else
            echo -e "${RED}${BOLD}>> 代码更新成功，但依赖安装失败，已重试 3 次。${NC}"
            echo -e "${YELLOW}${BOLD}>> 请检查网络连接后，手动执行依赖安装或重新尝试更新。${NC}"
        fi

        press_any_key
        cd "$HOME"
    else
        echo -e "${RED}${BOLD}>> 未检测到 SillyTavern 目录。${NC}"
        sleep 2
    fi
}

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
                ST_START="$HOME/SillyTavern/start.sh"
                if [ ! -d "$HOME/SillyTavern" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录。${NC}"; press_any_key; continue
                fi
                if [ ! -f "$ST_START" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 start.sh 文件，无法修改内存限制。${NC}"
                    press_any_key; continue
                fi
                [ ! -f "${ST_START}.bak" ] && cp "$ST_START" "${ST_START}.bak"

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

                if grep -q 'node --max-old-space-size=[0-9]\+ "server.js" "\$@"' "$ST_START"; then
                    sed -i "s/node --max-old-space-size=[0-9]\+ \"server.js\" \"\\\$@\"/node --max-old-space-size=${mem_limit} \"server.js\" \"\\\$@\"/" "$ST_START"
                    echo -e "${GREEN}${BOLD}>> 内存限制已设置为 ${mem_limit} MB。${NC}"
                elif grep -q 'node "server.js" "\$@"' "$ST_START"; then
                    sed -i "s/node \"server.js\" \"\\\$@\"/node --max-old-space-size=${mem_limit} \"server.js\" \"\\\$@\"/" "$ST_START"
                    echo -e "${GREEN}${BOLD}>> 已插入内存限制参数，现为 ${mem_limit} MB。${NC}"
                else
                    echo -e "${CYAN}${BOLD}>> 未检测到标准 node 启动命令，未做更改。${NC}"
                    press_any_key; continue
                fi
                press_any_key
                ;;
            3) startup_association_menu ;;
            4)
                ST_START="$HOME/SillyTavern/start.sh"
                if [ ! -d "$HOME/SillyTavern" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录。${NC}"; press_any_key; continue
                fi
                if [ ! -f "${ST_START}.bak" ]; then
                    echo -e "${MAGENTA}${BOLD}>> 未找到 start.sh.bak 备份文件，无法恢复。${NC}"
                    press_any_key; continue
                fi
                cp "${ST_START}.bak" "$ST_START"
                echo -e "${YELLOW}${BOLD}>> 启动文件已恢复为初始版本。${NC}"
                press_any_key
                ;;
            5)
                ST_CONFIG="$HOME/SillyTavern/config.yaml"
                if [ ! -d "$HOME/SillyTavern" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录。${NC}"; press_any_key; continue
                fi
                if [ ! -f "${ST_CONFIG}.bak" ]; then
                    echo -e "${BRIGHT_MAGENTA}${BOLD}>> 未找到 config.yaml.bak 备份文件，无法恢复。${NC}"
                    press_any_key; continue
                fi
                cp "${ST_CONFIG}.bak" "$ST_CONFIG"
                echo -e "${YELLOW}${BOLD}>> 配置文件已恢复为初始状态。${NC}"
                press_any_key
                ;;
            *) 
                echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 
                ;;
        esac
    done
}

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
                ST_CONFIG="$HOME/SillyTavern/config.yaml"
                if [ ! -d "$HOME/SillyTavern" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录，无法操作。${NC}"; press_any_key; continue
                fi
                if [ ! -f "$ST_CONFIG" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 config.yaml 文件，无法开启监听。${NC}"
                    press_any_key; continue
                fi
                [ ! -f "${ST_CONFIG}.bak" ] && cp "$ST_CONFIG" "${ST_CONFIG}.bak"
                sed -i 's/^listen: false$/listen: true/' "$ST_CONFIG"
                sed -i 's/^enableUserAccounts: false$/enableUserAccounts: true/' "$ST_CONFIG"
                sed -i 's/^enableDiscreetLogin: false$/enableDiscreetLogin: true/' "$ST_CONFIG"
                sed -i 's/^  - 127\.0\.0\.1$/  - 0.0.0.0\/0/' "$ST_CONFIG"
                echo -e "${GREEN}${BOLD}>> 网络监听已开启，允许外部设备访问。${NC}"
                echo -e "${RED}${BOLD}>> 安全提醒：默认用户没有密码！${NC}"
                echo -e "${YELLOW}${BOLD}>> 请启动酒馆后在「用户设置 → 管理用户」中为账户设置密码，${NC}"
                echo -e "${YELLOW}${BOLD}>> 否则同一网络内的任何人都可访问你的聊天记录与 API 密钥。${NC}"
                press_any_key
                ;;
            2)
                ST_CONFIG="$HOME/SillyTavern/config.yaml"
                if [ ! -d "$HOME/SillyTavern" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未检测到 SillyTavern 目录，无法操作。${NC}"; press_any_key; continue
                fi
                if [ ! -f "$ST_CONFIG" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 config.yaml 文件，无法关闭监听。${NC}"
                    press_any_key; continue
                fi
                [ ! -f "${ST_CONFIG}.bak" ] && cp "$ST_CONFIG" "${ST_CONFIG}.bak"
                sed -i 's/^listen: true$/listen: false/' "$ST_CONFIG"
                sed -i 's/^enableUserAccounts: true$/enableUserAccounts: false/' "$ST_CONFIG"
                sed -i 's/^enableDiscreetLogin: true$/enableDiscreetLogin: false/' "$ST_CONFIG"
                sed -i 's/^  - 0\.0\.0\.0\/0$/  - 127.0.0.1/' "$ST_CONFIG"
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
                echo -e "    - 返回主菜单，选择“启动酒馆”，务必保持终端窗口运行。\n"
                echo -e "  ${BOLD}4. 其他设备访问${NC}"
                echo -e "    - 在同网络下的手机、电脑等浏览器输入上一步获取的网址访问 SillyTavern。\n"

                echo -e "${CYAN}${BOLD}三、常见连接方式${NC}"
                echo -e "${CYAN}--------------------------------------------------${NC}"
                echo -e "${CYAN}${BOLD}方式一：两台设备连接同一WiFi/路由器${NC}"
                echo -e "  - 本机和目标设备都连同一WiFi路由器。"
                echo -e "  - 直接在浏览器输入 $ip_display 访问。\n"
                echo -e "${CYAN}${BOLD}方式二：目标设备连接本机热点${NC}"
                echo -e "  - 本机开启“个人热点”，目标设备连接该热点。"
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

# =========================================================================
# 关联启动配置菜单
# =========================================================================
startup_association_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 关联启动配置 ====${NC}"

        # 显示当前配置状态
        if [ -f "$HOME/.env" ]; then
            source "$HOME/.env"
            if [ "$START_MODE" = "1" ]; then
                echo -e "${YELLOW}${BOLD}当前状态: 单独启动模式${NC}"
            elif [ "$START_MODE" = "2" ]; then
                echo -e "${GREEN}${BOLD}当前状态: 关联启动模式${NC}"
            else
                echo -e "${RED}${BOLD}当前状态: 配置异常 (START_MODE=$START_MODE)${NC}"
            fi
        else
            echo -e "${RED}${BOLD}当前状态: 配置文件缺失${NC}"
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

                # 检测 .env 文件
                if [ ! -f "$HOME/.env" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 .env 配置文件。${NC}"
                    press_any_key; continue
                fi

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
                if grep -q "^START_MODE=" "$HOME/.env"; then
                    sed -i 's/^START_MODE=.*/START_MODE=2/' "$HOME/.env"
                    echo -e "${GREEN}${BOLD}>> 关联启动已开启。${NC}"
                    echo -e "${CYAN}${BOLD}>> 下次启动酒馆时将同时启动 Gemini-CLI-Termux 反代服务。${NC}"
                else
                    echo -e "${RED}${BOLD}>> [错误] .env 文件中未找到 START_MODE 变量。${NC}"
                    echo -e "${YELLOW}${BOLD}>> 正在添加配置...${NC}"
                    echo "START_MODE=2" >> "$HOME/.env"
                    echo -e "${GREEN}${BOLD}>> 关联启动已开启。${NC}"
                fi
                press_any_key
                ;;
            2)
                # 关闭关联启动
                echo -e "\n${CYAN}${BOLD}==== 关闭关联启动 ====${NC}"

                # 检测 .env 文件
                if [ ! -f "$HOME/.env" ]; then
                    echo -e "${RED}${BOLD}>> [错误] 未找到 .env 配置文件。${NC}"
                    press_any_key; continue
                fi

                # 修改 START_MODE 为 1
                if grep -q "^START_MODE=" "$HOME/.env"; then
                    sed -i 's/^START_MODE=.*/START_MODE=1/' "$HOME/.env"
                    echo -e "${GREEN}${BOLD}>> 关联启动已关闭。${NC}"
                    echo -e "${CYAN}${BOLD}>> 下次启动酒馆时将只启动 SillyTavern。${NC}"
                else
                    echo -e "${RED}${BOLD}>> [错误] .env 文件中未找到 START_MODE 变量。${NC}"
                    echo -e "${YELLOW}${BOLD}>> 正在添加配置...${NC}"
                    echo "START_MODE=1" >> "$HOME/.env"
                    echo -e "${GREEN}${BOLD}>> 关联启动已关闭。${NC}"
                fi
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

# =========================================================================
# 4. 酒馆插件
# =========================================================================
plugin_install_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 插件安装 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 酒馆助手      ${YELLOW}${BOLD}（多功能扩展）${NC}"
        echo -e "${BLUE}${BOLD}2. 记忆表格      ${GREEN}${BOLD}（结构化记忆）${NC}"
        echo -e "${MAGENTA}${BOLD}3. 自定模型      ${CYAN}${BOLD}（自定义模型）${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-3）：${NC}"
        read -n1 plugin_choice; echo
        case "$plugin_choice" in
            0) break ;;
            1)
                clear
                echo -e "${GREEN}${BOLD}====== 酒馆助手 ======${NC}\n"
                echo -e "${YELLOW}${BOLD}仓库地址：${NC}\nhttps://github.com/N0VI028/JS-Slash-Runner\n"
                echo -e "${CYAN}${BOLD}插件简介：${NC}"
                echo -e "${GREEN}· 酒馆助手是一款专为 SillyTavern 打造的多功能扩展插件，带来前所未有的交互体验"
                echo -e "· 支持对话中渲染多样交互元素，从简单按钮到自定义游戏界面应有尽有"
                echo -e "· 可使用 jQuery 操作 SillyTavern DOM，自由修改样式与事件绑定"
                echo -e "· 作为后端中转，轻松联动外部应用，实现数据交换与能力扩展${NC}\n"
                echo -e "${BLUE}${BOLD}核心亮点：${NC}"
                echo -e "${WHITE}- 灵活丰富的前端交互，极大提升对话玩法"
                echo -e "- 连接外部世界，让 SillyTavern 变得更强大"
                echo -e "- 支持通过 iframe 隔离安全运行自定义 JS 脚本${NC}\n"
                echo -e "${YELLOW}${BOLD}安全提示：${NC}"
                echo -e "${WHITE}· 插件支持执行自定义 JavaScript 脚本，存在一定安全风险。"
                echo -e "· 恶意脚本可能窃取 API 密钥、聊天记录，或篡改设置。"
                echo -e "· 请仅运行来源可信、内容可控的脚本，务必理解其功能和影响。"
                echo -e "· 因第三方脚本带来的任何损失，插件及作者概不负责。${NC}\n"
                echo -e "${CYAN}${BOLD}插件名称：酒馆助手${NC}"
                echo -e "${GREEN}${BOLD}开发作者：KAKAA、青空莉想做舞台少女的狗${NC}"
                echo -e "${MAGENTA}${BOLD}© 2025 N0VI028. 保留所有权利。${NC}\n"
                echo -ne "${YELLOW}${BOLD}是否安装酒馆助手？(y/n)：${NC}"
                read -n1 ans; echo
                if [[ "$ans" =~ [yY] ]]; then
                    PLUGIN_DIR="$HOME/SillyTavern/public/scripts/extensions/third-party/JS-Slash-Runner"
                    if [ -d "$PLUGIN_DIR" ]; then
                        echo -e "${YELLOW}${BOLD}>> 插件已存在，无需重复安装。${NC}"
                    else
                        git clone https://github.com/N0VI028/JS-Slash-Runner "$PLUGIN_DIR" \
                            && echo -e "${GREEN}${BOLD}>> 安装成功。${NC}" \
                            || echo -e "${RED}${BOLD}>> 安装失败，请检查网络。${NC}"
                    fi
                    press_any_key
                fi
                ;;
            2)
                clear
                echo -e "${BLUE}${BOLD}====== 记忆表格 ======${NC}\n"
                echo -e "${YELLOW}${BOLD}仓库地址：${NC}\nhttps://github.com/muyoou/st-memory-enhancement\n"
                echo -e "${CYAN}${BOLD}插件简介：${NC}"
                echo -e "${WHITE}✨ 记忆表格插件为 SillyTavern 注入强大的结构化长期记忆，助您在角色扮演场景中，实现更真实与连贯的 AI 推演。"
                echo -e "支持对角色设定、关键事件、重要物品等内容的自定义管理，显著提升记忆和情境还原。${NC}\n"
                echo -e "${BLUE}${BOLD}核心优势：${NC}"
                echo -e "${GREEN}😊 用户友好：通过直观表格轻松查看与编辑，全面掌控角色记忆"
                echo -e "🛠️ 创作者友好：灵活导出/分享配置，JSON 文件自定义结构，满足多样创作"
                echo -e "📅 结构化存储：强大表格系统，未来支持节点编辑器和多模板管理"
                echo -e "🤖 智能提示词：自动生成并注入提示词，深度集成世界书或预设"
                echo -e "🖼️ 数据推送：表格内容可推送至聊天界面，支持自定义展示样式"
                echo -e "📦 便捷导出：丰富自定义选项，支持模板导出与分享"
                echo -e "🚀 分步操作：结合主副 API，智能分配任务，高效管理长期记忆${NC}\n"
                echo -e "${YELLOW}${BOLD}使用须知：${NC}"
                echo -e "${WHITE}· 插件仅适用于 SillyTavern 的“聊天补全模式”"
                echo -e "· 插件界面简洁直观，上手快速，适合所有用户${NC}\n"
                echo -e "${CYAN}${BOLD}插件名称：记忆表格${NC}"
                echo -e "${GREEN}${BOLD}开发作者：木悠${NC}"
                echo -e "${YELLOW}${BOLD}插件交流群：1030109849 / 1045423946${NC}"
                echo -e "${MAGENTA}${BOLD}© 2025 muyoou. 保留所有权利。${NC}\n"
                echo -ne "${YELLOW}${BOLD}是否安装记忆表格？(y/n)：${NC}"
                read -n1 ans; echo
                if [[ "$ans" =~ [yY] ]]; then
                    PLUGIN_DIR="$HOME/SillyTavern/public/scripts/extensions/third-party/st-memory-enhancement"
                    if [ -d "$PLUGIN_DIR" ]; then
                        echo -e "${YELLOW}${BOLD}>> 插件已存在，无需重复安装。${NC}"
                    else
                        git clone https://github.com/muyoou/st-memory-enhancement "$PLUGIN_DIR" \
                            && echo -e "${GREEN}${BOLD}>> 安装成功。${NC}" \
                            || echo -e "${RED}${BOLD}>> 安装失败，请检查网络。${NC}"
                    fi
                    press_any_key
                fi
                ;;
            3)
                clear
                echo -e "${MAGENTA}${BOLD}====== 自定模型 ======${NC}\n"
                echo -e "${YELLOW}${BOLD}仓库地址：${NC}\nhttps://github.com/LenAnderson/SillyTavern-CustomModels\n"
                echo -e "${CYAN}${BOLD}插件简介：${NC}"
                echo -e "${WHITE}自定模型插件可为 SillyTavern 的 OpenAI、Claude 及 Google/Gemini 连接添加自定义模型名称，让您轻松扩展与管理各类模型，对话体验更加灵活丰富。${NC}\n"
                echo -e "${BLUE}${BOLD}主要特性：${NC}"
                echo -e "${GREEN}· 支持用户自定义添加和切换模型名称"
                echo -e "· 兼容 OpenAI、Claude、Google/Gemini 多种对接方式"
                echo -e "· 简化模型管理，满足多样需求，自由扩展 AI 能力${NC}\n"
                echo -e "${CYAN}${BOLD}插件名称：自定模型${NC}"
                echo -e "${GREEN}${BOLD}开发作者：LenAnderson${NC}"
                echo -e "${MAGENTA}${BOLD}© 2025 LenAnderson. 保留所有权利。${NC}\n"
                echo -ne "${YELLOW}${BOLD}是否安装自定模型？(y/n)：${NC}"
                read -n1 ans; echo
                if [[ "$ans" =~ [yY] ]]; then
                    PLUGIN_DIR="$HOME/SillyTavern/public/scripts/extensions/third-party/SillyTavern-CustomModels"
                    if [ -d "$PLUGIN_DIR" ]; then
                        echo -e "${YELLOW}${BOLD}>> 插件已存在，无需重复安装。${NC}"
                    else
                        git clone https://github.com/LenAnderson/SillyTavern-CustomModels "$PLUGIN_DIR" \
                            && echo -e "${GREEN}${BOLD}>> 安装成功。${NC}" \
                            || echo -e "${RED}${BOLD}>> 安装失败，请检查网络。${NC}"
                    fi
                    press_any_key
                fi
                ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

plugin_uninstall_menu() {
    local PLUGIN_ROOT="$HOME/SillyTavern/public/scripts/extensions/third-party"
    declare -A plugin_name_map=(
        [JS-Slash-Runner]="酒馆助手"
        [st-memory-enhancement]="记忆表格"
        [SillyTavern-CustomModels]="自定模型"
    )
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 插件卸载 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        if [ ! -d "$PLUGIN_ROOT" ]; then
            echo -e "${YELLOW}${BOLD}>> 插件目录不存在，无插件可卸载。${NC}"
            press_any_key; break
        fi
        mapfile -t plugin_dirs < <(find "$PLUGIN_ROOT" -mindepth 1 -maxdepth 1 -type d | sort)
        if [ ${#plugin_dirs[@]} -eq 0 ]; then
            echo -e "${YELLOW}${BOLD}>> 未检测到已安装插件。${NC}"
            press_any_key; break
        fi
        for i in "${!plugin_dirs[@]}"; do
            raw_name=$(basename "${plugin_dirs[$i]}")
            zh_name="${plugin_name_map[$raw_name]:-$raw_name}"
            echo -e "${BLUE}${BOLD}$((i+1)). ${GREEN}${BOLD}${zh_name}${NC}"
        done
        echo -e "${CYAN}${BOLD}请输入要卸载的插件序号后回车（或0返回）：${NC}"
        read -r idx
        if [[ "$idx" == "0" ]]; then
            break
        fi
        if [[ "$idx" =~ ^[1-9][0-9]*$ ]] && [ "$idx" -le "${#plugin_dirs[@]}" ]; then
            raw_name=$(basename "${plugin_dirs[$((idx-1))]}")
            zh_name="${plugin_name_map[$raw_name]:-$raw_name}"
            echo -ne "${YELLOW}${BOLD}是否卸载 ${zh_name}？(y/n)：${NC}"
            read -n1 ans; echo
            if [[ "$ans" =~ [yY] ]]; then
                rm -rf "${plugin_dirs[$((idx-1))]}"
                echo -e "${GREEN}${BOLD}>> 插件 ${zh_name} 已卸载。${NC}"
            else
                echo -e "${YELLOW}${BOLD}>> 已取消卸载。${NC}"
            fi
            press_any_key
        else
            echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"
            sleep 1
        fi
    done
}

plugin_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 酒馆插件 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 安装插件${NC}"
        echo -e "${RED}${BOLD}2. 卸载插件${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-2）：${NC}"
        read -n1 sub_choice; echo
        case "$sub_choice" in
            0) break ;;
            1) plugin_install_menu ;;
            2) plugin_uninstall_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

# =========================================================================
# 5. 系统维护
# =========================================================================
show_dependencies() {
    echo -e "\n${CYAN}${BOLD}==== 依赖版本信息 ====${NC}"
    echo -ne "${BLUE}${BOLD}git:   ${NC}"; command -v git >/dev/null 2>&1 && git --version || echo -e "${RED}${BOLD}未安装${NC}"
    echo -ne "${GREEN}${BOLD}node:  ${NC}"; command -v node >/dev/null 2>&1 && node -v || echo -e "${RED}${BOLD}未安装${NC}"
    echo -ne "${MAGENTA}${BOLD}npm:   ${NC}"; command -v npm >/dev/null 2>&1 && npm -v || echo -e "${RED}${BOLD}未安装${NC}"
    echo -ne "${YELLOW}${BOLD}curl:  ${NC}"; command -v curl >/dev/null 2>&1 && curl --version | head -n1 || echo -e "${RED}${BOLD}未安装${NC}"
    echo -e "${CYAN}${BOLD}======================${NC}"
    press_any_key
}

fix_dependencies() {
    echo -e "\n${CYAN}${BOLD}==== 修复依赖环境 ====${NC}"
    mirror_source="$PREFIX/etc/termux/mirrors/europe/packages.termux.dev"
    mirror_target="$PREFIX/etc/termux/chosen_mirrors"
    if [ -f "$mirror_source" ]; then
        ln -sf "$mirror_source" "$mirror_target"
    else
        echo -e "${YELLOW}${BOLD}>> 未检测到官方镜像配置，保留当前镜像配置。${NC}"
    fi
    pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    for dep in git curl zip unzip; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo -e "${YELLOW}${BOLD}>> 检测到未安装：$dep，正在安装...${NC}"
            pkg install -y $dep
        else
            echo -e "${GREEN}${BOLD}>> $dep 已安装，跳过。${NC}"
        fi
    done
    if ! command -v node >/dev/null 2>&1; then
        if pkg list-all | grep -q '^nodejs-lts/'; then
            echo -e "${MAGENTA}${BOLD}>> 检测到未安装：node，正在安装 nodejs-lts...${NC}"
            pkg install -y nodejs-lts || pkg install -y nodejs
        else
            echo -e "${MAGENTA}${BOLD}>> 检测到未安装：node，正在安装 nodejs...${NC}"
            pkg install -y nodejs
        fi
    else
        echo -e "${GREEN}${BOLD}>> node 已安装，跳过。${NC}"
    fi
    npm config set prefix "$PREFIX"
    echo -e "${GREEN}${BOLD}>> 依赖修复完成。${NC}"
    press_any_key
}

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
    echo -e "${CYAN}${BOLD}>> 正在打包酒馆本体（已排除 node_modules，导入后首次启动会自动安装依赖）...${NC}"
    zip -r "SillyTavern_${now}.zip" SillyTavern -x "SillyTavern/node_modules/*"
    mv "SillyTavern_${now}.zip" "$BACKUP_DIR/" 2>/dev/null \
        && echo -e "${GREEN}${BOLD}>> 导出完成，已保存到 SillyTavern 文件夹。${NC}" \
        || echo -e "${RED}${BOLD}>> 移动压缩包失败，请手动查找。${NC}"
    press_any_key
}

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

            # 检查备份文件中包含哪些目录（unzip -l 的 Name 列前必有空白，避免子串误判）
            has_data_in_zip=$(unzip -l "$selected_file" 2>/dev/null | grep -Ec '[[:space:]]data/')
            has_public_in_zip=$(unzip -l "$selected_file" 2>/dev/null | grep -Ec '[[:space:]]public/')

            if [ "$has_data_in_zip" -eq 0 ] && [ "$has_public_in_zip" -eq 0 ]; then
                echo -e "${YELLOW}${BOLD}>> 警告：备份文件中未检测到 data 或 public 目录。${NC}"
                press_any_key; return
            fi

            dirs_info=""
            [ "$has_data_in_zip" -gt 0 ] && dirs_info="${dirs_info}data "
            [ "$has_public_in_zip" -gt 0 ] && dirs_info="${dirs_info}public "

            echo -e "${YELLOW}${BOLD}>> 警告：将要覆盖以下目录：${dirs_info}${NC}"
            echo -e "${YELLOW}${BOLD}>> 继续操作将删除这些目录并从备份恢复。${NC}"
            echo -e "${YELLOW}${BOLD}>> 是否确认覆盖？(y/n)：${NC}\c"
            read -n1 confirm; echo
            if ! [[ "$confirm" =~ [yY] ]]; then
                echo -e "${YELLOW}${BOLD}>> 已取消恢复操作。${NC}"
                press_any_key; return
            fi

            # 先校验、后解压到临时目录，全部成功后才替换现有数据
            echo -e "${CYAN}${BOLD}>> 正在校验备份文件完整性...${NC}"
            if ! unzip -t "$selected_file" >/dev/null 2>&1; then
                echo -e "${RED}${BOLD}>> 备份文件已损坏，已中止恢复（未改动现有数据）。${NC}"
                press_any_key; return
            fi

            TMP_RESTORE=$(mktemp -d "$HOME/.st_restore.XXXXXX") || {
                echo -e "${RED}${BOLD}>> 创建临时目录失败，已中止恢复。${NC}"
                press_any_key; return
            }
            echo -e "${CYAN}${BOLD}>> 正在从 $(basename "$selected_file") 解压 ${dirs_info}目录...${NC}"
            if ! unzip -o "$selected_file" -d "$TMP_RESTORE" >/dev/null 2>&1; then
                rm -rf "$TMP_RESTORE"
                echo -e "${RED}${BOLD}>> 解压失败，已中止恢复（未改动现有数据）。${NC}"
                press_any_key; return
            fi

            restored=""
            for d in data public; do
                if [ -d "$TMP_RESTORE/$d" ]; then
                    rm -rf "$HOME/SillyTavern/$d"
                    mv "$TMP_RESTORE/$d" "$HOME/SillyTavern/$d"
                    restored="${restored}$d "
                fi
            done
            rm -rf "$TMP_RESTORE"

            if [ -n "$restored" ]; then
                echo -e "${GREEN}${BOLD}>> 恢复成功（${restored}）！建议重启 SillyTavern 以应用更改。${NC}"
            else
                echo -e "${YELLOW}${BOLD}>> 压缩包中未找到顶层 data/public 目录，未做任何更改。${NC}"
            fi
            press_any_key; return
        else
            echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"
            sleep 1
        fi
    done
}

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
                echo -e ">> 继续操作将删除该目录并从备份恢复。"
                echo -e ">> 是否确认覆盖？(y/n)：${NC}\c"
                read -n1 confirm; echo
                if ! [[ "$confirm" =~ [yY] ]]; then
                    echo -e "${YELLOW}${BOLD}>> 已取消恢复操作。${NC}"
                    press_any_key; return
                fi
            fi

            # 先校验、后解压到临时目录，全部成功后才替换现有目录
            echo -e "${CYAN}${BOLD}>> 正在校验备份文件完整性...${NC}"
            if ! unzip -t "$selected_file" >/dev/null 2>&1; then
                echo -e "${RED}${BOLD}>> 备份文件已损坏，已中止恢复（未改动现有数据）。${NC}"
                press_any_key; return
            fi

            TMP_RESTORE=$(mktemp -d "$HOME/.st_restore.XXXXXX") || {
                echo -e "${RED}${BOLD}>> 创建临时目录失败，已中止恢复。${NC}"
                press_any_key; return
            }
            echo -e "${CYAN}${BOLD}>> 正在从 $(basename "$selected_file") 解压...${NC}"
            if ! unzip -o "$selected_file" -d "$TMP_RESTORE" >/dev/null 2>&1; then
                rm -rf "$TMP_RESTORE"
                echo -e "${RED}${BOLD}>> 解压失败，已中止恢复（未改动现有数据）。${NC}"
                press_any_key; return
            fi
            if [ ! -d "$TMP_RESTORE/SillyTavern" ]; then
                rm -rf "$TMP_RESTORE"
                echo -e "${RED}${BOLD}>> 压缩包内未找到 SillyTavern 目录，已中止恢复（未改动现有数据）。${NC}"
                press_any_key; return
            fi

            rm -rf "$TARGET_DIR"
            mv "$TMP_RESTORE/SillyTavern" "$TARGET_DIR"
            rm -rf "$TMP_RESTORE"
            echo -e "${GREEN}${BOLD}>> 恢复成功！建议重启 SillyTavern 以应用更改。${NC}"
            echo -e "${YELLOW}${BOLD}>> 若该备份不含依赖(node_modules)，首次启动时将自动安装，请保持网络畅通。${NC}"
            press_any_key; return
        else
            echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"
            sleep 1
        fi
    done
}

# =========================================================================
# 5.7 酒馆版本切换
# =========================================================================
show_version_tags() {
    echo -e "\n${CYAN}${BOLD}==== 查看版本标签 ====${NC}"

    # 检查 SillyTavern 目录
    if [ ! -d "$HOME/SillyTavern" ]; then
        echo -e "${RED}${BOLD}>> SillyTavern 目录不存在，无法查看版本标签。${NC}"
        press_any_key
        return
    fi

    cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> 进入 SillyTavern 目录失败。${NC}"; press_any_key; return; }

    # 检查 Git 仓库
    if [ ! -d ".git" ]; then
        echo -e "${RED}${BOLD}>> SillyTavern 目录不是有效的 Git 仓库。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 检查 git 命令
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 检测到 git 命令不可用，请先修复依赖环境。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 获取当前版本
    current_version=$(git describe --tags --exact-match 2>/dev/null || echo "release 分支")
    echo -e "${YELLOW}${BOLD}>> 当前版本：${current_version}${NC}\n"

    # 尝试更新标签列表
    echo -e "${CYAN}${BOLD}>> 正在获取最新版本标签...${NC}"
    if git fetch --tags 2>/dev/null; then
        echo -e "${GREEN}${BOLD}>> 标签列表已更新。${NC}\n"
    else
        echo -e "${YELLOW}${BOLD}>> 无法连接到远程仓库，显示本地标签。${NC}\n"
    fi

    # 列出所有标签
    tag_count=$(git tag | wc -l)
    if [ "$tag_count" -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到任何版本标签。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    echo -e "${CYAN}${BOLD}==== 可用版本标签列表 ====${NC}"
    git --no-pager tag --sort=creatordate --format='%(creatordate:short) %(color:bold green)%(refname:short)%(color:reset)' --color=always \
    | awk '{printf "\033[1;36m%2d\033[0m %s\n", NR, $0}'
    echo -e "${CYAN}${BOLD}============================${NC}"

    press_any_key
    cd "$HOME"
}

switch_tavern_version() {
    echo -e "\n${CYAN}${BOLD}==== 切换酒馆版本 ====${NC}"

    # 检查 SillyTavern 目录
    if [ ! -d "$HOME/SillyTavern" ]; then
        echo -e "${RED}${BOLD}>> SillyTavern 目录不存在，无法切换版本。${NC}"
        press_any_key
        return
    fi

    cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> 进入 SillyTavern 目录失败。${NC}"; press_any_key; return; }

    # 检查 Git 仓库
    if [ ! -d ".git" ]; then
        echo -e "${RED}${BOLD}>> SillyTavern 目录不是有效的 Git 仓库。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 检查必要命令
    for cmd in node npm git; do
        if ! command -v $cmd >/dev/null 2>&1; then
            echo -e "${RED}${BOLD}>> 检测到缺失依赖：$cmd，请先修复依赖环境。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi
    done

    # 检查未提交的更改
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${YELLOW}${BOLD}>> 警告：检测到未提交的更改，切换版本将丢失这些更改！${NC}"
        echo -ne "${YELLOW}${BOLD}是否继续？(y/n)：${NC}"
        read -n1 confirm; echo
        if ! [[ "$confirm" =~ [yY] ]]; then
            echo -e "${YELLOW}${BOLD}>> 已取消版本切换。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi
    fi

    # 获取当前版本
    current_version=$(git describe --tags --exact-match 2>/dev/null || echo "release 分支")
    echo -e "${YELLOW}${BOLD}>> 当前版本：${current_version}${NC}\n"

    # 尝试更新标签列表
    echo -e "${CYAN}${BOLD}>> 正在获取最新版本标签...${NC}"
    git fetch --tags 2>/dev/null

    # 列出所有标签
    tag_count=$(git tag | wc -l)
    if [ "$tag_count" -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到任何版本标签，无法切换。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    echo -e "${CYAN}${BOLD}==== 可用版本标签列表 ====${NC}"
    git --no-pager tag --sort=creatordate --format='%(creatordate:short) %(color:bold green)%(refname:short)%(color:reset)' --color=always \
    | awk '{printf "\033[1;36m%2d\033[0m %s\n", NR, $0}'
    echo -e "${CYAN}${BOLD}============================${NC}"

    # 用户选择版本
    while true; do
        echo -ne "${CYAN}${BOLD}请输入版本序号后回车（或输入0返回）：${NC}"
        read -r input_number

        if [[ "$input_number" == "0" ]]; then
            echo -e "${YELLOW}${BOLD}>> 已取消版本切换。${NC}"
            press_any_key
            cd "$HOME"
            return
        fi

        if ! [[ "$input_number" =~ ^[1-9][0-9]*$ ]]; then
            echo -e "${RED}${BOLD}>> 输入无效，请输入有效的数字。${NC}"
            continue
        fi

        if [ "$input_number" -gt "$tag_count" ]; then
            echo -e "${RED}${BOLD}>> 序号超出范围，请重新输入。${NC}"
            continue
        fi

        break
    done

    # 获取选中的标签名
    selected_tag=$(git tag --sort=creatordate | sed -n "${input_number}p")

    if [ -z "$selected_tag" ]; then
        echo -e "${RED}${BOLD}>> 获取标签失败，请重试。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 二次确认
    echo -e "${YELLOW}${BOLD}>> 即将切换到版本：${selected_tag}${NC}"
    echo -ne "${YELLOW}${BOLD}确认切换？(y/n)：${NC}"
    read -n1 confirm; echo
    if ! [[ "$confirm" =~ [yY] ]]; then
        echo -e "${YELLOW}${BOLD}>> 已取消版本切换。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    # 执行版本切换
    echo -e "${CYAN}${BOLD}>> 正在切换到版本 ${selected_tag}...${NC}"
    if ! git checkout -f tags/${selected_tag} 2>&1; then
        echo -e "${RED}${BOLD}>> 版本切换失败，请检查错误信息。${NC}"
        press_any_key
        cd "$HOME"
        return
    fi

    echo -e "${GREEN}${BOLD}>> 版本切换成功。${NC}"

    # 重新安装依赖
    echo -e "${CYAN}${BOLD}>> 正在重新安装依赖模块...${NC}"
    export NODE_ENV=production

    if install_st_deps; then
        echo -e "${GREEN}${BOLD}>> 版本切换完成！当前版本：${selected_tag}${NC}"
        echo -e "${GREEN}${BOLD}>> 依赖已重新安装，可以正常使用。${NC}"
    else
        echo -e "${RED}${BOLD}>> 版本已切换，但依赖安装失败，已重试 3 次。${NC}"
        echo -e "${YELLOW}${BOLD}>> 请检查网络连接，或稍后在系统维护中选择“修复依赖环境”。${NC}"
    fi

    press_any_key
    cd "$HOME"
}

show_version_switch_help() {
    echo -e "${CYAN}${BOLD}==================================================${NC}"
    echo -e "${CYAN}${BOLD}SillyTavern 版本切换指南${NC}"
    echo -e "${CYAN}${BOLD}==================================================${NC}\n"

    echo -e "${CYAN}${BOLD}一、功能说明${NC}"
    echo -e "  SillyTavern 采用 Git 版本管理，项目维护者会为稳定版本打上标签。"
    echo -e "  本功能允许您在不同版本间自由切换，方便测试或回退到稳定版本。\n"

    echo -e "${CYAN}${BOLD}二、操作流程${NC}"
    echo -e "  ${BOLD}1. 查看版本标签${NC}"
    echo -e "    - 列出所有可用的版本标签及发布日期"
    echo -e "    - 序号标记方便快速选择"
    echo -e "    - 显示当前所在版本\n"

    echo -e "  ${BOLD}2. 切换酒馆版本${NC}"
    echo -e "    - 输入对应序号切换到目标版本"
    echo -e "    - 自动重新安装该版本的依赖"
    echo -e "    - 支持二次确认，避免误操作\n"

    echo -e "${CYAN}${BOLD}三、版本说明${NC}"
    echo -e "${CYAN}--------------------------------------------------${NC}"
    echo -e "  ${BOLD}标签版本：${NC}"
    echo -e "    - 由项目维护者发布的稳定版本（如 1.13.4）"
    echo -e "    - 适合日常使用，稳定性较好\n"

    echo -e "  ${BOLD}release 分支：${NC}"
    echo -e "    - 项目的主要开发分支"
    echo -e "    - 包含最新功能和修复，但可能存在不稳定因素"
    echo -e "    - 通过“更新酒馆”功能可切换回该分支\n"

    echo -e "${CYAN}${BOLD}四、注意事项${NC}"
    echo -e "  · ${BOLD}版本切换前：${NC} 建议先备份酒馆数据（系统维护 → 导出酒馆数据）"
    echo -e "  · ${BOLD}未提交更改：${NC} 切换版本会丢失未提交的文件修改，请注意保存"
    echo -e "  · ${BOLD}依赖安装：${NC} 切换版本后会自动重新安装依赖，需要良好的网络连接"
    echo -e "  · ${BOLD}依赖失败：${NC} 若依赖安装失败，可在系统维护中选择“修复依赖环境”"
    echo -e "  · ${BOLD}回到最新：${NC} 如需回到最新版本，使用主菜单的“更新酒馆”功能\n"

    echo -e "${CYAN}${BOLD}五、常见问题${NC}"
    echo -e "  ${BOLD}Q：版本切换后启动失败怎么办？${NC}"
    echo -e "  A：检查依赖是否安装成功，可尝试“系统维护 → 修复依赖环境”。\n"

    echo -e "  ${BOLD}Q：如何回到最新的 release 分支？${NC}"
    echo -e "  A：使用主菜单的“更新酒馆”功能，会自动切换到 release 分支。\n"

    echo -e "  ${BOLD}Q：切换版本会影响我的数据吗？${NC}"
    echo -e "  A：不会，用户数据存储在 data 目录，版本切换不影响该目录。\n"

    echo -e "${CYAN}${BOLD}==================================================${NC}"
    press_any_key
}

version_switch_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 酒馆版本切换 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 查看版本标签${NC}"
        echo -e "${BLUE}${BOLD}2. 切换酒馆版本${NC}"
        echo -e "${MAGENTA}${BOLD}3. 版本切换帮助${NC}"
        echo -e "${CYAN}${BOLD}======================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-3）：${NC}"
        read -n1 version_choice; echo

        case "$version_choice" in
            0) break ;;
            1) show_version_tags ;;
            2) switch_tavern_version ;;
            3) show_version_switch_help ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

maintenance_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 系统维护 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${BLUE}${BOLD}1. 查看依赖版本${NC}"
        echo -e "${GREEN}${BOLD}2. 修复依赖环境${NC}"
        echo -e "${YELLOW}${BOLD}3. 导出酒馆数据${NC}"
        echo -e "${MAGENTA}${BOLD}4. 导出酒馆本体${NC}"
        echo -e "${GREEN}${BOLD}5. 导入酒馆数据${NC}"
        echo -e "${BLUE}${BOLD}6. 导入酒馆本体${NC}"
        echo -e "${CYAN}${BOLD}7. 酒馆版本切换${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-7）：${NC}"
        read -n1 sub_choice; echo
        case "$sub_choice" in
            0) break ;;
            1) show_dependencies ;;
            2) fix_dependencies ;;
            3) export_tavern_data ;;
            4) export_tavern_full ;;
            5) import_tavern_data ;;
            6) import_tavern_full ;;
            7) version_switch_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

# =========================================================================
# 6. 脚本管理
# =========================================================================
check_update() {
    TMP_ENV="$HOME/.env.remote"
    echo -e "\n${CYAN}${BOLD}==== 检查脚本更新 ====${NC}"
    if ! curl -fsSL -m 15 -o "$TMP_ENV" "$REMOTE_ENV_URL"; then
        echo -e "${RED}${BOLD}>> 无法获取远程版本信息，请检查网络连接。${NC}"
        rm -f "$TMP_ENV"; press_any_key; return
    fi
    # 版本号以脚本文件本体为准；.env 仅承载 START_MODE 等本地配置，不再被更新覆盖
    LOCAL_MENU_VERSION=$(get_version "$HOME/Menu.sh" "MENU_VERSION")
    if [ -f "$HOME/Install.sh" ]; then
        LOCAL_INSTALL_VERSION=$(get_version "$HOME/Install.sh" "INSTALL_VERSION")
    else
        LOCAL_INSTALL_VERSION=0
    fi
    REMOTE_INSTALL_VERSION=$(get_version "$TMP_ENV" "INSTALL_VERSION")
    REMOTE_MENU_VERSION=$(get_version "$TMP_ENV" "MENU_VERSION")
    rm -f "$TMP_ENV"
    echo -e "${YELLOW}${BOLD}>> 本地 Install.sh 版本：${LOCAL_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程 Install.sh 版本：${REMOTE_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 本地 Menu.sh 版本：${LOCAL_MENU_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程 Menu.sh 版本：${REMOTE_MENU_VERSION}${NC}"
    for v in "$LOCAL_INSTALL_VERSION" "$LOCAL_MENU_VERSION" "$REMOTE_INSTALL_VERSION" "$REMOTE_MENU_VERSION"; do
        if ! [[ "$v" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}${BOLD}>> 版本号读取失败，请检查脚本文件与远程配置。${NC}"
            press_any_key; return
        fi
    done
    menu_updated=0
    if [ "$LOCAL_INSTALL_VERSION" -lt "$REMOTE_INSTALL_VERSION" ]; then
        echo -e "${MAGENTA}${BOLD}>> 检测到 Install.sh 有新版本，正在更新...${NC}"
        if curl -fsSL -o "$HOME/Install.sh.new" "$REMOTE_INSTALL_URL"; then
            chmod +x "$HOME/Install.sh.new"
            mv "$HOME/Install.sh.new" "$HOME/Install.sh"
            echo -e "${GREEN}${BOLD}>> Install.sh 已更新。${NC}"
        else
            rm -f "$HOME/Install.sh.new"
            echo -e "${RED}${BOLD}>> Install.sh 更新失败，下次检查将再次尝试。${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}>> Install.sh 已是最新版本。${NC}"
    fi
    if [ "$LOCAL_MENU_VERSION" -lt "$REMOTE_MENU_VERSION" ]; then
        echo -e "${BLUE}${BOLD}>> 检测到 Menu.sh 有新版本，正在更新...${NC}"
        # 下载到临时文件后原子替换，避免覆盖正在运行的脚本
        if curl -fsSL -o "$HOME/Menu.sh.new" "$REMOTE_MENU_URL"; then
            chmod +x "$HOME/Menu.sh.new"
            mv "$HOME/Menu.sh.new" "$HOME/Menu.sh"
            menu_updated=1
            echo -e "${GREEN}${BOLD}>> Menu.sh 已更新。${NC}"
        else
            rm -f "$HOME/Menu.sh.new"
            echo -e "${RED}${BOLD}>> Menu.sh 更新失败，下次检查将再次尝试。${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}>> Menu.sh 已是最新版本。${NC}"
    fi
    if [ $menu_updated -eq 1 ]; then
        echo -e "${CYAN}${BOLD}>> 脚本已更新，将自动重启菜单...${NC}"
        sleep 2
        exec bash "$HOME/Menu.sh"
    fi
    press_any_key
}

show_update_log() {
    echo -e "\n${CYAN}${BOLD}==== 更新日志 ====${NC}"
    echo -e "${MAGENTA}${BOLD}脚本更新日期：${YELLOW}${BOLD}${UPDATE_DATE}${NC}"
    echo -e "${CYAN}${BOLD}更新内容：${NC}${UPDATE_CONTENT}"
    echo -e "${CYAN}${BOLD}==================${NC}"
    press_any_key
}

uninstall_all() {
    echo -e "\n${CYAN}${BOLD}==== 卸载警告 ====${NC}"
    echo -e "${RED}${BOLD}>> 即将卸载 SillyTavern 及相关配置，操作不可逆！${NC}"
    echo -ne "${YELLOW}${BOLD}是否继续？(y/n)：${NC}"
    read -n1 confirm; echo
    if [[ "$confirm" =~ [yY] ]]; then
        if [ -d "$HOME/SillyTavern/.git" ]; then
            rm -rf "$HOME/SillyTavern"
        fi
        rm -f "$HOME/Menu.sh" "$HOME/.env" "$HOME/Install.sh"
        sed -i '/# SillyTavern-Termux 菜单自启动/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/# SillyTavern-Termux 菜单自启动/d' "$HOME/.bash_profile" 2>/dev/null
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.bash_profile" 2>/dev/null
        sed -i '/# SillyTavern-Termux 菜单自启动/d' "$HOME/.profile" 2>/dev/null
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.profile" 2>/dev/null
        echo -e "${GREEN}${BOLD}>> 卸载完成，已清理相关文件。${NC}"
        exit 0
    else
        echo -e "${YELLOW}${BOLD}>> 已取消卸载。${NC}"
        sleep 1
    fi
}

script_manage_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 脚本管理 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${BLUE}${BOLD}1. 菜单脚本更新${NC}"
        echo -e "${GREEN}${BOLD}2. 查看更新日志${NC}"
        echo -e "${RED}${BOLD}3. 一键卸载酒馆${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-3）：${NC}"
        read -n1 sub_choice; echo
        case "$sub_choice" in
            0) break ;;
            1) check_update ;;
            2) show_update_log ;;
            3) uninstall_all ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

# =========================================================================
# 7. 关于脚本
# =========================================================================
about_script_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 关于脚本 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 作者信息${NC}"
        echo -e "${BLUE}${BOLD}2. 加群交流${NC}"
        echo -e "${MAGENTA}${BOLD}3. 邮件反馈${NC}"
        echo -e "${BLUE}${BOLD}4. 资源获取${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-4）：${NC}"
        read -n1 about_choice; echo
        case "$about_choice" in
            0) break ;;
            1)
                echo -e "\n${CYAN}${BOLD}==== 作者信息 ====${NC}"
                echo -e "${GREEN}${BOLD}作者：欤歡${NC}"
                echo -e "${MAGENTA}${BOLD}Q群：807134015${NC}"
                echo -e "${BLUE}${BOLD}邮箱：print.yuhuan@gmail.com${NC}"
                echo -e "${CYAN}${BOLD}==================${NC}"
                press_any_key
                ;;
            2)
                echo -e "\n${CYAN}${BOLD}==== 加群交流 ====${NC}"
                echo -e "${GREEN}${BOLD}欢迎加入 SillyTavern-Termux 用户交流群！${NC}"
                echo -e "${MAGENTA}${BOLD}QQ群号：807134015${NC}"
                if command -v am >/dev/null 2>&1; then
                    am start -a android.intent.action.VIEW -d "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=807134015&card_type=group&source=qrcode" >/dev/null 2>&1 \
                        && echo -e "${GREEN}${BOLD}>> 已尝试自动打开 QQ 加群页面。${NC}" \
                        || echo -e "${YELLOW}${BOLD}>> 未能自动打开 QQ，请手动搜索群号加入。${NC}"
                else
                    echo -e "${YELLOW}${BOLD}>> 当前环境不支持自动打开 QQ，请手动搜索群号加入。${NC}"
                fi
                press_any_key
                ;;
            3)
                echo -e "\n${CYAN}${BOLD}==== 邮件反馈 ====${NC}"
                echo -e "${BLUE}${BOLD}即将打开系统邮件应用，收件人：print.yuhuan@gmail.com${NC}"
                if command -v am >/dev/null 2>&1; then
                    am start -a android.intent.action.SENDTO -d mailto:print.yuhuan@gmail.com >/dev/null 2>&1 \
                        && echo -e "${GREEN}${BOLD}>> 已调用系统邮件应用。${NC}" \
                        || echo -e "${YELLOW}${BOLD}>> 未能自动打开邮件App，请手动发送邮件至：print.yuhuan@gmail.com${NC}"
                else
                    echo -e "${YELLOW}${BOLD}>> 当前环境不支持自动打开邮件App，请手动发送邮件至：print.yuhuan@gmail.com${NC}"
                fi
                press_any_key
                ;;
            4) resource_links_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

# =========================================================================
# 7.1 资源获取
# =========================================================================
resource_links_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 资源获取 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 应用安装${NC}"
        echo -e "${BLUE}${BOLD}2. 酒馆社群${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-2）：${NC}"
        read -n1 res_choice; echo
        case "$res_choice" in
            0) break ;;
            1) install_app_menu ;;
            2) community_links_menu ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

# =========================================================================
# 7.1.1 应用安装
# =========================================================================
install_app_menu() {
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 应用安装 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${MAGENTA}${BOLD}1. 安装Discord${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-1）：${NC}"
        read -n1 app_choice; echo
        case "$app_choice" in
            0) break ;;
            1) install_discord_app ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

install_discord_app() {
    TMP_ENV="$HOME/.env.remote"
    echo -e "${CYAN}${BOLD}>> 正在获取 Discord 下载链接...${NC}"
    if ! curl -fsSL -o "$TMP_ENV" "$REMOTE_ENV_URL"; then
        echo -e "${RED}${BOLD}>> 远程配置文件获取失败，请检查网络。${NC}"
        press_any_key; return
    fi
    DISCORD_URL=$(get_env_value "$TMP_ENV" "DISCORD_DOWNLOAD")
    rm -f "$TMP_ENV"
    if [ -z "$DISCORD_URL" ]; then
        echo -e "${YELLOW}${BOLD}>> 未配置 Discord 下载链接，请稍后重试。${NC}"
        press_any_key; return
    fi
    if ! echo "$DISCORD_URL" | grep -q '^https\?://'; then
        echo -e "${YELLOW}${BOLD}>> Discord 下载链接格式错误：$DISCORD_URL${NC}"
        press_any_key; return
    fi
    FILENAME="Discord.apk"
    DEST="/storage/emulated/0/Download/$FILENAME"
    echo -e "${CYAN}${BOLD}>> 开始下载 Discord 应用...${NC}"
    if curl -Lf --progress-bar -o "$DEST" "$DISCORD_URL"; then
        if [ -s "$DEST" ]; then
            echo -e "${GREEN}${BOLD}>> 下载完成，已保存到: $DEST${NC}"
            # 优先使用 termux-open（内部转换 content:// URI，兼容 Android 7+）
            if command -v termux-open >/dev/null 2>&1; then
                termux-open "$DEST" \
                    && echo -e "${GREEN}${BOLD}>> 已调用系统安装管理器安装 Discord。${NC}" \
                    || echo -e "${YELLOW}${BOLD}>> 未能自动调用安装管理器，请手动在文件管理中安装 Discord。${NC}"
            elif command -v am >/dev/null 2>&1; then
                am start -a android.intent.action.VIEW -d "file://$DEST" -t "application/vnd.android.package-archive" >/dev/null 2>&1 \
                    && echo -e "${GREEN}${BOLD}>> 已调用系统安装管理器安装 Discord。${NC}" \
                    || echo -e "${YELLOW}${BOLD}>> 未能自动调用安装管理器，请手动在文件管理中安装 Discord。${NC}"
            else
                echo -e "${YELLOW}${BOLD}>> 当前环境不支持自动安装，请手动在文件管理中安装 Discord。${NC}"
            fi
        else
            echo -e "${RED}${BOLD}>> 下载失败，文件为空，请检查网络或存储权限。${NC}"
            rm -f "$DEST"
        fi
    else
        echo -e "${RED}${BOLD}>> 下载失败，请检查网络或存储权限。${NC}"
        rm -f "$DEST"
    fi
    press_any_key
}

# =========================================================================
# 7.1.2 酒馆社群
# =========================================================================
community_links_menu() {
    TMP_ENV="$HOME/.env.remote"
    if ! curl -fsSL -o "$TMP_ENV" "$REMOTE_ENV_URL"; then
        echo -e "${RED}${BOLD}>> 远程配置文件获取失败，请检查网络。${NC}"
        press_any_key; return
    fi
    JIUGUAN_LINK=$(get_env_value "$TMP_ENV" "JIUGUAN_LINK")
    LEINAO_LINK=$(get_env_value "$TMP_ENV" "LEINAO_LINK")
    LVCHENG_LINK=$(get_env_value "$TMP_ENV" "LVCHENG_LINK")
    YANTING_LINK=$(get_env_value "$TMP_ENV" "YANTING_LINK")
    TAOYUAN_LINK=$(get_env_value "$TMP_ENV" "TAOYUAN_LINK")
    rm -f "$TMP_ENV"
    while true; do
        clear
        echo -e "${CYAN}${BOLD}==== 酒馆社群 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${GREEN}${BOLD}1. 酒馆频道${NC}"
        echo -e "${BLUE}${BOLD}2. 类脑频道${NC}"
        echo -e "${MAGENTA}${BOLD}3. 旅程频道${NC}"
        echo -e "${CYAN}${BOLD}4. 言庭频道${NC}"
        echo -e "${YELLOW}${BOLD}5. 桃源频道${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-5）：${NC}"
        read -n1 link_choice; echo
        case "$link_choice" in
            0) break ;;
            1) open_link_menu "酒馆频道" "$JIUGUAN_LINK" ;;
            2) open_link_menu "类脑频道" "$LEINAO_LINK" ;;
            3) open_link_menu "旅程频道" "$LVCHENG_LINK" ;;
            4) open_link_menu "言庭频道" "$YANTING_LINK" ;;
            5) open_link_menu "桃源频道" "$TAOYUAN_LINK" ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

open_link_menu() {
    local name="$1"
    local url="$2"
    if [ -z "$url" ]; then
        echo -e "${YELLOW}${BOLD}>> $name 未配置链接，请稍后重试。${NC}"
        press_any_key; return
    fi
    echo -e "${CYAN}${BOLD}>> 即将打开 $name：$url${NC}"
    if command -v am >/dev/null 2>&1; then
        am start -a android.intent.action.VIEW -d "$url" >/dev/null 2>&1 \
            && echo -e "${GREEN}${BOLD}>> 已调用系统浏览器打开。${NC}" \
            || echo -e "${YELLOW}${BOLD}>> 未能自动打开浏览器，请手动访问上方链接。${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 当前环境不支持自动打开浏览器，请手动访问上方链接。${NC}"
    fi
    press_any_key
}

# =========================================================================
# 主菜单循环
# =========================================================================
while true; do
    clear
    echo -e "${CYAN}${BOLD}==== SillyTavern Termux 菜单 ====${NC}"
    echo -e "${RED}${BOLD}0. 退出脚本${NC}"
    echo -e "${GREEN}${BOLD}1. 启动酒馆${NC}"
    echo -e "${BLUE}${BOLD}2. 更新酒馆${NC}"
    echo -e "${YELLOW}${BOLD}3. 酒馆配置${NC}"
    echo -e "${MAGENTA}${BOLD}4. 酒馆插件${NC}"
    echo -e "${CYAN}${BOLD}5. 系统维护${NC}"
    echo -e "${BRIGHT_BLUE}${BOLD}6. 脚本管理${NC}"
    echo -e "${BRIGHT_MAGENTA}${BOLD}7. 关于脚本${NC}"
    echo -e "${CYAN}${BOLD}=================================${NC}"
    echo -ne "${CYAN}${BOLD}请选择操作（0-7）：${NC}"
    read -n1 choice; echo
    case "$choice" in
        0) echo -e "${RED}${BOLD}>> 脚本已退出，欢迎再次使用。${NC}"; sleep 0.5; clear; exit 0 ;;
        1) start_tavern ;;
        2) update_tavern ;;
        3) tavern_config_menu ;;
        4) plugin_menu ;;
        5) maintenance_menu ;;
        6) script_manage_menu ;;
        7) about_script_menu ;;
        *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
    esac
done
