select service_end_point from xxvertex.vertex_oic_configuration;

select * from xxvertex.vertex_service_endpoint;

update xxvertex.vertex_oic_configuration
set service_end_point = '&1';

delete from xxvertex.vertex_service_endpoint;

insert into xxvertex.vertex_service_endpoint 
select instance_name, '&1'
from gv$instance;

commit;

select service_end_point from xxvertex.vertex_oic_configuration;

select * from xxvertex.vertex_service_endpoint;

set serverout on
exec apps.vertexoicquoexample('SALE',1);

exit
