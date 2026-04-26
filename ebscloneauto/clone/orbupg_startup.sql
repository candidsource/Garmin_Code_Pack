--!echo ${t_SYS_PWD} | orapwd file='+DATA_DG_${PDB_NAME}/${DB_NAME}/password/orapw${l_DB_NAME}1' entries=20 dbuniquename=${DB_NAME} force=y 
--!echo Syspwd | orapwd file='+DATA_DG_ORBUPG/ORBUPGCD/password/orapworbupgcd1' entries=20 dbuniquename=ORBUPGCD force=y 

startup nomount pfile='/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orbupg_pre-pfile.ora';

create spfile='+DATA_DG_ORBUPG/ORBUPGCD/PARAMETERFILE/spfileorbupgcd.ora' from pfile='/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orbupg_pre-pfile.ora';

shutdown immediate;

startup nomount;

exit
