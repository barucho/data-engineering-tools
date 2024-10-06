-- Link https://dev.mysql.com/doc/refman/5.7/en/innodb-information-schema-examples.html#innodb-information-schema-exampl[%E2%80%A6]le,-When%20identifying%20blocking 
-- https://dev.mysql.com/doc/refman/5.7/en/innodb-information-schema-examples.html#innodb-information-schema-examples-null-blocking-query
-- show ENGINE lockes  
SHOW ENGINE INNODB STATUS \G

-- show users 
select user from sys.x$user_summary ;


--- which transactions are waiting and which transactions are blocking them: 
SELECT
  r.trx_id waiting_trx_id,
  r.trx_mysql_thread_id waiting_thread,
  r.trx_query waiting_query,
  b.trx_id blocking_trx_id,
  b.trx_mysql_thread_id blocking_thread,
  b.trx_query blocking_query
FROM       information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b
  ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r
  ON r.trx_id = w.requesting_trx_id\G

 -- Or, more simply, use the sys schema innodb_lock_waits view: 
SELECT
  waiting_trx_id,
  waiting_pid,
  waiting_query,
  blocking_trx_id,
  blocking_pid,
  blocking_query
FROM sys.innodb_lock_waits;


-- find block trx 
SELECT * 
FROM information_schema.INNODB_LOCKS 
WHERE LOCK_TRX_ID IN (SELECT BLOCKING_TRX_ID FROM information_schema.INNODB_LOCK_WAITS);

-- or 
SELECT INNODB_LOCKS.* 
FROM information_schema.INNODB_LOCKS
JOIN information_schema.INNODB_LOCK_WAITS
  ON (INNODB_LOCKS.LOCK_TRX_ID = INNODB_LOCK_WAITS.BLOCKING_TRX_ID);
-- or find LOCK WAIT
SELECT INNODB_LOCKS.* 
FROM information_schema.INNODB_LOCKS
JOIN information_schema.INNODB_LOCK_WAITS
  ON (INNODB_LOCKS.LOCK_TRX_ID = INNODB_LOCK_WAITS.BLOCKING_TRX_ID);


--
-- find locks 
--
SELECT   waiting_trx_id,waiting_pid,waiting_query,blocking_trx_id,blocking_pid,blocking_query 
FROM sys.innodb_lock_waits;



--- look for blocking_trx_id (pid)
set @blocking_trx_id_v=15156720;

SELECT THREAD_ID FROM performance_schema.threads WHERE PROCESSLIST_ID = @blocking_trx_id_v;

-- get THREAD_ID
set @THREAD_ID_v = 919561;

-- find sql text 
SELECT THREAD_ID, SQL_TEXT FROM performance_schema.events_statements_current 
WHERE THREAD_ID = @THREAD_ID_v\G


--running trx innodb_trx
select trx_started,trx_query,UNIX_TIMESTAMP(now())-UNIX_TIMESTAMP(trx_started) runtime from information_schema.innodb_trx;

-- long running trx 1800 sec ((30min))
select trx_started,UNIX_TIMESTAMP(now())-UNIX_TIMESTAMP(trx_started) as runtime 
from information_schema.innodb_trx
having runtime > 100 ;




-- test 

-- Test the blocking scenario using below use case
use test;
create table blocking (col1 int primary key);

insert into blocking values (1),(2),(3);

Begin;

update blocking set col1=4 where col1=1;

-- Take another sessions and run below update,

update blocking set col1=5 where col1=1;

-- Take another session and check for blockings

SELECT
  r.trx_id waiting_trx_id,
  r.trx_mysql_thread_id waiting_thread,
  r.trx_query waiting_query,
  b.trx_id blocking_trx_id,
  b.trx_mysql_thread_id blocking_thread,
  b.trx_query blocking_query
FROM       performance_schema.data_lock_waits w
INNER JOIN information_schema.innodb_trx b
  ON b.trx_id = w.blocking_engine_transaction_id
INNER JOIN information_schema.innodb_trx r
  ON r.trx_id = w.requesting_engine_transaction_id;


SELECT THREAD_ID FROM performance_schema.threads WHERE PROCESSLIST_ID =blocking thread;

SELECT THREAD_ID, SQL_TEXT FROM performance_schema.events_statements_current WHERE THREAD_ID = with the ID output of above query






SELECT p1.id waiting_thread,
              p1.user waiting_user,
              p1.host waiting_host,
              it1.trx_query waiting_query,        
              ilw.requesting_trx_id waiting_transaction, 
              ilw.blocking_lock_id blocking_lock, 
              il.lock_mode blocking_mode,
              il.lock_type blocking_type,
              ilw.blocking_trx_id blocking_transaction,
              CASE it.trx_state 
                WHEN 'LOCK WAIT' 
                THEN it.trx_state 
                ELSE p.state 
              END blocker_state, 
              il.lock_table locked_table,        
              it.trx_mysql_thread_id blocker_thread, 
              p.user blocker_user, 
              p.host blocker_host 
       FROM performance_schema.innodb_lock_waits ilw 
       JOIN performance_schema.innodb_locks il 
         ON ilw.blocking_lock_id = il.lock_id 
        AND ilw.blocking_trx_id = il.lock_trx_id
       JOIN performance_schema.innodb_trx it 
         ON ilw.blocking_trx_id = it.trx_id
       JOIN performance_schema.processlist p 
         ON it.trx_mysql_thread_id = p.id 
       JOIN performance_schema.innodb_trx it1 
         ON ilw.requesting_trx_id = it1.trx_id 
       JOIN performance_schema.processlist p1 
         ON it1.trx_mysql_thread_id = p1.id\G