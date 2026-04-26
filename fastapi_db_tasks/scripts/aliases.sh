




function binf() {
    if [[ -z "${SCRIPT_PATH}" ]]; then
        echo "Error: SCRIPT_PATH is not set."
        return 1
    fi

    local log_dir bin_dir log_file
    log_dir="${SCRIPT_PATH}/log"
    bin_dir="${SCRIPT_PATH}/bin"

    case $1 in
        cdb|clone_db)
            if [[ ! -f "${bin_dir}/clone_db.sh" ]]; then
                echo "FILE NOT FOUND: ${bin_dir}/clone_db.sh"
                return 1
            fi
            vim "${bin_dir}/clone_db.sh"
            return 0
        ;;
        utils|util*)
            if [[ ! -f "${bin_dir}/utils.sh" ]]; then
                echo "FILE NOT FOUND: ${bin_dir}/utils.sh"
                return 1
            fi
            vim "${bin_dir}/utils.sh"
            return 0
    esac
}


function logs() {
    log stream ${@}
}


function log() {
    local stream cmd="vim"
    if [[ -z "${SCRIPT_PATH}" ]]; then
        echo "Error: SCRIPT_PATH is not set."
        return 1
    fi
    if [[ "$1" = "stream" ]]; then
        stream="1"
        cmd="tail -f"
        shift
    fi

    local log_dir bin_dir log_file
    log_dir="${SCRIPT_PATH}/log"
    bin_dir="${SCRIPT_PATH}/bin"


    case $1 in
        server|srv*)
            log_file="${log_dir}/server/server.log"
            if [[ ! -f "${log_file}" ]]; then
                echo "FILE NOT FOUND: ${log_file}"
                return 1
            fi
        ;;
        status|stat*)
            log_dir="${log_dir}/TASK_STATUS"
            log_file="$(ls -t ${log_dir} | head -n 1)"
            log_file="${log_dir}/${log_file}"
            if [[ ! -f "${log_file}" ]]; then
                echo "FILE NOT FOUND: ${log_file}"
                return 1
            fi
        ;;
        task|tasks)
            log_dir="$(ls -td ${log_dir}/* | grep -vE "server|TASK_STATUS"| head -n 1)"
            log_file="$(find ${log_dir} -maxdepth 1 -type f ! -empty -printf "%T@ %f\n" | sort -nr | cut -d' ' -f2- | head -n 1)"
            if [[ ! -f "${log_file}" ]]; then
                echo "FILE NOT FOUND: ${log_file}"
                return 1
            fi
            echo "Last task log file: ${log_file}"
    esac

    echo "${cmd} ${log_file}"
    ${cmd} "${log_file}"
    
}