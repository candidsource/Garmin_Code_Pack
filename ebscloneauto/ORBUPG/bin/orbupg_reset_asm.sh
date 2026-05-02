#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

##export ORACLE_SID=${ASM_SIDS[0]}
##. oraenv
. $HOME/asm.env
##env | grep ORACLE

echo "Deleting ASM directories"
asmcmd rm -rf +DATA_DG_ORBUPG/ORBUPGCD/controlfile
asmcmd rm -rf +REDO1_DG_ORBUPG/ORBUPGCD/controlfile
asmcmd rm -rf +REDO2_DG_ORBUPG/ORBUPGCD/controlfile
asmcmd rm -rf +REDO2_DG_ORBUPG/ORBUPGCD/password
asmcmd rm -rf +REDO2_DG_ORBUPG/ORBUPGCD/PARAMETERFILE
asmcmd rm -rf +TEMP_DG_ORBUPG/ORBUPGCD/TEMPFILE
asmcmd rm -rf +TEMP_DG_ORBUPG/ORBUPGCD/
asmcmd rm -rf +TEMP_DG_ORBUPG/ORBUPG/
asmcmd rm -rf +TEMP_DG_ORBUPG/ORBUPGKC3/
asmcmd rm -rf +DATA_DG_ORBUPG/ORBUPGKC3/controlfile/
asmcmd rm -rf +REDO1_DG_ORBUPG/ORBUPGKC3/controlfile/
asmcmd rm -rf +REDO2_DG_ORBUPG/ORBUPGKC3/controlfile/
asmcmd rm -rf +RECO_DG_ORBUPG/ORBUPGCD/ARCHIVELOG/
asmcmd rm -rf +RECO_DG_ORBUPG/ORBUPGCD/AUTOBACKUP/
asmcmd rm -rf +DATA_DG_ORBUPG/ORBUPGCD/
asmcmd rm -rf +REDO1_DG_ORBUPG/ORBUPGCD/
asmcmd rm -rf +REDO2_DG_ORBUPG/ORBUPGCD/
asmcmd rm -rf +DATA_DG_ORBUPG/ORBUPGKC3/
asmcmd rm -rf +REDO1_DG_ORBUPG/ORBUPGKC3/
asmcmd rm -rf +REDO2_DG_ORBUPG/ORBUPGKC3/
asmcmd rm -rf +DATA_DG_ORBUPG/ORBUPGCDKC3/
asmcmd rm -rf +REDO1_DG_ORBUPG/ORBUPGCDKC3/
asmcmd rm -rf +REDO2_DG_ORBUPG/ORBUPGCDKC3/

echo "Creating ASM directories"
asmcmd mkdir +DATA_DG_ORBUPG/ORBUPGCD
asmcmd mkdir +REDO1_DG_ORBUPG/ORBUPGCD
asmcmd mkdir +REDO2_DG_ORBUPG/ORBUPGCD
asmcmd mkdir +DATA_DG_ORBUPG/ORBUPGKC3
asmcmd mkdir +TEMP_DG_ORBUPG/ORBUPGCD
asmcmd mkdir +TEMP_DG_ORBUPG/ORBUPG
asmcmd mkdir +TEMP_DG_ORBUPG/ORBUPGKC3
asmcmd mkdir +DATA_DG_ORBUPG/ORBUPGKC3
asmcmd mkdir +REDO1_DG_ORBUPG/ORBUPGKC3
asmcmd mkdir +REDO2_DG_ORBUPG/ORBUPGKC3

asmcmd mkdir +DATA_DG_ORBUPG/ORBUPGCD/controlfile
asmcmd mkdir +REDO1_DG_ORBUPG/ORBUPGCD/controlfile
asmcmd mkdir +REDO2_DG_ORBUPG/ORBUPGCD/controlfile
asmcmd mkdir +DATA_DG_ORBUPG/ORBUPGCD/password
asmcmd mkdir +DATA_DG_ORBUPG/ORBUPGCD/PARAMETERFILE
asmcmd mkdir +RECO_DG_ORBUPG/ORBUPGCD/ARCHIVELOG
asmcmd mkdir +RECO_DG_ORBUPG/ORBUPGCD/AUTOBACKUP

echo "Copying password file"
asmcmd rm -f +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD*
asmcmd cp /mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orapworbupgcd +DATA_DG_ORBUPG/ORBUPGCD/PASSWORD/orapworbupgcd
asmcmd ls -lt +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD

