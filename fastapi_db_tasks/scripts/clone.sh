#! /bin/bash

THIS_DIR="$(dirname $(readlink -f -- $0))"
echo "THIS_DIR: ${THIS_DIR}"
ENV="${1}"
task_type="${2}"
task_segment="${3}"
task="${4}"
stat_arg="${5}"


if [[ ! -d "${SCRIPT_PATH}" ]]; then
    echo "$*"
    echo "SCRIPT_PATH DOES NOT EXIST: ${SCRIPT_PATH}"
    exit 1
fi


server_log_dir="${SCRIPT_PATH}/log/server"
mkdir -p "${server_log_dir}" > /dev/null 2>&1
server_log_file="${server_log_dir}/server.log"

if [[ ! "${task_type}" = "task-status" ]]; then
   echo "" > "${server_log_file}"
   echo "ENV: ${ENV}
task_type: ${task_type}
task_segment: ${task_segment}
task: ${task}
stat_arg/read_logs/patch_adop_args: ${stat_arg}

script_to_run: ${script_to_run}" | tee -a "${server_log_file}"

fi


case "${task_type}" in
    fast*)
        script_to_run="clone_db_fast.sh"
    ;;
    *)
        script_to_run="clone_db_garmin.sh"
    ;;
esac



function get_task_status() {
    local LOG_BASE_DIR="${SCRIPT_PATH}/log" latest_task_status
    local TASK_STATUS_LOG_DIR="${LOG_BASE_DIR}/TASK_STATUS"
    latest_task_status="$(ls -td ${TASK_STATUS_LOG_DIR}/${ENV}_*.log -1 | head -n 1)"
    echo "Latest task status file: ${latest_task_status}"
}

echo "ps -eaf | grep \"${script_to_run} ${ENV}\" | grep -v 'grep'"

case $stat_arg in
    stat|status)
        # main.py to check if the task is already running
        task_running_already="$(ps -eaf | grep "${script_to_run} ${ENV}" | grep -v 'grep')"
        if [[ -n "${task_running_already}" ]]; then
            already_running_task="$(echo "${task_running_already}" | grep -oP "${script_to_run} ${ENV}\K.*" )"
            echo "A task is already running: ${already_running_task}" | tee -a  "${server_log_file}"
            echo "${task_running_already}" | tee -a "${server_log_file}"
            exit 0
        else
            echo "${task}: is not running" | tee -a "${server_log_file}"
            exit 0
        fi
    ;;
    *)
        if [[ -n "${stat_arg// /}" ]]; then
            echo "stat_arg is: ${stat_arg}"
            echo "DEBUG: stat_arg not matched: ${*}"
        fi
    ;;
esac


if [[ "${task_type}" = "task-status" ]]; then
    get_task_status
    exit $?
else
    db_clone_script="${SCRIPT_PATH}/bin/${script_to_run}"
    if [[ -f "${db_clone_script}" ]]; then
        echo "db_clone_script file exists" | tee -a "${server_log_file}"
    else
        echo "db_clone_script does not exists: ${db_clone_script}" | tee -a "${server_log_file}"
        exit 1
    fi
    # echo "sh ${db_clone_script} ${ENV} ${@}"
    echo "${db_clone_script} $*" >> "${server_log_file}"
    echo "clone_db script: $db_clone_script" >> "${server_log_file}"
    echo "params: ${@}"
    sh "${db_clone_script}" ${@}  >> "${server_log_dir}/server.log" 2>&1 &
    echo "job submitted in background, check server log for more info: ${server_log_file}"
    exit $?
fi


