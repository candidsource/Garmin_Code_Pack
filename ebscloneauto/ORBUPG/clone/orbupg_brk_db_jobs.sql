alter session set container=&1;

select decode(sys_context('USERENV','CON_ID'),1,'CDB','PDB') as db_type from dual;

drop table XX_BACKUP_DBA_JOBS;
exit
