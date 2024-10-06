


testm.cq45vv1w7ovq.eu-west-1.rds.amazonaws.com
testm-replica.cq45vv1w7ovq.eu-west-1.rds.amazonaws.com


select @@gtid_mode,@@enforce_gtid_consistency;
+----------------+----------------------------+
| @@gtid_mode    | @@enforce_gtid_consistency |
+----------------+----------------------------+
| ON | ON                        |
+----------------+----------------------------+
1 row in set (0.0005 sec)


```sql
-- on master 
CREATE USER 'repl_user'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'repl_user'@'%';
```


```sql
-- on master 
select @@gtid_current_pos; -- get the gtid pos
-- on slave 
CALL mysql.rds_set_external_master_gtid ('testm.sfsdfsdfsdfsdfsdf.eu-west-1.rds.amazonaws.com', 3306, 'repl_user', 'password', '0-283017185-45', 0);
CALL mysql.rds_start_replication; 
CALL mysql.rds_replica_status;
```