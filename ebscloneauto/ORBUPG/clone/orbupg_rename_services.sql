alter session set container=ORBUPG;

exec DBMS_SERVICE.create_service(service_name => 'ORBUPG_bi',network_name => 'ORBUPG_bi');
exec DBMS_SERVICE.create_service(service_name => 'ORBUPG_cmgr',network_name => 'ORBUPG_cmgr');
exec DBMS_SERVICE.create_service(service_name => 'ORBUPG_disc',network_name => 'ORBUPG_disc');
exec DBMS_SERVICE.create_service(service_name => 'ORBUPG_form',network_name => 'ORBUPG_form');
exec DBMS_SERVICE.create_service(service_name => 'ORBUPG_pcf',network_name => 'ORBUPG_pcf');
exec DBMS_SERVICE.create_service(service_name => 'ORBUPG_selfserv',network_name => 'ORBUPG_selfserv');
exec DBMS_SERVICE.create_service(service_name => 'ORBUPG_service',network_name => 'ORBUPG_service');



exec DBMS_SERVICE.start_service('ORBUPG_bi');
exec DBMS_SERVICE.start_service('ORBUPG_cmgr');
exec DBMS_SERVICE.start_service('ORBUPG_disc');
exec DBMS_SERVICE.start_service('ORBUPG_form');
exec DBMS_SERVICE.start_service('ORBUPG_pcf');
exec DBMS_SERVICE.start_service('ORBUPG_selfserv');
exec DBMS_SERVICE.start_service('ORBUPG_service');


commit;

--Note To start service in all instance use below command.
--exec dbms_service.start_service('ORBUPG', DBMS_SERVICE.ALL_INSTANCES);

exit;
