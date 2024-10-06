
# ansible tasks for mysql.yml



### only re/create all admin users 
```bash 
ansible-playbook ./mysql.yml -t mysql_admin_users  -l 'mysql_sdl_playground'
```
### recreate instance_info table 
```bash
ansible-playbook mysql.yml -t instance_info -l mysql_pii_members -l pdb-mysql-pii-members0a.uw2-pub-1.wixprod.net 
```
### reconfigure mysql files 
```bash 
ansible-playbook mysql.yml -l mysql_yosi_test -t mysql_config_files 
```


### reconfigure base packges (py,py3)
```bash 
ansible-playbook mysql.yml -t r_common  -l mysql_sdl_playground

```
### add /re-add new skip slave 
```bash
ansible-playbook mysql.yml -t r_common -t skip_slave -l mysql_sdl_playground
``` 
