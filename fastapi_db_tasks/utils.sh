#!/bin/bash

## util
function dbg() {
  echo -e "${@}"
}
export -f dbg


function check_file_exists() {
    local file_name="$1" var_name="${2:-FILE}" exit_if_not_exists="${3:-1}"

    if [[ -z "${file_name// /}" ]]; then
        dbg "File name is empty"
        return 1
    fi

    if [[ ! -f "${file_name}" ]]; then
        dbg "${var_name} DOES NOT EXIST: ${file_name}"
        ls -l "${file_name%/*}"
        if [[ "${exit_if_not_exists}" -eq 1 ]]; then
            return 1
        fi
    else
        dbg "${var_name} DOES EXIST: ${file_name}"
        return 0
    fi
}
export -f check_file_exists

function err() {
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    echo -e "${RED}${@}${NC}"
}

function mail_html_body() {
    local task env status log
    task="$1"
    env="${ENV:-$2}"
    status="$3"
    log="${@:4}"


    echo '<!DOCTYPE html>'
    echo -e "
<html>
<head>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h2>TASK: ${status}</h2>
    <table>
        <tr>
            <th>Name</th>
            <th>Value</th>
        </tr>
        <tr>
            <td>TASK</td>
            <td>${task}</td>
        </tr>
        <tr>
            <td>ENV</td>
            <td>${env}</td>
        </tr>
        <tr>
            <td>STATUS</td>
            <td>${status}</td>
        </tr>
        <tr>
            <td>SNAPSHOT</td>
            <td>${log}</td>
        </tr>
    </table>
</body>
</html>
"


}

function log_task_status() {
    local task_name="$1"
    local state="${2,,}"
    local env="${3:-$ENV}"
    local timestamp
    local logfile="${DBLOG}"
    local line
    timestamp="$(date +"%m-%d-%Y %H:%M:%S")"
    case $state in
        start*)
            state="RUNNING"
        ;;
        end*)
            state="COMPLETED"
        ;;
        fail*)
            state="FAILED"
        ;;
        q*)
            state="QUEUED"
        ;;
    esac
    
    if [[ "${task_name}" = app* ]]; then
        logfile="${APPLOG}"
    fi


    # end time is empty
    LINE="${timestamp},--,${task_name},${state}"
    if [[ "$state" = "RUNNING" ]] || [[ "$state" = "QUEUED" ]]; then
        # if new task lined up, replace the old line
        grep -q "${task_name}" "$TASK_STATUS" && sed -i "s|.*${task_name}.*|${LINE}|" "$TASK_STATUS" || echo "$LINE" >> "$TASK_STATUS"
    else
        # if state is not running, updated the line
        line="${timestamp},${task_name},${state}"
        grep -q "${task_name}" "$TASK_STATUS" && sed -i "s|--,${task_name}.*|${line}|" "$TASK_STATUS" || echo "${task_name} not initialized in task status file: ${TASK_STATUS}"
    fi

    if [[ "${state}" = "FAILED" ]]; then
        echo "$task FAILED, any job in queue will be aborted"
        clear_failed_downstream_tasks ${logfile}
    fi


    if [[ "FAILED|COMPLETED|RUNNING" = *${state}* ]]; then
        local mailto="${CANDID_EMAIL:-laks@candidsource.com}"
        mail_html_body ${task_name} ${env^^} ${state} "$(tail "${logfile}")" \
        | mutt -e 'set content_type=text/html' \
                -s "Task ${task_name} ${state}" \
                -a "${logfile}" -- "${mailto}"
    fi
    
}

function clear_failed_downstream_tasks() {
    local downstream_tasks logfile
    logfile="${1}"


    downstream_tasks="$(grep 'QUEUED' ${TASK_STATUS} | cut -d, -f3)"
    echo "Downstream tasks: ${downstream_tasks}"
    export DB_CLONE_TASKS=""
    export APP_CLONE_TASKS=""

    for atask in $downstream_tasks; do
        log_task_status $atask "Upstream Failed"
    done
}

