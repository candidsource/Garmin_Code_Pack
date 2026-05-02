alter pluggable database "ORBUPG" open read write instances=all;

alter session set container=ORBUPG;
exec dbms_service.start_SERVICE('ebs_ORBUPG','ORBUPGCDB1');
exec dbms_service.start_SERVICE('ebs_ORBUPG','ORBUPGCDB2');
exec dbms_service.start_SERVICE('ebs_ORBUPG','ORBUPGCDB3');
exec dbms_service.start_SERVICE('ORBUPG_ebs_patch','ORBUPGCDB1');
exec dbms_service.start_SERVICE('ORBUPG_ebs_patch','ORBUPGCDB2');
exec dbms_service.start_SERVICE('ORBUPG_ebs_patch','ORBUPGCDB3');

alter session set container=CDB$ROOT;

alter pluggable database all save state instances=all;

exit

