-- by type
SELECT
    page_type AS page_type,
    sum(data_size) / 1024 / 1024 AS size_in_mb
FROM
    information_schema.innodb_buffer_page
GROUP BY
    page_type
ORDER BY
    size_in_mb DESC;


--- by index 

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
