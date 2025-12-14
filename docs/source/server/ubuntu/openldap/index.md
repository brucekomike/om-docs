# openldap

## installation
```
sudo apt install slapd
sudo dpkg-reconfigure slapd
```

## config
```plain
cat << EOF > bootstrap.ldif
# users, lab.bytepen.com
dn: ou=users,dc=example,dc=com
changetype: add
objectClass: organizationalUnit
ou: users

# groups, lab.bytepen.com
dn: ou=groups,dc=example,dc=com
changetype: add
objectClass: organizationalUnit
ou: groups
EOF
```
(base dn backup)
```
# example.com
dn: dc=example,dc=com
changetype: add
objectClass: dcObject
objectClass: organization
dc: example
o: Example Company
```
## apply config
```
ldapadd -x -D "cn=admin,dc=<MY-DOMAIN>,dc=<COM>" -W -f bootstrap.ldif
```