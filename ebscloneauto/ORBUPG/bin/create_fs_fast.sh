# /ORBUPG/app/applmgr is base_fs


# mv /ORBUPG/app/applmgr/fs1 /ORBUPG/app/applmgr/recyclebin/fs1_bak
# mv /ORBUPG/app/applmgr/fs2 /ORBUPG/app/applmgr/recyclebin/fs2_bak
# mv /ORBUPG/app/applmgr/oraInventory /ORBUPG/app/applmgr/recyclebin/oraInventory_bak

# Logon to the primary ORBUPG application server as applmgr.
# $ mkdir -p /ORBUPG/app/applmgr/fs2/  --${TGT_RUN_FS}


# $ cd /ORBUPG/app/applmgr/fs2/

# --Restore the ORBIT binaries to ORBUPG app server (copy below command in notepad. make sure all the - are correct:
# gunzip -c  /mnt/nfs/oracle.patches/scripts/master_clone_files/ORBIT_EBSapps.tar.gz | tar -xlf - &

run_env="$1"
source "${run_env}"

. ${TGT_BASE_FS}/EBSapps.env run

title "Create Directories" | tee -a ${LOG}

APPL_TOP_TAR="/mnt/nfs/oracle.patches/scripts/master_clone_files/ORBIT_appl.tar.gz"
JAVA_TOP_TAR="/mnt/nfs/oracle.patches/scripts/master_clone_files/ORBIT_java_top.tar.gz"

if [[ -z "${APPL_TOP}" ]]; then
    echo "APPL_TOP env var is not set"
    exit 1
fi

if [[ -z "${OAD_TOP}" ]]; then
    echo "OAD_TOP env var is not set"
    exit 1
fi

# validate dir and files exist befor taking action
if [[ ! -d "${APPL_TOP}/.." ]]; then
    echo "DIR DOES NOT EXIST: ${APPL_TOP}/.."
    exit 1
fi
if [[ ! -d "${APPL_TOP}/../appl" ]]; then
    echo "DIR DOES NOT EXIST: ${APPL_TOP}/../appl"
    exit 1
fi

if [[ ! -d "${OAD_TOP}" ]]; then
    echo "DIR DOES NOT EXIST: ${OAD_TOP}"
    exit 1
fi
if [[ ! -d "${OAD_TOP}/java" ]]; then
    echo "DIR DOES NOT EXIST: ${OAD_TOP}/java"
    exit 1
fi


if [[ ! -f "${APPL_TOP_TAR}" ]]; then
    echo "TAR FILE DOES NOT EXIST: ${APPL_TOP_TAR}"
    exit 1
fi

if [[ ! -f "${JAVA_TOP_TAR}" ]]; then
    echo "TAR FILE DOES NOT EXIST: ${JAVA_TOP_TAR}"
    exit 1
fi


# backup appl and extract
cd "${APPL_TOP}/.."
echo -e "\n\nMoving ${APPL_TOP}/../appl to ${APPL_TOP}/../appl_old"
mv appl appl_old

echo "Extracting: ${APPL_TOP_TAR} "
echo "gunzip -c ${APPL_TOP_TAR}"
set -o pipefail
gunzip -c "${APPL_TOP_TAR}" | tar -xlf -
if [[ ${PIPESTATUS[0]} -eq 137 ]] || [[ ${PIPESTATUS[1]} -eq 137 ]]; then
    echo "Detected kill -9 in the pipeline."
    exit 1
elif [[ ${PIPESTATUS[0]} -ne 0 ]] || [[ ${PIPESTATUS[1]} -eq 0 ]]; then
    echo "Something went wrong"
    exit 1
fi



# backup java and extract
cd "${OAD_TOP}"
echo -e "\n\nMoving ${OAD_TOP}/java to ${OAD_TOP}/java_old"
mv java java_old


echo "Extracting: ${JAVA_TOP_TAR} "
echo "gunzip -c ${JAVA_TOP_TAR}"
set -o pipefail
gunzip -c "${JAVA_TOP_TAR}" | tar -xlf -
if [[ ${PIPESTATUS[0]} -eq 137 ]] || [[ ${PIPESTATUS[1]} -eq 137 ]]; then
    echo "Detected kill -9 in the pipeline."
    exit 1
elif [[ ${PIPESTATUS[0]} -ne 0 ]] || [[ ${PIPESTATUS[1]} -eq 0 ]]; then
    echo "Something went wrong"
    exit 1
fi

echo "Completed Reset..." | tee -a ${LOG}



