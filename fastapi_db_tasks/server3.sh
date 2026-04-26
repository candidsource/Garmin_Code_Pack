#! /bin/bash


BASE_DIR="/u01/ebscloneauto/fastapi_db_tasks"
PYTHON_EXEC="/home/ebscloneauto/.pyenv/versions/candid_3.13/bin/python3"
PORT="8000"

OPTIONS=$1

function startServer() {
        cd "${BASE_DIR}" || { echo "Failed to change directory to ${BASE_DIR}"; exit 1; }
        "${PYTHON_EXEC}" -m uvicorn main:app --host 0.0.0.0 --port 8443 --workers 4 --ssl-keyfile=/u01/ebscloneauto/fastapi_db_tasks/ssl/key.pem --ssl-certfile=/u01/ebscloneauto/fastapi_db_tasks/ssl/cert.pem
}

function stopServer() {
        cd "${BASE_DIR}" || { echo "Failed to change directory to ${BASE_DIR}"; exit 1; }

        PID="$(pgrep -f main:app)"
        if [[ -n "$PID" ]]
                then
                        PGID="$(ps --no-headers -p $PID -o pgid)"
                        kill -SIGINT -- -${PGID// /}
        fi
}

case "$OPTIONS" in
        '-s' | '--start')
                startServer
        ;;
        '-x' | '--stop')
                stopServer
        ;;
esac
# journalctl -u candid_source -f
