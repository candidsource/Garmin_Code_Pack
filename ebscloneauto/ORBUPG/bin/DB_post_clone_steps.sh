ENV=orbupg
BIN_DIR=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin
. /mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin/run.env

SCRIPT=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone
. /u01/app/oracle/product/19.0.0/ORBUPG/ORBUPG_kc3xsd-rac301.env
title "source the env"  tee -a ${DBLOG}
. $HOME/.bash_orbupg

title "Cleaning FND NODES" | tee -a ${DBLOG}
##SK##echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_clean_fnd.sql | tee -a ${DBLOG}

title "Checking FND" | tee -a ${DBLOG}
##SK##echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_list_fnd.sql | tee -a ${DBLOG}

title "Checking the DB Services" | tee -a ${DBLOG}
##SK##sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_dbservices.sql | tee -a ${DBLOG}    --Couldnot able to run due to env settings

title "Drop Source DB Links" | tee -a ${DBLOG}
##SK##echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_drop_prod_links.sql @${SCRIPT}/do_any_sql.sql | tee -a ${DBLOG}

title "Cancelling Pending CRs" | tee -a ${DBLOG}
##SK##echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_CancelPendingCRs.sql | tee -a ${DBLOG}


title "Cancelling Jobs" | tee -a ${DBLOG}
##LAKS##sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_brk_db_jobs.sql ${PDB_NAME} | tee -a ${DBLOG}
### The following 2 jobs needs to be run in PDB
##echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_disable_scheduler_jobs_01.sql | tee -a ${DBLOG}  
##echo ${SYSTEM_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_disable_scheduler_jobs_01.sql | tee -a ${DBLOG}

title "DROP all tables in the XX_JUNK tablespace to free up storage" | tee -a ${DBLOG}
i##SK##echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_drop_tables_XX_JUNK_TBLSPCE.sql  | tee -a ${DBLOG}

title "Increase the size of the XX_JUNK tablespace"  | tee -a ${DBLOG}
sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_add_XX_JUNK_datafiles.sql  | tee -a ${DBLOG}
