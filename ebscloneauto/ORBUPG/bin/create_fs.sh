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

title "Create Directories" | tee -a ${LOG}

base_fs="${BASE_FS%/}"

if [[ -z "${base_fs// /}" ]]; then
    echo "DIR NOT FOUND: base_fs"
    exit 1
fi

if [[ -z "${TGT_RUN_FS// /}" ]]; then
    echo "DIR NOT FOUND: TGT_RUN_FS"
    exit 1
fi

cd ${base_fs}

fs_dirs="${TGT_RUN_FS} ${TGT_PATCH_FS}"
bak_dirs="${fs_dirs} oraInventory"

# checks
recycle_backup="${base_fs}/recycle_bin_bak_$(date +%F_%H%M%S)"
if [[ -d "${base_fs}/recycle_bin" ]]; then
    echo "BACKING UP: ${base_fs}/recycle_bin  to ${recycle_backup}"
    mv ${base_fs}/recycle_bin ${recycle_backup}
else
    echo "DIR DOES NOT EXISTs: ${base_fs}/recycle_bin"
fi


dir_missing=0
for adir in ${bak_dirs}; do
    if [[ ! -d "${base_fs}/${adir}" ]]; then
        echo "DIR DOES NOT EXIST: ${base_fs}/${adir}"
        dir_missing=1
    fi
done
if [[ "${dir_missing}" -eq 1 ]]; then
    exit 1
fi



echo "Create new ${base_fs}/recycle_bin"
mkdir "${base_fs}/recycle_bin"

for adir in ${bak_dirs}; do
    echo "MOVING: ${base_fs}/${adir} to ${base_fs}/recycle_bin/"
    mv  "${base_fs}/${adir}" "${base_fs}/recycle_bin/"
    mkdir -p "${base_fs}/${adir}"
done

echo "cd ${TGT_RUN_BASE}"
cd "${TGT_RUN_BASE}"
echo "Starting extraction ORBIT_EBSapps.tar.gz"

gunzip -c  /mnt/nfs/oracle.patches/scripts/master_clone_files/ORBIT_EBSapps.tar.gz | tar -xlf -
if [[ ${PIPESTATUS[0]} -eq 137 ]] || [[ ${PIPESTATUS[1]} -eq 137 ]]; then
    echo "Detected kill -9 in the pipeline."
    exit 1
elif [[ ${PIPESTATUS[0]} -ne 0 ]] || [[ ${PIPESTATUS[1]} -eq 0 ]]; then
    echo "Something went wrong"
    exit 1
fi



echo "Completed Reset..." | tee -a ${LOG}



