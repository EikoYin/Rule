#!/bin/sh

# 配置参数
BACKEND_URL=""  # 转换后端地址
SUBSCRIPTION_URL=""  # 订阅地址
TEMPLATE_URL="https://raw.githubusercontent.com/EikoYin/Rule/refs/heads/main/Sing-Box/Config%20-%20Icon.json"  # 配置文件（规则模板)
MAX_RETRIES=3  # 最大重试次数
RETRY_DELAY=3  # 重试间隔时间（秒）
CONFIG_FILE="/etc/sing-box/config.json"
CONFIG_BACKUP="/etc/sing-box/configbackup.json"


# 默认日志文件路径
LOG_FILE="${LOG_FILE:-/var/log/sing-box-config.log}"


# 获取当前时间
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# 错误处理函数
error_exit() {
    echo "$(timestamp) 错误: $1" >&2
    exit "${2:-1}"
}

# 捕获中断信号以进行清理
trap 'error_exit "脚本被中断"' INT TERM

# 检查命令是否存在
check_command() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error_exit "$cmd 未安装，请安装后再运行此脚本"
    fi
}

# 停止 sing-box 服务
if killall sing-box 2>/dev/null; then
    echo "$(timestamp) 已停止现有 sing-box 服务"
else
    echo "$(timestamp) 没有运行中的 sing-box 服务"
fi
# 检查并删除已存在的 sing-box 表（如果存在）
if nft list tables | grep -q 'inet sing-box'; then
    nft delete table inet sing-box
fi


# 检查网络连接
check_network() {
    local ping_count=3
    local test_host="223.5.5.5"
    
    echo "$(timestamp) 检查网络连接..."
    if ! ping -c $ping_count $test_host >/dev/null 2>&1; then
        error_exit "网络连接失败，请检查网络设置"
    fi
}

# 检查端口占用
check_port() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        error_exit "端口 $port 已被占用"
    fi
}

# 下载配置文件
download_config() {
    local retry=0
    local url="$1"
    local output_file="$2"
    
    while [ $retry -lt $MAX_RETRIES ]; do
        if curl -L --connect-timeout 10 --max-time 30 -v "$url" -o "$output_file"; then
            echo "$(timestamp) 配置文件下载成功"
            return 0
        fi
        retry=$((retry + 1))
        echo "$(timestamp) 下载失败，第 $retry 次重试..."
        sleep $RETRY_DELAY
    done
    return 1
}

# 备份配置文件
backup_config() {
    local config_file="$1"
    local backup_file="$2"
    
    if [ -f "$config_file" ]; then
        cp "$config_file" "$backup_file"
        echo "$(timestamp) 已备份当前配置"
    fi
}

# 还原配置文件
restore_config() {
    local backup_file="$1"
    local config_file="$2"
    
    if [ -f "$backup_file" ]; then
        cp "$backup_file" "$config_file"
        echo "$(timestamp) 已还原至备份配置"
    fi
}


# 检查是否以 root 权限运行
if [ "$(id -u)" != "0" ]; then
    error_exit "此脚本需要 root 权限运行"
fi

# 检查必要命令是否安装
check_command "sing-box"
check_command "curl"
check_command "nft"
check_command "ip"
check_command "ping"
check_command "netstat"

# 检查网络和端口
check_network
check_port "$TPROXY_PORT"

# 创建配置目录
mkdir -p /etc/sing-box

# 备份当前配置
backup_config "$CONFIG_FILE" "$CONFIG_BACKUP"

# 下载新配置
echo "$(timestamp) 开始下载配置文件..."
FULL_URL="${BACKEND_URL}/config/${SUBSCRIPTION_URL}&file=${TEMPLATE_URL}"

if ! download_config "$FULL_URL" "$CONFIG_FILE"; then
    error_exit "配置文件下载失败，已重试 $MAX_RETRIES 次"
fi

# 验证配置
if ! sing-box check -c "$CONFIG_FILE"; then
    echo "$(timestamp) 配置文件验证失败，正在还原备份"
    restore_config "$CONFIG_BACKUP" "$CONFIG_FILE"
    error_exit "配置验证失败"
fi


# 启动服务并将输出重定向到 /dev/null( >/dev/null 2>&1 &)
echo "$(timestamp) 启动 sing-box 服务..."
sing-box run -c "$CONFIG_FILE" >/dev/null 2>&1 &

# 检查服务状态
sleep 2
if pgrep -x "sing-box" > /dev/null; then
    echo "$(timestamp) sing-box 启动成功  运行模式--Tun"
else
    error_exit "sing-box 启动失败，请检查日志"
fi