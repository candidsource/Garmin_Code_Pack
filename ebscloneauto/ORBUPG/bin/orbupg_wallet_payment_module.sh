#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

. ${BIN_DIR}/run.env

title "Setting environment" | tee -a ${LOG}
. ${TGT_BASE_FS}/EBSapps.env run > /tmp/env.$$
cat /tmp/env.$$ | tee -a ${LOG}
rm /tmp/env.$$

export DBC_NAME=${PDB_NAME}

title "Wallet creation for Payment Module"
cd $JAVA_TOP
java -DJTFDBCFILE=$INST_TOP/appl/fnd/12.0.0/secure/${DBC_NAME}.dbc  oracle.apps.iby.security.SystemKeyMigrationUtility $NE_BASE/common/wallet/cwallet.sso

sqlplus -s apps/${t_APPS_PWD} <<-EOF
select sys_key_file_location from apps.iby_sys_security_options;
exit
EOF

