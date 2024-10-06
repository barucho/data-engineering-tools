# notes about mysql redo logs 



https://www.percona.com/blog/2011/02/03/how-innodb-handles-redo-logging/ 


# InnoDB log file size


## How to calculate a good InnoDB log file size
---
### by script (engine innodb status)

```sql
pager grep sequence
show engine innodb status\G select sleep(60); show engine innodb status\G
```

```sql
Log sequence number 84 3836410803
1 row in set (0.06 sec)
1 row in set (1 min 0.00 sec)
Log sequence number 84 3838334638
1 row in set (0.05 sec)
select (3838334638 - 3836410803) / 1024 / 1024 as MB_per_min;
mysql> select (3838334638 - 3836410803) / 1024 / 1024 as MB_per_min;
+------------+
| MB_per_min |
+------------+
| 1.83471203 |
+------------+
innodb_log_file_size=64M

```
select (109796673 - 82183541) / 1024 / 1024 as MB_per_min;

---
###  by SQL 

* INNODB_OS_LOG_WRITTEN - The number of bytes written to the log file.

```sql
SELECT VARIABLE_VALUE INTO @baseline 
FROM performance_schema.GLOBAL_STATUS
	WHERE VARIABLE_NAME = 'INNODB_OS_LOG_WRITTEN';

SELECT SLEEP(60 * 60);

SELECT VARIABLE_VALUE INTO @afteronehour
 FROM performance_schema.GLOBAL_STATUS 
	WHERE VARIABLE_NAME = 'INNODB_OS_LOG_WRITTEN';

SET @BytesWrittenToLog = @afteronehour - @baseline;

SELECT @BytesWrittenToLog / POWER(1024,2) AS MB_PER_HR;
```

---
## How to change innodb-log-file-size and innodb-log-files-in-group

1. shutdown MySQL 

**NOTICE** 
If innodb_fast_shutdown is set to 2, set innodb_fast_shutdown to 1: 
```sql
SET GLOBAL innodb_fast_shutdown = 1;
```
2. backup and move the old redologs 
3. chnage paramters innodb-log-file-size and innodb-log-files-in-group 
4.  start MySQL 



