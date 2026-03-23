# 1. 修改 experimental

"external_ui": "/etc/momo/run/ui"→"external_ui": "/etc/sing-box/run/ui"

"path": "/etc/momo/run/cache.db"→"path": "/etc/sing-box/run/cache.db"

# 2. 修改 inbounds

  "inbounds": [
    {
      "tag": "tun-in",
      "type": "tun",
      "address": [
        "172.18.0.1/30",
        "fdfe:dcba:9876::1/126"
      ],
      "mtu": 9000,
      "auto_route": true,
      "auto_redirect": true,
      "strict_route": false
    },
    {
      "type": "mixed",
      "listen": "::",
      "listen_port": 7890
    }
  ],

# 3. 修改 rules

{"inbound": "dns-in", "action": "hijack-dns"}→{"type": "logical", "mode": "or", "rules": [{"port": 53}, {"protocol": "dns"}], "action": "hijack-dns"}

# 4. 修改 rule_set

"auto_detect_interface": false→"auto_detect_interface": true
