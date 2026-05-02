#!/bin/bash

usage()
{
  echo ""
  echo "Please pass environment to clone"
  echo "  cleanup_logs.sh <env>"
  echo "   - env = (dev, test)"
  echo ""
  exit 1
}

case ${1} in
  "dev" | "test" )
  ;;
  * )
    usage
  ;;
esac
ENV=${1}

BIN_DIR=$(dirname $(readlink -f $0))
cat ${BIN_DIR}/${ENV}.env > ${BIN_DIR}/run.env
. ${BIN_DIR}/header.sh

echo "Cleaning logs" | tee ${LOG}
echo ebssvr001 | tee -a ${LOG}
rm ~/log/${ENV}*clone.log
echo "  Done..." | tee -a ${LOG}
NODES="oracle@odbsvr001 ${DBS[@]} ${APPS[@]}"
for NODE in ${NODES}; do
  echo ${NODE} | cut -d@ -f2 | tee -a ${LOG}
  ssh -t ${NODE} "rm log/*" | tee -a ${LOG}
  echo "  Done..." | tee -a ${LOG}
done

. ${BIN_DIR}/footer.sh
