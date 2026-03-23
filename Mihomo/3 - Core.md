# 1. 删除项目

port: 8080

socks-port: 1080

redir-port: 7891

tproxy-port: 7892

# 2. 修改 external

external-ui: "/etc/nikki/run/ui"→external-ui: "/etc/mihomo/run/ui"


# 3. 修改 tun  

auto-route: false→auto-route: true

auto-redirect: false→auto-redirect: true

auto-detect-interface: false→auto-detect-interface: true
