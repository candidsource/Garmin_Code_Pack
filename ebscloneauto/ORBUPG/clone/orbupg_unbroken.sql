conn apps@orbupg

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/orbupg_unbroken.log

---accept p_job_number prompt 'Enter job number to unbreak: '
set verify off
set serveroutput on
variable p_job_number number;
exec :p_job_number := '&&1'
declare
begin
sys.dbms_job.broken (job => :p_job_number, broken => FALSE);
end;
/
set verify on
commit;

spool off
