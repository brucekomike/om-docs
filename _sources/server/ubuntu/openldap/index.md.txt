# openldap

## installation
```
sudo apt install slapd
sudo dpkg-reconfigure slapd
```

## config
```{code-block}
wget {{url}}/remote/ubuntu/slapd/bootstrap.ldif
wget {{url}}/remote/ubuntu/slapd/memberof2.ldif
wget {{url}}/remote/ubuntu/slapd/memberof3.ldif
```

## apply config
```
ldapadd -x -D "cn=admin,dc=<MY-DOMAIN>,dc=<COM>" -W -f bootstrap.ldif
```
```
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f memberof2.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f memberof3.ldif

```

## search
without login
```
ldapsearch -x -b "ou=users,dc=example,dc=com" "(uid=xxx)"
```
```
sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b "dc=example,dc=com"
```
with login
```
ldapsearch -x -H ldap://ldap.example.com \
    -D "cn=admin,dc=example,dc=com" -w "password" \
    -b "dc=example,dc=com" "(mail=john.doe@example.com)"
```
