set pages 0
set lines 140
set termout off
set echo off
set verify off
set heading off
set feedback off
spool /tmp/orbupg_CLEANUP_XX_JUNK_ORBUPG.sql
select 'DROP TABLE ' || OWNER || '.' || SEGMENT_NAME || ' CASCADE CONSTRAINTS PURGE;' from dba_segments where TABLESPACE_NAME='XX_JUNK' and SEGMENT_TYPE='TABLE';
spool off;
set feedback on
@/tmp/orbupg_CLEANUP_XX_JUNK_ORBUPG.sql
exit;

