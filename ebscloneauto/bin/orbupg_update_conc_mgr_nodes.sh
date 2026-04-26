#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

. ${BIN_DIR}/run.env

title "Setting environment" | tee -a ${LOG}
. ${TGT_BASE_FS}/EBSapps.env run > /tmp/env.$$
cat /tmp/env.$$ | tee -a ${LOG}
rm /tmp/env.$$

#Extracting concurrent manager nodes from context_files
CONC_MGR_NODES=($(grep s_batch_status ${INST_TOP%_*}*/appl/admin/${TWO_TASK%%_*}_*.xml |grep ">enabled<" |awk '{print $1}' | awk -F/ '{print $NF}' |awk -F: '{print $1}'| awk -F_ '{print $2}' |awk -F.xml '{print $1}' | xargs))

[ ${#CONC_MGR_NODES[@]} != 2 ] && { echo -e "\nError: The number of CM nodes fetched is not 2. Exiting"; exit 10; }

echo -e "\nThe CM Node1: ${CONC_MGR_NODES[0]}"
echo -e "The CM Node2: ${CONC_MGR_NODES[1]}"


sqlplus apps/${t_APPS_PWD}  @${SCRIPT}/${ENV}_conc_mgr_nodes.sql ${CONC_MGR_NODES[0]} ${CONC_MGR_NODES[1]}

