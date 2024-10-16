#!/bin/bash

# 询问用户输入域名和邮箱
read -p "请输入你的域名: " domain
read -p "请输入你的邮箱: " email
read -p "请输入你的面板ID: " node_id

# 安装 XrayR
echo "正在安装 XrayR..."
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

# 开启和配置防火墙
echo "配置防火墙中..."
yew | sudo ufw enable
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 22/tcp
sudo ufw reload

# 安装 Certbot
echo "正在安装 certbot..."
sudo apt update
sudo apt install -y certbot

# 申请 SSL 证书
echo "正在为域名 $domain 申请证书..."
sudo certbot certonly --standalone -d "$domain" --email "$email" --agree-tos --non-interactive

# 记录证书路径
certpem_path="/etc/letsencrypt/live/$domain/cert.pem"
privkey_path="/etc/letsencrypt/live/$domain/privkey.pem"

# 修改权限
echo "修改权限中..."
chmod 777 /etc/letsencrypt/
chmod 777 /etc/XrayR
chmod 777 /etc/XrayR/config.yml
chmod 777 /etc/letsencrypt/live/
chmod 777 /etc/letsencrypt/live/$domain
chmod 777 "$certpem_path"
chmod 777 "$privkey_path"

# 修改 XrayR 配置文件
echo "正在修改 /etc/XrayR/config.yml..."
cat <<EOF > /etc/XrayR/config.yml
Log:
  Level: warning
  AccessPath: 
  ErrorPath: 
DnsConfigPath: 
RouteConfigPath: 
InboundConfigPath: 
OutboundConfigPath: 
ConnectionConfig:
  Handshake: 4
  ConnIdle: 30
  UplinkOnly: 2
  DownlinkOnly: 4
  BufferSize: 64
Nodes:
  - PanelType: "NewV2board"
    ApiConfig:
      ApiHost: "https://x.mayi520.shop"
      ApiKey: "F9U42H892HFEWOIHFJ298"
      NodeID: $node_id
      NodeType: Trojan
      Timeout: 30
      EnableVless: false
      VlessFlow: "xtls-rprx-vision"
      SpeedLimit: 0
      DeviceLimit: 0
      RuleListPath: 
      DisableCustomConfig: false
    ControllerConfig:
      ListenIP: 0.0.0.0
      SendIP: 0.0.0.0
      UpdatePeriodic: 60
      EnableDNS: false
      DNSType: AsIs
      EnableProxyProtocol: false
      AutoSpeedLimitConfig:
        Limit: 0
        WarnTimes: 0
        LimitSpeed: 0
        LimitDuration: 0
      GlobalDeviceLimitConfig:
        Enable: false
        RedisNetwork: tcp
        RedisAddr: 127.0.0.1:6379
        RedisUsername: 
        RedisPassword: YOUR_PASSWORD
        RedisDB: 0
        Timeout: 5
        Expiry: 60
      EnableFallback: false
      FallBackConfigs:
        - SNI: 
          Alpn: 
          Path: 
          Dest: 80
          ProxyProtocolVer: 0
      DisableLocalREALITYConfig: false
      EnableREALITY: false
      REALITYConfigs:
        Show: true
        Dest: www.amazon.com:443
        ProxyProtocolVer: 0
        ServerNames:
          - www.amazon.com
        PrivateKey: YOUR_PRIVATE_KEY
        MinClientVer: 
        MaxClientVer: 
        MaxTimeDiff: 0
        ShortIds: 
          - ""
          - 0123456789abcdef
      CertConfig:
        CertMode: file
        CertDomain: "$domain"
        CertFile: "$certpem_path"
        KeyFile: "$privkey_path"
EOF


# 重启 XrayR
echo "重启 XrayR..."
xrayr restart

echo "所有步骤完成！"
