select TIME_FORMAT(SEC_TO_TIME(VARIABLE_VALUE ),'%Hh %im')  as Uptime
from information_schema.GLOBAL_STATUS
where VARIABLE_NAME='Uptime'
