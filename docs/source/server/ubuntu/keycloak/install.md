# install

## deps
```
sudo apt update && sudo apt upgrade
sudo apt install openjdk-21-jre
```
## download
download the zip file.
```
wget https://github.com/keycloak/keycloak/releases/download/26.4.7/keycloak-26.4.7.zip
unzip keycloak-26.4.7.zip
useradd keycloa
chown -R keycloak:keycloak keylocak-26.4.7
```

## config systemd
```
sudo useradd keycloak
```
```
[Unit]
Description=Keycloak Service
After=network.target

[Service]
User=keycloak
Group=keycloak
SuccessExitStatus=143
ExecStart=/opt/keycloak/keycloak-26.4.7/bin/kc.sh start --proxy-headers forwarded --proxy-trusted-addresses=127.0.0.1/8 --http-enabled true --optimized
WorkingDirectory=/opt/keycloak/keycloak-26.4.7

[Install]
WantedBy=multi-user.target
```

## nginx
```
server {
  server_name keycloak.public.dns;

  # To only redirect a specific set of paths, you may replace the line below with something of the form
  # location ~ ^(/auth/resources/|/auth/js/|/auth/realms/olvid/) {
  location /auth {
  proxy_set_header X-Forwarded-For $remote_addr;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Forwarded-Host $host;

	proxy_buffer_size       128k;
	proxy_buffers           4 256k;
	proxy_busy_buffers_size 256k;

	proxy_pass http://127.0.0.1:8080;
  }

  location /olvid {
    return 302 /auth/olvid/;
  }

  location = / {
    return 302 /auth;
  }

  client_max_body_size 10M;

  listen [::]:443 ssl ipv6only=on;
  listen 443 ssl;

  ssl_certificate /etc/letsencrypt/live/keycloak.public.dns/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/keycloak.public.dns/privkey.pem;
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}

server {
  server_name keycloak.public.dns;
  listen [::]:80;
  listen 80;

  return 301 https://$host$request_uri;
}
```

## create an admin user
access the 8080 port

