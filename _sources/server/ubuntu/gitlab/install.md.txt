# install

## update && upgrade
update system
```
sudo apt update && sudo apt upgrade 
```


## ensure services
```
sudo systemctl enable --now ssh
```

## firewall (UFW)
```
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## add repo (ce)
```
sudo apt install -y curl
curl "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh" | sudo bash
```

## set url and install
```
sudo EXTERNAL_URL="https://gitlab.example.com" apt install gitlab-ce
```

