conn apps@orbupg

spool /mnt/nfs/oracle.patches/scripts/master_clone_files/logs/orbupg_insert_iby_bep_acct_opt_vals.log

SET DEFINE OFF;

DELETE FROM iby.iby_bep_acct_opt_vals soap
      WHERE soap.bep_account_id = 4002;

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10053,
             'BO_PASSWORD',
             'N/A',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10056,
             'BO_USERNAME',
             'N/A',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10055,
             'CURRENCY',
             'N/A',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10148,
             'DUMMY1',
             '1',
             22376,
             SYSDATE,
             22376,
             SYSDATE,
             125115395,
             2,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10058,
             'IDEAL_SOAP_SERVICE',
             'https://pal-test.adyen.com/pal/servlet/soap/Payment',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10054,
             'MERCHANT_ACCOUNT',
             'GarminEUR',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10051,
             'MERCHANT_NAME',
             'Garmin',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10057,
             'PAYMENT_SOAP_SERVICE',
             'https://pal-test.adyen.com/pal/servlet/soap/Payment',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10052,
             'WEB_PASSWORD',
             'K!Q*)46q79J3nxE?iR{<&AzhF',
             -1,
             SYSDATE,
             -1,
             SYSDATE,
             -1,
             1,
             NULL);

INSERT INTO iby.iby_bep_acct_opt_vals
     VALUES (8013,
             10056,
             'WEB_USERNAME',
             'ws_230322@Company.Garmin',
             -1,
             TO_DATE ('2014-10-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
             -1,
             TO_DATE ('2014-10-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'),
             -1,
             1,
             NULL);

COMMIT;

spool off;

exit
