conn apps@ORBUPG

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/orbupg_XX_COMPILE_POST_CLONE_PACKAGE.log

@/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orbupg_XX_CREAT_DB_LNK.prc
@/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orbupg_XX_POST_CLONE_STEPS.pks
@/mnt/nfs/oracle.patches/ebscloneauto/ORBUPG/clone/orbupg_XX_POST_CLONE_STEPS.pkb

spool off;
exit

