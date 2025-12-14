# config

## use system nginx
```
nginx['enable'] = false
web_server['external_users'] = ['www-data']
gitlab_rails['trusted_proxies'] = [ '192.168.1.0/24', '192.168.2.1', '2001:0db8::/32' ]
```

### find the nginx config file
https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/support/nginx

## usage in unpriviliged CT
in the gitlab.rb
```
"package['modify_kernel_parameters'] = false"
```

## test ldap
```
sudo gitlab-rake gitlab:ldap:check
```