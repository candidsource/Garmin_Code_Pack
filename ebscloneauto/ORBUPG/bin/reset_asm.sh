#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

##export ORACLE_SID=${ASM_SIDS[0]}
##. oraenv
. $HOME/asm.env
##env | grep ORACLE

echo "Deleting ASM directories"
echo "asmcmd rm -rf  ${LOGS_DG1}/${DB_NAME}"
asmcmd rm -rf  ${LOGS_DG1}/${DB_NAME}
echo "asmcmd rm -rf  ${LOGS_DG1}/${DB_SVC}"
asmcmd rm -rf  ${LOGS_DG1}/${DB_SVC}
echo "asmcmd rm -rf  ${LOGS_DG2}/${DB_NAME}"
asmcmd rm -rf  ${LOGS_DG2}/${DB_NAME}
echo "asmcmd rm -rf  ${LOGS_DG2}/${DB_SVC}"
asmcmd rm -rf  ${LOGS_DG2}/${DB_SVC}

echo "asmcmd rm -rf  ${DATA_DG}/${DB_NAME}"
asmcmd rm -rf  ${DATA_DG}/${DB_NAME}
echo "asmcmd rm -rf  ${DATA_DG}/${DB_SVC}"
asmcmd rm -rf  ${DATA_DG}/${DB_SVC}

echo "asmcmd rm -rf  ${RECO_DG}/${DB_NAME}"
asmcmd rm -rf  ${RECO_DG}/${DB_NAME}
echo "asmcmd rm -rf  ${RECO_DG}/${DB_SVC}"
asmcmd rm -rf  ${RECO_DG}/${DB_SVC}
echo "asmcmd rm -rf  ${RECO_DG}/${PDB_NAME}"
asmcmd rm -rf  ${RECO_DG}/${PDB_NAME}

echo "asmcmd rm -rf  ${TEMP_DG}/${DB_NAME}"
asmcmd rm -rf  ${TEMP_DG}/${DB_NAME}
echo "asmcmd rm -rf  ${TEMP_DG}/${DB_SVC}"
asmcmd rm -rf  ${TEMP_DG}/${DB_SVC}
echo "asmcmd rm -rf  ${TEMP_DG}/${PDB_NAME}"
asmcmd rm -rf  ${TEMP_DG}/${PDB_NAME}

echo "Creating ASM directories"
asmcmd mkdir  ${LOGS_DG1}/${DB_NAME}
asmcmd mkdir  ${LOGS_DG1}/${DB_SVC}
asmcmd mkdir  ${LOGS_DG1}/${DB_SVC}/controlfile
asmcmd mkdir  ${LOGS_DG2}/${DB_NAME}
asmcmd mkdir  ${LOGS_DG2}/${DB_SVC}
asmcmd mkdir  ${LOGS_DG2}/${DB_SVC}/controlfile
asmcmd ls -lt  ${LOGS_DG1}/
asmcmd ls -lt  ${LOGS_DG2}/

asmcmd mkdir  ${DATA_DG}/${DB_NAME}
asmcmd mkdir  ${DATA_DG}/${DB_NAME}/password
asmcmd mkdir  ${DATA_DG}/${DB_SVC}
asmcmd mkdir  ${DATA_DG}/${DB_SVC}/controlfile
asmcmd ls -lt ${DATA_DG}/

asmcmd mkdir  ${RECO_DG}/${DB_NAME}
asmcmd mkdir  ${RECO_DG}/${DB_SVC}
asmcmd mkdir  ${RECO_DG}/${PDB_NAME}
asmcmd mkdir  ${RECO_DG}/${DB_NAME}/ARCHIVELOG
asmcmd mkdir  ${RECO_DG}/${DB_SVC}/ARCHIVELOG
asmcmd mkdir  ${RECO_DG}/${PDB_NAME}/ARCHIVELOG
asmcmd ls -lt ${RECO_DG}

asmcmd mkdir  ${TEMP_DG}/${DB_NAME}
asmcmd mkdir  ${TEMP_DG}/${DB_SVC}
asmcmd mkdir  ${TEMP_DG}/${PDB_NAME}
asmcmd ls -lt ${TEMP_DG}

echo "Copying password file"
asmcmd rm -f +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD*
asmcmd cp /mnt/nfs/oracle.patches/laks/.cscl/ORBUPG/orapwORBUPGCD +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD
asmcmd ls -lt +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD

