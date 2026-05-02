conn apps@ORBUPG

set pages 0
set lines 130
set termout off
set echo off
set verify off
set heading off
set feedback off
spool /tmp/orbupg_run_drop_prod_links.sql 
select decode(owner,'PUBLIC','','&1 ' || owner || ' "') 
|| 'drop ' || decode(owner,'PUBLIC','public ','') || 'database link '
|| db_link || decode(owner,'PUBLIC',';','"')
as "Do these SQL*Plus commands"
from dba_db_links ;
spool off;
@/tmp/orbupg_run_drop_prod_links.sql
exit;

