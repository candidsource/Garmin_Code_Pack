connect apps/apps

update fnd_user set USER_GUID = null;

commit;

exec fnd_oid_plug.setPlugin;

exit

