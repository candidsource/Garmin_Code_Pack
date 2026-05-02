conn apps@orbupg

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/orbupg_update_users_profile.log

/*************************************************************
*PURPOSE: To perform post-clone steps 5.2(a),5.2(b) & 5.3(a) *
*AUTHOR:  Venkat Atluri                                      *
*CREATED: 22-June-2023                                       *
*LAST MODIFIED: 27-June-2023                                 *
**************************************************************/
set serveroutput on escape on

DECLARE
   target_str varchar2(100);
BEGIN
  -- Extracting the target string for replacement
  select substr(home_url,0,instr(home_url,'/OA_HTML/')-1)||'/forms/frmservlet?play=\&record=names' into target_str 
  from icx_parameters;

  update fnd_profile_option_values set profile_option_value=target_str 
  where level_id=10004 and 
  profile_option_id=(select profile_option_id from fnd_profile_options 
  where profile_option_name='ICX_FORMS_LAUNCHER') and
  level_value in (select user_id from fnd_user where user_name like 'QATEST%' );
  dbms_output.put_line(sql%rowcount||' rows are updated with icx_forms_launcher profile value '||target_str);
  commit;
EXCEPTION
  when others then
  dbms_output.put_line(sqlcode||'- '||sqlerrm);
  raise;
END;
/

BEGIN
  update fnd_user set end_date=null where user_name in 
  ('PSUSER1','PSUSER2','PSUSER3','PSUSER4', 'PSUSER5','PSUSER6', 'PSUSER7', 'PSUSER8', 'PSUSER9', 'PSUSER10');
  dbms_output.put_line(sql%rowcount||' rows are updated with end_date null');
  commit;
  
EXCEPTION
  when others then
  dbms_output.put_line(sqlcode||'- '||sqlerrm);
  raise;
END;
/

DECLARE
  iby_http_str varchar2(50);
  notnull_exception exception;
BEGIN
  select profile_option_value into iby_http_str from fnd_profile_option_values
  where level_id=10001 and
  profile_option_id=(select profile_option_id from fnd_profile_options where profile_option_name='IBY_HTTP_PROXY');

  if iby_http_str is not null then
    update fnd_profile_option_values set profile_option_value=null 
    where level_id=10001 and
    profile_option_id=(select profile_option_id from fnd_profile_options where profile_option_name='IBY_HTTP_PROXY');
    dbms_output.put_line(sql%rowcount||' row is updated with IBY: HTTP Proxy profile value as null at site level');
    commit;
    raise notnull_exception;
  end if;
  
EXCEPTION
   when notnull_exception then
     dbms_output.put_line('!!!Update the s_proxyhost \& s_proxyport values to null in context file as below and run the autoconfig.!!!'||chr(10)||
                          '<proxyhost oa_var="s_proxyhost" customized="yes"/>'||chr(10)||
                          '<proxyport oa_var="s_proxyport" customized="yes"/>');
   when others then
     dbms_output.put_line(sqlcode||'- '||sqlerrm);
     raise;
END;
/

commit;

UPDATE fnd_svc_comp_param_vals
SET    parameter_value = nvl('ORBUPG Workflow Mailer', parameter_value)
WHERE  component_parameter_id = to_number(nvl('10065', '0'))
/

commit;

spool off;

