alter user system identified by &2 ;

alter session set container=&1;

alter user ebs_system identified by &2;
exit;

