echo "Disable not needed thread numbers as below"

alter database disable thread 4;
alter database disable thread 5;
alter database disable thread 6;
alter database disable thread 7;

select thread#, group#, bytes/1024/1024/1024 as gb, status from v$log order by thread#, group#;

select 'alter database drop logfile group ' || log.group# || ';' from v$thread thread, v$log log where log.thread#=thread.thread# and thread.enabled='DISABLED' order by 1;
Execute the generated commands.

alter database disable thread 3;
alter database disable thread 2;
alter database drop logfile group X; # Repeat as needed. Keep only two groups of thread 1 , 2 and 3
alter database enable thread 3;
alter database enable thread 2;

