# mariadb
## 快速入门
### 安装
```
sudo apt install mariadb-server

```

### 初始设置
```
mariadb-secure-installation

```
### 登录
```
mariadb -u root -p

```

### 基础操作
new db
```
CREATE DATABASE dbname;

```
new user
```
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';

```
reset user password
```
ALTER USER 'username'@'localhost' IDENTIFIED BY 'new_passwd';

```

grant privileges
```
GRANT ALL PRIVILEGES ON dbname.* TO 'username'@'localhost';

```
reload preivileges
```
FLUSH PRIVILEGES;

```

delete user
```
DROP USER username;

```

delete db
```
DROP DATABASE dbname;

```
