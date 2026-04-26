#! /bin/bash

ENV="${1}"
task_type="${2}"
task_segment="${3}"
task_name="${4}"

if [[ -z "${task_name}" ]]; then
    echo "Need a task"
    exit 1
fi

log_file="${5}"
log_page="${6:-0}"


LOG_DIR="${SCRIPT_PATH}/log/${task_type}-${task_segment}/${task_name}"


if [[ ! -d "${LOG_DIR}" ]]; then
    echo "ERROR: LOG_DIR does not exist: ${LOG_DIR}"
    exit 0
fi

if [[ -z "${log_file}" ]]; then
    # list all non empty log files
    # find "${LOG_DIR}" -type f -size +0c | ls -t -printf "%f\n"
    echo "READ_LOGS_OUTPUT"
    find "${LOG_DIR}" -type f -size +0c -name "${ENV}*log" | xargs ls -t | head -n 10 | awk -F '/' '{print $NF;}'
    exit 0
fi

task_log_file="${LOG_DIR}/${log_file}"
if [[ ! -f "${task_log_file}" ]]; then
    echo "ERROR: FILE DOES NOT EXIST: ${task_log_file}"
    exit 0
fi


if [[ "${log_page}" -eq 0 ]]; then
    echo "READ_LOGS_OUTPUT"
    wc -l "${task_log_file}"
    cat "${task_log_file}"
else
    echo "READ_LOGS_OUTPUT"
    wc -l "${task_log_file}"
    tail -n +${log_page} "${task_log_file}"
fi
exit 0





