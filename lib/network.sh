#!/data/data/com.termux/files/usr/bin/bash
# =========================================================================
# 网络工具函数库
# 职责：获取局域网 IPv4 地址
# =========================================================================

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

        # 备用方案：获取任意非 lo/tun/ppp 接口的地址
        ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '!/ (lo|tun|ppp)/ {print $4}' | cut -d'/' -f1 | head -n1)
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
