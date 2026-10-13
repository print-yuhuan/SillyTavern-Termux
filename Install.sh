#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# SillyTavern-Termux 安装脚本（Github）
# =========================================================================

# ==== 彩色输出定义 ====
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

# ==== 版本号 ====
INSTALL_VERSION=20261013

# ==== 下载与文件校验（与菜单脚本保持一致）====
download_resource() {
    local url="$1" output="$2" max_seconds="${3:-120}" progress="${4:-silent}"
    local -a display_args=(--silent --show-error)
    [ "$progress" = "progress" ] && display_args=(--progress-bar)
    curl -fL "${display_args[@]}" --connect-timeout 10 --max-time "$max_seconds" \
        --speed-limit 1024 --speed-time 30 --retry 2 --retry-delay 2 \
        -o "$output" "$url"
}

validate_resource() {
    local file="$1" kind="$2" expected="${3:-}" version
    [ -s "$file" ] || return 1
    case "$kind" in
        menu|install)
            bash -n "$file" || return 1
            if [ "$kind" = "menu" ]; then
                version=$(sed -n 's/^MENU_VERSION=\([0-9][0-9]*\)$/\1/p' "$file" | head -n1)
            else
                version=$(sed -n 's/^INSTALL_VERSION=\([0-9][0-9]*\)$/\1/p' "$file" | head -n1)
            fi
            [ -n "$version" ] && { [ -z "$expected" ] || [ "$version" = "$expected" ]; }
            ;;
        env)
            bash -n "$file" && grep -qE "^START_MODE=[\"']?[12][\"']?[[:space:]]*(#.*)?$" "$file"
            ;;
        font)
            node - "$file" <<'JS'
const fs = require('fs');
try {
    const b = fs.readFileSync(process.argv[2]);
    if (b.length < 12) process.exit(1);
    let faces = [0];
    if (b.subarray(0, 4).toString('ascii') === 'ttcf') {
        const count = b.readUInt32BE(8);
        if (!count || 12 + count * 4 > b.length) process.exit(1);
        faces = Array.from({ length: count }, (_, i) => b.readUInt32BE(12 + i * 4));
    }
    for (const face of faces) {
        const signature = b.subarray(face, face + 4).toString('hex');
        if (face + 12 > b.length || !['00010000', '4f54544f', '74727565'].includes(signature)) process.exit(1);
        const count = b.readUInt16BE(face + 4);
        if (!count || face + 12 + count * 16 > b.length) process.exit(1);
        for (let i = 0; i < count; i++) {
            const offset = b.readUInt32BE(face + 12 + i * 16 + 8);
            const length = b.readUInt32BE(face + 12 + i * 16 + 12);
            if (offset + length > b.length) process.exit(1);
        }
    }
} catch { process.exit(1); }
JS
            ;;
        apk)
            unzip -t "$file" >/dev/null 2>&1 \
                && unzip -Z1 "$file" | grep -qx 'AndroidManifest.xml'
            ;;
        *) return 1 ;;
    esac
}

download_validated() {
    local url="$1" target="$2" kind="$3" expected="${4:-}"
    local max_seconds="${5:-120}" progress="${6:-silent}" tmp
    tmp=$(mktemp "${target}.download.XXXXXX") || return 1
    if download_resource "$url" "$tmp" "$max_seconds" "$progress" \
       && validate_resource "$tmp" "$kind" "$expected" \
       && { [[ "$kind" != "menu" && "$kind" != "install" ]] || chmod +x "$tmp"; } \
       && mv -fT -- "$tmp" "$target"; then
        return 0
    fi
    rm -f -- "$tmp"
    return 1
}

# =========================================================================
# 步骤 1/8：环境检测
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 1/8：环境检测 ====${NC}"
if [ -z "$PREFIX" ] || [[ "$PREFIX" != "/data/data/com.termux/files/usr" ]]; then
    echo -e "${RED}${BOLD}>> 检测到非 Termux 环境，请在 Termux 中执行此脚本！${NC}"
    exit 1
fi

STORAGE_DIR="$HOME/storage/shared"
if [ ! -d "$STORAGE_DIR" ]; then
    echo -e "${YELLOW}${BOLD}>> 未检测到存储权限，尝试自动获取...${NC}"
    if ! command -v termux-setup-storage >/dev/null 2>&1; then
        echo -e "${YELLOW}${BOLD}>> 警告：'termux-setup-storage' 命令不存在，部分功能可能无法访问存储。${NC}"
    else
        termux-setup-storage
        echo -e "${CYAN}${BOLD}>> 请在弹出的窗口中点击“允许”授权，正在等待授权结果...${NC}"
        max_wait_time=15
        for ((i=0; i<max_wait_time; i++)); do
            [ -d "$STORAGE_DIR" ] && break
            sleep 1
        done
        if [ ! -d "$STORAGE_DIR" ]; then
            echo -e "${YELLOW}${BOLD}>> 警告：存储权限获取超时或被拒绝，部分功能可能受限。${NC}"
        else
            echo -e "${GREEN}${BOLD}>> 存储权限已成功获取。${NC}"
        fi
    fi
else
    echo -e "${GREEN}${BOLD}>> 存储权限已配置。${NC}"
fi
echo -e "${GREEN}${BOLD}>> 步骤 1/8 完成：环境检测通过。${NC}"

# =========================================================================
# 步骤 2/8：更新包管理器
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 2/8：更新包管理器 ====${NC}"
mirror_source="$PREFIX/etc/termux/mirrors/europe/packages.termux.dev"
mirror_target="$PREFIX/etc/termux/chosen_mirrors"
if [ -f "$mirror_source" ]; then
    mkdir -p "$(dirname "$mirror_target")"
    ln -sf "$mirror_source" "$mirror_target"
    echo -e "${GREEN}${BOLD}>> 已配置 Termux 官方镜像源。${NC}"
else
    echo -e "${YELLOW}${BOLD}>> 未检测到官方镜像配置，保留当前镜像配置。${NC}"
fi
if ! pkg update; then
    echo -e "${RED}${BOLD}>> 软件包索引更新失败，请检查网络连接状态。${NC}"
    exit 1
fi
if ! pkg upgrade -y -o Dpkg::Options::="--force-confnew"; then
    echo -e "${RED}${BOLD}>> 软件包升级失败，请确认网络连接状态。${NC}"
    exit 1
fi
echo -e "${GREEN}${BOLD}>> 步骤 2/8 完成：包管理器已更新。${NC}"

# =========================================================================
# 步骤 3/8：安装依赖
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 3/8：安装依赖 ====${NC}"
for dep in git curl zip unzip; do
    if ! command -v $dep >/dev/null 2>&1; then
        echo -e "${YELLOW}${BOLD}>> 检测到未安装：$dep，正在安装...${NC}"
        if ! pkg install -y "$dep"; then
            echo -e "${RED}${BOLD}>> $dep 安装失败，已中止安装，请检查网络或存储空间。${NC}"
            exit 1
        fi
    else
        echo -e "${CYAN}${BOLD}>> $dep 已安装，跳过。${NC}"
    fi
done

if ! command -v node >/dev/null 2>&1; then
    if pkg list-all | grep -q '^nodejs-lts/'; then
        echo -e "${YELLOW}${BOLD}>> 检测到未安装：node，正在安装 nodejs-lts...${NC}"
        if ! { pkg install -y nodejs-lts || pkg install -y nodejs; }; then
            echo -e "${RED}${BOLD}>> Node.js 安装失败，已中止安装。${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}${BOLD}>> 检测到未安装：node，正在安装 nodejs...${NC}"
        if ! pkg install -y nodejs; then
            echo -e "${RED}${BOLD}>> Node.js 安装失败，已中止安装。${NC}"
            exit 1
        fi
    fi
else
    echo -e "${CYAN}${BOLD}>> node 已安装，跳过。${NC}"
fi

for dep in git curl zip unzip node npm; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo -e "${RED}${BOLD}>> 检测到缺失依赖：$dep，已中止安装。${NC}"
        exit 1
    fi
done
if ! npm config set prefix "$PREFIX"; then
    echo -e "${RED}${BOLD}>> npm 配置失败，已中止安装，请检查配置文件权限。${NC}"
    exit 1
fi
echo -e "${GREEN}${BOLD}>> 步骤 3/8 完成：依赖已安装。${NC}"

# =========================================================================
# 步骤 4/8：下载并配置终端字体
# 字体：Maple Mono NF CN，作者：subframe7536
# 来源：https://github.com/subframe7536/maple-font
# 许可证：SIL Open Font License 1.1，原文见仓库 MapleMono-OFL.txt
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 4/8：下载并配置终端字体 ====${NC}"
FONT_DIR="$HOME/.termux"
FONT_PATH="$FONT_DIR/font.ttf"
mkdir -p "$FONT_DIR" || { echo -e "${RED}${BOLD}>> 字体目录创建失败。${NC}"; exit 1; }
font_ready=0
if validate_resource "$FONT_PATH" font; then
    font_ready=1
    echo -e "${YELLOW}${BOLD}>> 字体文件已存在，跳过下载。${NC}"
else
    if download_validated "https://github.com/print-yuhuan/SillyTavern-Termux/raw/refs/heads/main/MapleMono.ttf" "$FONT_PATH" font "" 300 progress; then
        font_ready=1
        echo -e "${GREEN}${BOLD}>> 字体已下载并保存为 .termux/font.ttf${NC}"
    else
        echo -e "${RED}${BOLD}>> 字体下载失败，请检查网络或稍后重试。${NC}"
        echo -e "${YELLOW}${BOLD}>> 步骤 4/8 跳过：字体未配置成功。${NC}"
    fi
fi

if [ "$font_ready" -eq 1 ]; then
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings \
        && echo -e "${GREEN}${BOLD}>> 配置已自动刷新，字体已生效。${NC}" \
        || echo -e "${YELLOW}${BOLD}>> 尝试刷新配置失败，请手动重启 Termux。${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 未检测到 termux-reload-settings，请手动重启 Termux 使字体生效。${NC}"
    fi
    echo -e "${GREEN}${BOLD}>> 步骤 4/8 完成：终端字体已配置。${NC}"
fi

# =========================================================================
# 步骤 5/8：克隆 SillyTavern 主仓库
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 5/8：克隆 SillyTavern 仓库 ====${NC}"
if [ -e "$HOME/SillyTavern/.git" ] \
   && git -C "$HOME/SillyTavern" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${YELLOW}${BOLD}>> SillyTavern 仓库已存在，跳过克隆。${NC}"
    echo -e "${YELLOW}${BOLD}>> 步骤 5/8 跳过：仓库已存在。${NC}"
else
    if [ -e "$HOME/SillyTavern" ] || [ -L "$HOME/SillyTavern" ]; then
        echo -e "${RED}${BOLD}>> 检测到现有 SillyTavern 目录，但未找到有效的 Git 仓库，已中止克隆。${NC}"
        echo -e "${YELLOW}${BOLD}>> 现有文件与数据已保留，请先备份并确认安装来源后再继续。${NC}"
        exit 1
    fi
    if git clone https://github.com/SillyTavern/SillyTavern "$HOME/SillyTavern"; then
        echo -e "${GREEN}${BOLD}>> 步骤 5/8 完成：SillyTavern 仓库已克隆。${NC}"
    else
        echo -e "${RED}${BOLD}>> 仓库克隆失败，请检查网络连接。${NC}"
        exit 1
    fi
fi

# =========================================================================
# 步骤 6/8：下载菜单脚本与配置文件
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 6/8：下载菜单脚本与配置文件 ====${NC}"
MENU_PATH="$HOME/Menu.sh"
ENV_PATH="$HOME/.env"
MENU_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/Menu.sh"
ENV_URL="https://raw.githubusercontent.com/print-yuhuan/SillyTavern-Termux/refs/heads/main/.env"

if validate_resource "$MENU_PATH" menu; then
    echo -e "${YELLOW}${BOLD}>> Menu.sh 已存在，跳过下载。${NC}"
else
    download_validated "$MENU_URL" "$MENU_PATH" menu \
    || { echo -e "${RED}${BOLD}>> Menu.sh 下载或校验失败，已中止安装！${NC}"; exit 1; }
fi

if validate_resource "$ENV_PATH" env; then
    echo -e "${YELLOW}${BOLD}>> .env 已存在，跳过下载。${NC}"
else
    if [ -e "$ENV_PATH" ] || [ -L "$ENV_PATH" ]; then
        echo -e "${RED}${BOLD}>> .env 配置校验失败，已中止安装。${NC}"
        echo -e "${YELLOW}${BOLD}>> 原配置已保留，请检查 START_MODE 与文件语法后重试。${NC}"
        exit 1
    fi
    download_validated "$ENV_URL" "$ENV_PATH" env "" 30 \
    || { echo -e "${RED}${BOLD}>> .env 下载或校验失败，已中止安装！${NC}"; exit 1; }
fi

if ! source "$ENV_PATH"; then
    echo -e "${RED}${BOLD}>> .env 配置加载失败，已中止安装。${NC}"
    exit 1
fi
echo -e "${GREEN}${BOLD}>> 步骤 6/8 完成：菜单脚本与配置文件已就绪。${NC}"

# =========================================================================
# 步骤 7/8：配置菜单自启动
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 7/8：配置菜单自启动 ====${NC}"
PROFILE_FILE=""
for pf in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$pf" ]; then
        PROFILE_FILE="$pf"
        break
    fi
done
if [ -z "$PROFILE_FILE" ]; then
    PROFILE_FILE="$HOME/.bashrc"
fi
touch "$PROFILE_FILE"
if ! grep -qE 'bash[ ]+\$HOME/Menu\.sh' "$PROFILE_FILE"; then
    if [ -s "$PROFILE_FILE" ]; then
        echo '' >> "$PROFILE_FILE"
    fi
    echo '# SillyTavern-Termux 菜单自启动' >> "$PROFILE_FILE"
    echo 'bash $HOME/Menu.sh' >> "$PROFILE_FILE"
    echo -e "${GREEN}${BOLD}>> 步骤 7/8 完成：已配置菜单自启动。${NC}"
else
    echo -e "${YELLOW}${BOLD}>> 菜单自启动已配置，跳过。${NC}"
    echo -e "${YELLOW}${BOLD}>> 步骤 7/8 跳过：菜单自启动已存在。${NC}"
fi

# =========================================================================
# 步骤 8/8：安装 SillyTavern 依赖
# =========================================================================
echo -e "\n${CYAN}${BOLD}==== 步骤 8/8：安装 SillyTavern 依赖 ====${NC}"
cd "$HOME/SillyTavern" || { echo -e "${RED}${BOLD}>> 进入 SillyTavern 目录失败！${NC}"; exit 1; }
export NODE_ENV=production
required_node=$(node -p 'const p=JSON.parse(require("fs").readFileSync("package.json", "utf8")); (p.engines && p.engines.node) || "未指定"') || {
    echo -e "${RED}${BOLD}>> 无法读取酒馆运行环境要求，已中止依赖安装。${NC}"; exit 1;
}
echo -e "${CYAN}${BOLD}>> 当前 Node.js：$(node -v)，酒馆版本要求：${required_node}${NC}"

retry_count=0
max_retries=3
install_success=0

while [ $retry_count -lt $max_retries ]; do
    if [ $retry_count -eq 0 ]; then
        echo -e "${CYAN}${BOLD}>> 正在安装 SillyTavern 依赖，请耐心等待…${NC}"
    else
        echo -e "${YELLOW}${BOLD}>> 重试安装依赖（第 $retry_count 次）…${NC}"
    fi

    if npm install --engine-strict --no-audit --no-fund --loglevel=error --omit=dev --prefer-offline; then
        install_success=1
        break
    else
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo -e "${YELLOW}${BOLD}>> 依赖安装失败，正在清理缓存并准备重试…${NC}"
            [ -d node_modules ] && rm -rf node_modules
            [ -d "$HOME/.npm/_cacache" ] && npm cache clean --force
            sleep 3
        fi
    fi
done

if [ $install_success -eq 1 ]; then
    echo -e "${GREEN}${BOLD}>> 步骤 8/8 完成：SillyTavern 依赖已安装。${NC}"
else
    echo -e "${RED}${BOLD}>> 依赖安装失败，已重试 $max_retries 次，请检查网络连接或日志信息。${NC}"
    echo -e "${YELLOW}${BOLD}>> 若日志提示 EBADENGINE，请升级 Node.js 至 ${required_node} 后重试。${NC}"
    exit 1
fi

# =========================================================================
# 安装完成，进入主菜单
# =========================================================================
echo -e "\n${GREEN}${BOLD}==== 安装完成！即将启动主菜单 ====${NC}\n"
echo -e "${CYAN}${BOLD}>> 按任意键进入主菜单...${NC}"
read -n1 -s
exec bash "$HOME/Menu.sh"
