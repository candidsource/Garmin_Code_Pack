#!/bin/bash

. $HOME/.bash_dev1

if [ $# -ne 1 ]; then
  echo "No environment passed..."
  exit 1
else
  INST=${1}
fi

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

title "Setting environment"
ORACLE_SID=${DB_SIDS[${INST}]}
##. oraenv
export TNS_ADMIN="${ORACLE_HOME}/network/admin/${ORACLE_SID}_$(hostname -s)"
env | grep ORACLE
env | grep TNS

title "HA Setup"
echo "" >> $TNS_ADMIN/sqlnet.ora
echo "tcp.invited_nodes=(${HA_NODE})" >> $TNS_ADMIN/sqlnet.ora
echo "tcp.validnode_checking=yes" >> $TNS_ADMIN/sqlnet.ora
echo "SQLNet updated."
