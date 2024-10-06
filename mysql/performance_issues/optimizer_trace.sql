
-- file: optimizer_trace.sql
-- Running trace on MySQL
-- Tested on Aurora MySQL,MySQL,RDS MySQL 

-- Step 1
SET optimizer_trace='enabled=on';
SET @@end_markers_in_json=on;
SET @@optimizer_trace_max_mem_size=32768;


-- Step 2
USE world

SELECT city.Name, language
FROM countrylanguage, country, city
WHERE city.countrycode = country.code 
AND city.id = country.Capital
AND city.population >= 1000000
AND countrylanguage.countrycode = country.code;

-- Step 3
SELECT TRACE INTO DUMPFILE "/tmp/explain.json" 
FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

-- Step 4
SET optimizer_trace='enabled=off';


