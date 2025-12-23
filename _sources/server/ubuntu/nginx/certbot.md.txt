# cerbot
配置ssl证书

## 安装
```
sudo apt update
sudo apt install python3 python3-venv libaugeas-dev
sudo python3 -m venv /opt/certbot/
sudo /opt/certbot/bin/pip install --upgrade pip
sudo /opt/certbot/bin/pip install certbot certbot-nginx
sudo ln -s /opt/certbot/bin/certbot /usr/bin/certbot
```

## 生成证书（交互式）（nginx）
```
cerbot --nginx
```