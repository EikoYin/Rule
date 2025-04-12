#!/bin/sh

# 默认日志文件路径
LOG_FILE="${LOG_FILE:-/var/log/sing-box-config-stop.log}"

# 重定向输出到日志文件
exec > >(tee -a "$LOG_FILE") 2>&1

# 获取当前时间
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# 错误处理函数
error_exit() {
    echo "$(timestamp) 错误: $1" >&2
    exit "${2:-1}"
}

# 检查命令是否存在
check_command() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error_exit "$cmd 未安装，请安装后再运行此脚本"
    fi
}

# 捕获中断信号以进行清理
trap 'error_exit "脚本被中断"' INT TERM

# 检查是否以 root 权限运行
if [ "$(id -u)" != "0" ]; then
    error_exit "此脚本需要 root 权限运行"
fi

# 检查必要命令是否安装
check_command "sing-box"
check_command "nft"
check_command "ip"

# 停止 sing-box 服务
killall sing-box 2>/dev/null && echo "$(timestamp) 已停止现有 sing-box 服务" || echo "$(timestamp) 没有运行中的 sing-box 服务"

# 删除防火墙规则文件
rm -f /etc/nftables.d/99-singbox.nft && echo "$(timestamp) 已删除防火墙规则文件"

# 删除 sing-box 表
nft delete table inet sing-box 2>/dev/null && echo "$(timestamp) 已删除 sing-box 表"

# 删除路由规则和清理路由表
ip rule del fwmark 1 table 100 2>/dev/null && echo "$(timestamp) 已删除路由规则"
ip route flush table 100 && echo "$(timestamp) 已清理路由表"

# 删除缓存
rm -f /etc/sing-box/cache.db && echo "$(timestamp) 已清理缓存文件"

echo "$(timestamp) 停止sing-box并清理完毕"
