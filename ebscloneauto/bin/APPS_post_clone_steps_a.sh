ENV=orbupg

BIN_DIR=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin
. /mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin/run.env

SCRIPT=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone
echo "expected to run on : applmgr@olaxua-orb01"
echo "running on: $(hostname)"


. ${TGT_BASE_FS}/EBSapps.env run
exit 1
echo "disable jobs as system user" | tee -a ${APPLOG}
echo ${SYSTEM_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_disable_scheduler_jobs_02.sql | tee -a ${APPLOG}

echo "Update User Profile for ICM Forms Launch" | tee -a ${APPLOG}
echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_update_users_profile.sql | tee -a ${APPLOG}

echo "Unbbreak dba job 7743" | tee -a ${APPLOG}
echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_unbroken.sql 7743 | tee -a ${APPLOG}

echo "Update Concurrent table with node Name" | tee -a ${APPLOG}
${SCRIPT}/../bin/${ENV}_update_conc_mgr_nodes.sh | tee -a ${APPLOG}

echo "Create cloning related database packages" | tee -a ${APPLOG}
echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_COMPILE_POST_CLONE_PACKAGE.sql | tee -a ${APPLOG}

echo "Update IBY tables" | tee -a ${APPLOG}
echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_insert_iby_bep_acct_opt_vals.sql | tee -a ${APPLOG}

echo "Scrub customer email addresses into the database - XX_POST_CLONE_STEPS_1" | tee -a ${APPLOG}
echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_1.sql | tee -a ${APPLOG}

echo "Scrub Credit Card Data - XX_POST_CLONE_STPE_2" | tee -a ${APPLOG}
echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_2.sql | tee -a ${APPLOG}

echo "XX_POST_CLONE_STEPS_3a" | tee -a ${APPLOG}
echo ${SYSTEM_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_3a.sql ${S_PDB_NAME} ${S_PDB_NAME} | tee -a ${APPLOG}


#### Updated by Laks. The follwoing below steps are split to b and c.

