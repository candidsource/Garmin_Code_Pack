ENV=orbupg
SCRIPT=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone
BIN_DIR=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin
. /mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin/run.env
echo "Changing Apps Password" | tee -a ${APPLOG}
#cd /r12_linux_oracle_depot/bmcd_clone/log | tee -a ${APPLOG}
. ${TGT_BASE_FS}/EBSapps.env run
FNDCPASS apps/${APPS_PWD} 0 Y system/${SYSTEM_PWD} SYSTEM APPLSYS ${t_APPS_PWD}  | tee -a ${APPLOG}
cd ${ADMIN_SCRIPTS_HOME};{ echo ${WLS_PWD};echo ${t_APPS_PWD}; } | ./adadminsrvctl.sh start | tee -a ${APPLOG}
cd $FND_TOP/patch/115/bin; { echo ${WLS_PWD}; echo ${t_APPS_PWD}; } |perl txkManageDBConnectionPool.pl -options=updateDSPassword -contextfile=$CONTEXT_FILE   | tee -a ${APPLOG}
{ echo ${WLS_PWD};echo ${t_APPS_PWD}; } | ./adadminsrvctl.sh stop | tee -a ${APPLOG}


title "Changing Applsyspub Password" | tee -a ${LOG}
FNDCPASS apps/${t_APPS_PWD} 0 Y system/${SYSTEM_PWD} ORACLE   APPLSYSPUB ${t_PUB_PWD}  | tee -a ${LOG}
title "Changing Module Password" | tee -a ${LOG}
FNDCPASS apps/${t_APPS_PWD} 0 Y system/${SYS_PWD}  ALLORACLE ${t_MOD_PWD}  | tee -a ${LOG}

echo "Changing SYSADMIN, ASADMIN Passwords" | tee -a ${APPLOG}
. ${TGT_BASE_FS}/EBSapps.env run | tee -a ${APPLOG}
FNDCPASS apps/${t_APPS_PWD} 0 Y system/${SYSTEM_PWD} USER SYSADMIN ${t_SYSADMIN_PWD}  | tee -a ${APPLOG}
#FNDCPASS apps/${t_APPS_PWD} 0 Y system/${SYSTEM_PWD} USER ASADMIN ${t_ASADMIN_PWD}  | tee -a ${APPLOG}

