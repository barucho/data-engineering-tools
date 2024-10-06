-- file: top_running_queris.sql
-- top running queris and server info
-- Tested on Aurora MySQL,MySQL,RDS MySQL 

-- version 
select @@version;

-- top 95 
select *  from sys.statements_with_runtimes_in_95th_percentile fts,performance_schema.events_statements_history shist where  fts.digest = shist.digest\G

select SQL_TEXT  from sys.statements_with_runtimes_in_95th_percentile fts,performance_schema.events_statements_history shist where fts.db = 'dbname' and fts.digest = shist.digest\G

-- general warnings 


select * from sys.`statements_with_errors_or_warnings`\G


-- FTS 

select *  from sys.statements_with_full_table_scans fts,performance_schema.events_statements_history shist where  fts.digest = shist.digest\G
select * from sys.statements_with_full_table_scans where db is not null and db not in ('sys') order by rows_examined_avg\G


-- statement_analysis

select rows_examined_avg,exec_count,last_seen,query,db,rows_sent_avg from sys.statement_analysis where db is not null  order by rows_sent_avg,last_seen desc;

/*
select * from sys.`x$statement_analysis`

select * from performance_schema.events_statements_history_long  where digest = 'b6e63136578ce753f6f1b890bdd34a27';
*/

-- using temp t 
select * from sys.statements_with_temp_tables  where db not in ('mysql','sys','performance_schema')\G
select * from sys.statements_with_sorting where db not in ('mysql','sys','performance_schema')\G

-- index`s 
select * from sys.schema_unused_indexes; 

-- schema statistics
select * from sys.x$schema_table_statistics where table_schema not in ('mysql','sys','performance_schema')\G



-- files [io]  statistics
select * from sys.x$io_global_by_file_by_bytes;
select * from sys.x$io_global_by_wait_by_bytes;


-- top wait events 