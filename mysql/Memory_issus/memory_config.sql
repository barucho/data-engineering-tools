 
 /*

Global Usage = key_buffer_size + query_cache_size + 1.1 * innodb_buffer_pool_size + innodb_additional_mem_pool_size + innodb_log_buffer_size

Per Thread   = thread_stack + 2 * net_buffer_length

Note: the per query contribution is more or less based on an average query
Per Query    = "buffer for reading rows" + "sorting" + "full joins" + "binlog cache" + "index preload" + "internal tmp tables"
                  =  max(read_buffer_size, read_rnd_buffer_size)
                  + max(sort_buffer_size/2, "avg queries with scan" * "avg scans with merge" * sort_buffer_size)
                  + "avg full joins" * join_buffer_size
                  + "avg binlog cache use" * binlog_cache_size
                  + preload_buffer_size
                  + "avg tmp tables" * min(tmp_table_size, max_heap_table_size)

Total        = "global" + max_used_connections * ("thread" + "query")

*/
 
/* 
-- enable perf schema 
performance-schema-instrument='memory/%=ON'

*/


--MySQL maintains many internal buffers that grow until they reach the configured maximum size.
-- The largest of these buffers is typically the Innodb buffer pool. 
--On a busy server with many tables this buffer can grow to the configured size quite quickly,
-- however on servers where the dataset is small it is possible that the buffer pool never fully initializes.
-- In this case it can appear that MySQL has a memory leak, but in fact the the buffer pool is growing continuously over a longer period of time, 
--to meet the configured size. Only once all buffers have been fully allocated can you evaluate whether there is a memory leak. A memory leak will look like a non-cyclic pattern of memory usage over a longer period of time; 
--cycles typically repeat from week to week as daily query loads form a pattern. If the memory usage only grows over a multi-week period, *and* your buffers are all fully allocated, then you may have a memory leak 



-- db 
```sql
-- by index 
SELECT
    table_name AS table_name,
    index_name AS index_name,
    count(*) AS page_count,
    sum(data_size) / 1024 / 1024 AS size_in_mb
FROM
    information_schema.innodb_buffer_page
GROUP BY
    table_name, index_name
ORDER BY
    size_in_mb DESC;

```

```sql
SELECT
    page_type AS page_type,
    sum(data_size) / 1024 / 1024 AS size_in_mb
FROM
    information_schema.innodb_buffer_page
GROUP BY
    page_type
ORDER BY
    size_in_mb DESC;
```
--os 
- find mem usage by mysqld

ps -ovsz,rss -p $(pidof mysqld)

ps -e -o pid,vsz,comm= | sort -n -k 2 

```jsx
pmap `pidof mysqld`
```

To free pagecache:

```
# echo 1 > /proc/sys/vm/drop_caches
```

To free dentries and inodes:

```
# echo 2 > /proc/sys/vm/drop_caches
```

To free pagecache, dentries and inodes:

```
echo 3 > /proc/sys/vm/drop_caches
```



-- os 
-- ps -ovsz,rss -p $(pidof mysqld)

-- total 
 SELECT * FROM sys.memory_global_total;
-- can run to get detaild info 

SELECT EVENT_NAME, COUNT_ALLOC, COUNT_FREE, sys.format_bytes(SUM_NUMBER_OF_BYTES_ALLOC) AS TotalAlloc,
sys.format_bytes(SUM_NUMBER_OF_BYTES_FREE) AS TotalFree, sys.format_bytes(CURRENT_NUMBER_OF_BYTES_USED) AS CurrentUsage,
sys.format_bytes(HIGH_NUMBER_OF_BYTES_USED) AS MaxUsed
FROM performance_schema.memory_summary_global_by_event_name
WHERE CURRENT_NUMBER_OF_BYTES_USED > 0
ORDER BY CURRENT_NUMBER_OF_BYTES_USED DESC;


 --  current memory usage within the server globally, broken down by allocation type. 
 
 SELECT * FROM sys.memory_global_by_current_bytes
       WHERE event_name LIKE 'memory/innodb/buf_buf_pool'\G


-- aggregates currently allocated memory (current_alloc) by code area
SELECT SUBSTRING_INDEX(event_name,'/',2) AS
       code_area, FORMAT_BYTES(SUM(current_alloc))
       AS current_alloc
       FROM sys.x$memory_global_by_current_bytes
       GROUP BY SUBSTRING_INDEX(event_name,'/',2)
       ORDER BY SUM(current_alloc) DESC;


-- individual contributions
SELECT EVENT_NAME, COUNT_ALLOC, COUNT_FREE, sys.format_bytes(SUM_NUMBER_OF_BYTES_ALLOC) AS TotalAlloc,
sys.format_bytes(SUM_NUMBER_OF_BYTES_FREE) AS TotalFree, sys.format_bytes(CURRENT_NUMBER_OF_BYTES_USED) AS CurrentUsage,
sys.format_bytes(HIGH_NUMBER_OF_BYTES_USED) AS MaxUsed
FROM performance_schema.memory_summary_global_by_event_name
WHERE CURRENT_NUMBER_OF_BYTES_USED > 0
ORDER BY CURRENT_NUMBER_OF_BYTES_USED DESC;


--  Max individual contributions
    SELECT EVENT_NAME, COUNT_ALLOC, COUNT_FREE, sys.format_bytes(SUM_NUMBER_OF_BYTES_ALLOC) AS TotalAlloc,
    sys.format_bytes(SUM_NUMBER_OF_BYTES_FREE) AS TotalFree, sys.format_bytes(CURRENT_NUMBER_OF_BYTES_USED) AS CurrentUsage,
    sys.format_bytes(HIGH_NUMBER_OF_BYTES_USED) AS MaxUsed
    FROM performance_schema.memory_summary_global_by_event_name
    WHERE CURRENT_NUMBER_OF_BYTES_USED > 0
    ORDER BY HIGH_NUMBER_OF_BYTES_USED DESC;
-- meme usage 

SELECT SUBSTRING_INDEX(event_name,'/',2) AS code_area, 
       sys.format_bytes(SUM(current_alloc)) AS current_alloc 
FROM sys.x$memory_global_by_current_bytes 
GROUP BY SUBSTRING_INDEX(event_name,'/',2) 
ORDER BY SUM(current_alloc) DESC;



-- 
SELECT SUBSTRING_INDEX(event_name,'/',2) AS code_area, 
       sys.format_bytes(SUM(current_alloc)) AS current_alloc 
FROM sys.x$memory_global_by_current_bytes 
GROUP BY SUBSTRING_INDEX(event_name,'/',2) 
ORDER BY SUM(current_alloc) DESC;


