#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 插件卸载函数库
# 职责：动态扫描已安装插件列表并按序号卸载
# =========================================================================

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
