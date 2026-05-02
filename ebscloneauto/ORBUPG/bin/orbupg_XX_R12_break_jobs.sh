#!/bin/sh

####################################################################
#Shell Script Created by Jim Hsiao 2014.07.14
#PL/SQL Script Created by Jack Hsieh 2014.07.14
#This script is used to break custom dbms job scripts when upgrade R12
####################################################################

logpath=/tmp; export logpath


#  --------------------Function--------------------------------------------------
# This function is used to break custom dbms job
#--------------------------------------------------------------------------------
fn_break_custom_jobs()
{
sqlplus -s / as sysdba > $logpath/execute_result.txt  <<EOF

  set verify off;
CREATE PROCEDURE sys.EXECUTE_SQL_COMMAND AS
  CURSOR c_1
      IS
  SELECT JOB,LOG_USER,next_date,INTERVAL,
         ROW_NUMBER() OVER (PARTITION BY LOG_USER ORDER BY JOB) rank_job,
         COUNT(1) OVER (PARTITION BY log_user) ttl_cnt
    FROM dba_jobs
   WHERE broken = 'N'
     AND log_user IN ('SYSTEM','APPS','YUEH','OBIEE_SRC','GARMIN')
   ORDER BY log_user,job;
  vc_ddl varchar2(32767);
  vf_file utl_file.file_type;
BEGIN
  vc_ddl := 'CREATE TABLE XX_BACKUP_DBA_JOBS AS SELECT JOB,LOG_USER,NEXT_DATE,INTERVAL FROM DBA_JOBS WHERE broken=''N''';
  vc_ddl := vc_ddl||' AND log_user in (''SYSTEM'',''APPS'',''YUEH'',''OBIEE_SRC'',''GARMIN'')';
 EXECUTE IMMEDIATE vc_ddl;
  vc_ddl := 'CREATE OR REPLACE procedure [OWNER].XX_STOP_JOB(JOB IN NUMBER) AUTHID DEFINER IS ';
  vc_ddl := vc_ddl||'BEGIN DBMS_JOB.BROKEN(JOB,true); COMMIT;';
  vc_ddl := vc_ddl||' EXCEPTION WHEN OTHERS THEN rollback; dbms_output.put_line(''falied:''||job); END;';
  vf_file := utl_file.fopen('XX_JIM_DIR','XXR12_BROKE_JOB.txt','w',32767);
  FOR r_1 IN c_1 LOOP
      IF r_1.rank_job = 1 THEN
        vc_ddl:= REPLACE(vc_ddl,'[OWNER]',r_1.log_user);
        EXECUTE IMMEDIATE vc_ddl;
      END IF;
      BEGIN
        EXECUTE IMMEDIATE 'begin '||r_1.log_user||'.XX_STOP_JOB('||r_1.job||'); end;';
        utl_file.put_line(vf_file,'broken job:'||r_1.job||' successfully');
        utl_file.fflush(vf_file);
      EXCEPTION
        WHEN OTHERS THEN
            utl_file.put_line(vf_file,'broken job:'||r_1.job||' failed;'||sqlerrm);
            utl_file.fflush(vf_file);
      END;
      IF r_1.rank_job = r_1.ttl_cnt THEN
         EXECUTE IMMEDIATE 'DROP procedure '||r_1.log_user||'.XX_STOP_JOB';
         vc_ddl := 'CREATE OR REPLACE procedure [OWNER].XX_STOP_JOB(JOB IN NUMBER) AUTHID DEFINER IS ';
         vc_ddl := vc_ddl||'BEGIN DBMS_JOB.BROKEN(JOB,true); COMMIT;';
         vc_ddl := vc_ddl||' EXCEPTION WHEN OTHERS THEN rollback; dbms_output.put_line(''falied:''||job); END;';
      END IF;
  END LOOP;
  IF utl_file.is_open(file => vf_file) THEN
     utl_file.fclose(vf_file);
  END IF;
        END;
        /

  EXECUTE sys.EXECUTE_SQL_COMMAND;    
  drop procedure sys.EXECUTE_SQL_COMMAND
/

exit;

EOF
}

#  --------------------Function--------------------------------------------------
# This function is to check if procedure execute successfully
#--------------------------------------------------------------------------------
fn_checkresult()
{
  if [ -f "$logpath/execute_result.txt" ];
  then
    if [ `grep -i "PL/SQL procedure successfully completed." $logpath/execute_result.txt|wc -l` -gt 0 ]
    then
        if [ -s "/tmp/XXR12_BROKE_JOB.txt" ];
        then
            cat /tmp/XXR12_BROKE_JOB.txt
        fi
    else
        echo "Failed to execute script, please check error log $logpath/execute_result.txt"
        exit
    fi
  fi
}

fn_drop_directory()
{
sqlplus -s / as sysdba >> $logpath/create_drop_dir.log <<EOF

   drop directory XX_JIM_DIR;
   exit;
EOF

if [ `cat $logpath/create_drop_dir.log|grep "Directory dropped"|wc -l` -lt 1 ];
then
    echo "Failed to drop directory XX_JIM_DIR, please check it!"
    exit
fi
}

sqlplus -s / as sysdba > $logpath/create_drop_dir.log <<EOF

   create or replace directory XX_JIM_DIR as '/tmp';
   exit;
EOF

EXITSTATUS=$?

if [ $EXITSTATUS != 0 ];
then
    echo "Unable to connect to database!"
    exit
else
    if [ -d "/tmp" ];
    then
        if [ `cat $logpath/create_drop_dir.log|grep "Directory created"|wc -l` -eq 1 ];
        then
            fn_break_custom_jobs
            fn_checkresult
            fn_drop_directory
        else
            echo "Failed to create directory!"
            exit
        fi
    else
        echo "/tmp doesn't exist!"
        exit
    fi
fi

