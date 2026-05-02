conn apps@ORBUPG

select  count(1)
from    fnd_concurrent_requests fcr
          , fnd_concurrent_programs_tl fcpt
where   fcr.concurrent_program_id = fcpt.concurrent_program_id
and     fcr.phase_code in ('P','R');


set lines 130 pages 5000
col "Prog Name" form a35
col "Arg_1" form a10
col "Arg_2" form a10
col "Arg_3" form a10

--set feedback off
prompt
prompt
prompt ==> Note: You are in the following database environment currently:
select name as "Database Name" from v$database;

prompt
--prompt ==> Note: We know it is okay to cancel the following custom requests in a non-prod env:
--prompt
--prompt XXnew_items (per Brian Bruton)
--prompt XX_Interim_Inventory_Transactions  (per Paul Cooper)
--prompt XX_SMTSCRAP  (per Kendric Beachey)
--prompt GI: Interim Inventory Transaction Outbound Interface (per Jaycy as relayed by Craig)
--prompt XX Item Revision All  (per L.D. Wang)
--prompt
--prompt
prompt ==> Here are the concurrent requests currently in pending phase:
set feedback 1
select 	distinct fcpt.USER_CONCURRENT_PROGRAM_NAME "Prog Name"
	  , fcr.request_id
	  , fcr.status_code	
	  , fcr.phase_code	
	  , fcr.argument1 "Arg_1"
	  , fcr.argument2 "Arg_2"	
	  , fcr.argument3 "Arg_3"
from  	fnd_concurrent_requests fcr
	  , fnd_concurrent_programs_tl fcpt
where 	fcr.concurrent_program_id = fcpt.concurrent_program_id
--and	fcpt.language = 'US'
--and	(
--	upper(fcpt.USER_CONCURRENT_PROGRAM_NAME) like 'XX%' 
--	OR fcpt.USER_CONCURRENT_PROGRAM_NAME =
--		'GI: Interim Inventory Transaction Outbound Interface'
--	)
and 	fcr.phase_code in ('P','R')
/

prompt
prompt ==> Now cancelling the above pending requests.

--To put a CR in completed status (from note# 158124.1)
update fnd_concurrent_requests
set status_code = 'X', phase_code='C'
where request_id in
(
select 	
  fcr.request_id
from  	fnd_concurrent_requests fcr
	  , fnd_concurrent_programs_tl fcpt
where 	fcr.concurrent_program_id = fcpt.concurrent_program_id
--and	fcpt.language = 'US'
--and	(
--	upper(fcpt.USER_CONCURRENT_PROGRAM_NAME) like 'XX%'
--	OR fcpt.USER_CONCURRENT_PROGRAM_NAME =
--		'GI: Interim Inventory Transaction Outbound Interface'
--	)
and 	fcr.phase_code in ('P','R')
)
/
prompt ==> The above requests have been cancelled. 
prompt
prompt ==> *** NOTE: Type "COMMIT;" or "ROLLBACK;" to save or undo these changes. ***
prompt

commit;

select  count(1)
from    fnd_concurrent_requests fcr
          , fnd_concurrent_programs_tl fcpt
where   fcr.concurrent_program_id = fcpt.concurrent_program_id
and     fcr.phase_code in ('P','R'); 

exit;

