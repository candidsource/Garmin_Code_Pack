ENV=orbupg

BIN_DIR=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin
. /mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/bin/run.env

SCRIPT=/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone
echo "expected to run on : oracle@kc3xsd-rac301"
echo "running on: $(hostname)"

ENV_FILE="/u01/app/oracle/product/19.0.0/ORBUPG/ORBUPG_kc3xsd-rac301.env"
if [ -f "${ENV_FILE}" ]; then
    . "${ENV_FILE}"
else
    echo "ENV FILE NOT EXISTS: ${ENV_FILE}"
    exit 1
fi	




##SK##echo "Executing XX_POST_CLONE_STEPS_3bi as sys user in CDB root" | tee -a ${APPLOG}
##SK##echo  sqlplus "/as sysdba" @${SCRIPT}/${ENV}_XX_POST_CLONE_STEPS_3b.sql | tee -a ${APPLOG}

