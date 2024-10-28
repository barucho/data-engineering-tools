
---
DELIMITER $$
DROP PROCEDURE IF EXISTS minute_rollup$$
CREATE PROCEDURE minute_rollup(input_number INT)
BEGIN
DECLARE counter int;
DECLARE out_number float;
set counter=0;
WHILE counter <= input_number DO
SET out_number=SQRT(rand());
SET counter = counter + 1;
END WHILE;
END$$
DELIMITER ;

--- 
call minute_rollup(100000000);