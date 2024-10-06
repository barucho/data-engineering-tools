CALL sys.ps_truncate_all_tables(FALSE);




-- enable  events_statements_history_n
UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME = 'events_statements_history';
UPDATE performance_schema.setup_consumers SET ENABLED = 'YES' WHERE NAME = 'events_statements_history_long';



UPDATE performance_schema.setup_instruments SET ENABLED = 'YES', TIMED = 'YES';

UPDATE performance_schema.setup_consumers SET ENABLED = 'YES';


select thread_id from performance_schema.threads where processlist_id = connection_id();


select thread_id, event_id, event_name, source, sys.format_time(timer_wait), sql_text from performance_schema.events_statements_current where thread_id = 192\G

-- get all running queirs form thread_id
select thread_id, event_id, event_name, source, sys.format_time(timer_wait), sql_text from performance_schema.events_statements_history where thread_id = 192;

