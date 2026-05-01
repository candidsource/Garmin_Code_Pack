#! /bin/bash

# *===========================================================================+
# |  Copyright (c) 2022 Candid Source LLC, USA
# |                        All rights reserved                                |
# +===========================================================================+
# License Type - License provided by Candid Source LLC for GARMIN INTERNATIONAL only
# Version 2.0



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

# script exits on error
set -e

echo "!!!!!!!!!!FULL CLONE DB LOGS!!!!!!!!!!!!!!!!!!"
ENV="${1}"
TASK_TYPE="${2}"
TASK_SEGMENT="${3}"
TASK="${4}"
RESUME="${5}"

LOG_BASE_DIR="${SCRIPT_PATH}/log"


echo "ENV: ${ENV}"
echo "TASK_TYPE: ${TASK_TYPE}"
echo "TASK_SEGMENT: ${TASK_SEGMENT}"
echo "TASK: ${TASK}"
echo "RESUME: ${RESUME}"


export BIN_DIR=$(dirname $(readlink -f -- $0))
echo "BIN_DIR is: ${BIN_DIR}"

function init_utils() {
    echo "initiating utils"
    local utils_script="${BIN_DIR}/utils.sh"
    source ${utils_script}
}
init_utils

echo "Automated Clone by Candid Source LLC.  You are running licensed version. Please do not copy or distribute"


my_exit() {
    echo "${1^^}: ${2^^} EXIT_CODE: ${3}" | tee -a "${log_file}"
    exit 1
}

db_clone_usage() {
    echo ""
    echo "Please pass environment to db clone"
    echo "  clone_db.bin <env>"
    echo "   - env = (orbupg, orbprj, plnppg)"
    echo ""
    exit 0
}

app_clone_usage() {
    echo ""
    echo "Please pass environment to app clone"
    echo "  clone_db.bin <env>"
    echo "   - env = (orbupg, orbprj, plnupg, plnprj)"
    echo ""
    exit 1
}

function set_logs() {
    export TIMESTAMP
    TIMESTAMP="$(date '+%Y_%m_%d_%H-%M-%S')"

    export TASK_STATUS_LOG_DIR="${LOG_BASE_DIR}/TASK_STATUS"
    mkdir -p "${TASK_STATUS_LOG_DIR}"

    export TASK_STATUS="${TASK_STATUS_LOG_DIR}/${ENV}_TASK_STATUS.log"
    echo "TASK_STATUS is: ${TASK_STATUS}"
}



function create_run_env() {
    local log_dir
    local task_type="${1}" task_segment="${2}" task="${3}"
    ENV_FILE="${BIN_DIR}/${ENV,,}.env"
    export RUN_ENV="${BIN_DIR}/run.env"
    check_file_exists "${ENV_FILE}" "ENV_FILE"

    dbg "Creating run.env from ${ENV}.env in ${BIN_DIR}"
    echo -e "SCRIPT_PATH=${SCRIPT_PATH}" | cat - "${ENV_FILE}" > "${RUN_ENV}"

    check_file_exists "${RUN_ENV}" "RUN_ENV"

    log_dir="${LOG_BASE_DIR}/${task_type}-${task_segment}/${task}"
    echo "making log dir:  ${log_dir}"
    mkdir -p "${log_dir}"
    

    export LOG_FILE="${log_dir}/${ENV}_${TIMESTAMP}_${task}.log"
    echo "Creating LOG_FILE: ${LOG_FILE}"
    touch "${LOG_FILE}"
    chmod 766 "${LOG_FILE}"
    echo "
export LOG_FILE=${LOG_FILE}

" >> "${RUN_ENV}"

    echo "
export TASK_STATUS=${TASK_STATUS_LOG_DIR}/${ENV}_TASK_STATUS.log

" >> "${RUN_ENV}"
}

function get_creds() {
    local creds="$(gpg --quiet --batch --yes --passphrase-fd 0  --decrypt ${BIN_DIR}/creds.sh.gpg <<< "$PASSPHRASE" | grep -E '^export')"
    
    if [[ -z "${creds// /}" ]]; then
        gpg-connect-agent reloadagent /bye
        creds="$(gpg --quiet --batch --yes --passphrase-fd 0  --decrypt ${BIN_DIR}/creds.sh.gpg <<< "$PASSPHRASE" | grep -E '^export')"
    fi
    export CREDS="${creds//$'\n'/; };"
    echo "Creds have been set up"
}

function create_env_file() {
    local task_type="${1}" task_segment="${2}" task="${3}"
    if [[ "${task_segment}" = "apps" ]]; then
        export CONFIG_JVM_ARGS="-Xmx28000m -Xms28000m -XX:MaxPermSize=2048m -XX:-UseGCOverheadLimit"
    fi
    create_run_env "${task_type}" "${task_segment}" "${task}"
    source ${BIN_DIR}/run.env
}

function db_clone_auto_cfg() {
    local task_type="${1}" task_segment="${2}" task="${3}"
    local script_path ssh_exit_code auto_config_completed_with_errors

    local log_file="${LOG_FILE}"
    
    if [[ -z "${task// /}" ]]; then
        echo "Kindly provide task name, task_type: ${task_type}, task_segment:${task_segment}, task: ${task}"
        log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
        my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
    elif [[ "${task}" = clone_post_steps* ]] || [[ "${task}" = "clone_auto_config_final" ]]; then
        echo "Running post clone db auto config for task: ${task}" | tee -a ${log_file}
        script_path="${BIN_DIR}/autocfg_db_post.sh"
    else
        script_path="${BIN_DIR}/autocfg_db.bin"
    fi

    local INST=0
    if ! get_creds; then
        log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
        my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
    fi
    echo "script to execute is: ${script_path}"

    for NODE in ${ACFG[@]}; do
        ((INST = INST + 1))
        echo "autocnfiguring db on ${NODE} and INST is: ${INST}"
        echo "TASK: ${task}, script path: ${script_path}"

        echo "${CREDS} ${script_path} $ENV ${INST} ${task}" | ssh -t "${NODE}" | tee -a "${log_file}"
        ssh_exit_code="${PIPESTATUS[1]}"
        echo "ssh_exit_code is: ${ssh_exit_code} for node: ${NODE}"

        if [[ "${ssh_exit_code}" -ne 0 ]]; then
            echo "Marking task: ${task} as failed, on node: ${NODE}"
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
            my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
        fi
        echo "ssh command completed successfully on node: ${NODE}"
        
    done
    echo "db_clone_auto_cfg completed for task_type: ${task_type}, task_segment: ${task_segment}, task: ${task}"
    return 0
}

function db_clone_tasks() {
    local script_path env="${1}" task_type="${2}" task_segment="${3}" task="${4}" creds
    local log_file="${LOG_FILE}" task_selector

    print_call_stack

    echo "RUNNING DB_CLONE TASK, task_type: ${task_type}, task_segment: ${task_segment}, task: ${task}" | tee -a "${log_file}"

    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" start "${log_file}"

    task_selector="${task_segment}_${task}"
    echo "db clone TASK selector IS: ${task_selector}"
    case "${task_selector}" in
        clone_primary)
            if [[ -z "${PRIMARY_DBS// /}" ]]; then
                echo "PRIMARY_DBS is not set"
                exit 1
            fi
            script_path="${BIN_DIR}/primary_db.bin"
            for node in $PRIMARY_DBS; do
                ssh -t $node ${script_path} "${ENV}" | tee -a "${log_file}"

                ssh_exit_code="${PIPESTATUS[0]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                    my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
                fi
            done
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0

        ;;
        clone_secondary)
            if [[ -z "${SECONDRY_DBS// /}" ]]; then
                echo "SECONDRY_DBS is not set"
                exit 1
            fi
            script_path="${BIN_DIR}/secondary_db.bin"
            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            for node in $SECONDRY_DBS; do
                echo  "${script_path} $ENV" | ssh -t $node | tee -a "${log_file}"

                ssh_exit_code="${PIPESTATUS[1]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                    my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
                fi
            done

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
        ;;
        clone_third)
            if [[ -z "${SECONDRY_DBS// /}" ]]; then
                echo "SECONDRY_DBS is not set"
                exit 1
            fi
            script_path="${BIN_DIR}/third_db.sh"
            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            for node in $THIRD_DBS; do
                echo  "${script_path} $ENV" | ssh -t $node | tee -a "${log_file}"

                ssh_exit_code="${PIPESTATUS[1]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                    my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
                fi
            done

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
	    ;;
        clone_auto_config*|final_clone_auto_config_final)
            local auto_config_completed_with_errors auto_config_completed_successfully
            db_clone_auto_cfg "${task_type}" "${task_segment}" "${task}"
            exit_code="$?"
            if [[ "${exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
        ;;
        clone_post_steps*)
            new_script_path=""
            if [[ "${task_selector}" = "clone_post_steps_apps" ]]; then
                script_path="${BIN_DIR}/db_post_clone_steps_apps.sh"
                env_file="${PDB_NAME}_${LOGICAL_DB_NODE1:-${DB_NODE1}}.env"
                new_script_path="${BIN_DIR}/DB_post_clone_steps_apps_${PDB_NAME}.sh"
            elif [[ "${task_selector}" = "clone_post_steps_sys" ]]; then
                script_path="${BIN_DIR}/db_post_clone_steps_sys.sh"
                env_file="${DB_SIDS[0]}_${LOGICAL_DB_NODE1:-${DB_NODE1}}.env"
                new_script_path="${BIN_DIR}/DB_post_clone_steps_sys_${DB_SIDS[0]}.sh"
            fi

            echo "ENV FILENAME ON: ${env_file}"
            echo "new_script_path: ${new_script_path}"
            if [[ -z "${new_script_path// /}" ]]; then
                echo "PATH DOES NOT EXIST: ${new_script_path}"
                echo "Ceate the file and give appropriate permissions"
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            extra_vars="ENV=${ENV}
BIN_DIR=${BIN_DIR}
. ${BIN_DIR}/run.env

SCRIPT=${SCRIPT_PATH}/clone
echo \"Sourcing: ${DB_HOME}/${env_file}\"
. ${DB_HOME}/${env_file}"

            echo -e "${extra_vars}" | cat - "${script_path}" > ${new_script_path}

            if [[ -z "${PRIMARY_DBS// /}" ]]; then
                echo "PRIMARY_DBS is not set"
	            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
		        my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
            fi
            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            echo "${CREDS} ${new_script_path}" | ssh -t ${PRIMARY_DBS[0]}  | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
            if [[ "${ssh_exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            if [[ "${task_selector}" = "clone_post_steps_apps" ]]; then
                echo "Executing db auto cfg after db post clone steps"
                db_clone_auto_cfg "${task_type}" "${task_segment}" "${task}"
                exit_code="$?"
                if [[ "${exit_code}" -ne 0 ]]; then
                    echo "db auto cfg after db post clone steps failed"
                    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                    my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
                fi
            fi
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"

        ;;
        *)
            echo "Unknown clone task: ${task_selector}"
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
	        my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
        ;;
    esac
}

function apps_clone_tasks() {
    local script_path env="${1}" task_type="${2}" task_segment="${3}"  task="${4}"
    local log_file="${LOG_FILE}"

    dbg "apps clone TASK IS: ${task}"
    echo "RUNNING APP_CLONE TASK, task_type:${task_type}, $task" | tee -a "${log_file}"

    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" start "${log_file}"

    task_selector="${task_segment}_${task}"
    echo "db clone TASK selector IS: ${task_selector}"
    case "${task_selector}" in
        apps_file_system)
            script_path="${BIN_DIR}/create_fs.sh"
            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            echo "${CREDS} ${script_path} ${RUN_ENV}" | ssh -t ${APPS[0]}  | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
            if [[ "${ssh_exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
        ;;
        apps_primary)
            RUN=${TGT_RUN_FS}
            PATCH=${TGT_PATCH_FS}
            script_path="${BIN_DIR}/primary_apps.bin"
            
            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            echo "${CREDS} ${script_path} ${RUN} ${PATCH}" | ssh -t ${APPS[0]} | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
        ;;
        apps_ha_steps)
            script_path="${BIN_DIR}/ha_apps.bin"
            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            echo "${CREDS} ${script_path}" | ssh -t ${APPS[0]}  | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
            if [[ "${ssh_exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
        ;;
        apps_secondary|apps_third)
            local hostname host_index
            RUN=${TGT_RUN_FS}
            PATCH=${TGT_PATCH_FS}
            tier="${task#*_}"
            script_path="${BIN_DIR}/secondary_apps.bin"
            
            tier_index="1"
            case $tier in
                secondary)
                    tier_index=2
                ;;
                third)
                    tier_index=3
                ;;
                fourth)
                    tier_index=4
                ;;
                *)
                    tier_index=1
                ;;
            esac

            echo "Running apps tier: ${tier_index}"
            host_index="$((tier_index - 1))"
            hostname="${APPS[${host_index}]}"
            if [[ -z "${hostname}" ]]; then
                echo "No hostname found"
                echo "tier_index: ${tier_index}"
                echo "${APPS[@]}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${1}"
            else
                echo "hostname: ${hostname} "
            fi

            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            if [[ -z "${CREDS}" ]]; then
                echo "No CREDS found"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${1}"
            fi
            echo "${CREDS} export APPS_TIER=${tier}; export APPS_TIER_INDEX=${tier_index}; ${script_path} ${RUN} ${PATCH}" | ssh -t "${hostname}" | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            script_path="${BIN_DIR}/stop_apps.sh"
            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            echo "${CREDS} ${script_path}" | ssh -t ${APPS[0]} | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0

        ;;
        apps_change_pass)
            script_path="${BIN_DIR}/change_passwords.sh"

            new_script_path="${BIN_DIR}/PASS_change.sh"
            extra_vars="ENV=${ENV}
SCRIPT=${SCRIPT_PATH}/clone
BIN_DIR=${BIN_DIR}
. ${BIN_DIR}/run.env"

            echo -e "${extra_vars}" | cat - "${script_path}" > ${new_script_path}

            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            echo "${CREDS} ${new_script_path}" | ssh -t ${APPS[0]} | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
            if [[ "${ssh_exit_code}" -ne 0 ]]; then
                echo "$task failed with exit code ${ssh_exit_code}" | tee -a "${log_file}"
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
		        my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
        ;;
        apps_auto_config|final_apps_auto_config_final)
            script_path="${BIN_DIR}/autocfg_apps.bin"

            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
            for NODE in ${APPS[@]}; do
                echo "${CREDS} ${script_path} ${ENV}" | ssh -t ${NODE} | tee -a "${log_file}"
                ssh_exit_code="${PIPESTATUS[1]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                    echo "$task failed with exit code ${ssh_exit_code}" | tee -a "${log_file}"
                    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
		            my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
                fi
            done

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
            ;;
        apps_post_clone*)
	        local host env_file

            host="${APPS[0]}"
            env_file=""
            extra_vars="ENV=${ENV}

BIN_DIR=${BIN_DIR}
. ${BIN_DIR}/run.env

SCRIPT=${SCRIPT_PATH}/clone
echo \"expected to run on : ${host}\"
echo \"running on: \$(hostname)\"
"
	        case "${task_selector}" in
                apps_post_clone_a)
                    script_path="${BIN_DIR}/post_clone_steps_apps_a.sh"
                    new_script_path="${BIN_DIR}/APPS_post_clone_steps_a.sh"
		        ;;
                apps_post_clone_b)
                    script_path="${BIN_DIR}/post_clone_steps_apps_b.sh"
                    new_script_path="${BIN_DIR}/APPS_post_clone_steps_b.sh"
		            host="${ACFG[0]}"
	                env_file="${DB_HOME}/${DB_SIDS[0]}_${LOGICAL_DB_NODE1:-${DB_NODE1}}.env"
		            extra_vars+="
ENV_FILE=\"${env_file}\"
if [ -f \"\${ENV_FILE}\" ]; then
    . \"\${ENV_FILE}\"
else
    echo \"ENV FILE NOT EXISTS: \${ENV_FILE}\"
    exit 1
fi	
"
                ;;
                apps_post_clone_c)
                    script_path="${BIN_DIR}/post_clone_steps_apps_c.sh"
                    new_script_path="${BIN_DIR}/APPS_post_clone_steps_c.sh"
                ;;
                *)
                    echo "Unknown task!!!"
                    log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                    my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
                ;;
            esac

            echo -e "${extra_vars}" | cat - "${script_path}" > ${new_script_path}

            if ! get_creds; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi
	        echo "-- sshing to: ${host}"
            echo "${CREDS} ${new_script_path}" | ssh -t "${host}" | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
            if [[ "${ssh_exit_code}" -ne 0 ]]; then
		        echo "ssh exit code is not 0: ${ssh_exit_code}"
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0
        ;;
        apps_orb_run_master_postclone_steps)
            script_path="/mnt/nfs/ebscam/postclone/orb_run_master_postclone_steps.sh"
            echo "${script_path}" | ssh -t ${APPS[0]} | tee -a "${log_file}"

            ssh_exit_code="${PIPESTATUS[1]}"
                if [[ "${ssh_exit_code}" -ne 0 ]]; then
                log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
                my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
            fi

            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${log_file}"
            return 0

        ;;
        *)
            echo "Unknown task: ${task}"
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
	        my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${exit_code}"
        ;;
    esac

}


function adop_tasks() {
    local script_path task_name_for_status env="${1}" task_type="${2}" task_segment="${3}" all_task_and_args="${4}"
    create_env_file "$task_type" "$task"
    task_name_for_status="${task_type}-${task_segment}_${task}"

    local log_file

    echo "RUNNING PATCH ADOP ENV: ${env}, task_type: ${task_type}, task and args: ${all_task_and_args}"

    if ! get_creds; then
        my_exit "${task_type}-${task_segment}_${task}" "FAILED" "${ssh_exit_code}"
    fi

    script_path="${BIN_DIR}/patch_adop.sh"

    while read -r line; do
        if [[ -z "${line// /}" ]]; then
            continue
        fi
        line="${line#\'}"   # remove leading '
        line="${line%\'}"   # remove trailing '

        task="${line%%,*}"
        log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" "queued"
    done <<< "${all_task_and_args//####/$'\n'}"

    while read -r line; do
        if [[ -z "${line// /}" ]]; then
            continue
        fi
        line="${line#\'}"   # remove leading '
        line="${line%\'}"   # remove trailing '

        task="${line%%,*}"
        ARGS="${line#*,}"
        if [[ -z "${ARGS// /}" ]] || [[ -z "${task// /}" ]]; then
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${log_file}"
            my_exit "${task_name_for_status}" "FAILED" 1
        fi

        local adop_log_path="${LOG_BASE_DIR}/${task_type}-${task_segment}/${task}"
        export ADOP_LOG="${adop_log_path}/${ENV}_ADOP_${TIMESTAMP}_${task}.log"
        if [[ ! -f "${ADOP_LOG}" ]]; then
            mkdir -p "${adop_log_path}"
            echo "Create file: ${ADOP_LOG}"
            touch "${ADOP_LOG}"
            chmod 766 "${ADOP_LOG}"
        fi
        
        echo "

export ADOP_LOG=\"${adop_log_path}/${ENV}_ADOP_${TIMESTAMP}_${task}.log\"

        " >> "${RUN_ENV}"


        echo "task: $task, args: ${ARGS}"
        log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" "start" "${ADOP_LOG}"

        echo "${CREDS} ${script_path} ${ENV} ${ARGS}" | ssh -t ${APPS[0]}  | tee -a "${ADOP_LOG}"
        ssh_exit_code="${PIPESTATUS[1]}"

        if [[ "${ssh_exit_code}" -ne 0 ]]; then
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${ADOP_LOG}"
            my_exit "${task_name_for_status}" "FAILED" "${ssh_exit_code}"
        fi

        echo "-=-=-=-= checking for error in the log: ${ADOP_LOG}"
        error_in_log="$(grep  -E 'adop exiting with status'  "${ADOP_LOG}")"
        if [[ "${error_in_log,,}" = *fail* ]]; then
            log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" failed "${ADOP_LOG}"
            my_exit "${task_name_for_status}" "FAILED" 1
        fi

        echo "marking ${task_name_for_status} as pass"
        log_task_status "${ENV}" "${task_type}" "${task_segment}" "${task}" end "${ADOP_LOG}"
    done <<< "${all_task_and_args//####/$'\n'}"
    
    
}

# actual executions
set_logs

if [[ -z "${SCRIPT_PATH// /}" ]]; then
    err "SCRIPT_PATH is not set"
    exit 1
else
    echo "SCRIPT_PATH: ${SCRIPT_PATH}"
fi


# IMPORTANT: Do not change the order of tasks
DB_CLONE_TASKS="clone_primary clone_secondary clone_third clone_auto_config clone_post_steps_apps clone_post_steps_sys"
APP_CLONE_TASKS="apps_file_system apps_primary apps_ha_steps apps_secondary apps_change_pass apps_post_clone_a apps_post_clone_b apps_post_clone_c apps_orb_run_master_postclone_steps"
FINAL_TASKS="final_clone_auto_config_final final_apps_auto_config_final"

if [[ "${RESUME}" = "resume" ]]; then
    echo "RESUME is set"

    # when resuming keep all tasks from the task onwards
    # remove all tasks before the task
    case $TASK_SEGMENT in
        clone*)
            DB_CLONE_TASKS="$(echo "${DB_CLONE_TASKS}" | grep -oE "${TASK_SEGMENT}_${TASK}.*")"
        ;;
        apps*)
            DB_CLONE_TASKS=""
            APP_CLONE_TASKS="$(echo "${APP_CLONE_TASKS}" | grep -oE "${TASK_SEGMENT}_${TASK}.*")"
        ;;
        final*)
            DB_CLONE_TASKS=""
            APP_CLONE_TASKS=""
            FINAL_TASKS="$(echo "${FINAL_TASKS}" | grep -oE "${TASK_SEGMENT}_${TASK}.*")"
        ;;
        *)
            echo "Unknown TASK_SEGMENT for resume: ${TASK_SEGMENT}"
            exit 1
        ;;
    esac

    for atask in $DB_CLONE_TASKS; do
        log_task_status "${ENV}" "${TASK_TYPE}" "clone" "${atask/clone_/}" "queued"  
    done
    echo "DB_CLONE tasks are: ${DB_CLONE_TASKS}"

    for atask in $APP_CLONE_TASKS; do
        log_task_status "${ENV}" "${TASK_TYPE}" "apps" "${atask/apps_/}" "queued"
    done
    echo "APP_CLONE tasks are: ${APP_CLONE_TASKS}"

    for atask in $FINAL_TASKS; do
        log_task_status "${ENV}" "${TASK_TYPE}" "final" "${atask/final_/}" "queued"
    done
    echo "FINAL_TASKS are: ${FINAL_TASKS}"

    if [[ -n "${DB_CLONE_TASKS}" ]]; then
        for task in ${DB_CLONE_TASKS}; do
            task="${task/clone_/}"
            echo "FULL_CLONE: Running DB clone task: ${task}"
            create_env_file "${TASK_TYPE}" "clone" "${task}"
            db_clone_tasks "${ENV}" "${TASK_TYPE}" "clone" "${task}"
        done
    fi

    if [[ -n "${APP_CLONE_TASKS}" ]]; then
        for task in ${APP_CLONE_TASKS}; do
            task="${task/apps_/}"
            echo "FULL_CLONE: Running APP clone task: ${task}"
            create_env_file "${TASK_TYPE}" "apps" "${task}"
            apps_clone_tasks "${ENV}" "${TASK_TYPE}" "apps" "${task}"
        done
    fi

    if [[ -n "${FINAL_TASKS}" ]]; then
        unset temp_task
        for atask in ${FINAL_TASKS}; do
            echo "FULL_CLONE: Running FINAL_TASKS task: ${atask}"
            temp_task="${atask/final_/}"
            case ${temp_task} in
                clone*)
                    create_env_file "${TASK_TYPE}" "clone" "${temp_task}"
                    echo "FINAL_TASKS triggering db clone task: clone  ${temp_task}"
                    db_clone_tasks "${ENV}" "${TASK_TYPE}" "final" "${temp_task}"
                ;;
                apps*)
                    create_env_file "${TASK_TYPE}" "apps" "${temp_task}"
                    echo "FINAL_TASKS triggering apps task: apps ${temp_task}"
                    apps_clone_tasks "${ENV}" "${TASK_TYPE}" "final" "${temp_task}"
                ;;
            esac
        done
    fi
    echo "clone_db.sh resume completed successfully"
    sleep 5
    exit 0
fi


case "${TASK_SEGMENT}" in
    clone*)
        # db clone tasks
        # always to start with clone_
        if [[ -z "${CLONE_ENV// /}" ]]; then
            case "${ENV,,}" in
                orbupg|plnupg|qa)
                    export ENV="${ENV}"
                    ;;
                none)
                    echo "Under development..."
                    exit 0
                    ;;
                *)
                    db_clone_usage
                    exit 0
                ;;
            esac
        else
            export ENV="${CLONE_ENV}"
        fi


        echo "db clone task, task_type: ${TASK_TYPE}, task: ${TASK}"
        create_env_file "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
        db_clone_tasks "${ENV}" "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
    ;;
    apps*)
        # app clone tasks
        # always to start with apps_
        if [[ -z "${CLONE_ENV// /}" ]]; then
            case "${ENV,,}" in
                orbupg|orbprj|qa)
                    export ENV="${ENV}"
                ;;
                "none")
                    echo "Under development..."
                    exit 1
                ;;
                *)
                    usage
                ;;
            esac
        else
            export ENV="${CLONE_ENV}"
        fi

        echo "app clone task"
        create_env_file "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
        apps_clone_tasks "${ENV}" "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"

    ;;
    final*)
        # final tasks are from either clone or apps
        task_actual_name="${TASK/final_/}"
        echo "final task section: ${task_actual_name}"

        case ${task_actual_name} in
            clone*)
                echo "final-task: db clone task: ${TASK_TYPE} ${TASK}"
                create_env_file "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
                db_clone_tasks "${ENV}" "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
            ;;
            apps*)
                echo "final-task: app clone task: ${TASK_TYPE} ${TASK}"
                create_env_file "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
                apps_clone_tasks "${ENV}" "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
            ;;
        esac
        

    ;;
    adop)
        adop_tasks "${ENV}" "${TASK_TYPE}" "${TASK_SEGMENT}" "${TASK}"
    ;;
esac

echo "clone_db.sh completed successfully for task_type: ${TASK_TYPE}, task_segment: ${TASK_SEGMENT}, task: ${TASK}"




