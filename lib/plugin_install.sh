#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 插件安装函数库
# 职责：展示插件介绍并执行 git clone 安装（酒馆助手 / 记忆表格 / 自定模型）
# =========================================================================

# =========================================================================
# 4. 酒馆插件 - 安装
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
                echo -e "${WHITE}· 插件仅适用于 SillyTavern 的"聊天补全模式""
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
