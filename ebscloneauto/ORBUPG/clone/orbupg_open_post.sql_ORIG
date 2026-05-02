startup nomount pfile='/mnt/nfs/oralce.patches/ebscloneauto/ORBUPG/clone/initORBUPGCDB.ora.postdup';
create spfile='+DATA_DG_ORBUPG/ORBUPGCD/PARAMETERFILE/spfileORBUPGCD.ora' from pfile='/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/initORBUPGCDB.ora.postdup';
shutdown immediate;
startup;
alter session set container=ORBUPG;
alter pluggable database ORBUPG open read write;

exit;

