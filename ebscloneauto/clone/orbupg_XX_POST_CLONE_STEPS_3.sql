conn system@ORBUPG

VARIABLE v_source_instance VARCHAR2(100);
VARIABLE vr_source_instance VARCHAR2(100);
exec :v_source_instance := '&&1'
exec :vr_source_instance := '&&2'

SET HEADING OFF
SET VERIFY OFF;
SET SERVEROUTPUT ON SIZE 1000000;
SET FEEDBACK ON;


PROMPT '==========================================================';
PROMPT '1 drop role sse_role';
DROP ROLE sse_role;

PROMPT '2 create role sse_role';
CREATE ROLE sse_role;

PROMPT '3 grant connect to sse_role';
GRANT CONNECT TO sse_role;

PROMPT '4 grant resource to sse_role';
GRANT RESOURCE TO sse_role;

PROMPT '5 grant select any table to sse_role';
GRANT SELECT ANY TABLE TO sse_role;

PROMPT '6 grant create synonym to sse_role';
GRANT CREATE SYNONYM TO sse_role;

PROMPT '7 GRANT CREATE ROLE TO apps';
GRANT CREATE ROLE TO apps;

PROMPT '8 GRANT ALTER USER TO apps';
GRANT ALTER USER TO apps;

PROMPT '9 GRANT CREATE DATABASE LINK TO selapps';
GRANT CREATE DATABASE LINK TO selapps;

PROMPT '10 grant select, update, insert, delete on eng.eng_eng_changes_interface to garmin';
GRANT SELECT,
      UPDATE,
      INSERT,
      DELETE
   ON eng.eng_eng_changes_interface
   TO garmin;

PROMPT '11 grant select, update, insert, delete on eng.eng_eco_revisions_interface to garmin';
GRANT SELECT,
      UPDATE,
      INSERT,
      DELETE
   ON eng.eng_eco_revisions_interface
   TO garmin;

PROMPT '12 grant select, update, insert, delete on eng.eng_revised_items_interface to garmin';
GRANT SELECT,
      UPDATE,
      INSERT,
      DELETE
   ON eng.eng_revised_items_interface
   TO garmin;

PROMPT '13 grant select on wsh.wsh_delivery_assignments to web_orders';
GRANT SELECT ON wsh.wsh_delivery_assignments TO web_orders;

BEGIN
   --:v_source_instance := 'v_source_instance';

   --:vr_source_instance := 'vr_source_instance';

   apps.xx_post_clone_steps.starting (:v_source_instance, :vr_source_instance);
END;
/

PROMPT '==========================================================';

--REVOKE CREATE ROLE FROM apps;/

--REVOKE ALTER USER FROM apps;/

--REVOKE CREATE DATABASE LINK FROM selapps;/

commit;

exit

