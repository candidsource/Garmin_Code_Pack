conn apps@orbupg

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/ORBUPG_XX_POST_CLONE_STEPS_5.log

/* Formatted on 2/11/2013 3:00:18 PM (QP5 v5.227.12220.39724) */
SET HEADING OFF
SET VERIFY OFF;
SET SERVEROUTPUT ON SIZE 1000000;
SET FEEDBACK ON;

BEGIN
   apps.xx_post_clone_steps.AP_PROFILE;
END;
/

spool off;

