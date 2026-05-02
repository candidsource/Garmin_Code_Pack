conn apps@ORBUPG

select node_name from apps.fnd_nodes;

exec fnd_conc_clone.setup_clean;
truncate table applsys.adop_valid_nodes;

select node_name from apps.fnd_nodes;

exit
