conn system@ORBUPG

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/orbupg_disable_scheduler_jobs_02.log

exec DBMS_SCHEDULER.disable('COGNOS_SALLES_BILLING_STATS1');
exec DBMS_SCHEDULER.disable('COGNOS_SALLES_BILLING_STATS3');
exec DBMS_SCHEDULER.disable('COGNOS_SALLES_BILLING_STATS2');

spool off;

exit

