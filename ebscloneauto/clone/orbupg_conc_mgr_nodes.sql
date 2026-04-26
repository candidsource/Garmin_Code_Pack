/****************************************************************
*PURPOSE : To update CM nodes with target env nodes             *
*AUTHOR  : Venkat Atluri                                        *
*CREATED : 10-May-2023                                          *
*LAST MODIFIED: 17-Aug-2023                                     *
*****************************************************************/

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/orbupg_conc_mgr_nodes.log

set serveroutput on escape on verify off;
DECLARE
  n1 varchar2(15) := null; 
  n2 varchar2(15) := null;
  cn integer := 1;
  null_check exception;

   cursor fnd_conc_q is
   SELECT CONCURRENT_QUEUE_NAME,TARGET_NODE,NODE_NAME,NODE_NAME2,MAX_PROCESSES FROM  FND_CONCURRENT_QUEUES  
   WHERE
   ENABLED_FLAG='Y' and  
   NODE_NAME is null and 
   NODE_NAME2 is null  ORDER BY 5,1 ASC;
   --
BEGIN
  n1 := trim(upper('&1'));
  n2 := trim(upper('&2'));
  --
  if n1 is null or n2 is null then
     raise null_check;
  end if;
  --
  for r_fnd_conc_q in fnd_conc_q
  loop
    if mod(cn,2) = 1 then
       UPDATE  FND_CONCURRENT_QUEUES SET TARGET_NODE = n1, NODE_NAME = n1, NODE_NAME2 = n2 
       WHERE  CONCURRENT_QUEUE_NAME = r_fnd_conc_q.CONCURRENT_QUEUE_NAME;
    else
       UPDATE  FND_CONCURRENT_QUEUES SET TARGET_NODE = n2, NODE_NAME = n2, NODE_NAME2 = n1  
       WHERE CONCURRENT_QUEUE_NAME = r_fnd_conc_q.CONCURRENT_QUEUE_NAME;
    end if;
    cn := cn + 1;
  end loop;
  commit;
  if (cn=1) then
    dbms_output.put_line(cn-1 ||' rows are updated.');
  else
   dbms_output.put_line(cn ||' rows are updated.');
  end if;
  --
EXCEPTION
  when null_check then
    raise_application_error(-20107,'Concurrent manager node name can not be null.');   
  when others then
    dbms_output.put_line(sqlcode||'- '||sqlerrm);
    raise;
END;
/

commit;

spool off;

exit
