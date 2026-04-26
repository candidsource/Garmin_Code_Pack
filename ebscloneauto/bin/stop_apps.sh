#!/bin/bash

BIN_DIR=$(dirname $(readlink -f $0))
. ${BIN_DIR}/header.sh

echo "Shutting down" | tee ${LOG}
PROCS="[F]ND|[I]NV|[P]AL|[P]OX|[R]CV|[I]NC|[A]LE|[f]s1|[f]s2"
EXC="clone|ocfs2"
PIDS=$(ps -ef | egrep "${PROCS}" | egrep -v "${EXC}" | awk '{print $2}' | xargs)
if [ $(echo ${PIDS} | wc -w) -eq 0 ]; then
  echo "No processes running" | tee -a ${LOG}
else
  echo "Killing $(echo ${PIDS} | wc -w) processes..." | tee -a ${LOG}
  sleep 30
  PIDS=$(ps -ef | egrep "${PROCS}" | egrep -v "${EXC}" | awk '{print $2}' | xargs)
  echo "$(echo ${PIDS} | wc -w) processes left." | tee -a ${LOG}
  ps -ef |grep `whoami` |grep -v sleep |grep -v stop_apps.sh |grep -v grep |grep -v "ps -ef" |grep -v sshd |grep -v bash |awk '{print $2}' 
fi

. ${BIN_DIR}/footer.sh
