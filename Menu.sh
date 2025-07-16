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
MENU_VERSION=20250716
UPDATE_DATE="2025-07-16"
UPDATE_CONTENT="
1. 全面重构安装与菜单脚本，统一注释与交互风格，提升可读性与美观度。
2. 增强依赖检测与修复逻辑，自动补全缺失组件（git、curl、zip、unzip、nodejs等）。
3. 新增主菜单模块：系统维护、脚本管理、插件管理，结构更清晰。
4. 支持插件一键安装与卸载，附详细功能介绍与安全提示。
5. 实现脚本自更新，远程同步版本号，自动重载菜单。
6. 自动配置终端字体，优化界面显示效果。
7. 所有菜单与提示信息采用统一色彩与加粗高亮，提升交互体验。
8. 关于脚本菜单支持作者信息、加群交流、邮件反馈，支持自动调起相关应用。
9. 系统维护模块支持一键导出/导入酒馆数据和本体，自动扫描下载目录备份，交互式选择与安全恢复，具备覆盖警告与二次确认。
10. 支持依赖版本检测与一键修复。
11. 支持一键卸载酒馆及相关脚本配置，彻底清理环境。
12. 所有操作均有详细进度与友好反馈，提升易用性与安全性。
13. 关于脚本菜单新增“资源获取”子菜单，支持：
    - 应用安装：一键下载并自动安装 Discord 客户端，下载进度可视化，支持断点续传。
    - 酒馆社群：一键直达五大 Discord 社群频道（酒馆、类脑、旅程、言庭、桃源）。
"
REMOTE_ENV_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/.env"
REMOTE_INSTALL_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Install.sh"
REMOTE_MENU_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Menu.sh"

# ==== 通用函数 ====
get_version() { [ -f "$1" ] && grep -E "^$2=" "$1" | head -n1 | cut -d'=' -f2 | tr -d '\r'; }
press_any_key() { echo -e "${CYAN}${BOLD}>> 按任意键返回菜单...${NC}"; read -n1 -s; }

# =========================================================================
# 1. 启动酒馆
# =========================================================================
start_tavern() {
    echo -e "\n${CYAN}${BOLD}==== 启动 SillyTavern ====${NC}"
    for dep in node npm git; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo -e "${RED}${BOLD}>> 检测到缺失依赖：$dep，请先修复依赖环境。${NC}"
            press_any_key; return
        fi
    done
    if [ -d "$HOME/SillyTavern" ]; then
        cd "$HOME/SillyTavern"
        if [ -f "start.sh" ]; then
            bash start.sh
        else
            npm start
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
        echo -e "${CYAN}${BOLD}>> 正在拉取最新代码...${NC}"
        git pull
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
        echo -e "${CYAN}${BOLD}==== 酒馆配置 ====${NC}"
        echo -e "${YELLOW}${BOLD}0. 返回上级菜单${NC}"
        echo -e "${BLUE}${BOLD}1. 开启网络监听${NC}"
        echo -e "${MAGENTA}${BOLD}2. 关闭网络监听${NC}"
        echo -e "${YELLOW}${BOLD}3. 恢复配置文件${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-3）：${NC}"
        read -n1 config_choice; echo
        case "$config_choice" in
            0) break ;;
            1|2|3)
                cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> 目录不存在！${NC}"; press_any_key; continue; }
                if [ ! -f config.yaml ] && [ "$config_choice" != "3" ]; then
                    echo -e "${RED}${BOLD}>> 未找到 config.yaml 文件，无法操作。${NC}"
                    press_any_key; continue
                fi
                [ ! -f config.yaml.bak ] && cp config.yaml config.yaml.bak
                if [ "$config_choice" = "1" ]; then
                    sed -i 's/^listen: false$/listen: true/' config.yaml
                    sed -i 's/^enableUserAccounts: false$/enableUserAccounts: true/' config.yaml
                    sed -i 's/^enableDiscreetLogin: false$/enableDiscreetLogin: true/' config.yaml
                    sed -i 's/^  - 127\.0\.0\.1$/  - 0.0.0.0\/0/' config.yaml
                    echo -e "${GREEN}${BOLD}>> 网络监听已开启${NC}"
                elif [ "$config_choice" = "2" ]; then
                    sed -i 's/^listen: true$/listen: false/' config.yaml
                    sed -i 's/^enableUserAccounts: true$/enableUserAccounts: false/' config.yaml
                    sed -i 's/^enableDiscreetLogin: true$/enableDiscreetLogin: false/' config.yaml
                    sed -i 's/^  - 0\.0\.0\.0\/0$/  - 127.0.0.1/' config.yaml
                    echo -e "${YELLOW}${BOLD}>> 网络监听已关闭${NC}"
                else
                    if [ ! -f config.yaml.bak ]; then
                        echo -e "${YELLOW}${BOLD}>> 未找到 config.yaml.bak 备份文件，无法恢复配置文件。${NC}"
                        press_any_key; continue
                    fi
                    cp config.yaml.bak config.yaml
                    echo -e "${CYAN}${BOLD}>> 已恢复初始配置${NC}"
                fi
                press_any_key
                ;;
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
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
        echo -e "${MAGENTA}${BOLD}1. 酒馆助手      ${YELLOW}${BOLD}（多功能扩展）${NC}"
        echo -e "${BLUE}${BOLD}2. 记忆表格      ${GREEN}${BOLD}（结构化记忆）${NC}"
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-2）：${NC}"
        read -n1 plugin_choice; echo
        case "$plugin_choice" in
            0) break ;;
            1)
                clear
                echo -e "${MAGENTA}${BOLD}==== 酒馆助手 ====${NC}"
                echo -e "${YELLOW}${BOLD}仓库：${NC}https://github.com/N0VI028/JS-Slash-Runner"
                echo -e "${CYAN}${BOLD}功能简介：${NC}
酒馆助手是为 SillyTavern 设计的多功能扩展插件，支持在对话中渲染各种交互式前端界面，实现与 SillyTavern 的深度交互，并可作为中间层连接外部应用程序，极大丰富了对话体验和扩展能力。
"
                echo -e "${CYAN}${BOLD}主要特性：${NC}
  - 支持在对话中创建从简单按钮到小游戏等丰富的交互元素
  - 可用 jQuery 操作 SillyTavern 的 DOM，灵活修改样式、绑定事件等
  - 作为后端中转，实现与外部应用的数据交换和功能联动
  - 通过 iframe 隔离运行外部 JavaScript 脚本，突破 SillyTavern 默认限制
"
                echo -e "${YELLOW}${BOLD}安全提示：${NC}
  - 插件允许执行自定义 JavaScript 代码，存在一定安全风险
  - 恶意脚本可能窃取 API 密钥、聊天记录等敏感信息，或破坏设置
  - 请务必核查脚本来源和内容，确保安全可信后再运行
"
                echo -e "${CYAN}${BOLD}插件作者信息：                                          插件名称：酒馆助手${NC}"
                echo -e "${GREEN}${BOLD}作者：KAKAA、青空莉想做舞台少女的狗${NC}"
                echo -e "${MAGENTA}${BOLD}© 2025 N0VI028. 保留所有权利。${NC}"
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
                echo -e "${BLUE}${BOLD}==== 记忆表格 ====${NC}"
                echo -e "${YELLOW}${BOLD}仓库：${NC}https://github.com/muyoou/st-memory-enhancement"
                echo -e "${CYAN}${BOLD}功能简介：${NC}
记忆增强插件专为 SillyTavern 酒馆打造，注入结构化长期记忆能力，支持角色设定、关键事件、重要物品等自定义内容，帮助 AI 更好地理解和记住对话上下文，使推演更连贯、更贴合情境。
"
                echo -e "${CYAN}${BOLD}主要特性：${NC}
  - 通过直观表格轻松查看、编辑和管理 AI 记忆
  - 支持导出、分享与自定义 JSON 表格结构，满足多样创作需求
  - 结构化记忆储存，未来支持节点编辑器和多模板管理
  - 智能提示词自动生成与注入，深度集成世界书或预设
  - 表格内容可推送至聊天界面，支持自定义样式
  - 丰富的自定义导出和分享选项，便捷配置管理
  - 未来支持分步任务与主副 API 智能分配，高效管理长期记忆
"
                echo -e "${YELLOW}${BOLD}使用说明：${NC}
  - 插件仅在 SillyTavern 的“聊天补全模式”下工作
"
                echo -e "${CYAN}${BOLD}插件作者信息：                                          插件名称：记忆表格${NC}"
                echo -e "${GREEN}${BOLD}作者：木悠${NC}"
                echo -e "${GREEN}${BOLD}插件交流Q群：${NC}"
                echo -e "${GREEN}${BOLD}一群：1030109849${NC}"
                echo -e "${GREEN}${BOLD}二群：1045423946${NC}"
                echo -e "${MAGENTA}${BOLD}© 2025 muyoou. 保留所有权利。${NC}"
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
            *) echo -e "${RED}${BOLD}>> 无效选项，请重新输入。${NC}"; sleep 1 ;;
        esac
    done
}

plugin_uninstall_menu() {
    local PLUGIN_ROOT="$HOME/SillyTavern/public/scripts/extensions/third-party"
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
            plugin_name=$(basename "${plugin_dirs[$i]}")
            echo -e "${BLUE}${BOLD}$((i+1)). ${GREEN}${BOLD}${plugin_name}${NC}"
        done
        echo -e "${CYAN}${BOLD}请输入要卸载的插件序号后回车（或0返回）：${NC}"
        read -r idx
        if [[ "$idx" == "0" ]]; then
            break
        fi
        if [[ "$idx" =~ ^[1-9][0-9]*$ ]] && [ "$idx" -le "${#plugin_dirs[@]}" ]; then
            plugin_name=$(basename "${plugin_dirs[$((idx-1))]}")
            echo -ne "${YELLOW}${BOLD}是否卸载 ${plugin_name}？(y/n)：${NC}"
            read -n1 ans; echo
            if [[ "$ans" =~ [yY] ]]; then
                rm -rf "${plugin_dirs[$((idx-1))]}"
                echo -e "${GREEN}${BOLD}>> 插件 ${plugin_name} 已卸载。${NC}"
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
        echo -e "${MAGENTA}${BOLD}1. 安装插件${NC}"
        echo -e "${BLUE}${BOLD}2. 卸载插件${NC}"
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
    echo -ne "${BLUE}${BOLD}git:   ${NC}"; git --version
    echo -ne "${GREEN}${BOLD}node:  ${NC}"; node -v
    echo -ne "${MAGENTA}${BOLD}npm:   ${NC}"; command -v npm >/dev/null 2>&1 && npm -v || echo -e "${RED}${BOLD}未安装${NC}"
    echo -ne "${YELLOW}${BOLD}curl:  ${NC}"; command -v curl >/dev/null 2>&1 && curl --version | head -n1 || echo -e "${RED}${BOLD}未安装${NC}"
    echo -e "${CYAN}${BOLD}======================${NC}"
    press_any_key
}

fix_dependencies() {
    echo -e "\n${CYAN}${BOLD}==== 修复依赖环境 ====${NC}"
    pkg update && pkg upgrade -y -o Dpkg::Options::="--force-confnew"
    for dep in git curl unzip; do
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
    npm config set prefix $PREFIX
    echo -e "${GREEN}${BOLD}>> 依赖修复完成。${NC}"
    press_any_key
}

export_tavern_data() {
    echo -e "\n${CYAN}${BOLD}==== 导出酒馆数据 ====${NC}"
    cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> SillyTavern 目录不存在，无法导出。${NC}"; press_any_key; return; }
    now=$(date +%Y%m%d_%H%M%S)
    if [ ! -d data ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到 data 目录，无数据可导出。${NC}"
        press_any_key
        return
    fi
    zip -r "SillyTavern-Data_${now}.zip" data
    mv "SillyTavern-Data_${now}.zip" /storage/emulated/0/Download/ 2>/dev/null \
        && echo -e "${GREEN}${BOLD}>> 导出完成，已保存到 下载 文件夹。${NC}" \
        || echo -e "${RED}${BOLD}>> 移动压缩包失败，请手动查找。${NC}"
    press_any_key
}

export_tavern_full() {
    echo -e "\n${CYAN}${BOLD}==== 导出酒馆本体 ====${NC}"
    cd "$HOME" || { echo -e "${RED}${BOLD}>> HOME 目录不存在，无法导出。${NC}"; press_any_key; return; }
    if [ ! -d SillyTavern ]; then
        echo -e "${YELLOW}${BOLD}>> 未检测到 SillyTavern 目录，无本体可导出。${NC}"
        press_any_key
        return
    fi
    now=$(date +%Y%m%d_%H%M%S)
    zip -r "SillyTavern_${now}.zip" SillyTavern
    mv "SillyTavern_${now}.zip" /storage/emulated/0/Download/ 2>/dev/null \
        && echo -e "${GREEN}${BOLD}>> 导出完成，已保存到 下载 文件夹。${NC}" \
        || echo -e "${RED}${BOLD}>> 移动压缩包失败，请手动查找。${NC}"
    press_any_key
}

import_tavern_data() {
    echo -e "\n${CYAN}${BOLD}==== 导入酒馆数据 ====${NC}"
    if ! command -v unzip >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 检测到 unzip 未安装，请执行 pkg install unzip 后重试。${NC}"
        press_any_key; return
    fi
    BACKUP_DIR="/storage/emulated/0/Download"
    PATTERN="SillyTavern-Data_*.zip"
    mapfile -t backup_files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "$PATTERN" 2>/dev/null | xargs -r ls -t 2>/dev/null)
    if [ ${#backup_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未在下载目录中检测到可用的备份文件。${NC}"
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
        echo -e "${CYAN}${BOLD}=====================${NC}"
        echo -ne "${CYAN}${BOLD}请输入要恢复的备份文件序号（或0返回）：${NC}"
        read -r idx
        if [[ "$idx" == "0" ]]; then
            return
        fi
        if [[ "$idx" =~ ^[1-9][0-9]*$ ]] && [ "$idx" -le "${#backup_files[@]}" ]; then
            selected_file="${backup_files[$((idx-1))]}"
            TARGET_DIR="$HOME/SillyTavern/data"
            if [ ! -d "$HOME/SillyTavern" ]; then
                echo -e "${YELLOW}${BOLD}>> 未检测到 SillyTavern 主目录，请先恢复酒馆本体。${NC}"
                press_any_key; return
            fi
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

import_tavern_full() {
    echo -e "\n${CYAN}${BOLD}==== 导入酒馆本体 ====${NC}"
    if ! command -v unzip >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 检测到 unzip 未安装，请执行 pkg install unzip 后重试。${NC}"
        press_any_key; return
    fi
    BACKUP_DIR="/storage/emulated/0/Download"
    PATTERN="SillyTavern_*.zip"
    mapfile -t backup_files < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name "$PATTERN" 2>/dev/null | xargs -r ls -t 2>/dev/null)
    if [ ${#backup_files[@]} -eq 0 ]; then
        echo -e "${YELLOW}${BOLD}>> 未在下载目录中检测到可用的备份文件。${NC}"
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
        echo -e "${CYAN}${BOLD}=====================${NC}"
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
        echo -e "${CYAN}${BOLD}==================${NC}"
        echo -ne "${CYAN}${BOLD}请选择操作（0-6）：${NC}"
        read -n1 sub_choice; echo
        case "$sub_choice" in
            0) break ;;
            1) show_dependencies ;;
            2) fix_dependencies ;;
            3) export_tavern_data ;;
            4) export_tavern_full ;;
            5) import_tavern_data ;;
            6) import_tavern_full ;;
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
    if ! ping -c 1 -W 1 github.com >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 网络不可用，请检查网络连接。${NC}"
        press_any_key; return
    fi
    if ! curl -fsSL -o "$TMP_ENV" "$REMOTE_ENV_URL"; then
        echo -e "${RED}${BOLD}>> 无法获取远程版本信息，请检查网络。${NC}"
        rm -f "$TMP_ENV"; press_any_key; return
    fi
    if [ ! -f "$HOME/.env" ]; then
        echo -e "${RED}${BOLD}>> 本地 .env 文件不存在，无法检测更新。${NC}"
        rm -f "$TMP_ENV"; press_any_key; return
    fi
    LOCAL_INSTALL_VERSION=$(get_version "$HOME/.env" "INSTALL_VERSION")
    LOCAL_MENU_VERSION=$(get_version "$HOME/.env" "MENU_VERSION")
    REMOTE_INSTALL_VERSION=$(get_version "$TMP_ENV" "INSTALL_VERSION")
    REMOTE_MENU_VERSION=$(get_version "$TMP_ENV" "MENU_VERSION")
    echo -e "${YELLOW}${BOLD}>> 本地 Install.sh 版本：${LOCAL_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程 Install.sh 版本：${REMOTE_INSTALL_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 本地 Menu.sh 版本：${LOCAL_MENU_VERSION}${NC}"
    echo -e "${YELLOW}${BOLD}>> 远程 Menu.sh 版本：${REMOTE_MENU_VERSION}${NC}"
    if [ -z "$LOCAL_INSTALL_VERSION" ] || [ -z "$LOCAL_MENU_VERSION" ] || [ -z "$REMOTE_INSTALL_VERSION" ] || [ -z "$REMOTE_MENU_VERSION" ]; then
        echo -e "${RED}${BOLD}>> 版本号读取失败，请检查 .env 文件格式。${NC}"
        rm -f "$TMP_ENV"; press_any_key; return
    fi
    updated=0
    if [ "$LOCAL_INSTALL_VERSION" -lt "$REMOTE_INSTALL_VERSION" ]; then
        echo -e "${MAGENTA}${BOLD}>> 检测到 Install.sh 有新版本，正在更新...${NC}"
        if curl -fsSL -o "$HOME/Install.sh" "$REMOTE_INSTALL_URL"; then
            chmod +x "$HOME/Install.sh"
            echo -e "${GREEN}${BOLD}>> Install.sh 已更新。${NC}"
            updated=1
        else
            echo -e "${RED}${BOLD}>> Install.sh 更新失败。${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}>> Install.sh 已是最新版本。${NC}"
    fi
    if [ "$LOCAL_MENU_VERSION" -lt "$REMOTE_MENU_VERSION" ]; then
        echo -e "${BLUE}${BOLD}>> 检测到 Menu.sh 有新版本，正在更新...${NC}"
        if curl -fsSL -o "$HOME/Menu.sh" "$REMOTE_MENU_URL"; then
            chmod +x "$HOME/Menu.sh"
            echo -e "${GREEN}${BOLD}>> Menu.sh 已更新。${NC}"
            updated=1
        else
            echo -e "${RED}${BOLD}>> Menu.sh 更新失败。${NC}"
        fi
    else
        echo -e "${GREEN}${BOLD}>> Menu.sh 已是最新版本。${NC}"
    fi
    if [ $updated -eq 1 ]; then
        mv "$TMP_ENV" "$HOME/.env"
        echo -e "${GREEN}${BOLD}>> 本地版本号已同步更新。${NC}"
        echo -e "${CYAN}${BOLD}>> 脚本已更新，将自动重启菜单...${NC}"
        sleep 2
        exec bash "$HOME/Menu.sh"
    else
        rm -f "$TMP_ENV"
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
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/bash[ ]\+\$HOME\/Menu\.sh/d' "$HOME/.bash_profile" 2>/dev/null
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
    DISCORD_URL=$(grep '^DISCORD_DOWNLOAD=' "$TMP_ENV" | cut -d'=' -f2- | tr -d '\r' | xargs)
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
            if command -v am >/dev/null 2>&1; then
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
    JIUGUAN_LINK=$(grep '^JIUGUAN_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    LEINAO_LINK=$(grep '^LEINAO_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    LVCHENG_LINK=$(grep '^LVCHENG_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    YANTING_LINK=$(grep '^YANTING_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
    TAOYUAN_LINK=$(grep '^TAOYUAN_LINK=' "$TMP_ENV" | cut -d'=' -f2-)
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
