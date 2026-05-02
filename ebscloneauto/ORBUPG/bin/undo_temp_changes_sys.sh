



echo "source the env"  tee -a ${DBLOG}
##. $HOME/.bash_orbupg

echo "Disable Scheduler Jobs" | tee -a ${DBLOG}
sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_disable_schd_jobs.sql  | tee -a ${DBLOG}

echo "Disabling Threads" | tee -a ${DBLOG}
sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_disable_thread.sql | tee -a ${DBLOG}

echo "Drop undo Tablespaces"  | tee -a ${DBLOG}
sqlplus "/ as sysdba" @${SCRIPT}/${ENV}_undo_tblspace.sql  | tee -a ${DBLOG} 
