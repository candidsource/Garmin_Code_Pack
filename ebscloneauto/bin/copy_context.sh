#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

title "Setting environment" | tee -a ${LOG}
. ${TGT_BASE_FS}/EBSapps.env run > /tmp/env.$$
cat /tmp/env.$$ | tee -a ${LOG}
rm /tmp/env.$$
cp 
