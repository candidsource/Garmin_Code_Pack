#!/bin/bash

#. $HOME/.bash_clone

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

. ${BIN_DIR}/run.env

echo 'Active duplicate Start: ' `date`
echo ''
rman target=sys/<password>@ORBITCD_DR_VIP auxiliary=sys/<password>@ORBUPGCD_DR_VIP cmdfile ${SCRIPT}/../clone/orbupg_duplicate_from_STBYCDB.sh
echo ''
echo 'Active duplicate END: ' `date`
