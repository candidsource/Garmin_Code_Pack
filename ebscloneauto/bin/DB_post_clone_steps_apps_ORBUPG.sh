ENV=orbupg
BIN_DIR=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin
. /mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin/run.env

SCRIPT=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone
echo "Sourcing: /u01/app/oracle/product/19.0.0/ORBUPG/ORBUPG_kc3xsd-rac301.env"
. /u01/app/oracle/product/19.0.0/ORBUPG/ORBUPG_kc3xsd-rac301.env
echo "source the env"  tee -a ${DBLOG}
. $HOME/.bash_orbupg

echo "Cleaning FND NODES" | tee -a ${DBLOG}
echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_clean_fnd.sql | tee -a ${DBLOG}

echo "Checking FND" | tee -a ${DBLOG}
echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_list_fnd.sql | tee -a ${DBLOG}

echo "Drop Source DB Links" | tee -a ${DBLOG}
echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_drop_prod_links.sql @${SCRIPT}/do_any_sql.sql | tee -a ${DBLOG}

echo "Cancelling Pending CRs" | tee -a ${DBLOG}
echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_CancelPendingCRs.sql | tee -a ${DBLOG}

echo "Cancelling Jobs" | tee -a ${DBLOG}
## The following 2 jobs needs to be run in PDB
echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_disable_scheduler_jobs_01.sql | tee -a ${DBLOG}  
echo ${SYSTEM_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_disable_scheduler_jobs_02.sql | tee -a ${DBLOG}

echo "DROP all tables in the XX_JUNK tablespace to free up storage" | tee -a ${DBLOG}
#echo ${APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_drop_tables_XX_JUNK_TBLSPCE.sql  | tee -a ${DBLOG} 
