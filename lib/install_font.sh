#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 安装步骤 4/8：终端字体配置函数库
# 职责：下载 MapleMono 字体到 ~/.termux/font.ttf，并热刷新 Termux 配置
# =========================================================================

install_step4_font() {
    echo -e "\n${CYAN}${BOLD}==== 步骤 4/8：下载并配置终端字体 ====${NC}"
    mkdir -p "$FONT_DIR"
    if [ -f "$FONT_PATH" ]; then
        echo -e "${YELLOW}${BOLD}>> 字体文件已存在，跳过下载。${NC}"
    else
        if curl -L --progress-bar -o "$FONT_PATH" "$FONT_URL"; then
            echo -e "${GREEN}${BOLD}>> 字体已下载并保存为 .termux/font.ttf${NC}"
        else
            echo -e "${RED}${BOLD}>> 字体下载失败，请检查网络或稍后重试。${NC}"
            echo -e "${YELLOW}${BOLD}>> 步骤 4/8 跳过：字体未配置成功。${NC}"
        fi
    fi

    if [ -f "$FONT_PATH" ]; then
        if command -v termux-reload-settings >/dev/null 2>&1; then
            termux-reload-settings \
            && echo -e "${GREEN}${BOLD}>> 配置已自动刷新，字体已生效。${NC}" \
            || echo -e "${YELLOW}${BOLD}>> 尝试刷新配置失败，请手动重启 Termux。${NC}"
        else
            echo -e "${YELLOW}${BOLD}>> 未检测到 termux-reload-settings，请手动重启 Termux 使字体生效。${NC}"
        fi
        echo -e "${GREEN}${BOLD}>> 步骤 4/8 完成：终端字体已配置。${NC}"
    fi
}
