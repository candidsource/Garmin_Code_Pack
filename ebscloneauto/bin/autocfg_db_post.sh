#!/bin/bash

_env_file="$HOME/.bash_${1,,}"
if [[ -f "$_env_file" ]]; then
    echo "env file is $_env_file"
    source $_env_file
fi


if [ $# -lt 2 ]; then
  echo "No environment passed..."
  exit 1
else
  SID=${2}
fi

TASK="${3}"

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

echo "Setting environment" | tee -a ${DBLOG}
ORACLE_SID=${DB_SIDS[${SID}]}
##. oraenv
env | grep ORACLE | tee -a ${DBLOG}
APPSUTIL="${DB_HOME}/appsutil"
ORACLE_PDB=${PDB_NAME}

HOSTNAME="$(hostname -s)"

LOGICAL_HOSTNAME="LOGICAL_DB_NODE${SID}"
echo "LOGICAL_HOSTNAME variable name: ${LOGICAL_HOSTNAME}"
echo "LOGICAL_HOSTNAME: ${!LOGICAL_HOSTNAME}"

THE_HOSTNAME="${!LOGICAL_HOSTNAME:-${HOSTNAME}}"
echo "THE_HOSTNAME: $THE_HOSTNAME"

CONTEXT="${ORACLE_PDB}_${THE_HOSTNAME}"
echo "CONTEXT is: ${CONTEXT}"

export ORACLE_HOME=${ORACLE_HOME}
export PATH=$ORACLE_HOME/perl/bin:$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME:$ORACLE_HOME/lib
export PERL5LIB=$ORACLE_HOME/perl/lib/5.28.1:$ORACLE_HOME/perl/site_perl/5.28.1:$ORACLE_HOME/appsutil/perl
export PATH=$ORACLE_HOME/perl:$ORACLE_HOME/perl/lib:$ORACLE_HOME/perl/bin:$PATH

echo "set s_scan_name to Target Scan Name"  | tee -a ${DBLOG}
echo "perl -pi -e 's/s_scan_name\">'${s_SCAN_NAME}'/s_scan_name\">'${t_SCAN_NAME}'/' ${APPSUTIL}/${CONTEXT}.xml"  | tee -a ${DBLOG}
perl -pi -e 's/s_scan_name\">'${s_SCAN_NAME}'/s_scan_name\">'${t_SCAN_NAME}'/' ${APPSUTIL}/${CONTEXT}.xml  | tee -a ${DBLOG}

echo "set update_Scan to TRUE"  | tee -a ${DBLOG}
perl -pi -e 's/s_update_scan\">FALSE/s_update_scan\">TRUE/' ${APPSUTIL}/${CONTEXT}.xml  | tee -a ${DBLOG}

echo "Running autoconfig for task: ${TASK}" | tee -a ${DBLOG}

PASS="${APPS_PWD}"
if [[ "${TASK}" = "clone_auto_config_final" ]]; then
    PASS="${t_APPS_PWD}"
fi

echo ${PASS} | ${APPSUTIL}/scripts/${CONTEXT}/adautocfg.sh | tee -a ${DBLOG}
perl -pi -e 's/s_update_scan\">FALSE/s_update_scan\">TRUE/' ${APPSUTIL}/${CONTEXT}.xml  | tee -a ${DBLOG}

. ${BIN_DIR}/footer.sh

