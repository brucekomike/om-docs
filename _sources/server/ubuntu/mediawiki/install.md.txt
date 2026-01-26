# mediawiki installation

## update system packages
```
sudo apt update && sudo apt upgrade
export apt_cli="sudo apt install"
$apt_cli nginx mariadb-server composer
$apt_cli php-fpm php php-mysql php-xml php-mbstring php-intl php-curl php-apcu php-gd
```
## setup proxy scripts
```
# required for local mandariners, client settings see [[ssh]]
curl -fsSL "ossmedia.cn/set-proxy.sh?raw" | OW_PORT=12321 bash
```

## env
环境变量,后面的脚本依赖这个,插件列表也在这里，记得改一下，然后存一个自己的版本，新安装的话，好像不需要socialprofile
### 1.43

```
## edit this part as your wish
export mw_version=REL1_43
export citizen_ver=v2.40.2
export proxyer=
# comment the proxyer below to use the actual proxyer
export proxyer=proxy.sh
export run_as_user="sudo -u www-data $proxyer"

## should not be edited
export git_var="--branch $mw_version --single-branch --depth 1"
```

### 1.44
目前 PreToClip 以及 DPL3 没有 REL1_44 这个分支，需要手动选择 master
```
## edit this part as your wishs
export mw_version=REL1_44
export citizen_ver=v3.1.0
export proxyer=
# comment the proxyer below to use the actual proxyer
export proxyer=proxy.sh
export run_as_user="sudo -u www-data $proxyer"

## should not be edited
export git_var="--branch $mw_version --single-branch --depth 1"
```
## extension select
```
# extension list
declare -a basictools=("Popups" 
"PreToClip"
"Popups"
"TemplateStyles"
"ConfirmAccount"
"intersection"
"CodeMirror"
)
# multi lang pack
declare -a multilang=("Babel"
"cldr"
"CleanChanges"
"Translate"
"UniversalLanguageSelector"
)
declare -a centered_auth=(
"Interwiki"
"PluggableAuth"
"Auth_remoteuser"
"LDAPAuthentication2"
"LDAPAuthorization"
"LDAPGroups"
"LDAPUserInfo"
"LDAPProvider"
"LDAPSyncAll"
"PluggableAuth"
)
#"BlueSpiceExtendedSearch"
#"JsonConfig"
#"SocialProfile"
```
then have a sellection
### basic
```
extns=("${basictools[@]}")
```
### basic + multilang
```
extns=("${basictools[@]}" "${multilang[@]}")
```
### basic + multilang + ldap (1.43)
```
extns=("${basictools[@]}" "${multilang[@]}" "${centered_auth[@]}")
```
## db init
只有第一次安装需要这个，所以没怎么测试，配置数据库的
### credits 
```
# Set your variables
export db_user="your_username"
export db_name="your_database"
export db_pass=$(openssl rand -base64 12)  # Generates a random password

# MySQL root credentials
export db_root="root"
export db_root_pass="passwd here"
```

### db creation
```
# Create the database
mysql -u "$db_root" -p"$db_root_pass" -e "CREATE DATABASE IF NOT EXISTS $db_name;"

# Create the user and grant permissions
mysql -u "$db_root" -p"$db_root_pass" -e "CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
mysql -u "$db_root" -p"$db_root_pass" -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';"
mysql -u "$db_root" -p"$db_root_pass" -e "FLUSH PRIVILEGES;"

# Output the generated password
echo "Database: $db_name"
echo "User: $db_user"
echo "Password: $db_pass"
```
## pre wiki upgrade
备份数据库，更新前跑一下，以防万一不是，先进到安装目录
```
# create the backups dir
$run_as_user mkdir backups
cd backups
```
然后从你的配置文件拉取账号信息自动备份，假定用的mariadb（mysql估计没问题
```
# Path to your LocalSettings.php file
export conf_file="../LocalSettings.php"
export separator="'"
# might be '"' at 1.41, and "'" in 1.42
```
```
# Extract database credentials
export db_name=$($run_as_user grep "\$wgDBname" "$conf_file" | awk -F $separator '{print $2}')
export db_user=$($run_as_user grep "\$wgDBuser" "$conf_file" | awk -F $separator '{print $2}')
export db_pass=$($run_as_user grep "\$wgDBpassword" "$conf_file" | awk -F $separator '{print $2}')

timestamp=$(date +%Y%m%d_%H%M%S)
sql_bak="backup_${timestamp}.sql"
xml_bak="backup_${timestamp}.xml"

$run_as_user mysqldump --user=$db_user --password=$db_pass $db_name | $run_as_user tee $sql_bak > /dev/null
$run_as_user mysqldump --user=$db_user --password=$db_pass $db_name --xml | $run_as_user tee $xml_bak > /dev/null
```

## main
安装主要部分，本体、插件、皮肤
```
# get the mediawiki
cd /opt/www
$run_as_user git clone https://gerrit.wikimedia.org/r/mediawiki/core.git \
$git_var mediawiki-$mw_version

# get vendor lib
cd mediawiki-$mw_version
# first update all submodule
$run_as_user git submodule update --init --recursive --depth 1

# composer way, in use
$run_as_user composer install --no-dev
# git way, commented
#$run_as_user git clone https://gerrit.wikimedia.org/r/mediawiki/vendor.git $git_var 

## get the extensions

cd extensions

export repo_url=https://github.com/wikimedia/mediawiki-extensions-
for extn in "${extns[@]}"; do
  echo installing extension: $extn
  $run_as_user git clone $repo_url$extn $extn $git_var
done

# dpl3
export repo_url=https://github.com/Universal-Omega/DynamicPageList3.git
$run_as_user git clone $repo_url $git_var

# extender
export get_repo="git clone https://github.com/octfx/mediawiki-extensions-TemplateStylesExtender"
export clone_dir="TemplateStylesExtender"
$run_as_user $get_repo $clone_dir

# misctools
export repo_url=https://github.com/brucekomike/MiscTools
$run_as_user git clone $repo_url $git_var

## extentions install
for dir in */; do
  if [ -d "$dir" ]; then
    echo "Entering directory: $dir"
    cd "$dir"
    # Check if composer.json exists
    if [ -f "composer.json" ]; then
      $run_as_user composer install --no-dev
    else
      echo "No composer.json found in $dir, skipping..."
    fi
    cd ..
  fi
done

## get skin
cd ../skins

# citizen
export repo_url=https://github.com/StarCitizenTools/mediawiki-skins-Citizen
$run_as_user git clone $repo_url --branch $citizen_ver --single-branch --depth=1 Citizen

# back to the main dir
cd ..
```
## post installation
just enable what your want, and config as other pages discribed
### 复制文件
命令可以用这个
`$run_as_user cp <old_dir> <new_dir>`
检查列表(相对路径)
- /LocalSettings.php
- /resources/assets/*
### update scripts
最后运行更新脚本
```
$run_as_user php maintenance/run.php update
```
### linking
替换软链接上架网站 XD
```
# link the installation to /var/www
cd ..
sudo rm /var/www/mediawiki
sudo ln -s /opt/www/mediawiki-$mw_version /var/www/mediawiki
```
