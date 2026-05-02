AFTER="$(date +%s)"
SECONDS="$(expr ${AFTER} - ${BEFORE})"
TIME=`date --date "1970-01-01 ${SECONDS} sec" "+%T"`
title "Completed in : ${TIME}" | tee -a ${LOG}
