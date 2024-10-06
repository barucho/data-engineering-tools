max_connections * 
(@@sort_buffer_size + 
@@read_rnd_buffer_size +
@@join_buffer_size +
@@binlog_cache_size +
@@thread_stack +
[the smaller of @@tmp_table_size
and @@max_heap_table_size])

-- 
-- recommended_innodb_buffer_pool_size
SELECT CONCAT(ROUND(KBS/POWER(1024,
IF(PowerOf1024<0,0,IF(PowerOf1024>3,0,PowerOf1024)))+0.49999),
SUBSTR(' KMG',IF(PowerOf1024<0,0,
IF(PowerOf1024>3,0,PowerOf1024))+1,1)) recommended_innodb_buffer_pool_size
FROM (SELECT SUM(data_length+index_length) KBS FROM information_schema.tables
WHERE engine='InnoDB') A,
(SELECT 2 PowerOf1024) B;
