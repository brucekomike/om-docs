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
```

## initial start
```
cd keycloak-26.4.7
bin/kc.sh start --bootstrap-admin-username tmpadm --bootstrap-admin-password pass
```

```
bin/kc.sh start --proxy-headers forwarded --proxy-trusted-addresses=127.0.0.1/8 --http-enabled true
```

## create an admin user
access the 8080 port