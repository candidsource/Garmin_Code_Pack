#!/bin/env bash
###########################################################################
# This script is to update primary and secondary concurrent manager nodes #
#  script name : orb_update_conc_mgr_nodes.sh                             #
#  created by  : Venkat Atluri                                            #
#  created on  : 17-July-23                                               #
#  Last modfied: 06-Aug-23                                               #
###########################################################################
SCOUNT=0
APPS_PWD=
TARGET_ENV=
SCRIPT_PATH=
LOG_FILE_NAME=
ALL_LOG_FILE_NAME=
CONC_MGR_NODES=

#source the global functions file
source /mnt/nfs/ebscam/clone/global_functions.sh > /dev/null

update_exec_status()
{
 local SCRIPT_EXEC_STATUS=$(_checkExecStatus ${LOG_FILE_NAME} $(($SCOUNT+1)) )
 [ "${SCRIPT_EXEC_STATUS}" = "Success" ] && { SCOUNT=$(($SCOUNT+1)) ; }
 echo "${1}+++${2}+++${SCRIPT_EXEC_STATUS}" >> ${ALL_LOG_FILE_NAME}
}

#Check if target env parameter is passed
if [ ! -z "$1" ]; then
  TARGET_ENV="${1,,}"
else
  TARGET_ENV=$(_getDBName)
  [ -z "$TARGET_ENV" ] && {  echo "Error: Unable to fetch target DB name. Exiting"; exit 10; }
fi

#Get apps password if not passed as 2nd argument
[ -z "$2" ] && { APPS_PWD=$(_getAppsPwd); } || { APPS_PWD="$2"; }
#Check if apps password is null
[ -z "${APPS_PWD}" ] && { echo -e "\nError: Apps user password can't be null. Exiting"; exit 10; }

#Extracting full script path
SCRIPT_PATH=$(dirname $(realpath -s "$0"))
LOG_FILE_NAME=$(_getLogFileName "$TARGET_ENV" "$0")
ALL_LOG_FILE_NAME=$(_getAllStatusLog "$TARGET_ENV" "$0" "postclone")

[ -z "${LOG_FILE_NAME}" ] && { echo -e "\nError: Unable to generate the log file. Exiting"; exit 10; }

#Extracting concurrent manager nodes from context_files
CONC_MGR_NODES=($(grep s_batch_status ${INST_TOP%_*}*/appl/admin/${TWO_TASK%%_*}_*.xml |grep ">enabled<" |awk '{print $1}' | awk -F/ '{print $NF}' |awk -F: '{print $1}'| awk -F_ '{print $2}' |awk -F.xml '{print $1}' | xargs))

[ ${#CONC_MGR_NODES[@]} != 2 ] && { echo -e "\nError: The number of CM nodes fetched is not 2. Exiting"; exit 10; }

#Making the contents of the logfile to null
> ${LOG_FILE_NAME}
#> ${ALL_LOG_FILE_NAME}

echo -e "\nThe CM Node1: ${CONC_MGR_NODES[0]}"
echo -e "The CM Node2: ${CONC_MGR_NODES[1]}"

sqlplus -s apps/${APPS_PWD} <<-EOF
 spool $LOG_FILE_NAME
 @${SCRIPT_PATH}/orb_update_conc_mgr_nodes.sql ${CONC_MGR_NODES[0]} ${CONC_MGR_NODES[1]}
 spool off
 exit
EOF

grep "PL/SQL procedure successfully completed." ${LOG_FILE_NAME} > /dev/null
update_exec_status "3.1" "Update concurrent manager nodes" 
[ $? != 0 ] && { echo -e "\n Error:Updation of concurrent manager nodes failed."; exit 10; }


echo -e "\nLog File: $LOG_FILE_NAME"
#Deleting old log files
_deleteOldLogs "${LOG_FILE_NAME}"

