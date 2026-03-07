# 1. 删除路径

external-ui: "/etc/nikki/run/ui"

external-ui-name: zashboard

external-ui-url: "https://gh-proxy.com/https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages.zip"

# 2. 修改 0.0.0.0
external-controller: 0.0.0.0:9090→external-controller: 127.0.0.1:9090

listen: 0.0.0.0:1053→listen: 127.0.0.1:1053

# 3. 修改 tun  

auto-route: false→auto-route: true

auto-redirect: false→auto-redirect: true

auto-detect-interface: false→auto-detect-interface: true
