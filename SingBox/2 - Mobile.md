# 1. 删除路径
   "external_ui": "/etc/momo/run/ui"
   "external_ui_download_url": "https://gh-proxy.com/https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages.zip"
   "external_ui_download_detour": "Direct"
   "path": "/etc/momo/run/cache.db"

# 2. 修改 0.0.0.0
   "external_controller": "0.0.0.0:9090"→"external_controller": "127.0.0.1:9090"

# 3. 修改 inbounds
   "inbounds": [
   {
     "type": "tun",
     "address": [
       "172.18.0.1/30",
       "fdfe:dcba:9876::1/126"
     ],
     "stack": "mixed",
     "auto_route": true,
     "platform": {
       "http_proxy": {
         "enabled": true,
         "server": "127.0.0.1",
         "server_port": 7890
       }
     }
   },
   {
     "type": "mixed",
     "listen": "127.0.0.1",
     "listen_port": 7890
   }
     ],

# 4. 修改 rules
   {"inbound": "dns-in", "action": "hijack-dns"}→{"type": "logical", "mode": "or", "rules": [{"port": 53}, {"protocol": "dns"}], "action": "hijack-dns"}

# 5. 添加 auto_detect_interface
   在"rule_set"的"final"下一行添加"auto_detect_interface": true
