# config

## ldap federation
main config
- ldap://127.0.0.1:389
- ou=users,dc=_,dc=_
- WRITABLE

group config
1. add mapper
2. 选择 group-ldap-mapper
3. ou=groups,dc=_,dc=_
4. `User Group Retrieve Stratagy` => `GET_GROUP_`
5. `Member-Of LDAP Attr` => `memberOf`