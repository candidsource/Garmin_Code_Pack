
. ${TGT_BASE_FS}/EBSapps.env run
exit 1
##SK##echo "step217" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_step217.sql | tee -a ${APPLOG}

##SK##echo "Post Clone script XX_POST_CLONE_STEPS_4" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_4.sql | tee -a ${APPLOG}

##SK##echo "Post Clone script XX_POST_CLONE_STEPS_4C" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_4C.sql | tee -a ${APPLOG}

##SK##echo "Post Clone script XX_POST_CLONE_STEPS_6" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_6.sql | tee -a ${APPLOG}

##SK##echo "Post Clone script XX_POST_CLONE_STEPS_5" | tee -a ${APPLOG}
##SK##echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_5.sql | tee -a ${APPLOG}

echo "Post Clone Update user level profile values for iSupplier Users" | tee -a ${APPLOG}
echo ${t_APPS_PWD} | sqlplus "/nolog" @${SCRIPT}/pos_upg_usr.sql | tee -a ${APPLOG}

##SK##echo "Restore Agile property files After the clone"
##SK##cp ${SCRIPT}/${ENV}_CommonLogin.properties $GARM_JAVA_TOP/CommonLogin.properties
##SK##cp -r ${SCRIPT}/${TGT_RUN_FS}_custom${PDB_NAME}_`hostname`.env $INST_TOP/appl/admin/custom${PDB_NAME}_`hostname`.env
##SK##cp -r ${SCRIPT}/${TGT_RUN_FS}_custom${PDB_NAME}_olaxua-orb02.env $INST_TOP/appl/admin/custom${PDB_NAME}_olaxua-orb02.env

##SK##echo "Wallet creation for Payment Module" | tee -a ${APPLOG}
##SK##${SCRIPT}/../bin/${ENV}_wallet_payment_module.sh| tee -a ${APPLOG}
