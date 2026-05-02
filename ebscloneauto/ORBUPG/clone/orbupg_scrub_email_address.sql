conn apps@orbupg

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/orbupg_scrub_email_address.log;


--  Set the customer’s email address to inactive in any cloned instances so that we aren’t emailing customer’s reports during testing, per Brandy (on October 16, 2006).
UPDATE apps.hz_contact_points 
     SET status = 'I'
   WHERE contact_point_type = 'EMAIL'
     AND status = 'A'
     AND owner_table_name = 'HZ_PARTY_SITES';

commit;

-- The below DML inactivates email contacts for Customers. 
UPDATE apps.hz_contact_points 
   SET status = 'I'
WHERE NVL (phone_line_type, contact_point_type) = 'EMAIL';

update apps.HZ_CONTACT_POINTS set email_address = 'XX_' || email_address
 where email_address is not null and upper(email_address) not like '%@GARMIN%' and upper(email_address) not like 'XX%' ;    

update  apps.hz_parties set email_address = 'XX_' || email_address
 where email_address is not null and upper(email_address) not like '%@GARMIN%'  and upper(email_address) not like 'XX%';

UPDATE apps.po_vendor_contacts
   SET email_address = NULL
WHERE email_address IS NOT NULL and upper(email_address) not like '%@GARMIN%' and upper(email_address) not like 'XX%';

UPDATE apps.po_vendor_sites_all
   SET email_address = NULL
WHERE email_address IS NOT NULL and upper(email_address) not like '%@GARMIN%' and upper(email_address) not like 'XX%';

UPDATE apps.fnd_user p
    SET email_address = 'XX_' ||  email_address 
  WHERE email_address IS NOT NULL
    AND NOT EXISTS (
      SELECT 1
            FROM apps.fnd_user fu
            WHERE UPPER (fu.email_address) LIKE '%@GARMIN%' 
            AND p.user_id = fu.user_id);

commit;

-- The following two update statements set the supplier user's preferences to QUERY mode which represents the option to not receive emails.
update apps.fnd_user_preferences
set preference_value = 'QUERY'
where preference_name = 'MAILTYPE'
and user_name in (
select DISTINCT user1.user_name
from apps.fnd_user user1,
ak_web_user_sec_attr_values ak1,
ak_web_user_sec_attr_values ak2,
fnd_user_resp_groups fur
where
user1.user_id=ak1.web_user_id
and ak1.attribute_code in
('ICX_SUPPLIER_ORG_ID','ICX_SUPPLIER_SITE_ID','ICX_SUPPLIER_CONTACT_ID')
and ak1.ATTRIBUTE_APPLICATION_ID=177
and ak2.ATTRIBUTE_APPLICATION_ID=177
and ak1.web_user_id=ak2.web_user_id
and fur.responsibility_application_id = 177
and fur.user_id = user1.user_id
and fur.start_date < sysdate
and nvl(fur.end_date, sysdate + 1) >= sysdate
and trunc(sysdate)
BETWEEN nvl(trunc(user1.start_date), trunc(sysdate))
AND nvl(trunc(user1.end_date), trunc(sysdate)));

commit;


update apps.wf_local_roles
set notification_preference = 'QUERY'
where orig_system = 'FND_USR'
and status = 'ACTIVE'
and parent_orig_system = 'HZ_PARTY'
and notification_preference <> 'QUERY'
and user_flag = 'Y'
and name in (
select DISTINCT user1.user_name
from apps.fnd_user user1,
ak_web_user_sec_attr_values ak1,
ak_web_user_sec_attr_values ak2,
fnd_user_resp_groups fur
where
user1.user_id=ak1.web_user_id
and ak1.attribute_code in
('ICX_SUPPLIER_ORG_ID','ICX_SUPPLIER_SITE_ID','ICX_SUPPLIER_CONTACT_ID')
and ak1.ATTRIBUTE_APPLICATION_ID=177
and ak2.ATTRIBUTE_APPLICATION_ID=177
and ak1.web_user_id=ak2.web_user_id
and fur.responsibility_application_id = 177
and fur.user_id = user1.user_id
and fur.start_date < sysdate
and nvl(fur.end_date, sysdate + 1) >= sysdate
and trunc(sysdate)
BETWEEN nvl(trunc(user1.start_date), trunc(sysdate))
AND nvl(trunc(user1.end_date), trunc(sysdate)));

commit;

spool off;
exit

