ENV=orbupg
BIN_DIR=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin
. /mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin/run.env

SCRIPT=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone
echo "Sourcing: /u01/app/oracle/product/19.0.0/ORBUPG/ORBUPGCD1_kc3xsd-rac301.env"
. /u01/app/oracle/product/19.0.0/ORBUPG/ORBUPGCD1_kc3xsd-rac301.env
echo "source the env"  tee -a ${DBLOG}
##. $HOME/.bash_orbupg


echo "Checking the DB Services" | tee -a ${DBLOG}
sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_dbservices.sql | tee -a ${DBLOG}


echo "Cancelling Jobs" | tee -a ${DBLOG}
sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_brk_db_jobs.sql ${PDB_NAME} | tee -a ${DBLOG} 

echo "Increase the size of the XX_JUNK tablespace"  | tee -a ${DBLOG}
sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_add_XX_JUNK_datafiles.sql  | tee -a ${DBLOG} 
