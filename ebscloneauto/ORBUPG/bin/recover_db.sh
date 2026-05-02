#!/bin/bash

. $HOME/.bash_profile

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh
PATH=${PATH}:/usr/local/bin

title "Setting environment" | tee -a ${LOG}
ORACLE_SID=${DB_SIDS[0]}
##. oraenv
env | grep ORACLE | tee -a ${LOG}

title "Recovering" | tee -a ${LOG}
rman target / @${SCRIPT}/recover.rman | tee -a ${LOG}

. ${BIN_DIR}/footer.sh
