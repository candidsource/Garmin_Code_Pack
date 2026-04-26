#!/bin/bash

. $HOME/.bash_clone

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

. ${BIN_DIR}/run.env

echo 'Active duplicate Start: ' `date` 
echo ''
rman target=sys/${s_SYS_PWD}@${S_PDB_NAME}CD_DR_VIP auxiliary=sys/${s_SYS_PWD}@${DB_NAME}_DR_VIP cmdfile ${SCRIPT}/../bin/.${ENV}_duplicate_from_${S_PDB_NAME}.rcv 
echo ''
echo 'Active duplicate END: ' `date`
