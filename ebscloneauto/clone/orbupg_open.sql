alter pluggable database ORBIT close;

!touch /u01/app/oracle/product/19.0.0/ORBUPG/dbs/ORBUPG_PDBDesc.xml
!mv /u01/app/oracle/product/19.0.0/ORBUPG/dbs/ORBUPG_PDBDesc.xml /u01/app/oracle/product/19.0.0/ORBUPG/dbs/ORBUPG_PDBDesc.xml_OLD

alter session set container=CDB$ROOT;

alter pluggable database "ORBIT" unplug into '/u01/app/oracle/product/19.0.0/ORBUPG/dbs/ORBUPG_PDBDesc.xml';

drop pluggable database "ORBIT";

select service_id,name,con_id from v$active_services;

set pagesize 200;
set linesize 200;
column NAME format a50;
column NETWORK_NAME format a50;
column ENABLED format a10;
column PDB format a10;
select NAME,NETWORK_NAME,ENABLED,PDB from dba_services;

create pluggable database "ORBUPG" using '/u01/app/oracle/product/19.0.0/ORBUPG/dbs/ORBUPG_PDBDesc.xml' NOCOPY SERVICE_NAME_CONVERT=('ebs_ORBIT','ebs_ORBUPG','ORBIT_ebs_patch','ORBUPG_ebs_patch','ORBITCDxdb','ORBUPGCDxdb');

alter pluggable database ORBUPG open read write;

show pdbs

alter session set container=CDB$ROOT;


alter pluggable database all save state instances=all;

show pdbs;

shutdown immediate;

startup nomount pfile='/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orbupg_post-pfile.ora';

create spfile='+DATA_DG_ORBUPG/ORBUPGCD/PARAMETERFILE/spfileorbupgcd.ora' from pfile='/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orbupg_post-pfile.ora';

shutdown immediate;

startup;

exit
