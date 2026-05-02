#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

title "Setting environment" | tee -a ${LOG}
. ${TGT_BASE_FS}/EBSapps.env run > /tmp/env.$$
cat /tmp/env.$$ | tee -a ${LOG}
rm /tmp/env.$$


title "Starting services" | tee -a ${LOG}
cd ${ADMIN_SCRIPTS_HOME}
echo ${WLS_PWD} | ./adstrtal.sh apps/${t_APPS_PWD} | tee -a ${LOG}


. ${BIN_DIR}/footer.sh

