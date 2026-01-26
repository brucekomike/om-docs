# frp
```
git clone https://github.com/brucekomike/frp-scripts
cd frp-scripts
```

## server 
```
./frps-setup.sh
```
编辑配置文件后
```
systemctl start frps
```
## client
```
./frpc-setup.sh
```
编辑配置文件后
```
systemctl start frpc
```