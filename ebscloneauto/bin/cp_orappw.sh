#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

. $HOME/asm.env

asmcmd rm -f +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD
asmcmd cp /mnt/nfs/oracle.patches/laks/.cscl/ORBUPG/orapwORBUPGCD +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD
asmcmd ls -lt +DATA_DG_ORBUPG/ORBUPGCD/password/orapwORBUPGCD


##. $HOME/.bash_clone

##rm -f  $ORACLE_HOME/dbs/orapwORBUPGCD*
##rm -f  $ORACLE_HOME/dbs/orapworbupgcd*
##cp /mnt/nfs/oracle.patches/laks/.cscl/ORBUPG/orapwORBUPGCD  $ORACLE_HOME/dbs/orapwORBUPGCD
##cp /mnt/nfs/oracle.patches/laks/.cscl/ORBUPG/orapwORBUPGCD  $ORACLE_HOME/dbs/orapwORBUPGCD1
##cp /mnt/nfs/oracle.patches/laks/.cscl/ORBUPG/orapwORBUPGCD  $ORACLE_HOME/dbs/orapworbupgcd
##cp /mnt/nfs/oracle.patches/laks/.cscl/ORBUPG/orapwORBUPGCD  $ORACLE_HOME/dbs/orapworbupgcd1
##ls -ltr $ORACLE_HOME/dbs/orapwORBUPGCD*
##ls -ltr $ORACLE_HOME/dbs/orapworbupgcd*
