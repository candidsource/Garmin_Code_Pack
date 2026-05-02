#!/bin/bash

## util
function dbg() {
    echo -e "${@}"
}
export -f dbg

print_call_stack() {
    echo "Call stack:"
    local i
    for ((i=${#FUNCNAME[@]}-1; i>=1; i--)); do
        printf '  at %s() in %s:%s\n' \
            "${FUNCNAME[i]}" \
            "${BASH_SOURCE[i]}" \
            "${BASH_LINENO[i-1]}"
    done
}


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
    env="$1"
    task_type="$2"
    task_segment="$3"
    task="$4"
    status="$5"
    log="${@:6}"

    local style='style="background-color: #adb5bd; max-width: 200px;"'
    local header_bg

    if [[ "${status,,}" = fail* ]]; then
        header_bg="red"
    elif [[ "${status,,}" =~ pass|comp ]]; then
        header_bg="green"
    else
        header_bg="yellow"
    fi

    echo '<!DOCTYPE html>'
    echo -e "
<html>
<head>
    <style>
         h2 {
            color: black;
            background-color: ${header_bg};
        }
        table {
            width: 100%;
            border-collapse: collapse;

        }
        th, td {
            border: 1px solid #dee2e6;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }

        
    </style>
</head>
<body>
    <div style=\"max-width: 800px;\">
    	<h2> Candid Source LLC 'ebscloneauto' Licensed for use for L3Harris Technologies</h2>
        <h2>TASK: ${status}</h2>
        <table>
            <tr>
                <td ${style}>TASK</td>
                <td>${task_type^^}-${task_segment^^}_${task^^}</td>
            </tr>
            <tr>
                <td ${style}>ENV</td>
                <td>${env}</td>
            </tr>
            <tr>
                <td ${style}>STATUS</td>
                <td>${status}</td>
            </tr>
            <tr>
                <td ${style}>SNAPSHOT</td>
                <td>${log}</td>
            </tr>
        </table>
    </div>
</body>
</html>
"

}

function mail_html_body_v2(){
    local task env status log msg
    env="$1"
    task_type="$2"
    task_segment="$3"
    task="$4"
    status="$5"
    log="${@:6}"

    msg="${task_type^^} ${task_segment^^} ${task_name^^}: ${state^^}"

    # echo "env=${env}"
    # echo "task_type=${task_type}"
    # echo "task_segment=${task_segment}"
    # echo "task=${task}"
    # echo "status=${status}"

    local style='style="background-color: #adb5bd; max-width: 200px;"'
    local msg_bg

    if [[ "${status,,}" = fail* ]]; then
        msg_bg="red"
    elif [[ "${status,,}" =~ pass|comp ]]; then
        msg_bg="green"
    else
        msg_bg="yellow"
    fi

    cat "${SCRIPT_PATH}/bin/mail.html"  | sed \
        -e "s|__TASK__|${task_type^^}-${task_segment^^}_${task^^}|g" \
        -e "s|__ENV__|${env}|g" \
        -e "s|__STATUS__|${status}|g" \
        -e "s|__MESSAGE__|${msg}|g" \
        -e "s|__MSG_BG__|${msg_bg}|" \
        -e "s|__COMPANY__|Candid Source|g"
        # -e "s|__LOG__|${log}|g" \


}

function log_task_status() {
    local env="$1"
    local task_type="$2"
    local task_segment="$3"
    local task_name="$4"
    local state="${5,,}"
    local logfile="${6}"
    local timestamp logfile line

    # echo "env: ${env}"
    # echo "task_type: ${task_type}"
    # echo "task_segment: ${task_segment}"
    # echo "task_name: ${task_name}"
    # echo "state: ${state}"
    # echo "logfile: ${logfile}"
    # print_call_stack


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

    # end time is empty
    if [[ "$state" = "RUNNING" ]] || [[ "$state" = "QUEUED" ]]; then
        LINE="${timestamp},--,${task_type},${task_segment},${task_name},${state}"

        # if new task already lined up, replace the old line
        grep -q "${task_type},${task_segment},${task_name}" "$TASK_STATUS" && sed -i "s|.*${task_type},${task_segment},${task_name}.*|${LINE}|" "$TASK_STATUS" || echo "$LINE" >>"$TASK_STATUS"
    else
        # if state is not running ie completed or failed, update the line
        line="${timestamp},${task_type},${task_segment},${task_name},${state}"
        
        if grep -q "${task_type},${task_segment},${task_name}" "$TASK_STATUS"; then
            sed -i "s|--,${task_type},${task_segment},${task_name}.*|${line}|" "$TASK_STATUS"
        else
            cat "$TASK_STATUS"
            echo "${task_type}:${task_segment}:${task_name} not initialized in task status file: ${TASK_STATUS}"
        fi
    fi

    if [[ "${state}" = "FAILED" ]]; then
        echo "!! FAILED, any job in queue will be aborted: ${ENV} ${task_type}-${task_segment}_${task}"
        clear_failed_downstream_tasks "${ENV}" "${task_type}" "${task_segment}" "${task}" "${logfile}"
    fi

    if [[ "FAILED|COMPLETED|RUNNING" = *${state}* ]]; then
        command -v mutt &>/dev/null || { echo "mutt not installed, cannot send email"; return 1; }
        
        local mailto="${CANDID_EMAIL:-aditya@candidsource.com},laks@candidsource.com"
        # mail_html_body ${task_name} ${logfile%%_*} ${state} "$(tail "${logfile}")"  | mutt -s "Task ${task_name} ${state}" -a "${logfile}" "${mailto}"

        if [[ ! -f "${logfile}" ]]; then
            echo "!!!! Log file does not exist: ${logfile}"
            mail_html_body_v2 "${env^^}" "${task_type}" "${task_segment}" "${task_name}" "${state}" "FILE NOT FOUND: ${logfile}" |
            mutt -e 'set content_type=text/html' \
                -s "Task ${task_type^^} ${task_segment^^} ${task_name^^} ${state^^}" \
                -- "${mailto}"
            return 0
        fi
        
        # used to format log file snapshot
        # "$(tail "${logfile}" | sed ':a;N;$!ba;s/\n/<br>/g')" 

        mail_html_body_v2 "${env^^}" "${task_type}" "${task_segment}" "${task_name}" "${state}" "LOG PLACE HOLDER" | mutt \
            -e 'set content_type=text/html' \
            -s "Task ${task_type^^} ${task_segment^^} ${task_name^^} ${state^^}" \
            -a "${logfile}" -- "${mailto}"
    fi

}

function clear_failed_downstream_tasks() {
    local downstream_tasks env task_type task_segment task logfile
    env="$1"
    task_type="$2"
    task_segment="$3"
    task_name="$4"
    logfile="${5}"

    echo "Clearing downstream tasks for failed task: ${env} ${task_type}-${task_segment}"
    downstream_tasks="$(grep -E "QUEUED" "${TASK_STATUS}" | cut -d, -f3-5)"
    echo "Downstream tasks to clear: ${downstream_tasks}"
    export DB_CLONE_TASKS=""
    export APP_CLONE_TASKS=""
    export FINAL_TASKS=""

    for atask in $downstream_tasks; do
        task_type="$(echo "${atask}" | cut -d, -f1)"
        task_segment="$(echo "${atask}" | cut -d, -f2)"
        task_name="$(echo "${atask}" | cut -d, -f3)"
        echo "Clearing downstream task: ${task_type}:${task_name}"
        log_task_status "${env}" "${task_type}" "${task_segment}" "${task_name}" "Upstream Failed" "${logfile}"
    done
}



