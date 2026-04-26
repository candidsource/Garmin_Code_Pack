
-- from Shivaraddi Channalli (aka "Shiva") of Oracle ACS 7/22/2023

prompt
prompt This script is designed to display database services for each currently visible container 
prompt in this database.
prompt

set heading off
set feedback off
select 'Note: You are currently in the ' || decode(sys_context('USERENV','CON_ID'),1,'CDB','PDB') || decode(sys_context('USERENV','CON_ID'),3,' so you can not see any CDB Root values') || '.' from dual;
set heading on
prompt
prompt


set lines 132
set pages 2000
set feedback off

prompt ALL DB Services:

col service_name heading 'Service Name' for a19
col network_name heading 'Network Name' for a43
col creation_date heading 'Service|Creation' for a11
col pdb heading 'Container' for a9
col pertinent_con heading 'Pertinent|Container(s)' for a13

select distinct
  name as service_name,
  ltrim(rtrim(network_name)) as network_name,
  to_char (creation_date, 'dd-MON-YYYY') as creation_date,
  pdb,
  case con_id when 0 then 'CDB and PDBs' when 1 then 'CDB$ROOT' when 2 then 'PDB$SEED' when 3 then 'PDB'  else to_char(con_id) end as pertinent_con
from
  gv$services
order by
  upper(service_name)
/

prompt


col service_name heading 'Service Name' for a19
col network_name heading 'Network Name' for a43
col creation_date heading 'Service|Creation' for a11
col failover_method heading 'Failover|Method' for a8
col failover_type heading 'Failover|Type' for a11
col edition_name heading 'Edition|Name' for a15
col pdb heading 'Container' for a9
col pertinent_con heading 'Pertinent|Container(s)' for a13

prompt
prompt All CDB Services:

select
  name as service_name,
  ltrim(rtrim(network_name)) as network_name,
  to_char (creation_date, 'dd-MON-YYYY') as creation_date,
--  failover_method,
--  failover_type,
  pdb,
  case con_id when 0 then 'CDB and PDBs' when 1 then 'CDB$ROOT' when 2 then 'PDB$SEED' when 3 then 'PDB'  else to_char(con_id) end as pertinent_con,
  substr(nvl(edition, '(Null)'),1,15) as edition_name
from
  cdb_services
order by
  upper(service_name)
/

prompt



col service_name heading 'Service Name' for a19
col network_name heading 'Network Name' for a43
col creation_date heading 'Service|Creation' for a11
col con_name heading 'Service|Container' for a15
col pertinent_con heading 'Pertinent|Container(s)' for a13
col blocked heading 'Block|ed?' for a5

prompt
prompt ACTIVE DB Services:

select distinct
  name as service_name,
  ltrim(rtrim(network_name)) as network_name,
  to_char (creation_date, 'dd-MON-YYYY') as creation_date,
  con_name,
  case con_id when 0 then 'CDB and PDBs' when 1 then 'CDB$ROOT' when 2 then 'PDB$SEED' when 3 then 'PDB'  else to_char(con_id) end as pertinent_con,
  blocked
from
  gv$active_services
order by
  upper(service_name)
/

prompt

set feedback on

exit;

