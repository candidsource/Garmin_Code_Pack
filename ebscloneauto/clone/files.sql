set pages 512
set feed off
set head off

select '  ''' || name || ''',' from v$datafile;

exit
