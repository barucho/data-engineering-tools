-- file: db_size.sql
-- database size query
SELECT table_schema "Data Base Name", 
sum( data_length + index_length ) / 1024 / 1024 /1024
 "Data Base Size in GB", 
sum( data_free )/ 1024 /1024 /1024  "Free Space in GB" 
FROM information_schema.TABLES 
GROUP BY table_schema ; 



SELECT 
     table_schema as `Database`, 
     table_name AS `Table`, 
     round(((data_length + index_length) / 1024 / 1024), 2) `Size in MB` 
FROM information_schema.TABLES 
ORDER BY (data_length + index_length) DESC;