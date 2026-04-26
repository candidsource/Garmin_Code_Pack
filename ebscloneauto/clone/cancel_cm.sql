connect apps@MISTST1

update fnd_concurrent_requests 
set status_code = 'C',
    phase_code = 'C'
where PHASE_CODE = 'P';

commit;

exit
