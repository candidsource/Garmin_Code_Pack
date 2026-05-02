conn apps@orbupg

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/ORBUPG_XX_POST_CLONE_STEPS_4.log

/* Formatted on 2/11/2013 3:00:18 PM (QP5 v5.227.12220.39724) */
SET HEADING OFF
SET VERIFY OFF;
SET SERVEROUTPUT ON SIZE 1000000;
SET FEEDBACK ON;
DECLARE
lv_result VARCHAR2(10);
BEGIN
   apps.xx_post_clone_steps.xx_validate(lv_result);
   
   IF lv_result = 'F' THEN
    dbms_output.put_line ('Error in Validation Process. Please check the log to fix the issue !!');
   ELSE
    dbms_output.put_line('Validation Process Successful. !!!');
   END IF; 
END;
/

spool off
