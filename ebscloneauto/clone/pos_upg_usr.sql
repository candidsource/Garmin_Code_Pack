conn apps@orbupg

REM $Header: pos_upg_usr.sql 120.0.12020000.2 2014/10/07 12:30:54 pneralla ship $
REM              (c) Copyright O 2014,2014 Oracle and/or its affiliates.
REM                      All Rights Reserved
REM
REM *********************************************************************
REM * NAME                                                              *
REM *    *
REM *                                                                   *
REM * DESCRIPTION                                                       *
REM *  This upgrade script is used to set framework agent for supplier users
REM *  because of the sso integration              *
REM *                                                                   *
REM * HISTORY                                                           *
REM * 02/12/04           Jpasala     Modified for 11.5.9 release
REM * 07/10/14           pneralla    Modified for 12.2.2 release to syncup with latest 12.1 file version*
REM *********************************************************************
REM dbdrv: none 

SET VERIFY OFF;

WHENEVER SQLERROR EXIT FAILURE ROLLBACK;
WHENEVER OSERROR EXIT FAILURE ROLLBACK;


DECLARE

x_user_id       	FND_USER.USER_ID%TYPE;
x_user_name     	FND_USER.USER_NAME%TYPE;
x_party_id      	NUMBER;
x_exception_msg 	VARCHAR2(2000);
x_status        	VARCHAR2(100);

CURSOR supplier_users IS
select user_id, person_party_id, user_name from fnd_user
where 
employee_id is null
and person_party_id in
(
select object_id from
hz_relationships hzr, hz_party_usg_assignments hpua
where hzr.status ='A'
and hzr.start_date < sysdate
and hzr.end_date > sysdate
and hzr.relationship_type = 'CONTACT'
and hzr.subject_type = 'ORGANIZATION'
and hzr.subject_table_name = 'HZ_PARTIES'
and hzr.object_table_name = 'HZ_PARTIES'
and hzr.object_type = 'PERSON'
and hzr.subject_id = hpua.party_id
and hpua.status_flag = 'A'
and ( hpua.effective_start_date is null or hpua.effective_start_date < sysdate )
and ( hpua.effective_end_date is null or hpua.effective_end_date > sysdate )
and hpua.party_usage_code = 'SUPPLIER'
);


lv_ext_servlet_agent VARCHAR2(4000);
lv_ext_framework_agent VARCHAR2(4000);
lv_ext_web_agent varchar2(4000);
lv_pattern varchar2(40) := '/pls';
lv_flag varchar2(10):= '';
BEGIN

    fnd_profile.get('POS_EXTERNAL_URL', lv_ext_servlet_agent);
    --fnd_profile.get('POS_EXTERNAL_URL', lv_ext_framework_agent);
    owa_pattern.change(lv_ext_servlet_agent, '/$', ''); -- remove trailing slash
    If (owa_pattern.match(lv_ext_servlet_agent,lv_pattern, lv_flag)) then
        lv_ext_web_agent := lv_ext_servlet_agent;
        owa_pattern.change(lv_ext_servlet_agent, '/pls.*', '');
        lv_ext_framework_agent := lv_ext_servlet_agent;
        owa_pattern.change(lv_ext_framework_agent, '/oa_servlets.*', '');
    else
        lv_ext_web_agent := '';
        lv_ext_framework_agent := lv_ext_servlet_agent;
	lv_ext_servlet_agent := lv_ext_servlet_agent || '/OA_HTML' ;
    end if;
    /* Bug #16580039 , Commenting below code to not to set APPS Framework,Servlet,Web Agent profiles 
       at user level. Please see bug for more details */
    /*

    OPEN supplier_users;

    LOOP
	    FETCH supplier_users INTO x_user_id,x_party_id, x_user_name;
    	EXIT WHEN supplier_users%NOTFOUND;

        IF ( not fnd_profile.save( x_name => 'APPS_SERVLET_AGENT',
                            x_value => lv_ext_servlet_agent,
                            x_level_name => 'USER',
                            x_level_value => x_user_id ) ) THEN
            raise_application_error(-20005, ' Failed to save servlet profile option value for user with id:'
                    ||x_user_id || ' with value :'|| lv_ext_servlet_agent , true);
        END IF;

        IF ( not fnd_profile.save( x_name => 'APPS_FRAMEWORK_AGENT',
                            x_value => lv_ext_framework_agent,
                            x_level_name => 'USER',
                            x_level_value => x_user_id ) ) THEN
            raise_application_error(-20005, ' Failed to save framework profile option value'
                    ||x_user_id || ' with value :'|| lv_ext_framework_agent , true);
        END IF;

        if ( lv_ext_web_agent is not null ) then
            IF ( not fnd_profile.save( x_name => 'APPS_WEB_AGENT',
                            x_value => lv_ext_web_agent,
                            x_level_name => 'USER',
                            x_level_value => x_user_id ) ) THEN
                raise_application_error(-20005, ' Failed to save web agent profile option value'
                    ||x_user_id || ' with value :'|| lv_ext_web_agent , true);
            END IF;
        end if;
        

    END LOOP;

    CLOSE supplier_users;

    */

EXCEPTION
   WHEN OTHERS THEN
        raise_application_error(-20005, 'Failed to set application framework agent profile for user :'|| x_user_name, true);
END;
/
commit;
/
exit;
/

