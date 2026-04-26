
. ${TGT_BASE_FS}/EBSapps.env run

##SK##echo "disable jobs as system user" | tee -a ${APPLOG}
##SK##echo "disable jobs as system user" | tee -a ${APPLOG}
##SK##echo ${SYSTEM_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_disable_scheduler_jobs_02.sql | tee -a ${APPLOG}

##SK##echo "Update User Profile for ICM Forms Launch" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_update_users_profile.sql | tee -a ${APPLOG}

##SK##echo "Unbbreak dba job 7743" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_unbroken.sql 7743 | tee -a ${APPLOG}

##SK##echo "Update Concurrent table with node Name" | tee -a ${APPLOG}
##SK##${SCRIPT}/../bin/${ENV}_update_conc_mgr_nodes.sh | tee -a ${APPLOG}

##SK##echo "Create cloning related database packages" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_COMPILE_POST_CLONE_PACKAGE.sql | tee -a ${APPLOG}

##SK##echo "Update IBY tables" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_insert_iby_bep_acct_opt_vals.sql | tee -a ${APPLOG}

##SK##echo "Scrub customer email addresses into the database - XX_POST_CLONE_STEPS_1" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_1.sql | tee -a ${APPLOG}

##SK##echo "Scrub Credit Card Data - XX_POST_CLONE_STPE_2" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_2.sql | tee -a ${APPLOG}

##SK##echo "XX_POST_CLONE_STEPS_3a" | tee -a ${APPLOG}
##SK##echo ${SYSTEM_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_3a.sql ${S_PDB_NAME} ${S_PDB_NAME} | tee -a ${APPLOG}


#### Updated by Laks. The follwoing below steps are split to b and c.

