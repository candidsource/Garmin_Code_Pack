conn apps@ORBUPG

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/ORBUPG_XX_POST_CLONE_STEPS_2.log;


/* Formatted on 2/11/2013 3:00:05 PM (QP5 v5.227.12220.39724) */
SET HEADING OFF
SET VERIFY OFF;
SET SERVEROUTPUT ON SIZE 1000000;
SET FEEDBACK ON;

BEGIN
   apps.xx_post_clone_steps.post_enc_cc_scrub;
END;
/

spool off;


exit

