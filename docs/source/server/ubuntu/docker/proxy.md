# 配置代理

本文介绍如何为docker 配置代理。适用于网络环境不好的场景。
## 创建配置文件
```
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo touch /etc/systemd/system/docker.service.d/proxy.conf
```
## 编辑配置文件
记得编辑内容，使其符合局域网内的代理服务配置。
```
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080/"
Environment="HTTPS_PROXY=http://proxy.example.com:8080/"
Environment="NO_PROXY=localhost,127.0.0.1,.example.com"
```
## 刷新服务
```
sudo systemctl daemon-reload 
sudo systemctl restart docker.service
```