-- file: query_timing_profile.sql
-- Running query profiling on MySQL
-- Tested on Aurora MySQL,MySQL,RDS MySQL 


-- start profiling
set profiling = 1; 
-- run query 
-- 

show profiles; 
-- will show all profiles with queries 
-- show all profile for selected query 
show profile for query 1;
-- full info 
show profile ALL for query 1\G

-- stop profiling
set profiling = 0; 


-- events info 
https://dev.mysql.com/doc/refman/5.7/en/general-thread-states.html
