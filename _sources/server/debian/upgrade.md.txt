# 升级系统

## 更新
```
apt update && apt full-upgrade
```

## 换源
把所有包名改成最新的

### 12 to 13

```
sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
```

## 更新

### part1

```
apt-mark hold mdadm
apt update && apt full-upgrade
```

### part2
```
apt-mart unhold mdadm
apt update && apt full-upgrade