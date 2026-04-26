CREATE OR REPLACE PACKAGE BODY APPS.XX_POST_CLONE_STEPS
AS
    /********************************************************************************************
         *
         * Created By: Shuai Wang.
         * Creation Date: 12-05-2011.
         *
         * This package is used and maintained by DBA to automate the post-cloned steps
         *
         * $Header: /cvs/orbit/sql/Post_Clone/XX_POST_CLONE_STEPS.pkb,v 1.27 2013-09-19 19:06:35 krishnanpr Exp $
         * Roger Wolf November 4, 2014  ERPPJ-5412 PCI Scrub after Cloning
    -- R12 Roger Wolf changes for PCI incriptions procedure post_enc_cc_scrub
    -- R12 Roger Wolf changes for Supplier Email scrupt
    -- R12 Roger Wolf changes for online patching
    -- R12 Roger Wolf rmeoved PROCEDURE update_printers -- formscape printers zama and tikal -- per Pradeep not needed with R12
    -- R12                    In R12 Formscape printers are named with a $ sign at the end. In cups these Printers are defined
    -- R12                    to redirect the print jobs to the Formscape server. In Formscape servers these $queues are defined
    -- R12                    to redirect the jobs to the Formscape code and print to the actual printer appropriately.
    -- R12                    So we do not have to worry about form scape because the sys net side configure the cups printers
    -- R12                    to send it to the correct form scape server.
    -- R12 February 20, 2015 Changed to set the active_flag to N in the iby_creditcard in the post_enc_cc_scrub procedure
    -- R12 March 30, 2014    Generic change of profile values of Site.
    --
    -- R12 Changes needed for PROCEDURE update_directories --  hard code instance names
    -- R12 changes needed for PROCEDURE create_plan_links -- hard code instance names
    -- R12 changes needed for PROCEDURE create_ascp_links -- hard code instance names
    -- R12 changes needed for PROCEDURE create_agile_links -- hard code instance names
    -- R12 may need changes for PROCEDURE disable_customer_email it disables all contacts in apps.hz_contact_points -- table is used in a few places customer/suppliers perhaps more.
    -- R12 May 26, 2015 Roger Wolf Jira ERPPJ-8914 PCI Credit Card Purge after clone
    -- R12                         Make the post clone scrub work like the quarterly scrub
    -- R12 June 17, 2015 Roger wolf Change to remove BNE_UIX_PHYSICAL_DIRECTORY value.
    -- R12 June 19, 2015 Roger wolf Fixes to the program.
    -- R12 July 13, 2015 Roger Wolf Added AP_PROFILE Email changes -- ERPPJ-9914 Automate Post Clone steps in AP
    --     Auguest 28, 2015 Roger Wolf EBA-1702 To change the credit card active flag to Y in ORBQA and ORBIT and change default scrub days from 365 to 180
    --                                 3) Post clone package update to set active_flag = 'Y' - Roger
    --     September 9, 2015 Roger Wolf EBA-1702 Upgraded email scrub per Mark Rogers suggestion
    --     October 2, 2015 Roger Wolf Changed email distribution list and added my self to email
    --     October 6, 2015 Roger Wolf Change email scrubs -- changes to credit card scrub
    --     December 9, 2015 Roger Wolf EBA-4302 Post clone steps for APM phase2
    --                                 added more profile to change in normal process anad a added procedure APM_PROFILE
    --     January 6, 2016 Roger Wolf Post Clone steps for APM adjust name slightly
    --     January 7, 2016 Roger Wolf modified starting procedure to reset the the site, user and responsiblity profiles that had the sounce instance name
    --                                prevously it was only doing site with ORBIT in it.
    --     January 29, 2016 Roger Wolf modified Starting to reset email addresses in the table garmin.xx_wsh_invoice_headers column email_addresses.
    --                                 added the PROCEDURE remove_ci_email
    --     January 29, 2016 Roger Wolf changed mail.garmin.com to smtp.garmin.com.
    --     January 29, 2016 Roger Wolf modified Starting to reset email address in the table apps.OE_ORDER_HEADERS_ALL column attribute12 attribute20.
    --                                 added the PROCEDURE remove_oeh_email
    --     February 2, 2016 Roger Wolf modified Starting to reset email address in the table APPS.XX_PRO_COMM_STG_TBL columns EMAIL_ADDRESS, B_EMAIL_ADDRESS, S_EMAIL_ADDRESS
    --                                 added the procedure remove_pro_com_email
    --     February 17, 2016 Roger Wolf made a mistake scrubing attribute 20
    --     February 19, 2016 Roger Wolf Printer and copies need scrubed at the user level.  It was only done on the responsibility level.  Made query easier to read.
    --                                  add disabling and re-enabling the data base triggers for order header email scrub PROCEDURE remove_oeh_email
    --     February 22, 2016 Roger Wolf Change the procedure AP_PROFILE to use all records intead of just the one starting with GARMIN%
    --     April 6, 2016 Roger Wolf EBA-4954 Automate ADYEN APM-2 related Payments setup after evey clone
    --                                       Changes to APM_PROFILE
    --                                       Also addeed a few changes the DBA wanted.
    --     April 14, 2016 Roger Wolf Slight adjustment for EBA-4954
    --                                       Changes to APM_PROFILE -- add profile changes to 571, 612, 751, 828,903
    --     April 29, 2016 Roger Wolf Changed Modification on April 14 to a cursor to make it more flexable.
    --                                       Changes to APM_PROFILE
    --     June 8, 2016 Roger Wolf Removed iby_update procedure because steps in APM Profile replaced it.
    --                             Except for the update of IBY_BEPINFO that I put in APM_PROFILE.
         * June 22, 2016 RWW EBA-8995 Post Clone change
         *                   added SUBMIT_GATHER_STATS
    --     October 28, 2016 RWW Changed apps.fnd_databases to use v$database because it was not populated.
    --     November 11, 2016 Roger Wolf EBA-13829 ORBIT Post Clone Update
    --                                  Profile name: Database Wallet Directory
    --     November 21, 2016 Roger Wolf EBA-9274 Post Clone Update for all instances for Transmission configs (IBY_TRASMIT_VALUES)
    --                                            Changes to AP_PROFILE
    --     November 21, 2016 Roger Wolf EBA-14208 Post Clone Adyen changes needed in Automated script for Garmin GMBH
    --                                            Changes to APM_PROFILE
    --     December 13, 2016 Roger Wolf EBA-14022 Supplier Contacts Create Duplicate Records When Maintained
    --                                            When updating Email do not make the status Inactive
    --     December 14, 2016 Roger Wolf Minor change for the above EBA-14022
    --     December 16, 2016 Roger Wolf Minor change for the above EBA-14022
    --     December 16, 2016 Roger Wolf Errors in Changes to APM_PROFILE
    --                                  Changes still needed.
    --     May 8, 2017 RWW EBA-18066 Post Clone Changes Needed
    --                                 Multiple Email addresses are comma as well as semicolon ? need to scrub both
    --                                   USE REGEXP_COUNT to count @ in email.
    --                                 please change dba_email_address to ITDBAOnCallMailbox@garmin.com
    --                                 Basically just need to remove the end date from the Oracle Accounts and set them all up as buyers.
    --                                 We have set everything in Production that was approved in order to speed up the process, so only takes me about 15 mins to prep the instance for your testing purposes?
    --                                   created procedure used by update_loadtest_users
    --                                 During DACH CRP testing, it was found that the customer emails at the HZ_PARTIES level were not scrubbed in the non-prod environments.
    --                                 The Post Clone program only updated HZ_CONTACT_POINTS and prefix the email with XX_.
    --                                 Change email scrubing to be with prefix the email with XX_ instead of with suffix _XX.
    --                                    Modified email to scrub the same consistantly
    --                                 We need to have the same on the customer emails at the HZ_PARTIES table.
    --                                   disable_customer_email
    --     August 9, 2017 RWW Corrected issue with long email in OEH
    --     December 13, 2017 Roger Wolf EBA-22829 please add step in Post clone package
    --                                  Product Support needs PSUSER1-PSUSER20 in non-prod.
    --                                     Changes to update_loadtest_users
    --                                  OAF URL Updates
    --                                     created procedure update_oaf_settings
    --    December 21, 2017 Roger Wolf Additional changes
    --                                  QA team needs AUTOMATION1-AUTOMATION10 in non-prod.
    --    June 27, 2018 Roger Wolf Disable trigger XX_OE_ORDER_HEADERS_ALL_TRG2
    --                                  This is causing slow performance with bussiness events.
    --                                  Changes in PROCEDURE remove_oeh_email
    --    June 27, 2018 Roger Wolf Update XX_POST_CLONE_STEPS_6.sql script?
    --                             Changes to procedure APM_PROFILE
    --    July 18, 2018 Roger Wolf Post Clone Directory Update
    --                             Changes to procedure update_directories
    --    November 2, 2018 Pradeep Added update statements for Business Event REST Service link
    --    November 2, 2018 Roger Wolf Changes was done to MAIN - the STARTING is executed in step 3 added it to starting
    --                                Change new procedure to ROLL back to that save point instead all.
    --                                SHUAI may of had something in mind for MAIN some time
    --    November 4, 2019 Roger Wolf EBA-44979 Docuware part of grooming to do for 10/30 Sprint - Update to Garmin Services Host setup through POST Clone process
    --                                updated to change the Garmin Services Host (XX_SERVICES_HOST) and Garmin Services Secondary Host (XX_SERVICES_SEC_HOST) profile values.
    --                                Made procedure update_oaf_settings work better no matter where the instance was cloned from.
    --                                update update lookup XX_DOCUWARE_URLS new procedure update_docuware_lookup
    --    February 12, 2020 Roger Wolf EBA-48454 Post Clone Adjustments
    --                                 IBY_ECAPP_URL and ICX_PAY_SERVER Profile changes
    --                                 PROCEDURE APM_PROFILE to include GarminNederland
    --    April 16, 2020    BKL        EBA-49388-Post Clone updates for Quality Plan additions from TACX implementation
    --                                 modified Starting to reset email address in the table APPS.QA_RESULTS CHARACTER columns
    --                                 added the procedure remove_qa_plan_email
    --    April 20, 2020   Roger Wolf  EBA-50398 Post Clone Steps Tasks - Add New Merchant Accounts
    --                                 procedure APM_PROFILE - Correct GarminSwissDistr -- add GarminMXN and GarminEuropeRON
    --    May 20, 2020     Roger Wolf  EBA-51387 Post Clone Change for PCF
    --                                 procedure APM_PROFILE new URLS
    --                                 Multiple Emails not scrubed if it contains Garmin
    --                                 EBA-50722 Modify DBA Post Clone Script for Quality Plan - Prepend with 'XX' also for Garmin Email Addresses
    --    Aug 24, 2020     BKL         EBA-54156-Update Docuware View URLS and GUIDs across all UI Types based on Q_DOCUWARE_VALUE_ENV_MAP_V
    --    April 28, 2021   Roger Wolf  EBA-63973 Roger's Non-IMPL Support: Post Clone Program Updates
    --                                 Update IBY_ECAPP_URL profile
    --                                 Update ICX_PAY_SERVER Profile
    --                                 Add XX_WSH_SERVICES_HOST Profile
    --                                 Add XX_WSH_SERVICES_SEC_HOST Profile
    --                                 Better messages on profile update
    --   May 11, 2021     Roger Wolf   APM_PROFILE updates new accounts
    --                                 GarminDeutschlandGmbH-Ecom
    --                                 GarminAustria
    --                                 GarminCzechSro
    --                                 GarminSpain
    --                                 GarminThailand
    --                                 Reformated to make to more automatic
    --   May 27, 2021     Andrada      EBA-62193 Reset CARRIER_EMAIL and CARRIER_EMAIL_CC in the table garmin.xx_wsh_invoice_headers
    --                                 Disable XX_GARMIN_EMAIL_CI_CARRIER lookup
    --   June 1, 2021     Roger Wolf   changed xx_validate_email_address new name xx_validate to check triggers and concurrent programs
    --                                 New Procedure to Schedule Concurrent programs xx_concurrent to be ran after xx_validate
    --                                 renumber some steps
    --   Aug 25, 2021     BKL          EBA-66433 - change URL hosts on function to launch TRADR Web UI; added update_function_param
    --  june 30th 2023    Param Aneja          v$database fix version 1.0
     ******************************************************************************************************/
    v_all_message          CLOB;
    g_email_from           VARCHAR2 (30) := 'donotreply@garmin.com';
    dba_email_address      VARCHAR2 (200) := 'ITDBAOnCallMailbox@garmin.com';
    dba_email_address_CC   VARCHAR2 (200) := 'roger.wolf@garmin.com';


    PROCEDURE build_log (p_message VARCHAR2)
    IS
        err_num   NUMBER;
        err_msg   VARCHAR (100);
    BEGIN
        DBMS_OUTPUT.put_line (SUBSTRB (p_message, 1, 255));
        v_all_message := v_all_message || CHR (10) || p_message;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;

            err_msg := SUBSTR (SQLERRM, 1, 100);

            DBMS_OUTPUT.put_line (
                   '                Failed in '
                || 'build_log '
                || ' '
                || err_num
                || ' '
                || err_msg);
    END;

    PROCEDURE send_mail (p_to            IN VARCHAR2,
                         p_cc            IN VARCHAR2,
                         p_from          IN VARCHAR2,
                         p_subject       IN VARCHAR2,
                         p_text_msg      IN VARCHAR2 DEFAULT NULL,
                         p_attach_name   IN VARCHAR2 DEFAULT NULL,
                         p_attach_mime   IN VARCHAR2 DEFAULT NULL,
                         p_attach_clob   IN CLOB DEFAULT NULL,
                         p_smtp_host     IN VARCHAR2,
                         p_smtp_port     IN NUMBER DEFAULT 25)
    AS
        l_mail_conn   UTL_SMTP.connection;
        l_boundary    VARCHAR2 (50) := '----=*#abc1234321cba#*=';
        l_step        PLS_INTEGER := 24573;
    BEGIN
        l_mail_conn := UTL_SMTP.open_connection (p_smtp_host, p_smtp_port);
        UTL_SMTP.helo (l_mail_conn, p_smtp_host);
        UTL_SMTP.mail (l_mail_conn, p_from);
        UTL_SMTP.rcpt (l_mail_conn, p_to);
        UTL_SMTP.rcpt (l_mail_conn, p_cc);

        UTL_SMTP.open_data (l_mail_conn);

        UTL_SMTP.write_data (
            l_mail_conn,
               'Date: '
            || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
            || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn, 'CC: ' || p_CC || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn,
                             'Subject: ' || p_subject || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn,
                             'Reply-To: ' || p_from || UTL_TCP.crlf);
        UTL_SMTP.write_data (l_mail_conn,
                             'MIME-Version: 1.0' || UTL_TCP.crlf);
        UTL_SMTP.write_data (
            l_mail_conn,
               'Content-Type: multipart/mixed; boundary="'
            || l_boundary
            || '"'
            || UTL_TCP.crlf
            || UTL_TCP.crlf);

        IF p_text_msg IS NOT NULL
        THEN
            UTL_SMTP.write_data (l_mail_conn,
                                 '--' || l_boundary || UTL_TCP.crlf);
            UTL_SMTP.write_data (
                l_mail_conn,
                   'Content-Type: text/plain; charset="iso-8859-1"'
                || UTL_TCP.crlf
                || UTL_TCP.crlf);

            UTL_SMTP.write_data (l_mail_conn, p_text_msg);
            UTL_SMTP.write_data (l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
        END IF;

        IF p_attach_name IS NOT NULL
        THEN
            UTL_SMTP.write_data (l_mail_conn,
                                 '--' || l_boundary || UTL_TCP.crlf);
            UTL_SMTP.write_data (
                l_mail_conn,
                   'Content-Type: '
                || p_attach_mime
                || '; name="'
                || p_attach_name
                || '"'
                || UTL_TCP.crlf);
            UTL_SMTP.write_data (
                l_mail_conn,
                   'Content-Disposition: attachment; filename="'
                || p_attach_name
                || '"'
                || UTL_TCP.crlf
                || UTL_TCP.crlf);

            FOR i IN 0 ..
                     TRUNC (
                         (DBMS_LOB.getlength (p_attach_clob) - 1) / l_step)
            LOOP
                UTL_SMTP.write_data (
                    l_mail_conn,
                    DBMS_LOB.SUBSTR (p_attach_clob, l_step, i * l_step + 1));
            END LOOP;

            UTL_SMTP.write_data (l_mail_conn, UTL_TCP.crlf || UTL_TCP.crlf);
        END IF;

        UTL_SMTP.write_data (l_mail_conn,
                             '--' || l_boundary || '--' || UTL_TCP.crlf);
        UTL_SMTP.close_data (l_mail_conn);

        UTL_SMTP.quit (l_mail_conn);
    END;

    --re-run sql to check the node to ensure cm tier is for admin/cm, two apps tiers are for forms/web Step1.0

    PROCEDURE display_cm_tier_options (p_step VARCHAR2)
    IS
        CURSOR curr_list IS
            SELECT node_name,
                   status,
                   support_cp,
                   support_admin,
                   support_web,
                   support_forms
              FROM apps.fnd_nodes;
    BEGIN
        build_log (
               p_step
            || ' Please check information below to ensure cm tier is for admin/cm, two apps tiers are for forms/web');

        build_log (
               '                       '
            || LPAD ('NOTE', 20, '#')
            || '                 status      SUPPORT_CP       SUPPORT_admin    SUPPORT_web    SUPPORT_forms');

        FOR my_c IN curr_list
        LOOP
            build_log (
                   '                       '
                || LPAD (my_c.node_name, 20, '#')
                || '          '
                || LPAD (my_c.status, 15, ' ')
                || '          '
                || LPAD (my_c.support_cp, 15, ' ')
                || '          '
                || LPAD (my_c.support_admin, 15, ' ')
                || '          '
                || LPAD (my_c.support_web, 15, ' ')
                || '          '
                || LPAD (my_c.support_forms, 15, ' '));
        END LOOP;
    END;

    PROCEDURE is_program_running (p_exec_name   IN     VARCHAR2,
                                  p_result         OUT VARCHAR2)
    IS
        l_phase                  VARCHAR2 (60);
        l_status                 VARCHAR2 (60);
        l_concurrent_prog_name   VARCHAR2 (60);
        l_request_id             VARCHAR2 (60);

        CURSOR curr_list IS
            SELECT wrk.request_id,
                   DECODE (wrk.phase_code,
                           'C', 'Complete',
                           'I', 'Inactive',
                           'P', 'Pending',
                           'R', 'Running',
                           'Unknown')    phase_code,
                   DECODE (wrk.status_code,
                           'C', 'Normal',
                           'D', 'Cancelled',
                           'E', 'Error',
                           'F', 'Scheduled',
                           'I', 'Normal',
                           'M', 'No Manager',
                           'Q', 'Standby',
                           'R', 'Normal',
                           'S', 'Suspended',
                           'T', 'Terminating',
                           'U', 'Disabled',
                           'W', 'Paused',
                           'Z', 'Waiting',
                           'Unknown')    status_code,
                   prg.concurrent_program_name
              FROM apps.fnd_concurrent_programs  prg,
                   apps.fnd_concurrent_requests  wrk
             WHERE     prg.application_id = wrk.program_application_id
                   AND prg.concurrent_program_id = wrk.concurrent_program_id
                   AND prg.concurrent_program_name = p_exec_name
                   AND wrk.phase_code <> 'C';
    BEGIN
        l_request_id := 0; -- if there is no running instance, then  request id is 0

        FOR my_c IN curr_list
        LOOP
            l_phase := my_c.phase_code;

            l_status := my_c.status_code;

            l_concurrent_prog_name := my_c.concurrent_program_name;

            l_request_id := my_c.request_id;
        END LOOP;

        IF l_request_id <> 0
        THEN
            p_result :=
                   l_concurrent_prog_name
                || ' is ALREADY scheduled to run with '
                || l_phase
                || ' phase, '
                || l_status
                || ' status, and the request id is '
                || l_request_id;
        ELSE
            p_result := 'No';
        END IF;
    END;

    --Update the temporary directory for BI Publisher by following these steps: Step1.101

    PROCEDURE update_bip_temp_dir (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_bip_temp_dir';
        v_temp_dir       VARCHAR2 (200);
    BEGIN
        build_log (
               p_step
            || ' Update temporary directory for XML Publisher Administrator begin...');

        /*SELECT '/u02/' || name || '/GRMNtmp'
          INTO v_temp_dir
          FROM v$database
         WHERE ROWNUM = 1;*/ --commented for parmdsa

         SELECT '/u02/' || apps.xx_db_util.get_dbname  || '/GRMNtmp'
          INTO v_temp_dir
          FROM dual
         WHERE ROWNUM = 1;  -- added for version 1.0




        build_log (
               '                  '
            || 'The temporary directory is '
            || v_temp_dir);

        SAVEPOINT update_bip;

        BEGIN
            UPDATE apps.xdo_config_values xcv
               SET xcv.VALUE = v_temp_dir
             WHERE xcv.property_code = 'SYSTEM_TEMP_DIR' AND ROWNUM = 1;

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO update_bip;

                err_num := SQLCODE;

                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        COMMIT;

        build_log (
            '                  Update update_bip_temp_dir successfully');
    END;

    PROCEDURE update_directories (p_step            VARCHAR2,
                                  p_source_db       VARCHAR2,
                                  p_result      OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR2 (100);
        procedure_name   VARCHAR2 (200) := 'update_directories';
        v_db_name        v$database.name%TYPE;
        sql_str          VARCHAR2 (1000);
        v_total_val      NUMBER := 0;

        --used to replace the source Database Host to current Host Name

        CURSOR list_dir IS
              SELECT dd.directory_path, dd.directory_name
                FROM sys.dba_directories dd
               WHERE dd.directory_path LIKE '%' || UPPER (p_source_db) || '%'
            ORDER BY dd.directory_path;
    BEGIN
        build_log (p_step || ' Update DB Directories begin...');

         --SELECT name INTO v_db_name FROM v$database; --cmmented for version 1.0

         SELECT apps.xx_db_util.get_dbname INTO v_db_name  FROM DUAL;


        SAVEPOINT update_directories;

        v_total_val := 0;

        BEGIN
            FOR cur_rec IN list_dir
            LOOP
                v_total_val := v_total_val + 1;

                sql_str :=
                       'CREATE OR REPLACE DIRECTORY '
                    || cur_rec.directory_name
                    || '  as '
                    || ''''
                    || REPLACE (cur_rec.directory_path,
                                UPPER (p_source_db),
                                v_db_name)
                    || '''';

                EXECUTE IMMEDIATE sql_str;

                build_log (
                       '                  '
                    || sql_str
                    || ' from '
                    || cur_rec.directory_path);
            END LOOP;

            build_log (
                   '                  Total directories (Database Name) udpated '
                || v_total_val);

            p_result := success;

            build_log ('                  Update directories successfully');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO update_directories;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;
        END;
    END;

    PROCEDURE disable_profile_printer_copies (p_step         VARCHAR2,
                                              p_result   OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'disable_profile_printer_copies';
    BEGIN
        build_log (p_step || ' Disable Profile Printers and Copies begin...');

        SAVEPOINT disable_profile_printer_copies;

        BEGIN
            DELETE FROM apps.fnd_profile_option_values fpov
                  WHERE     fpov.profile_option_id IN
                                (SELECT fpo.profile_option_id
                                   FROM apps.fnd_profile_options fpo
                                  WHERE fpo.profile_option_name IN
                                            ('PRINTER', 'CONC_COPIES'))
                        AND fpov.level_id IN (10003, 10004);     -- RESP, USER

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO disable_profile_printer_copies;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        COMMIT;

        build_log (
            '                  Disable Profile Printers and Copies successfully');
    END;


    PROCEDURE disable_alert (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'disable_alert';
    BEGIN
        build_log (p_step || ' Disable alerts begin...');

        SAVEPOINT disable_alert;

        BEGIN
            UPDATE apps.alr_alerts
               SET enabled_flag = 'N'
             WHERE enabled_flag = 'Y';

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO disable_alert;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        COMMIT;

        build_log ('                  Disable disable alert successfully');
    END;

    PROCEDURE disable_concurrent_prog (p_step         VARCHAR2,
                                       p_result   OUT VARCHAR2)
    IS
        err_num                     NUMBER;
        err_msg                     VARCHAR (100);
        procedure_name              VARCHAR2 (200) := 'disable_concurrent_prog';
        concurrent_program_name_a   VARCHAR2 (500) := 'XXPROACTBK';
        concurrent_program_name_b   VARCHAR2 (500) := 'XXPROACTRC';
        concurrent_program_name_c   VARCHAR2 (500) := 'XXPROACTSH';
    BEGIN
        build_log (
               p_step
            || ' Disable Concurrent Programs: XXPROACTBK, XXPROACTRC and XXPROACTSH begin...');

        SAVEPOINT disable_concurrent_prog;

        BEGIN
            UPDATE apps.fnd_concurrent_programs fcp
               SET enabled_flag = 'N'
             WHERE     fcp.concurrent_program_name IN
                           (concurrent_program_name_a,
                            concurrent_program_name_b,
                            concurrent_program_name_c)
                   AND enabled_flag <> 'N';

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO disable_concurrent_prog;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        COMMIT;

        build_log (
            '                  Disable Concurrent Programs successfully');
    END;



    PROCEDURE enable_concurrent_prog (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num                     NUMBER;
        err_msg                     VARCHAR (100);
        procedure_name              VARCHAR2 (200) := 'enable_concurrent_prog';
        concurrent_program_name_a   VARCHAR2 (500) := 'XX_OE_CLONE';
    BEGIN
        build_log (
            p_step || ' Enable Concurrent Programs XX_OE_CLONE begin...');

        SAVEPOINT enable_concurrent_prog;

        BEGIN
            UPDATE apps.fnd_concurrent_programs fcp
               SET enabled_flag = 'Y'
             WHERE     fcp.concurrent_program_name IN
                           (concurrent_program_name_a)
                   AND enabled_flag <> 'Y';

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO enable_concurrent_prog;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        COMMIT;

        build_log ('                  Enable Concurrent Programs successful');
    END;


    --Change the email address of HPC, HTC, HJW, HIRENE, HALVIS, HALVIS1, Step 1.100

    PROCEDURE update_fnd_user_email (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;

        err_msg          VARCHAR (100);

        procedure_name   VARCHAR2 (200) := 'update_fnd_user_email';
    BEGIN
        build_log (p_step || ' Update_fnd_user_email begin...');

        BEGIN
            SAVEPOINT sp;

            UPDATE apps.fnd_user p
               SET p.email_address =
                          'XX_'
                       || TO_CHAR (SYSDATE, 'hhmmss')
                       || '_XX'
                       || email_address
             WHERE     p.email_address IS NOT NULL
                   AND UPPER (p.email_Address) NOT LIKE 'XX_%'
                   AND UPPER (p.email_Address) NOT LIKE '%GARMIN%';

            build_log (
                   '                  '
                || 'Rows updated: '
                || TO_CHAR (SQL%ROWCOUNT));

            COMMIT;

            build_log (
                '                  update_fnd_user_email with _XX end...');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO sp;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        BEGIN
            SAVEPOINT sp1;

            UPDATE apps.fnd_user
               SET email_address = 'postman.tw@garmin.com'
             WHERE     user_name IN ('HPC',
                                     'HTC',
                                     'HJW',
                                     'HIRENE',
                                     'HALVIS',
                                     'HALVIS1')
                   AND email_address <> 'postman.tw@garmin.com';


            build_log (
                   '                  '
                || 'Rows updated: '
                || TO_CHAR (SQL%ROWCOUNT));

            COMMIT;

            build_log (
                '                  Update_fnd_user_email HPC, HTC, HJW, HIRENE, HALVIS, HALVIS1 to postman.tw@garmin.com end...');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO sp1;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;
    END;


    PROCEDURE remove_vendor_email (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num            NUMBER;
        err_msg            VARCHAR (100);
        procedure_name     VARCHAR2 (200) := 'remove_vendor_email';
        backup_tbl         VARCHAR2 (200)
            := 'garmin.HZ_CONTACT_POINTS_AP_' || TO_CHAR (SYSDATE, 'hhmmss');
        backup_tbl2        VARCHAR2 (200)
            := 'garmin.AP_SUPPLIER_SITES_ALL_' || TO_CHAR (SYSDATE, 'hhmmss');
        backup_tbl3        VARCHAR2 (200)
            := 'garmin.HZ_PARTIES_' || TO_CHAR (SYSDATE, 'hhmmss');
        backup_statement   VARCHAR2 (1000);
    BEGIN
        build_log (p_step || ' Remove_vendor_email begin...');

        backup_statement :=
               '                  '
            || 'create TABLE '
            || backup_tbl
            || ' TABLESPACE xx_junk AS '
            || 'SELECT HCP8.* '
            || 'FROM apps.HZ_CONTACT_POINTS HCP8, apps.AP_SUPPLIER_CONTACTS PVC '
            || 'WHERE     HCP8.OWNER_TABLE_NAME = ''HZ_PARTIES'' '
            || 'AND HCP8.CONTACT_POINT_TYPE = ''EMAIL'' '
            || 'AND HCP8.email_address IS NOT NULL '
            || 'AND HCP8.OWNER_TABLE_ID = PVC.REL_PARTY_ID';

        build_log ('    ' || backup_statement);

        EXECUTE IMMEDIATE backup_statement;

        -- R12 change
        -- table change to AP_SUPPLIER_SITES_ALL column email_address
        backup_statement :=
               '                  '
            || 'create TABLE '
            || backup_tbl2
            || ' TABLESPACE xx_junk AS SELECT * FROM apps.AP_SUPPLIER_SITES_ALL PVS WHERE email_address IS NOT NULL';

        build_log ('    ' || backup_statement);

        EXECUTE IMMEDIATE backup_statement;

        UPDATE apps.HZ_CONTACT_POINTS HCP8
           SET HCP8.email_address =
                   CASE
                       WHEN NVL (REGEXP_COUNT (HCP8.EMAIL_ADDRESS,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (HCP8.EMAIL_ADDRESS) NOT LIKE
                                    '%GARMIN%'
                            AND UPPER (HCP8.EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || HCP8.EMAIL_ADDRESS
                       ELSE
                           HCP8.EMAIL_ADDRESS
                   END
         WHERE     HCP8.OWNER_TABLE_NAME = 'HZ_PARTIES'
               AND HCP8.CONTACT_POINT_TYPE = 'EMAIL'
               AND HCP8.email_address IS NOT NULL
               AND HCP8.OWNER_TABLE_ID IN
                       (SELECT PVC.REL_PARTY_ID
                          FROM apps.AP_SUPPLIER_CONTACTS PVC);

        build_log (
               '                  '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));
        COMMIT;

        backup_statement :=
               '                  '
            || 'create TABLE '
            || backup_tbl3
            || ' TABLESPACE xx_junk AS '
            || 'SELECT hp2.* '
            || 'FROM apps.HZ_PARTIES HP2, apps.AP_SUPPLIER_CONTACTS PVC '
            || 'WHERE     hp2.email_address IS NOT NULL '
            || 'AND PVC.REL_PARTY_ID = HP2.PARTY_ID';

        build_log ('    ' || backup_statement);

        UPDATE apps.HZ_PARTIES HP2
           SET hp2.email_address =
                   CASE
                       WHEN NVL (REGEXP_COUNT (hp2.email_address,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (HP2.EMAIL_ADDRESS) NOT LIKE '%GARMIN%'
                            AND UPPER (HP2.EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || hp2.email_address
                       ELSE
                           hp2.email_address
                   END
         WHERE     hp2.email_address IS NOT NULL
               AND HP2.PARTY_ID IN (SELECT PVC.REL_PARTY_ID
                                      FROM AP_SUPPLIER_CONTACTS PVC);

        build_log ('    po_vendor_contacts email_address');
        build_log (
               '                  '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));
        COMMIT;

        UPDATE apps.AP_SUPPLIER_SITES_ALL
           SET email_address =
                   CASE
                       WHEN NVL (REGEXP_COUNT (email_address,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (EMAIL_ADDRESS) NOT LIKE '%GARMIN%'
                            AND UPPER (EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || email_address
                       ELSE
                           email_address
                   END
         WHERE email_address IS NOT NULL;

        build_log ('    apps.AP_SUPPLIER_SITES_ALL');
        build_log (
               '                  '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));
        COMMIT;

        build_log ('                  ' || ' remove_vendor_email end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;

    PROCEDURE update_vendor_user_pref (p_step         VARCHAR2,
                                       p_result   OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_vendor_user_pref';
    BEGIN
        build_log (p_step || ' update_vendor_user_pref begin...');

        SAVEPOINT sp;

        UPDATE apps.fnd_user_preferences
           SET preference_value = 'QUERY'
         WHERE     preference_value <> 'QUERY'
               AND preference_name = 'MAILTYPE'
               AND user_name IN
                       (SELECT DISTINCT user1.user_name
                          FROM apps.fnd_user                     user1,
                               apps.ak_web_user_sec_attr_values  ak1,
                               apps.ak_web_user_sec_attr_values  ak2,
                               apps.fnd_user_resp_groups         fur
                         WHERE     user1.user_id = ak1.web_user_id
                               AND ak1.attribute_code IN
                                       ('ICX_SUPPLIER_ORG_ID',
                                        'ICX_SUPPLIER_SITE_ID',
                                        'ICX_SUPPLIER_CONTACT_ID')
                               AND ak1.attribute_application_id = 177
                               AND ak2.attribute_application_id = 177
                               AND ak1.web_user_id = ak2.web_user_id
                               AND fur.responsibility_application_id = 177
                               AND fur.user_id = user1.user_id
                               AND fur.start_date < SYSDATE
                               AND NVL (fur.end_date, SYSDATE + 1) >= SYSDATE
                               AND TRUNC (SYSDATE) BETWEEN NVL (
                                                               TRUNC (
                                                                   user1.start_date),
                                                               TRUNC (
                                                                   SYSDATE))
                                                       AND NVL (
                                                               TRUNC (
                                                                   user1.end_date),
                                                               TRUNC (
                                                                   SYSDATE)));

        build_log (
               '                  '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));

        build_log (
               '                  '
            || 'also updat the notification_preference for wf_local_roles');

        UPDATE apps.wf_local_roles
           SET notification_preference = 'QUERY'
         WHERE     orig_system = 'FND_USR'
               AND status = 'ACTIVE'
               AND parent_orig_system = 'HZ_PARTY'
               AND notification_preference <> 'QUERY'
               AND user_flag = 'Y'
               AND name IN
                       (SELECT DISTINCT user1.user_name
                          FROM apps.fnd_user                     user1,
                               apps.ak_web_user_sec_attr_values  ak1,
                               apps.ak_web_user_sec_attr_values  ak2,
                               apps.fnd_user_resp_groups         fur
                         WHERE     user1.user_id = ak1.web_user_id
                               AND ak1.attribute_code IN
                                       ('ICX_SUPPLIER_ORG_ID',
                                        'ICX_SUPPLIER_SITE_ID',
                                        'ICX_SUPPLIER_CONTACT_ID')
                               AND ak1.attribute_application_id = 177
                               AND ak2.attribute_application_id = 177
                               AND ak1.web_user_id = ak2.web_user_id
                               AND fur.responsibility_application_id = 177
                               AND fur.user_id = user1.user_id
                               AND fur.start_date < SYSDATE
                               AND NVL (fur.end_date, SYSDATE + 1) >= SYSDATE
                               AND TRUNC (SYSDATE) BETWEEN NVL (
                                                               TRUNC (
                                                                   user1.start_date),
                                                               TRUNC (
                                                                   SYSDATE))
                                                       AND NVL (
                                                               TRUNC (
                                                                   user1.end_date),
                                                               TRUNC (
                                                                   SYSDATE)));

        build_log (
               '                  '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));

        COMMIT;

        build_log ('                  ' || ' update_vendor_user_pref end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO sp;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;

    PROCEDURE remove_ci_email (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num            NUMBER;
        err_msg            VARCHAR (100);
        procedure_name     VARCHAR2 (200) := 'remove_ci_email';
        backup_tbl         VARCHAR2 (200)
            :=    'garmin.xx_wsh_invoice_headers_'
               || TO_CHAR (SYSDATE, 'hhmmss');
        backup_statement   VARCHAR2 (1000);
    BEGIN
        build_log (p_step || ' ' || procedure_name || ' begin...');

        backup_statement :=
               '                  '
            || 'create TABLE '
            || backup_tbl
            || ' TABLESPACE xx_junk AS '
            || 'SELECT xwih.* '
            || 'FROM garmin.xx_wsh_invoice_headers xwih '
            || 'WHERE     xwih.email_addresses is not null OR xwih.carrier_email is not null OR xwih.carrier_email_cc is not null';

        build_log ('    ' || backup_statement);

        EXECUTE IMMEDIATE backup_statement;

        UPDATE garmin.xx_wsh_invoice_headers xwih
           SET xwih.email_addresses =
                   CASE
                       WHEN NVL (REGEXP_COUNT (xwih.email_addresses,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (xwih.email_addresses) NOT LIKE
                                    '%GARMIN%'
                            AND UPPER (xwih.email_addresses) NOT LIKE 'XX_%'
                            AND xwih.email_addresses IS NOT NULL
                       THEN
                           'XX_' || xwih.email_addresses
                       ELSE
                           xwih.email_addresses
                   END,
               xwih.carrier_email =
                   CASE
                       WHEN NVL (REGEXP_COUNT (xwih.carrier_email,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (xwih.carrier_email) NOT LIKE
                                    '%GARMIN%'
                            AND UPPER (xwih.carrier_email) NOT LIKE 'XX_%'
                            AND xwih.carrier_email IS NOT NULL
                       THEN
                           'XX_' || xwih.carrier_email
                       ELSE
                           xwih.carrier_email
                   END,
               xwih.carrier_email_cc =
                   CASE
                       WHEN NVL (REGEXP_COUNT (xwih.carrier_email_cc,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (xwih.carrier_email_cc) NOT LIKE
                                    '%GARMIN%'
                            AND UPPER (xwih.carrier_email_cc) NOT LIKE 'XX_%'
                            AND xwih.carrier_email_cc IS NOT NULL
                       THEN
                           'XX_' || xwih.carrier_email_cc
                       ELSE
                           xwih.carrier_email_cc
                   END
         WHERE    xwih.email_addresses IS NOT NULL
               OR xwih.carrier_email IS NOT NULL
               OR xwih.carrier_email_cc IS NOT NULL;

        build_log (
               '                  '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));
        COMMIT;

        build_log ('                  ' || procedure_name || ' end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;

    PROCEDURE remove_oeh_email (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num              NUMBER;
        err_msg              VARCHAR (100);
        procedure_name       VARCHAR2 (200) := 'remove_oeh_email';
        backup_tbl           VARCHAR2 (200)
            := 'garmin.xx_oeh_email_' || TO_CHAR (SYSDATE, 'hhmmss');
        backup_statement     VARCHAR2 (1000);
        TRIGGER_1            VARCHAR2 (50) := 'APPS.XX_OE_ORDER_HEADERS_ALL_T1';
        TRIGGER_2            VARCHAR2 (50)
                                 := 'APPS.XX_DPL_ORD_HDR_TRIGGER_UPDT';
        TRIGGER_3            VARCHAR2 (50)
                                 := 'APPS.XX_OE_ORDER_HEADERS_ALL_TRG2';
        TRIGGGER_STATEMENT   VARCHAR2 (1000);
    BEGIN
        build_log (p_step || ' ' || procedure_name || ' begin...');

        backup_statement :=
               '                  '
            || 'create TABLE '
            || backup_tbl
            || ' TABLESPACE xx_junk AS '
            || 'SELECT oeh.HEADER_ID, oeh.ATTRIBUTE12, oeh.ATTRIBUTE20 '
            || 'FROM apps.OE_ORDER_HEADERS_ALL oeh '
            || 'WHERE     oeh.ATTRIBUTE12 is not null '
            || '       or  oeh.ATTRIBUTE20 is not null ';

        build_log ('    ' || backup_statement);


        BEGIN
            EXECUTE IMMEDIATE backup_statement;
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);
                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);
        END;

        TRIGGGER_STATEMENT :=
               '                  '
            || 'ALTER TRIGGER  '
            || TRIGGER_1
            || ' DISABLE ';

        build_log ('    ' || TRIGGGER_STATEMENT);

        BEGIN
            EXECUTE IMMEDIATE TRIGGGER_STATEMENT;
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);
                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);
        END;

        TRIGGGER_STATEMENT :=
               '                  '
            || 'ALTER TRIGGER  '
            || TRIGGER_2
            || ' DISABLE ';

        build_log ('    ' || TRIGGGER_STATEMENT);

        BEGIN
            EXECUTE IMMEDIATE TRIGGGER_STATEMENT;
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);
                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);
        END;

        TRIGGGER_STATEMENT :=
               '                  '
            || 'ALTER TRIGGER  '
            || TRIGGER_3
            || ' DISABLE ';

        build_log ('    ' || TRIGGGER_STATEMENT);

        BEGIN
            EXECUTE IMMEDIATE TRIGGGER_STATEMENT;
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);
                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);
        END;

        UPDATE apps.OE_ORDER_HEADERS_ALL oeh
           SET oeh.ATTRIBUTE12 =
                   CASE
                       WHEN oeh.ATTRIBUTE12 IS NULL
                       THEN
                           NULL
                       WHEN NVL (REGEXP_COUNT (oeh.ATTRIBUTE12,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (oeh.ATTRIBUTE12) NOT LIKE '%GARMIN%'
                            AND UPPER (oeh.ATTRIBUTE12) NOT LIKE 'XX_%'
                       THEN
                           CASE
                               WHEN LENGTHB (oeh.ATTRIBUTE12) > 237
                               THEN
                                   'XX_LONG_EMAIL@GARMIN.COM'
                               ELSE
                                   'XX_' || oeh.ATTRIBUTE12
                           END
                       ELSE
                           oeh.ATTRIBUTE12
                   END,
               oeh.ATTRIBUTE20 =
                   CASE
                       WHEN oeh.ATTRIBUTE20 IS NULL
                       THEN
                           NULL
                       WHEN NVL (REGEXP_COUNT (oeh.ATTRIBUTE20,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (oeh.ATTRIBUTE20) NOT LIKE '%GARMIN%'
                            AND UPPER (oeh.ATTRIBUTE20) NOT LIKE 'XX_%'
                       THEN
                           CASE
                               WHEN LENGTHB (oeh.ATTRIBUTE20) > 237
                               THEN
                                   'XX_LONG_EMAIL@GARMIN.COM'
                               ELSE
                                   'XX_' || oeh.ATTRIBUTE20
                           END
                       ELSE
                           oeh.ATTRIBUTE20
                   END
         WHERE oeh.ATTRIBUTE12 IS NOT NULL OR oeh.ATTRIBUTE20 IS NOT NULL;

        build_log (
               '                  ATTRIBUTE12 and ATTRIBUTE20 '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));
        COMMIT;

        TRIGGGER_STATEMENT :=
               '                  '
            || 'ALTER TRIGGER  '
            || TRIGGER_1
            || ' ENABLE ';

        build_log ('    ' || TRIGGGER_STATEMENT);

        BEGIN
            EXECUTE IMMEDIATE TRIGGGER_STATEMENT;
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);
                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);
        END;

        TRIGGGER_STATEMENT :=
               '                  '
            || 'ALTER TRIGGER  '
            || TRIGGER_2
            || ' ENABLE ';

        build_log ('    ' || TRIGGGER_STATEMENT);

        BEGIN
            EXECUTE IMMEDIATE TRIGGGER_STATEMENT;
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);
                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);
        END;

        TRIGGGER_STATEMENT :=
               '                  '
            || 'ALTER TRIGGER  '
            || TRIGGER_3
            || ' ENABLE ';

        build_log ('    ' || TRIGGGER_STATEMENT);

        BEGIN
            EXECUTE IMMEDIATE TRIGGGER_STATEMENT;
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);
                build_log (
                       '  Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);
        END;

        build_log ('                  ' || procedure_name || ' end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;

    PROCEDURE remove_pro_com_email (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num            NUMBER;
        err_msg            VARCHAR (100);
        procedure_name     VARCHAR2 (200) := 'remove_pro_com_email';
        backup_tbl         VARCHAR2 (200)
            := 'garmin.xx_pro_comm_stg_tbl_' || TO_CHAR (SYSDATE, 'hhmmss');
        backup_statement   VARCHAR2 (1000);
    BEGIN
        build_log (p_step || ' ' || procedure_name || ' begin...');

        backup_statement :=
               '                  '
            || 'create TABLE '
            || backup_tbl
            || ' TABLESPACE xx_junk AS '
            || 'SELECT COMM_ID, EMAIL_ADDRESS, B_EMAIL_ADDRESS, S_EMAIL_ADDRESS '
            || 'FROM APPS.XX_PRO_COMM_STG_TBL '
            || 'WHERE     EMAIL_ADDRESS is not null '
            || '      or  B_EMAIL_ADDRESS is not null '
            || '      or  S_EMAIL_ADDRESS is not null ';

        build_log ('    ' || backup_statement);

        EXECUTE IMMEDIATE backup_statement;

        UPDATE APPS.XX_PRO_COMM_STG_TBL
           SET EMAIL_ADDRESS =
                   CASE
                       WHEN EMAIL_ADDRESS IS NULL
                       THEN
                           NULL
                       WHEN NVL (REGEXP_COUNT (EMAIL_ADDRESS,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (EMAIL_ADDRESS) NOT LIKE '%GARMIN%'
                            AND UPPER (EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || EMAIL_ADDRESS
                       ELSE
                           EMAIL_ADDRESS
                   END,
               B_EMAIL_ADDRESS =
                   CASE
                       WHEN B_EMAIL_ADDRESS IS NULL
                       THEN
                           NULL
                       WHEN NVL (REGEXP_COUNT (B_EMAIL_ADDRESS,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (B_EMAIL_ADDRESS) NOT LIKE '%GARMIN%'
                            AND UPPER (B_EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || B_EMAIL_ADDRESS
                       ELSE
                           B_EMAIL_ADDRESS
                   END,
               S_EMAIL_ADDRESS =
                   CASE
                       WHEN S_EMAIL_ADDRESS IS NULL
                       THEN
                           NULL
                       WHEN NVL (REGEXP_COUNT (S_EMAIL_ADDRESS,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (S_EMAIL_ADDRESS) NOT LIKE '%GARMIN%'
                            AND UPPER (S_EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || S_EMAIL_ADDRESS
                       ELSE
                           S_EMAIL_ADDRESS
                   END
         WHERE    EMAIL_ADDRESS IS NOT NULL
               OR B_EMAIL_ADDRESS IS NOT NULL
               OR S_EMAIL_ADDRESS IS NOT NULL;

        build_log (
               '                  EMAIL ADDRESS '
            || 'Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));
        COMMIT;

        build_log ('                  ' || procedure_name || ' end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;

    PROCEDURE remove_qa_plan_email (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num              NUMBER;
        err_msg              VARCHAR (100);
        l_procedure_name     VARCHAR2 (200) := 'remove_qa_plan_email';
        l_backup_tbl         VARCHAR2 (200)
            := 'garmin.xx_qa_results_tbl_' || TO_CHAR (SYSDATE, 'hhmmss');
        l_backup_statement   VARCHAR2 (1000);
        l_update_statement   VARCHAR2 (1000);

        CURSOR c_qa_plan_chars IS
            SELECT qpc.result_column_name
              FROM apps.qa_plan_chars qpc, apps.qa_plans qp
             WHERE     qpc.plan_id = qp.plan_id
                   AND qp.view_name = 'Q_GLOBAL_EXT_DOC_MAPPINGS_V';
    BEGIN
        build_log (p_step || ' ' || l_procedure_name || ' begin...');

        l_backup_statement :=
               '                  '
            || 'CREATE TABLE '
            || l_backup_tbl
            || ' TABLESPACE xx_junk AS '
            || 'SELECT * '
            || 'FROM APPS.QA_RESULTS '
            || 'WHERE PLAN_ID IN '
            || '      (SELECT PLAN_ID '
            || '      FROM APPS.QA_PLANS '
            || '      WHERE VIEW_NAME =''Q_GLOBAL_EXT_DOC_MAPPINGS_V'') ';

        build_log ('    ' || l_backup_statement);

        EXECUTE IMMEDIATE l_backup_statement;

        FOR r_qa_plan_chars IN c_qa_plan_chars
        LOOP
            l_update_statement :=
                   '                  '
                || 'UPDATE APPS.QA_RESULTS qr '
                || ' SET '
                || ' qr.'
                || r_qa_plan_chars.result_column_name
                || ' =    CASE '
                || '      WHEN NVL(REGEXP_COUNT(qr.'
                || r_qa_plan_chars.result_column_name
                || ',''@'', 1, ''i''),0) > 1'
                || '      THEN '
                || '           ''XX_MUTIPLE_EMAIL@GARMIN.COM'''
                || '      WHEN     UPPER (qr.'
                || r_qa_plan_chars.result_column_name
                || ') NOT LIKE ''XX_%'''
                || '      THEN '
                || '           ''XX_''||qr.'
                || r_qa_plan_chars.result_column_name
                || '      ELSE '
                || '           qr.'
                || r_qa_plan_chars.result_column_name
                || '      END '
                || ' WHERE qr.'
                || r_qa_plan_chars.result_column_name
                || ' LIKE ''%@%'''
                || ' AND PLAN_ID IN '
                || '      (SELECT PLAN_ID '
                || '      FROM APPS.QA_PLANS '
                || '      WHERE VIEW_NAME =''Q_GLOBAL_EXT_DOC_MAPPINGS_V'') ';

            EXECUTE IMMEDIATE l_update_statement;

            build_log (
                   '                  '
                || r_qa_plan_chars.result_column_name
                || ' Email Rows updated: '
                || TO_CHAR (SQL%ROWCOUNT));
        END LOOP;

        COMMIT;

        build_log ('                  ' || l_procedure_name || ' end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || l_procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END remove_qa_plan_email;

    PROCEDURE close_wf_notifications (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'close_wf_notifications';
    BEGIN
        build_log (p_step || ' close_wf_notifications begin...');

        SAVEPOINT sp;

        UPDATE apps.wf_notifications
           SET mail_status = 'SENT', status = 'CLOSED'
         WHERE mail_status = 'MAIL';

        build_log (
               '                  '
            || '''mail_status = MAIL'' Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));

        UPDATE apps.wf_notifications
           SET mail_status = 'SENT', status = 'CLOSED'
         WHERE mail_status IS NULL AND status = 'OPEN';

        build_log (
               '                  '
            || '''mail_status IS NULL AND STATUS = OPEN'' Rows updated: '
            || TO_CHAR (SQL%ROWCOUNT));

        COMMIT;

        build_log ('                  ' || ' close_wf_notifications end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO sp;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;

    /**Pradeep**/

    PROCEDURE update_conc_processes (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_conc_processes';
    BEGIN
        build_log (p_step || ' update_conc_processes begin...');

        SAVEPOINT sp;

        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 3, min_processes = 3
         WHERE concurrent_queue_id IN (1312, 16346);   --Output Post Processor

        build_log (
               '                  '
            || '''Output Post Processor, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));

        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 3, min_processes = 3
         WHERE concurrent_queue_id IN (10, 16348);         --Inventory_manager

        build_log (
               '                  '
            || '''Inventory_manager, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));



        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 3, min_processes = 3
         WHERE concurrent_queue_id IN (222, 16347); --Receiving Transaction Manager

        build_log (
               '                  '
            || '''Receiving Transaction Manager, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));


        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 12, min_processes = 12
         WHERE concurrent_queue_id IN (1282, 16343); --Garmin Global Standard Manager

        build_log (
               '                  '
            || '''Garmin Global Standard Manager, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));



        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 5, min_processes = 3
         WHERE concurrent_queue_id IN (1281, 16344); --Garmin Long Running Manager

        build_log (
               '                  '
            || '''Garmin Long Running Manager, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));



        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 5, min_processes = 3
         WHERE concurrent_queue_id IN (1220, 16340); --Garmin Short Running Manager

        build_log (
               '                  '
            || '''Garmin Short Running Manager, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));



        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 3, min_processes = 3
         WHERE concurrent_queue_id IN (1317, 16339); --Garmin Concurrent Mgr for Requisition Import and Create Releases

        build_log (
               '                  '
            || '''Garmin Concurrent Mgr for Requisition Import and Create Releases, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));



        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 3, min_processes = 3
         WHERE concurrent_queue_id IN (3335, 16345); --Garmin HSN Temporary Manager

        build_log (
               '                  '
            || '''Garmin HSN Temporary Manager, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));


        UPDATE apps.FND_CONCURRENT_QUEUE_SIZE
           SET max_processes = 2, min_processes = 2
         WHERE concurrent_queue_id IN (4335, 16342); --Garmin Agile Import Manager

        build_log (
               '                  '
            || '''Garmin Agile Import Manager, Max and MIN Processes Updated to : '
            || TO_CHAR (SQL%ROWCOUNT));

        COMMIT;

        build_log ('                  ' || ' update_conc_processes end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO sp;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;

    PROCEDURE alter_users (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num                NUMBER;
        err_msg                VARCHAR (100);
        procedure_name         VARCHAR2 (200) := 'alter_users';
        alter_user_statement   VARCHAR2 (200);
    BEGIN
        build_log (p_step || ' alter_users begin...');

        alter_user_statement := ' alter user ukwms identified by devwms3 ';

        build_log ('                  ' || alter_user_statement);

        EXECUTE IMMEDIATE alter_user_statement;

        alter_user_statement := ' alter user ups identified by ups  ';

        build_log ('                  ' || alter_user_statement);

        EXECUTE IMMEDIATE alter_user_statement;

        build_log ('                  ' || ' alter_users end...');
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;

    PROCEDURE update_loadtest_users (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_loadtest_users';
    BEGIN
        build_log (p_step || ' update_loadtest_users begin...');

        SAVEPOINT loadtest_users;

        BEGIN
            UPDATE APPS.FND_USER
               SET END_DATE = NULL
             WHERE     (   USER_NAME LIKE 'QATEST%'
                        OR USER_NAME LIKE 'PSUSER%'
                        OR USER_NAME LIKE 'AUTOMATION%')
                   AND END_DATE IS NOT NULL;

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO loadtest_users;

                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        COMMIT;

        build_log ('                  update_loadtest_users successfully');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;


    PROCEDURE update_oaf_settings (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_oaf_settings';
        L_COUNT          NUMBER;


        CURSOR c1 IS
           /* SELECT a.ROWID                                             AS row_id,
                   a.ATT_VALUE,
                   db.name,
                      CASE
                          WHEN db.name = 'ORBDEV' THEN 'https://servicesdev'
                          WHEN db.name = 'ORBTST' THEN 'https://servicestest'
                          WHEN db.name = 'ORBQA' THEN 'https://servicesstg'
                          ELSE 'https://servicesdev'
                      END
                   || SUBSTR (a.ATT_VALUE,
                              (INSTR (a.ATT_VALUE, '.garmin.com')))    AS new_att_value
              FROM APPS.JDR_ATTRIBUTES a, v$database db
             WHERE a.ATT_VALUE LIKE 'https%services%.garmin.com%';*/ -- commented for version 1.0
             SELECT a.ROWID                                             AS row_id,
                   a.ATT_VALUE,
                   db.name,
                      CASE
                          WHEN db.name = 'ORBDEV' THEN 'https://servicesdev'
                          WHEN db.name = 'ORBTST' THEN 'https://servicestest'
                          WHEN db.name = 'ORBQA' THEN 'https://servicesstg'
                          ELSE 'https://servicesdev'
                      END
                   || SUBSTR (a.ATT_VALUE,
                              (INSTR (a.ATT_VALUE, '.garmin.com')))    AS new_att_value
              FROM APPS.JDR_ATTRIBUTES a,(select apps.xx_db_util.get_dbname name from dual) db-- v$database db
             WHERE a.ATT_VALUE LIKE 'https%services%.garmin.com%'; -- added for version 1.0


    BEGIN
        build_log (p_step || ' update_oaf_settings begin...');

        SAVEPOINT oaf_settings;

        L_COUNT := 0;

        FOR L_C1 IN C1
        LOOP
            BEGIN
                UPDATE APPS.JDR_ATTRIBUTES
                   SET ATT_VALUE = L_C1.new_att_value
                 WHERE ROWID = L_C1.ROW_ID;

                L_COUNT := L_COUNT + 1;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO oaf_settings;

                    err_num := SQLCODE;
                    err_msg := SUBSTR (SQLERRM, 1, 100);

                    build_log (
                           '                Failed in '
                        || procedure_name
                        || ' '
                        || err_num
                        || ' '
                        || err_msg);

                    p_result := fail;

                    RETURN;
            END;
        END LOOP;

        COMMIT;

        build_log (
               '                  '
            || TO_CHAR (L_COUNT)
            || ' records were updated');
        build_log ('                  update_oaf_settings successfully');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;


    PROCEDURE update_docuware_lookup (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_docuware_lookup';
        L_COUNT          NUMBER;

        --EBA-54156-update docuware urls/guids based on quality plan
        CURSOR c1 IS
            SELECT flv.ROWID     AS row_id,
                   flv.description,
                   db.name,
                   flv.language,
                   flv.tag,
                   flv.meaning,
                   /*CASE
                       WHEN flv.description LIKE 'https://docuware%'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'https://docuwaredev'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'https://docuwaretest'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'https://docuwareqa'
                               ELSE
                                   'https://docuwaredev'
                           END
                       WHEN flv.description LIKE
                                'https://erpapp-internal%'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'https://erpapp-internal.dev'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'https://erpapp-internal.test'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'https://erpapp-internal.stage'
                               ELSE
                                   'https://erpapp-internal.dev'
                           END
                   END
                || SUBSTR (flv.description,
                           (INSTR (flv.description, '.garmin.com')))*/
                   fc_url        AS new_description
              FROM apps.FND_LOOKUP_VALUES           flv,
                  -- v$database                       db, --commented for version 1.0
                  (select apps.xx_db_util.get_dbname name from dual) db, -- added for version 1.0
                   apps.Q_DOCUWARE_VALUE_ENV_MAP_V  qp
             WHERE     flv.lookup_type = qp.ui_type --XX_DOCUWARE_URLS or XX_DOCUWARE_FC_GUID
                   AND db.name = qp.db_instance                  --db_instance
                   AND (   flv.attribute13 = qp.org_id
                        OR flv.attribute13 IS NULL) --org id (NULL for APInvoice/Dropzone)
                   AND NVL (tag, REPLACE (flv.meaning, '-' || db.name, '')) =
                       qp.ui_type_code   --APInvoice/Dropzone not based on tag
                   AND flv.lookup_type = 'XX_DOCUWARE_URLS'
                   --AND flv.enabled_flag = 'Y'
                   --AND NVL (flv.end_date_active, SYSDATE + 1) > SYSDATE
                   AND (   flv.description LIKE 'https://docuware%'
                        OR flv.description LIKE 'https://erpapp-internal%')
            UNION ALL
            SELECT flv.ROWID     AS row_id,
                   flv.description,
                   db.name,
                   flv.language,
                   flv.tag,
                   flv.meaning,
                   fc_guid       AS new_description
              FROM apps.FND_LOOKUP_VALUES           flv,
                   -- v$database                       db, --commented for version 1.0
                  (select apps.xx_db_util.get_dbname name from dual) db, -- added for version 1.0
                   apps.Q_DOCUWARE_VALUE_ENV_MAP_V  qp
             WHERE     flv.lookup_type = qp.ui_type --XX_DOCUWARE_URLS or XX_DOCUWARE_FC_GUID
                   AND db.name = qp.db_instance                  --db_instance
                   AND flv.tag = qp.org_id                            --org id
                   AND flv.lookup_code = qp.ui_type_code
                   AND flv.lookup_type = 'XX_DOCUWARE_FC_GUID';
    BEGIN
        build_log (p_step || ' update_docuware_lookup begin...');

        SAVEPOINT docuware_lookups;

        L_COUNT := 0;

        FOR L_C1 IN C1
        LOOP
            BEGIN
                UPDATE apps.FND_LOOKUP_VALUES
                   SET description = L_C1.new_description
                 WHERE ROWID = L_C1.ROW_ID;

                L_COUNT := L_COUNT + 1;
            EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK TO docuware_lookup;

                    err_num := SQLCODE;
                    err_msg := SUBSTR (SQLERRM, 1, 100);

                    build_log (
                           '                Failed in '
                        || procedure_name
                        || ' '
                        || err_num
                        || ' '
                        || err_msg);

                    p_result := fail;

                    RETURN;
            END;
        END LOOP;

        COMMIT;

        build_log (
               '                  '
            || TO_CHAR (L_COUNT)
            || ' records were updated');
        build_log ('                  update_docuware_lookup successfully');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;

    -- sample query for profiles.
    --SELECT fpot.USER_PROFILE_OPTION_NAME,
    --       fpo.profile_option_name,
    --       fpov.profile_option_value,
    --       fpo.profile_option_id,
    --       fpov.level_id,
    --       CASE
    --          WHEN fpov.level_id = 10001 THEN 'SITE'
    --          WHEN fpov.level_id = 10002 THEN 'APPL'
    --          WHEN fpov.level_id = 10003 THEN 'RESP'
    --          WHEN fpov.level_id = 10004 THEN 'USER'
    --          WHEN fpov.level_id = 10005 THEN 'SERVER'
    --          WHEN fpov.level_id = 10006 THEN 'ORG'
    --          WHEN fpov.level_id = 10007 THEN 'SERVRESP'
    --       END
    --          AS LEVEL_NAME,
    --       fpov.level_value,
    --       fpov.LEVEL_VALUE_APPLICATION_ID,
    --       CASE
    --          WHEN fpov.level_id = 10002
    --          THEN
    --             (SELECT fa.APPLICATION_NAME FA
    --                FROM apps.fnd_application_vl FA
    --               WHERE fa.application_id = fpov.level_value)
    --          WHEN fpov.level_id = 10003
    --          THEN
    --             (SELECT fr.responsibility_key
    --                FROM apps.fnd_responsibility fr
    --               WHERE     fr.responsibility_id = fpov.level_value
    --                     AND fr.application_id = fpov.LEVEL_VALUE_APPLICATION_ID)
    --          WHEN fpov.level_id = 10004
    --          THEN
    --             (SELECT fu.user_name
    --                FROM apps.fnd_user fu
    --               WHERE fu.user_id = fpov.level_value)
    --          WHEN fpov.level_id = 10006
    --          THEN
    --             (SELECT xle.OPERATING_UNIT_CODE
    --                FROM APPS.XX_LEGAL_ENTITY_V xle
    --               WHERE xle.organization_id = fpov.level_value)
    --       END
    --          NAME
    --  FROM apps.fnd_profile_options fpo,
    --       apps.fnd_profile_option_values fpov,
    --       apps.FND_PROFILE_OPTIONS_TL fpot
    -- WHERE     fpo.profile_option_id = fpov.profile_option_id
    --       AND fpot.PROFILE_OPTION_NAME = fpo.PROFILE_OPTION_NAME
    --       AND fpot.LANGUAGE = USERENV ('LANG')
    --       AND fpo.profile_option_name = 'XXIBY_HOP_SECURE_TOKENIZATION_URL'
    --
    PROCEDURE update_profile_value (p_step                     VARCHAR2,
                                    p_result               OUT VARCHAR2,
                                    p_profile_name             VARCHAR2,
                                    p_profile_value            VARCHAR2,
                                    p_level_name               VARCHAR2,
                                    p_level_value              VARCHAR2,
                                    p_level_value_app_id       VARCHAR2,
                                    p_level_value2             VARCHAR2)
    IS
        err_num                 NUMBER;
        err_msg                 VARCHAR (100);
        procedure_name          VARCHAR2 (200) := 'update_profile_value';
        l_profileLevelEnabled   VARCHAR2 (1) := NULL;
    BEGIN
        build_log (
               p_step
            || ' '
            || 'Update Profile '
            || p_profile_name
            || ' to Value...'
            || p_profile_value
            || ' at '
            || p_level_name
            || ' level '
            || p_level_value);

        IF apps.fnd_profile.save (p_profile_name,
                                  p_profile_value,
                                  p_level_name, --can be SITE, APPL, RESP,USER
                                  p_level_value, --level value to be set ex. user id for USER level
                                  p_level_value_app_id, --used for RESP and SERVRESP level Resp Application_id
                                  p_level_value2 -- second level that we are setting at.
                                                )
        THEN
            build_log (
                   '                  '
                || 'Update the profile to '
                || p_profile_value
                || ' successfully for '
                || p_profile_name
                || ' at '
                || p_level_name
                || ' level');

            COMMIT;
        ELSE
            build_log (
                   '  Fail to update the profile to '
                || p_profile_value
                || '  for '
                || p_profile_name
                || ' at '
                || p_level_name
                || ' level');

            BEGIN
                SELECT DECODE (p_level_name,
                               'USER', user_enabled_flag,
                               'RESP', resp_enabled_flag,
                               'APPL', app_enabled_flag,
                               'SERVER', server_enabled_flag,
                               'ORG', org_enabled_flag,
                               'SERVRESP', serverresp_enabled_flag,
                               'SITE', site_enabled_flag)
                  INTO l_profileLevelEnabled
                  FROM APPS.fnd_profile_options
                 WHERE PROFILE_OPTION_NAME = p_profile_name;
            EXCEPTION
                WHEN OTHERS
                THEN
                    l_profileLevelEnabled := NULL;
            END;

            build_log (
                   '  Check Profile Enabled Flag for Level '
                || p_level_name
                || ' Enabled Flag Shows: '
                || l_profileLevelEnabled);
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;


    PROCEDURE update_be_rest_value (p_step                VARCHAR2,
                                    p_result          OUT VARCHAR2,
                                    p_be_rest_value       VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_be_rest_value';
    BEGIN
        SAVEPOINT update_be_rest_value;

        build_log (
               p_step
            || ' '
            || 'Update BE REST Link '
            || ' to Value...'
            || p_be_rest_value);

        UPDATE wf_event_subscriptions
           SET parameters = p_be_rest_value
         WHERE ACTION_CODE = 'INVOKE_REST_RG';

        COMMIT;
        build_log (
               '                  '
            || 'Successfully Updated BE REST Link '
            || ' to Value...'
            || p_be_rest_value);
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO update_be_rest_value;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            build_log (
                   ' Fail to Update BE REST Link  '
                || ' to Value...'
                || p_be_rest_value);

            RETURN;
    END;

    --Step1.74

    PROCEDURE update_wf_resource (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_wf_resource';
    BEGIN
        build_log (p_step || ' Update_wf_resource begin...');

        SAVEPOINT update_wf;

        BEGIN
            UPDATE apps.wf_resources
               SET text = 'FND_RESP|SYSADMIN|SYSTEM_ADMINISTRATOR|STANDARD'
             WHERE name = 'WF_ADMIN_ROLE';

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
            COMMIT;

            build_log ('                  Update_wf_resource successfully');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO update_wf;
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;
    END;

    --This step is only required if this clone is from ORBIT: 1.72

    PROCEDURE update_shipping_doc_set (p_step         VARCHAR2,
                                       p_result   OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_shipping_doc_set';

        TYPE tt_id IS TABLE OF NUMBER
            INDEX BY PLS_INTEGER;

        vt_id            tt_id;
        vn_row           NUMBER;
    BEGIN
        build_log (p_step || ' update_shipping_doc_set begin...');

        SAVEPOINT update_sd;

          SELECT report_set_id
            BULK COLLECT INTO vt_id
            FROM apps.wsh_report_sets
           WHERE     EXISTS
                         (SELECT 'usage_type'
                            FROM apps.wsh_lookups
                           WHERE     lookup_type = 'REPORT_USAGE'
                                 AND lookup_code = wsh_report_sets.usage_code)
                 AND (name LIKE '%')
        ORDER BY name;

        FORALL vn_row IN vt_id.FIRST .. vt_id.LAST
            UPDATE apps.wsh_report_set_lines
               SET number_of_copies = 0,
                   last_update_date = SYSDATE,
                   last_updated_by = 0
             WHERE report_set_id = vt_id (vn_row) AND number_of_copies > 0;

        COMMIT;
        build_log ('                  update_shipping_doc_set successfully');
    EXCEPTION
        WHEN OTHERS
        THEN
            ROLLBACK TO update_sd;

            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;

            RETURN;
    END;

    --Set up privileges for the XXXX  User Account:Step1.76

    PROCEDURE grant_privileges (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num                      NUMBER;
        err_msg                      VARCHAR (100);
        procedure_name               VARCHAR2 (200) := 'grant_privileges';
        grant_privileges_statement   VARCHAR2 (300);
    BEGIN
        build_log (p_step || ' grant_privileges begin...');

        grant_privileges_statement :=
            ' grant select, update, insert, delete on apps.eng_eng_changes_interface to garmin ';

        build_log ('                  ' || grant_privileges_statement);

        EXECUTE IMMEDIATE grant_privileges_statement;

        grant_privileges_statement :=
            ' grant select, update, insert, delete on apps.eng_eco_revisions_interface to garmin  ';

        build_log ('                  ' || grant_privileges_statement);

        EXECUTE IMMEDIATE grant_privileges_statement;

        grant_privileges_statement :=
            ' grant select, update, insert, delete on apps.eng_revised_items_interface to garmin  ';

        build_log ('                  ' || grant_privileges_statement);

        EXECUTE IMMEDIATE grant_privileges_statement;

        grant_privileges_statement :=
            ' grant select on apps.wsh_delivery_assignments to web_orders  ';

        build_log ('                  ' || grant_privileges_statement);

        EXECUTE IMMEDIATE grant_privileges_statement;

        build_log ('                  ' || 'grant_privileges successfully');
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;

    PROCEDURE create_plan_links (p_step               VARCHAR2,
                                 p_garmin_pass        VARCHAR2,
                                 p_apps_pass          VARCHAR2,
                                 p_selapps_pass       VARCHAR2,
                                 p_result         OUT VARCHAR2)
    IS
        err_num                NUMBER;
        err_msg                VARCHAR (100);
        procedure_name         VARCHAR2 (200) := 'create_plan_links';
        create_dbl_statement   VARCHAR2 (300);
        v_db_name              VARCHAR2 (200);
        v_db_link_name         VARCHAR2 (200);
        drop_dbl_statement     VARCHAR2 (300);
    BEGIN
        SELECT name,
               DECODE (name,
                       'ORBPAT', 'PLNDEV',
                       'ORBDEV', 'PLNDEV',
                       'ORBTST', 'PLNTST',
                       'ORBQA', 'PLNQA')
          INTO v_db_name, v_db_link_name
         -- FROM v$database; -- commented for version 1.0
                FROM  (select apps.xx_db_util.get_dbname name from dual) db ;-- added for version 1.0

        build_log (
               p_step
            || ' create_plan_links in '
            || v_db_name
            || ' to '
            || v_db_link_name
            || ' begin...');

        IF v_db_link_name IS NOT NULL
        THEN
            drop_dbl_statement := ' drop database link to_plan.garmin.com';

            build_log ('                  ' || drop_dbl_statement);
            create_dbl_statement :=
                   ' create database link to_plan.garmin.com connect to apps identified by '
                || p_apps_pass
                || ' using '''
                || v_db_link_name
                || '''';

            build_log ('                  ' || create_dbl_statement);
            apps.xx_cre_db_lnk (drop_dbl_statement,
                                create_dbl_statement,
                                p_result);
            create_dbl_statement :=
                   ' create database link to_plan.garmin.com connect to garmin identified by '
                || p_garmin_pass
                || ' using '''
                || v_db_link_name
                || '''';

            build_log ('                  ' || create_dbl_statement);
            garmin.xx_cre_db_lnk (drop_dbl_statement,
                                  create_dbl_statement,
                                  p_result);
            create_dbl_statement :=
                   ' create database link to_plan.garmin.com connect to selapps identified by '
                || p_selapps_pass
                || ' using '''
                || v_db_link_name
                || '''';

            build_log ('                  ' || create_dbl_statement);
            selapps.xx_cre_db_lnk (drop_dbl_statement,
                                   create_dbl_statement,
                                   p_result);
            build_log (
                '                  ' || 'create_plan_links successfully');
        ELSE
            build_log (
                '                  ' || 'No plan database links are required');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;


    PROCEDURE create_ascp_links (p_step               VARCHAR2,
                                 p_garmin_pass        VARCHAR2,
                                 p_apps_pass          VARCHAR2,
                                 p_selapps_pass       VARCHAR2,
                                 p_result         OUT VARCHAR2)
    IS
        err_num                NUMBER;
        err_msg                VARCHAR (100);
        procedure_name         VARCHAR2 (200) := 'create_ascp_links';
        create_dbl_statement   VARCHAR2 (300);
        v_db_name              VARCHAR2 (200);
        v_db_link_name         VARCHAR2 (200);
        drop_dbl_statement     VARCHAR2 (300);
    BEGIN
        SELECT name,
               DECODE (name,
                       'ORBPAT', 'PLNDEV',
                       'ORBDEV', 'PLNDEV',
                       'ORBTST', 'PLNTST',
                       'ORBQA', 'PLNQA')
          INTO v_db_name, v_db_link_name
          FROM
          --v$database; -- commented for version 1.0
          (select apps.xx_db_util.get_dbname name from dual) db ;-- added for version 1.0

        build_log (
               p_step
            || ' create_ascp_links in '
            || v_db_name
            || ' to '
            || v_db_link_name
            || ' begin...');

        IF v_db_link_name IS NOT NULL
        THEN
            drop_dbl_statement := ' drop database link to_ascp.garmin.com';

            build_log ('                  ' || drop_dbl_statement);
            create_dbl_statement :=
                   ' create database link to_ascp.garmin.com connect to apps identified by '
                || p_apps_pass
                || ' using '''
                || v_db_link_name
                || '''';

            build_log ('                  ' || create_dbl_statement);
            -- db link under apps schema
            apps.xx_cre_db_lnk (drop_dbl_statement,
                                create_dbl_statement,
                                p_result);
            create_dbl_statement :=
                   ' create database link to_ascp.garmin.com connect to garmin identified by '
                || p_garmin_pass
                || ' using '''
                || v_db_link_name
                || '''';

            build_log ('                  ' || create_dbl_statement);
            -- db link under garmin schema
            garmin.xx_cre_db_lnk (drop_dbl_statement,
                                  create_dbl_statement,
                                  p_result);
            create_dbl_statement :=
                   ' create database link to_ascp.garmin.com connect to selapps identified by '
                || p_selapps_pass
                || ' using '''
                || v_db_link_name
                || '''';

            build_log ('                  ' || create_dbl_statement);
            -- db link under apps selapps
            selapps.xx_cre_db_lnk (drop_dbl_statement,
                                   create_dbl_statement,
                                   p_result);

            build_log (
                '                  ' || 'create_ascp_links successfully');
        ELSE
            build_log (
                '                  ' || 'No ascp database links are required');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;

    PROCEDURE create_agile_links (p_step                     VARCHAR2,
                                  p_agile_garmin_pass        VARCHAR2,
                                  p_agile_apps_pass          VARCHAR2,
                                  p_agile_selapps_pass       VARCHAR2,
                                  p_result               OUT VARCHAR2)
    IS
        err_num                NUMBER;
        err_msg                VARCHAR (100);
        procedure_name         VARCHAR2 (200) := 'create_agile_links';
        create_dbl_statement   VARCHAR2 (300);
        v_db_name              VARCHAR2 (200);
        v_db_link_name         VARCHAR2 (200);
        drop_dbl_statement     VARCHAR2 (300);
    BEGIN
        SELECT name,
               DECODE (name,
                       'ORBIT', 'AGPRDN',
                       'ORBQA', 'AGQAN',
                       'ORBTST', 'AGTST',
                       'ORBDEV', 'AGDEV',
                       'ORBPAT', 'AGDEV')
          INTO v_db_name, v_db_link_name
          FROM --v$database;
          (select apps.xx_db_util.get_dbname name from dual) db;

        build_log (
               p_step
            || ' create_agile_links in '
            || v_db_name
            || ' to '
            || v_db_link_name
            || ' begin...');

        IF v_db_link_name IS NOT NULL
        THEN
            drop_dbl_statement := ' drop database link to_agile.garmin.com';

            build_log ('                  ' || drop_dbl_statement);

            create_dbl_statement :=
                   ' create database link to_agile.garmin.com connect to agile identified by '
                || p_agile_apps_pass
                || ' using '''
                || v_db_link_name
                || '''';
            build_log ('                  ' || create_dbl_statement);
            -- db link under apps schema
            apps.xx_cre_db_lnk (drop_dbl_statement,
                                create_dbl_statement,
                                p_result);

            create_dbl_statement :=
                   ' create database link to_agile.garmin.com connect to agile identified by '
                || p_agile_garmin_pass
                || ' using '''
                || v_db_link_name
                || '''';
            build_log ('                  ' || create_dbl_statement);
            -- db link under garmin schema
            garmin.xx_cre_db_lnk (drop_dbl_statement,
                                  create_dbl_statement,
                                  p_result);

            create_dbl_statement :=
                   ' create database link to_agile.garmin.com connect to selapps identified by '
                || p_agile_selapps_pass
                || ' using '''
                || v_db_link_name
                || '''';
            build_log ('                  ' || create_dbl_statement);
            -- db link under selapps schema
            selapps.xx_cre_db_lnk (drop_dbl_statement,
                                   create_dbl_statement,
                                   p_result);
            build_log (
                '                  ' || 'create_agile_links successfully');
        ELSE
            build_log (
                   '                  '
                || 'No agile database links are required');
        END IF;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '  Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            p_result := fail;
            RETURN;
    END;

    --Workflow Background Process

    PROCEDURE schedule_fndwfbg_daily (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'SYSTEM_ADMINISTRATOR';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
    BEGIN
        --Start Workflow Background Engine Process
        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (p_step || ' Schedule Workflow Background Process daily');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            -- Set the repeat interval to 1 day for the request
            b_set_interval :=
                fnd_request.set_repeat_options (repeat_time       => NULL,
                                                repeat_interval   => 1,
                                                repeat_unit       => 'DAYS',
                                                repeat_type       => 'START',
                                                repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'FND',
                                            program       => 'FNDWFBG',
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE,
                                            argument1     => NULL,
                                            argument2     => NULL,
                                            argument3     => NULL,
                                            argument4     => 'Y',
                                            argument5     => 'Y',
                                            argument6     => 'Y');

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully '
                    || ' Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    --Workflow Background Process

    PROCEDURE schedule_fndwfbg_5_minutes (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'SYSTEM_ADMINISTRATOR';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
    BEGIN
        --Start Workflow Background Engine Process

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
            p_step || ' Schedule Workflow Background Process every 5 minutes');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            -- Set the repeat interval to 5 minutes for the request
            b_set_interval :=
                fnd_request.set_repeat_options (
                    repeat_time       => NULL,
                    repeat_interval   => 5,
                    repeat_unit       => 'MINUTES',
                    repeat_type       => 'START',
                    repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'FND',
                                            program       => 'FNDWFBG',
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE,
                                            argument1     => NULL,
                                            argument2     => NULL,
                                            argument3     => NULL,
                                            argument4     => 'Y',
                                            argument5     => 'Y',
                                            argument6     => 'N');

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;
                build_log (
                       '                  '
                    || 'Request submitted sucessfully ''Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    --Purge Obsolete Workflow Runtime Data

    PROCEDURE schedule_fndwfpr (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'SYSTEM_ADMINISTRATOR';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60) := 'FNDWFPR'; --Purge Obsolete Workflow Runtime Data
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);

        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
            p_step || ' Schedule Purge Obsolete Workflow Runtime Data daily');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            b_set_interval :=
                fnd_request.set_repeat_options (repeat_time       => NULL,
                                                repeat_interval   => 1,
                                                repeat_unit       => 'DAYS',
                                                repeat_type       => 'START',
                                                repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'FND',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE,
                                            argument1     => NULL,
                                            argument2     => NULL,
                                            argument3     => '30',
                                            argument4     => 'TEMP',
                                            argument5     => 'N',
                                            argument6     => 500,
                                            argument7     => 'N');

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully '
                    || 'Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    --Workflow Control Queue Cleanup

    PROCEDURE schedule_fndwfbes_control_qc (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'SYSTEM_ADMINISTRATOR';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60)
                                   := 'FNDWFBES_CONTROL_QUEUE_CLEANUP'; --Workflow Control Queue Cleanup
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);

        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
            p_step || ' Schedule Workflow Control Queue Cleanup Daily');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            b_set_interval :=
                fnd_request.set_repeat_options (repeat_time       => NULL,
                                                repeat_interval   => 1,
                                                repeat_unit       => 'DAYS',
                                                repeat_type       => 'START',
                                                repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'FND',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE);

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully '
                    || 'Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    ---Purge Signon Audit data

    PROCEDURE schedule_fndscprg (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'SYSTEM_ADMINISTRATOR';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60) := 'FNDSCPRG'; --Purge Signon Audit data
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);

        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
               p_step
            || ' Schedule Purge Signon Audit data Once with default parameter');

        BEGIN
            n_req_id :=
                fnd_request.submit_request (
                    application   => 'FND',
                    program       => 'FNDSCPRG',     --Purge Signon Audit data
                    start_time    => SYSDATE,
                    sub_request   => FALSE,
                    argument1     => TO_CHAR (SYSDATE, 'yyyy/mm/dd hh:mi:ss'));

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully '
                    || 'Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;

        build_log (
               '                  '
            || ' Schedule Purge Signon Audit data every 7 days to purge all Signon Audit data that is older than 14 days');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            b_set_interval :=
                fnd_request.set_repeat_options (repeat_time       => NULL,
                                                repeat_interval   => 7,
                                                repeat_unit       => 'DAYS',
                                                repeat_type       => 'START',
                                                repeat_end_time   => NULL,
                                                increment_dates   => 'Y');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (
                    application   => 'FND',
                    program       => v_cur_exe_name, --Purge Signon Audit data
                    start_time    => SYSDATE,
                    sub_request   => FALSE,
                    argument1     =>
                        TO_CHAR (SYSDATE - 14, 'yyyy/mm/dd hh:mi:ss'));

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully '
                    || 'Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    --Purge Concurrent Request and/or Manager Data

    PROCEDURE schedule_fndcppur (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'SYSTEM_ADMINISTRATOR';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60) := 'FNDCPPUR'; --Purge Concurrent Request and/or Manager Data
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);

        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
               p_step
            || ' Schedule Purge Concurrent Request and/or Manager Data Once: mode=1');

        --run the program once first
        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'FND',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE,
                                            argument1     => 'ALL',
                                            argument2     => 'Age',
                                            argument3     => 1,      --mode =1
                                            argument4     => NULL,
                                            argument5     => NULL,
                                            argument6     => NULL,
                                            argument7     => NULL,
                                            argument8     => NULL,
                                            argument9     => NULL,
                                            argument10    => NULL,
                                            argument11    => NULL,
                                            argument12    => 'Y',
                                            argument13    => 'Y');



            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully '
                    || 'Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;

        build_log (
               '                  '
            || 'Schedule Purge Concurrent Request and/or Manager Data every 7 days: mode=60');

        --run the program every 7 days

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            b_set_interval :=
                fnd_request.set_repeat_options (repeat_time       => NULL,
                                                repeat_interval   => 7,
                                                repeat_unit       => 'DAYS',
                                                repeat_type       => 'START',
                                                repeat_end_time   => NULL,
                                                increment_dates   => 'Y');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'FND',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE,
                                            argument1     => 'ALL',
                                            argument2     => 'Age',
                                            argument3     => 60,   --mode = 60
                                            argument4     => NULL,
                                            argument5     => NULL,
                                            argument6     => NULL,
                                            argument7     => NULL,
                                            argument8     => NULL,
                                            argument9     => NULL,
                                            argument10    => NULL,
                                            argument11    => NULL,
                                            argument12    => 'Y',
                                            argument13    => 'Y');

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully ''Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    --Cost Manager

    PROCEDURE schedule_cmctcm_5_minutes (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'INVENTORY_GI';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60) := 'CMCTCM';       --Cost Manager
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);

        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        --Start Workflow Background Engine Process
        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (p_step || ' Schedule Cost Manager every 5 minutes');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            -- Set the repeat interval to 5 minutes for the request

            b_set_interval :=
                fnd_request.set_repeat_options (
                    repeat_time       => NULL,
                    repeat_interval   => 5,
                    repeat_unit       => 'MINUTES',
                    repeat_type       => 'START',
                    repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'BOM',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE);

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully ''Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    --WIP Move Transaction Manager

    PROCEDURE schedule_wictms_5_minutes (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'INVENTORY_GI';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60) := 'WICTMS'; --WIP Move Transaction Manager
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);



        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;



        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
               p_step
            || ' Schedule WIP Move Transaction Manager every 5 minutes');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            -- Set the repeat interval to 5 minutes for the request

            b_set_interval :=
                fnd_request.set_repeat_options (
                    repeat_time       => NULL,
                    repeat_interval   => 5,
                    repeat_unit       => 'MINUTES',
                    repeat_type       => 'START',
                    repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'WIP',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE);

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully ''Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    PROCEDURE xx_validate (P_RESULT OUT VARCHAR2)
    AS
        lv_contact_points_res   NUMBER;
        lv_vend_sites_res       NUMBER;
        lv_fnd_user_res         NUMBER;
        lv_hz_parties_res       NUMBER;
        lv_alert_res            NUMBER;
        lv_concurrent_res       NUMBER;
        procedure_name          VARCHAR2 (200) := 'XX_VALIDATE';
        v_db_name               VARCHAR2 (100);
    BEGIN
        SELECT name INTO v_db_name
        FROM
         --v$database;
         (select apps.xx_db_util.get_dbname name from dual) db;


        build_log (
               procedure_name
            || ' begin...'
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        BEGIN
            SELECT COUNT (1)
              INTO lv_vend_sites_res
              FROM apps.AP_SUPPLIER_SITES_ALL
             WHERE     email_address IS NOT NULL
                   AND (       UPPER (email_address) NOT LIKE 'XX_%'
                           AND UPPER (email_address) NOT LIKE '%GARMIN%'
                        OR NVL (REGEXP_COUNT (email_address,
                                              '@',
                                              1,
                                              'i'),
                                0) > 1);
        EXCEPTION
            WHEN OTHERS
            THEN
                build_log (
                    'Exception while validating the Vendor Sites (AP_SUPPLIER_SITES_ALL) email. Please check to confirm that the vendor sites email addresses have been scrubbed!!!');
                --RETURN FALSE;
                P_RESULT := 'F';
        END;

        BEGIN
            SELECT COUNT (1)
              INTO lv_contact_points_res
              FROM apps.hz_contact_points hcp
             WHERE     hcp.email_address IS NOT NULL
                   AND (       UPPER (hcp.email_address) NOT LIKE 'XX_%'
                           AND UPPER (hcp.email_address) NOT LIKE '%GARMIN%'
                        OR NVL (REGEXP_COUNT (hcp.email_address,
                                              '@',
                                              1,
                                              'i'),
                                0) > 1);
        EXCEPTION
            WHEN OTHERS
            THEN
                Build_log (
                    'Exception while validating the hz_contact_points email. Please check to confirm that the hz_contact_points have been scrubbed!!!');
                P_RESULT := 'F';
        END;

        BEGIN
            SELECT COUNT (1)
              INTO lv_fnd_user_res
              FROM apps.fnd_user p
             WHERE     p.email_address IS NOT NULL
                   AND UPPER (p.email_Address) NOT LIKE 'XX_%'
                   AND UPPER (p.email_Address) NOT LIKE '%GARMIN%';
        EXCEPTION
            WHEN OTHERS
            THEN
                Build_log (
                    'Exception while validating the Fnd User email. Please check to confirm that the vendor sites email addresses have been scrubbed!!!');
                P_RESULT := 'F';
        END;

        BEGIN
            SELECT COUNT (1)
              INTO lv_hz_parties_res
              FROM apps.hz_parties
             WHERE     email_address IS NOT NULL
                   AND (       UPPER (email_address) NOT LIKE 'XX_%'
                           AND UPPER (email_address) NOT LIKE '%GARMIN%'
                        OR NVL (REGEXP_COUNT (email_address,
                                              '@',
                                              1,
                                              'i'),
                                0) > 1);
        EXCEPTION
            WHEN OTHERS
            THEN
                Build_log (
                    'Exception while validating the hz_parties. Please check to confirm that the hz_parties have been scrubbed!!!');
                P_RESULT := 'F';
        END;

        BEGIN
            SELECT COUNT (1)
              INTO lv_alert_res
              FROM apps.alr_alerts
             WHERE     enabled_flag = 'Y'
                   AND UPPER (alert_name) NOT LIKE '%INVALID%OBJECTS%';
        EXCEPTION
            WHEN OTHERS
            THEN
                Build_log (
                    'Exception while validating the apps.alr_alerts. Please check to confirm that the apps.alr_alerts have been dis-abled!!!');
                P_RESULT := 'F';
        END;

        -- sample query of pending concurrent requests
        --SELECT wrk.request_id,
        --       DECODE (wrk.phase_code,
        --               'C', 'Complete',
        --               'I', 'Inactive',
        --               'P', 'Pending',
        --               'R', 'Running',
        --               'Unknown')
        --           phase_code,
        --       DECODE (wrk.status_code,
        --               'C', 'Normal',
        --               'D', 'Cancelled',
        --               'E', 'Error',
        --               'F', 'Scheduled',
        --               'I', 'Normal',
        --               'M', 'No Manager',
        --               'Q', 'Standby',
        --               'R', 'Normal',
        --               'S', 'Suspended',
        --               'T', 'Terminating',
        --               'U', 'Disabled',
        --               'W', 'Paused',
        --               'Z', 'Waiting',
        --               'Unknown')
        --           status_code,
        --       prg.concurrent_program_id,
        --       prg.concurrent_program_name,
        --       cpt.USER_CONCURRENT_PROGRAM_NAME
        --  FROM apps.fnd_concurrent_programs     prg,
        --       apps.fnd_concurrent_requests     wrk,
        --       apps.fnd_concurrent_programs_tl  cpt
        -- WHERE     prg.application_id = wrk.program_application_id
        --       AND prg.concurrent_program_id = wrk.concurrent_program_id
        --       AND cpt.CONCURRENT_PROGRAM_ID(+) = wrk.concurrent_program_id
        --       AND cpt.SOURCE_LANG(+) = USERENV ('LANG')
        --       AND wrk.phase_code IN ('P', 'R');

        BEGIN
            SELECT COUNT (1)
              INTO lv_concurrent_res
              FROM apps.fnd_concurrent_programs  prg,
                   apps.fnd_concurrent_requests  wrk
             WHERE     prg.application_id = wrk.program_application_id
                   AND prg.concurrent_program_id = wrk.concurrent_program_id
                   AND wrk.phase_code IN ('P', 'R');
        EXCEPTION
            WHEN OTHERS
            THEN
                Build_log (
                    'Exception while validating the apps.fnd_concurrent_requests. Please check to confirm that the apps.fnd_concurrent_requests are not pending and running!!!');
                P_RESULT := 'F';
        END;

        IF lv_vend_sites_res > 0
        THEN
            build_log (
                'Email Addresses On the Vendor Sites (po_vendor_sites_all) have NOT Been Updated. Please check !!!');
            P_RESULT := 'F';
        END IF;

        IF lv_contact_points_res > 0
        THEN
            build_log (
                'Email Address On the hz_contact_points have NOT Been Updated. Please check !!!');
            P_RESULT := 'F';
        END IF;

        IF lv_fnd_user_res > 0
        THEN
            build_log (
                'Email Address On the FND Users (fnd_user) have NOT Been Updated. Please check !!!');
            P_RESULT := 'F';
        END IF;

        IF lv_hz_parties_res > 0
        THEN
            build_log (
                'Email Address On the hz_parties have NOT Been Updated. Please check !!!');
            P_RESULT := 'F';
        END IF;

        IF lv_alert_res > 0
        THEN
            build_log (
                'Alerts enabled On the alr_alerts have NOT Been disabled. Please check !!!');
            P_RESULT := 'F';
        END IF;

        IF lv_concurrent_res > 0
        THEN
            build_log (
                'Concurrents Programs are Pending or running. Please check !!!');
            P_RESULT := 'F';
        END IF;

        build_log (
               procedure_name
            || ' successfully completed '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       => ' Post Clone Log for ' || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_4_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    END;

    --Manager: Lot Move Transactions

    PROCEDURE schedule_wscmtm_5_minutes (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'INVENTORY_GI';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60) := 'WSCMTM'; --Manager: Lot Move Transactions
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);

        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
               p_step
            || ' Schedule Manager: Lot Move Transactions every 5 minutes');

        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            -- Set the repeat interval to 5 minutes for the request

            b_set_interval :=
                fnd_request.set_repeat_options (
                    repeat_time       => NULL,
                    repeat_interval   => 5,
                    repeat_unit       => 'MINUTES',
                    repeat_type       => 'START',
                    repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'WSM',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE);

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully ''Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    --Process transaction interface

    PROCEDURE schedule_inctcm_5_minutes (p_step VARCHAR2)
    IS
        b_set_interval         BOOLEAN := FALSE;
        b_init                 BOOLEAN;
        v_ret_status           VARCHAR2 (30);
        n_req_id               NUMBER;
        b_set_nls              BOOLEAN;
        b_set_mode             BOOLEAN;
        schedule_exception     EXCEPTION;
        submission_exception   EXCEPTION;
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_responsibility_key   VARCHAR2 (240) := 'INVENTORY_GI';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        v_cur_exe_name         VARCHAR2 (60) := 'INCTCM'; --Process transaction interface
        p_output               VARCHAR2 (2000);
    BEGIN
        is_program_running (v_cur_exe_name, p_output);

        IF p_output <> 'No'
        THEN
            build_log (p_step || ' ' || p_output);

            RETURN;
        END IF;

        b_set_mode := apps.fnd_submit.set_mode (FALSE);

        SELECT user_id
          INTO v_user_id
          FROM apps.fnd_user
         WHERE user_name = v_user_name;

        SELECT application_id, responsibility_id
          INTO v_application_id, v_responsibility_id
          FROM apps.fnd_responsibility_vl
         WHERE responsibility_key = v_responsibility_key;

        fnd_global.apps_initialize (user_id        => v_user_id,
                                    resp_id        => v_responsibility_id,
                                    resp_appl_id   => v_application_id);

        build_log (
               p_step
            || ' Schedule Process transaction interface every 5 minutes');



        BEGIN
            b_set_interval := fnd_request.set_options ('YES');

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;

            -- Set the repeat interval to 5 minutes for the request

            b_set_interval :=
                fnd_request.set_repeat_options (
                    repeat_time       => NULL,
                    repeat_interval   => 5,
                    repeat_unit       => 'MINUTES',
                    repeat_type       => 'START',
                    repeat_end_time   => NULL);

            IF NOT (b_set_interval)
            THEN
                RAISE schedule_exception;
            END IF;
        END;

        BEGIN
            n_req_id :=
                fnd_request.submit_request (application   => 'INV',
                                            program       => v_cur_exe_name,
                                            start_time    => SYSDATE,
                                            sub_request   => FALSE);

            IF NOT (n_req_id > 0)
            THEN
                RAISE submission_exception;
            ELSE
                COMMIT;

                build_log (
                       '                  '
                    || 'Request submitted sucessfully ''Request ID: '
                    || n_req_id);
            END IF;
        EXCEPTION
            WHEN schedule_exception
            THEN
                build_log (
                    'Error while setting the repeat interval for request submission.');
            WHEN submission_exception
            THEN
                build_log (
                    'Error while submitting the concurrent request, Workflow Background Process.');
            WHEN OTHERS
            THEN
                build_log ('Unknown error ' || SQLERRM);
        END;
    END;

    PROCEDURE disable_ci_lookup (p_step IN VARCHAR2, p_result OUT VARCHAR2)
    IS
    BEGIN
        build_log (
            p_step || ' Disable lookup XX_GARMIN_EMAIL_CI_CARRIER begin...');

        SAVEPOINT update_ci_email_call;

        BEGIN
            UPDATE apps.fnd_lookup_values
               SET enabled_flag = 'N'
             WHERE     lookup_type = 'XX_GARMIN_EMAIL_CI_CARRIER'
                   AND enabled_flag = 'Y';

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
            COMMIT;

            build_log (
                '                  disable_xx_garmin_email_ci_carrier successfully');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO update_ci_email_call;
                build_log (
                       '                Failed in disable_xx_garmin_email_ci_carrier '
                    || SQLCODE
                    || ' '
                    || SUBSTR (SQLERRM, 1, 100));

                p_result := fail;

                RETURN;
        END;
    END disable_ci_lookup;

    PROCEDURE diable_xx_proact_comm_enable (p_step         VARCHAR2,
                                            p_result   OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'diable_xx_proact_comm_enable';
    BEGIN
        build_log (
            p_step || ' Disable lookup XX_PROACT_COMM_ENABLE begin...');

        SAVEPOINT update_di;

        BEGIN
            UPDATE apps.fnd_lookup_values b
               SET b.enabled_flag = 'N'
             WHERE     b.lookup_type = 'XX_PROACT_COMM_ENABLE'
                   AND b.view_application_id = 660;

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
            COMMIT;

            build_log (
                '                  diable_xx_proact_comm_enable successfully');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO update_di;
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;
    END;


    PROCEDURE update_xxroyaltyimport_para (p_step           VARCHAR2,
                                           p_database       VARCHAR2,
                                           p_result     OUT VARCHAR2)
    IS
        err_num                NUMBER;
        err_msg                VARCHAR (100);
        procedure_name         VARCHAR2 (200) := 'update_xxroyaltyimport_para';
        v_archivingdirectory   VARCHAR2 (500);
        v_directory            VARCHAR2 (500);
    BEGIN
        build_log (
               p_step
            || ' update concurent program xxroyaltyimport default parameter values begin...');

        SAVEPOINT update_pa;

        BEGIN
            v_archivingdirectory :=
                   '/austin/data/interface/'
                || p_database
                || '/Brazil/Royalty_EFT/Archive/';

            v_directory :=
                   '/austin/data/interface/'
                || p_database
                || '/Brazil/Royalty_EFT/';

            build_log (
                   '                  updating the default value of parameter ArchivingDirectory to '
                || v_archivingdirectory);

            UPDATE fnd_descr_flex_column_usages b
               SET b.DEFAULT_VALUE = v_archivingdirectory
             WHERE     b.descriptive_flexfield_name = '$SRS$.XXROYALTYIMPORT'
                   AND b.end_user_column_name = 'ArchivingDirectory'
                   AND b.application_column_name = 'ATTRIBUTE2';

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
            COMMIT;

            build_log (
                   '                  updating the default value of parameter Directory to '
                || v_directory);

            UPDATE fnd_descr_flex_column_usages b
               SET b.DEFAULT_VALUE = v_directory
             WHERE     b.descriptive_flexfield_name = '$SRS$.XXROYALTYIMPORT'
                   AND b.end_user_column_name = 'Directory'
                   AND b.application_column_name = 'ATTRIBUTE1';

            build_log (
                   '                  '
                || SQL%ROWCOUNT
                || ' records were updated');
            COMMIT;

            build_log (
                '                  update_xxroyaltyimport_para successfully');
        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO update_pa;
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;
    END;

    PROCEDURE update_global_name (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num           NUMBER;
        err_msg           VARCHAR (100);
        procedure_name    VARCHAR2 (200) := 'update_global_name';
        v_database_name   VARCHAR2 (100);
        l_script          VARCHAR2 (400);
    BEGIN
        build_log (p_step || ' update_global_name begin...');

        SELECT name INTO v_database_name FROM (select apps.xx_db_util.get_dbname name from dual) ; -- added for version 1.0
        --v$database; -- commented for version 1.0

        BEGIN
            l_script :=
                   '  alter database rename global_name to "'
                || v_database_name
                || '.GARMIN.COM"';

            build_log ('                  ' || l_script);

            EXECUTE IMMEDIATE l_script;

            build_log ('                  update_global_name successfully');
        EXCEPTION
            WHEN OTHERS
            THEN
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

                RETURN;
        END;

        COMMIT;

        build_log ('                  update_global_name successfully');
    END;

    PROCEDURE update_function_param (p_step VARCHAR2, p_result OUT VARCHAR2)
    IS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'update_function_param';

        CURSOR c1 IS
          SELECT wau.tag db_name,
               garmin.xx_char_util.return_parse (wau.description, '|', 2) old_url,
               wau.meaning new_url,
               REPLACE (fff.parameters, garmin.xx_char_util.return_parse (wau.description, '|', 2), wau.meaning) new_parameters,
               fff.function_id,
               fff.web_host_name,
               fff.web_agent_name,
               fff.web_html_call,
               fff.web_encrypt_parameters,
               fff.web_secured,
               fff.web_icon,
               fff.object_id,
               fff.region_application_id,
               fff.region_code,
               fff.function_name,
               fff.application_id,
               fff.form_id,
               fff.TYPE,
               fff.user_function_name,
               fff.description,
               fff.maintenance_mode_support,
               fff.context_dependence,
               fff.jrad_ref_path
          FROM apps.fnd_lookup_values_vl wau,
          apps.fnd_form_functions_vl fff
          WHERE    wau.lookup_type = 'XX_WEB_APP_URLS'
               AND wau.enabled_flag = 'Y'
               AND TRUNC (SYSDATE) >= TRUNC (wau.start_date_active)
               AND TRUNC (SYSDATE) < TRUNC (NVL (wau.end_date_active, SYSDATE + 1))
               AND garmin.xx_char_util.return_parse (wau.description, '|', 1) = fff.function_name
               AND wau.tag IN
               --(SELECT name FROM v$database); -- commented from version 1.0
               (select apps.xx_db_util.get_dbname  from dual); -- added for version 1.0

    BEGIN
        build_log (p_step || ' Update_function_param begin...');

        SAVEPOINT update_function_param;

        BEGIN
        FOR r1 IN c1
        LOOP

        BEGIN
        FND_FORM_FUNCTIONS_PKG.UPDATE_ROW ( X_FUNCTION_ID              =>  r1.FUNCTION_ID,
                                               X_WEB_HOST_NAME         =>  r1.WEB_HOST_NAME, --null
                                            X_WEB_AGENT_NAME           =>  r1.WEB_AGENT_NAME, --null
                                            X_WEB_HTML_CALL            =>  r1.WEB_HTML_CALL,  --xxCustImport_Edge.htm
                                            X_WEB_ENCRYPT_PARAMETERS   =>  r1.WEB_ENCRYPT_PARAMETERS, --N
                                            X_WEB_SECURED              =>  r1.WEB_SECURED, --N
                                            X_WEB_ICON                 =>  r1.WEB_ICON, --null
                                            X_OBJECT_ID                =>  r1.OBJECT_ID, --null
                                            X_REGION_APPLICATION_ID    =>  r1.REGION_APPLICATION_ID, --null
                                            X_REGION_CODE              =>  r1.REGION_CODE, --null
                                            X_FUNCTION_NAME            =>  r1.FUNCTION_NAME, --XX_CUST_VALID_IMPORT_CZ
                                            X_APPLICATION_ID           =>  r1.APPLICATION_ID, --null
                                            X_FORM_ID                  =>  r1.FORM_ID, --null
                                            X_PARAMETERS               =>  r1.NEW_PARAMETERS, --replaced old_url with new_url in cursor
                                            X_TYPE                     =>  r1.TYPE, --INTEROPJSP
                                            X_USER_FUNCTION_NAME       =>  r1.USER_FUNCTION_NAME, --Czech TRADR Web UI
                                            X_DESCRIPTION              =>  r1.DESCRIPTION, --Czech Customer Tax Registration and Data Retrieval (TRADR) Web Application
                                            X_LAST_UPDATE_DATE         =>  SYSDATE,
                                            X_LAST_UPDATED_BY          =>  0, --SYSADMIN
                                            X_LAST_UPDATE_LOGIN        =>  0, --SYSADMIN
                                            X_MAINTENANCE_MODE_SUPPORT =>  r1.MAINTENANCE_MODE_SUPPORT, --NONE
                                            X_CONTEXT_DEPENDENCE       =>  r1.CONTEXT_DEPENDENCE, --RESP
                                            X_JRAD_REF_PATH            =>  r1.JRAD_REF_PATH --null
                                         );

                 build_log (
                       '                  '
                    || 'Function Parameters updated from '
                    || r1.old_url
                    || ' to '
                    || r1.new_url
                    || ' for function name '
                    || r1.function_name);

        EXCEPTION
        WHEN OTHERS THEN
                build_log (
                       '                  '
                    || 'Function Parameters not updated from '
                    || r1.old_url
                    || ' to '
                    || r1.new_url
                    || ' for function name '
                    || r1.function_name
                    || ' **Check lookup XX_WEB_APP_URLS entries.**');
        END;

        COMMIT;
        END LOOP;

            build_log ('                  Update_function_param end');

        EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK TO update_function_param;
                err_num := SQLCODE;
                err_msg := SUBSTR (SQLERRM, 1, 100);

                build_log (
                       '                Failed in '
                    || procedure_name
                    || ' '
                    || err_num
                    || ' '
                    || err_msg);

                p_result := fail;

        END;
    END update_function_param;

    PROCEDURE main (p_source_db       VARCHAR2,
                    p_garmin_pass     VARCHAR2,
                    p_apps_pass       VARCHAR2,
                    p_selapps_pass    VARCHAR2,
                    pr_source_db      VARCHAR2,
                    pr_garmin_pass    VARCHAR2,
                    pr_apps_pass      VARCHAR2,
                    pr_selapps_pass   VARCHAR2)
    IS
        p_result          VARCHAR2 (200);
        v_profile_value   VARCHAR2 (500);
        v_db_name         VARCHAR2 (100);
        v_db_clone_date   VARCHAR2 (100);
        v_web_form_host   VARCHAR2 (100);
        port_number       NUMBER;
        v_curr_user       VARCHAR2 (100);
        err_num           NUMBER;
        err_msg           VARCHAR (100);
        v_be_rest_value   VARCHAR2 (500);
    BEGIN
        DBMS_OUTPUT.enable (NULL);
        v_all_message := NULL;

        build_log ('You entered Clone Source Database as ' || p_source_db);
        build_log ('You entered Garmin Password as ' || p_garmin_pass);
        build_log ('You entered APPS Password as ' || p_apps_pass);
        build_log (
            'You entered SELAPPS Password as ' || p_selapps_pass || CHR (10));

        SELECT username
          INTO v_curr_user
          FROM sys.v_$session
         WHERE sid = (SELECT DISTINCT sid
                        FROM sys.v_$mystat);

        IF v_curr_user <> 'SYSTEM'
        THEN
            build_log (' You must login as SYSTEM, quit...');
            RETURN;
        END IF;

        IF p_source_db <> pr_source_db
        THEN
            build_log (
                ' You entered the wrong Source Database Name, quit...');
            RETURN;
        END IF;

        IF p_garmin_pass <> pr_garmin_pass
        THEN
            build_log (' You entered the wrong Garmin Password, quit...');
            RETURN;
        END IF;

        IF p_apps_pass <> pr_apps_pass
        THEN
            build_log (' You entered the wrong APPS Password, quit...');
            RETURN;
        END IF;


        IF p_selapps_pass <> pr_selapps_pass
        THEN
            build_log (' You entered the wrong SALAPPS Password, quit...');
            RETURN;
        END IF;

       -- SELECT name INTO v_db_name FROM v$database;

        select apps.xx_db_util.get_dbname INTO v_db_name from dual;

        SELECT TO_CHAR (resetlogs_time, 'mm/dd/yyyy')
          INTO v_db_clone_date
          FROM v$database
         WHERE ROWNUM = 1;

        build_log (
               TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss')
            || ' Post Clone from '
            || p_source_db
            || ' to '
            || v_db_name
            || ' start... ');


        build_log (' ');

        disable_concurrent_prog ('=====>Step 2', p_result);

        build_log (' ');

        enable_concurrent_prog ('=====>Step 3', p_result);

        build_log (' ');

        update_directories ('=====>Step 4', p_source_db, p_result);

        build_log (' ');

        -- FND: SMTP Host

        v_profile_value := 'smtptrusted.garmin.com';

        update_profile_value ('=====>Step 5',
                              p_result,
                              'FND_SMTP_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Garmin SMTP Server

        v_profile_value := 'smtptrusted.garmin.com';

        update_profile_value ('=====>Step 5.1',
                              p_result,
                              'GARMIN_SMTP_SERVER',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- IEX: SMTP Host

        v_profile_value := 'smtptrusted.garmin.com';

        update_profile_value ('=====>Step 5.2',
                              p_result,
                              'IEX_SMTP_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  IBY: ECAPP URL

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://orbdevr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://orbtstr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://orbqar12.garmin.com/OA_HTML/ibyecapp'
                   ELSE
                       NULL
               END
          INTO v_profile_value
        --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db ;-- added for version 1.0

        update_profile_value ('=====>Step 6',
                              p_result,
                              'IBY_ECAPP_URL',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');


        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://orbdevr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://orbtstr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://orbqar12.garmin.com/OA_HTML/ibyecapp'
                   ELSE
                       NULL
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        -- Profile:  ICX: Oracle Payment Server URL

        update_profile_value ('=====>Step 6a',
                              p_result,
                              'ICX_PAY_SERVER',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- start of post clone additions for APM

        -- XXIBY: Adyen HOP Tokenization URL

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/viewTokens'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
               END
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 6b',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Query to get application id
        --SELECT application_short_name,
        --       APPLICATION_NAME,
        --       application_id
        --  FROM apps.fnd_application_vl

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/tokenization'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
               END
          INTO v_profile_value
         --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        -- XXIBY: Adyen HOP Tokenization URL
        update_profile_value ('=====>Step 6c',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'APPL',
                              222,                  ---Receivables application
                              NULL,
                              NULL);

        build_log (' ');

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/tokenization'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/tokenization'
               END
          INTO v_profile_value
         --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        -- XXIBY: Adyen HOP Tokenization URL
        update_profile_value ('=====>Step 6d',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'APPL',
                              695,                              ---Collections
                              NULL,
                              NULL);

        build_log (' ');

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/viewTokens'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
               END
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        -- XXIBY: Adyen HOP Tokenization URL
        update_profile_value ('=====>Step 6e',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'APPL',
                              660,                         ---Order Management
                              NULL,
                              NULL);

        build_log (' ');

        -- End of post clone additions for APM

        -- Profile:  Database Wallet Directory

        SELECT '/acfsmounts/acfs1/wllet/' || LOWER (name)
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 6f',
                              p_result,
                              'FND_DB_WALLET_DIR',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Update Business Events REST Link

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'WFBES_REST_RESOURCE_BASE=https://servicesdev.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'WFBES_REST_RESOURCE_BASE=https://servicestest.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'WFBES_REST_RESOURCE_BASE=https://servicesstg.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
                   ELSE
                       'WFBES_REST_RESOURCE_BASE=https://servicesdev.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
               END
          INTO v_be_rest_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0



        update_be_rest_value ('=====>Step 6g', p_result, v_be_rest_value);

        -- End of REST link Change

        -- Update Garmin WSH Services Host

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://services-int-dev.garmin.com'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://services-int-test.garmin.com'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://services-int-stg.garmin.com'
                   ELSE
                       NULL
               END
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        -- Profile:  Garmin WSH Services Host

        update_profile_value ('=====>Step 6h',
                              p_result,
                              'XX_WSH_SERVICES_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://services-kcg-dev.garmin.com'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://servicestest.garmin.com'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://servicesstg.garmin.com'
                   ELSE
                       NULL
               END
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        -- Profile:  Garmin WSH Services Secondary Host

        update_profile_value ('=====>Step 6i',
                              p_result,
                              'XX_WSH_SERVICES_SEC_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Function Parameters:  XX_CUST_VALID_IMPORT_CZ, etc

        update_function_param (p_step => '=====>Step 6j',
                               p_result => p_result);

        build_log (' ');

        -- End of Garmin WSH Services Host

        -- Site Name

        v_profile_value :=
               v_db_name
            || ' - Cloned from the '
            || v_db_clone_date
            || ' '
            || UPPER (p_source_db)
            || ' Backup';

        update_profile_value ('=====>Step 7',
                              p_result,
                              'SITENAME',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Hide Diagnostics menu entry

        v_profile_value := 'N';
        update_profile_value ('=====>Step 8',
                              p_result,
                              'FND_HIDE_DIAGNOSTICS',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Utilities:Diagnostics

        v_profile_value := 'Y';
        update_profile_value ('=====>Step 8.1',
                              p_result,
                              'DIAGNOSTICS',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- AME:Installed

        v_profile_value := 'Y';

        update_profile_value ('=====>Step 9',
                              p_result,
                              'AME_INSTALLED_FLAG',
                              v_profile_value,
                              'APPL',
                              200,                      ---Payable application
                              NULL,
                              NULL);

        build_log (' ');

        --      SELECT HOST
        --        INTO v_web_form_host
        --        FROM apps.fnd_nodes
        --       WHERE support_forms = 'Y' AND support_web = 'Y' AND ROWNUM = 1;

        --      SELECT SUBSTR (
        --                TRIM (
        --                   TRANSLATE (fpov.profile_option_value,
        --                              'abcdefghijklmnopqrstuvwxyz://.ABCDEFGHIJKLMNOPQRSTUVWXYZ_',
        --                              ' ')),
        --                0,
        --                4)
        --                port
        --        INTO port_number
        --        FROM apps.fnd_profile_option_values fpov
        --       WHERE profile_option_id = '8017';
        --
        --      v_profile_value :=
        --         'http://' || v_web_form_host || '.garmin.com:' || port_number || '/dev60cgi/f60cgi?play=' || '&' || 'record=names';
        --
        --      update_profile_value ('=====>Step 10',
        --                            p_result,
        --                            'ICX_FORMS_LAUNCHER',
        --                            v_profile_value,
        --                            'USER',
        --                            16903,            --it is for the user TURNKEYUSER1, need to get port dynamically from Rinky
        --                            NULL,
        --                            NULL);
        --
        --      build_log (' ');
        --
        --      v_profile_value := 'http://' || v_web_form_host || '.garmin.com:' || port_number || '/';
        --
        --      update_profile_value ('=====>Step 10.1',
        --                            p_result,
        --                            'WF_MAIL_WEB_AGENT',
        --                            v_profile_value,
        --                            'SITE',
        --                            NULL,             --it is for the user TURNKEYUSER1, need to get port dynamically from Rinky
        --                            NULL,
        --                            NULL);
        --
        --      build_log (' ');
        --
        --      v_profile_value := '/' || v_db_name || '/applmgr/' || v_db_name || 'comn/html/cabo';
        --
        --      update_profile_value ('=====>Step 11',
        --                            p_result,
        --                            'BNE_UIX_PHYSICAL_DIRECTORY',
        --                            v_profile_value,
        --                            'SITE',
        --                            NULL,
        --                            NULL,
        --                            NULL);
        --
        --     build_log (' ');
        --

        -- ICX: Forms Launcher

        v_profile_value := NULL;

        update_profile_value ('=====>Step 10',
                              p_result,
                              'ICX_FORMS_LAUNCHER',
                              v_profile_value,
                              'USER',
                              0,                 --it is for the user SYSADMIN
                              NULL,
                              NULL);

        build_log (' ');

        -- WSH: BPEL Webservice URI for OTM
        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://olaxda-otmint01.garmin.com:8001/soa-infra/services/default'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://olaxta-otmint03.garmin.com:8001/soa-infra/services/default'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://olaxqa-otmint04.garmin.com:8001/soa-infra/services/default'
                   ELSE
                       'http://olaxda-otmint01.garmin.com:8001/soa-infra/services/default'
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        -- WSH: BPEL Webservice URI for OTM
        update_profile_value ('=====>Step 11.1',
                              p_result,
                              'WSH_OTM_OB_SERVICE_ENDPOINT',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- OTM: Servlet URI

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://otmdev637.garmin.com/GC3/glog.integration.servlet.WMServlet'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://otmtest637.garmin.com/GC3/glog.integration.servlet.WMServlet'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://otmqa637.garmin.com/GC3/glog.integration.servlet.WMServlet'
                   ELSE
                       'http://otmdev637.garmin.com/GC3/glog.integration.servlet.WMServlet'
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 11.2',
                              p_result,
                              'WSH_OTM_SERVLET_URI',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        update_fnd_user_email ('=====>Step 12', p_result);

        build_log (' ');

        remove_vendor_email ('=====>Step 13', p_result);

        build_log (' ');

        update_vendor_user_pref ('=====>Step 14', p_result);

        build_log (' ');

        remove_ci_email ('=====>Step 14.1', p_result);

        build_log (' ');

        disable_ci_lookup ('=====>Step 14.1.1', p_result);

        build_log (' ');

        remove_oeh_email ('=====>Step 14.2', p_result);

        build_log (' ');

        remove_pro_com_email ('=====>Step 14.3', p_result);

        build_log (' ');

        close_wf_notifications ('=====>Step 15', p_result);

        build_log (' ');

        display_cm_tier_options ('=====>Step 16');

        build_log (' ');

        update_bip_temp_dir ('=====>Step 17', p_result);

        build_log (' ');

        update_wf_resource ('=====>Step 18', p_result);

        build_log (' ');

        alter_users ('=====>Step 19', p_result);

        build_log (' ');

        update_shipping_doc_set ('=====>Step 20', p_result);

        build_log (' ');

        grant_privileges ('=====>Step 21', p_result);

        build_log (' ');

        diable_xx_proact_comm_enable ('=====>Step 22', p_result);

        build_log (' ');

        update_xxroyaltyimport_para ('=====>Step 23', v_db_name, p_result);

        build_log (' ');

        create_agile_links ('=====>Step 24',
                            'garm1ndev',                      --p_garmin_pass,
                            'tartan',                           --p_apps_pass,
                            'seldev',                        --p_selapps_pass,
                            p_result);

        create_ascp_links ('=====>Step 25',
                           'geem1ndev',                       --p_garmin_pass,
                           'devmarch',                          --p_apps_pass,
                           'devapp3',                        --p_selapps_pass,
                           p_result);

        create_plan_links ('=====>Step 26',
                           'geem1ndev',                       --p_garmin_pass,
                           'devmarch',                          --p_apps_pass,
                           'devapp3',                        --p_selapps_pass,
                           p_result);

        disable_profile_printer_copies ('=====>Step 27', p_result);

        build_log (' ');

        disable_alert ('=====>Step 28', p_result);

        build_log (
               ' Post Clone successfully completed at '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        --DBMS_OUTPUT.PUT_LINE ('NEW' || v_all_message);
        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       =>
                   ' Post Clone Log from '
                || UPPER (p_source_db)
                || ' to '
                || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_3_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || 'Main'
                || ' '
                || err_num
                || ' '
                || err_msg);
    END;


    PROCEDURE starting (p_source_db VARCHAR2, pr_source_db VARCHAR2)
    IS
        p_result          VARCHAR2 (200);
        v_profile_value   VARCHAR2 (500);
        v_db_name         VARCHAR2 (100);
        v_db_clone_date   VARCHAR2 (100);
        v_web_form_host   VARCHAR2 (100);
        v_be_rest_value   VARCHAR2 (500);
        port_number       NUMBER;
        v_curr_user       VARCHAR2 (100);
        err_num           NUMBER;
        err_msg           VARCHAR (100);

        CURSOR C_PRF_DB IS
            SELECT fpot.USER_PROFILE_OPTION_NAME,
                   fpo.profile_option_name,
                   fpov.profile_option_value,
                   fpo.profile_option_id,
                   fpov.level_id,
                   fpov.level_value
                       AS fpov_level_value,
                   fpov.LEVEL_VALUE_APPLICATION_ID
                       AS fpov_LEVEL_VALUE_APP_ID,
                   CASE
                       WHEN fpov.level_id = 10001 THEN 'SITE'
                       WHEN fpov.level_id = 10002 THEN 'APPL'
                       WHEN fpov.level_id = 10003 THEN 'RESP'
                       WHEN fpov.level_id = 10004 THEN 'USER'
                       WHEN fpov.level_id = 10005 THEN 'SERVER'
                       WHEN fpov.level_id = 10006 THEN 'ORG'
                       WHEN fpov.level_id = 10007 THEN 'SERVRESP'
                   END
                       AS LEVEL_NAME,
                   CASE
                       WHEN fpov.level_id = 10001
                       THEN
                           NULL
                       WHEN fpov.level_id = 10002
                       THEN
                           fpov.LEVEL_VALUE_APPLICATION_ID
                       WHEN fpov.level_id = 10003
                       THEN
                           fpov.level_value
                       WHEN fpov.level_id = 10004
                       THEN
                           fpov.level_value
                   END
                       AS level_value,
                   CASE
                       WHEN fpov.level_id = 10001
                       THEN
                           NULL
                       WHEN fpov.level_id = 10002
                       THEN
                           NULL
                       WHEN fpov.level_id = 10003
                       THEN
                           fpov.LEVEL_VALUE_APPLICATION_ID
                       WHEN fpov.level_id = 10004
                       THEN
                           NULL
                   END
                       AS level_value_app_id
              FROM apps.fnd_profile_options        fpo,
                   apps.fnd_profile_option_values  fpov,
                   apps.FND_PROFILE_OPTIONS_TL     fpot
             WHERE     fpo.profile_option_id = fpov.profile_option_id
                   AND fpot.PROFILE_OPTION_NAME = fpo.PROFILE_OPTION_NAME
                   AND fpot.LANGUAGE = USERENV ('LANG')
                   AND fpo.profile_option_name != 'SITENAME'
                   AND UPPER (fpov.profile_option_value) LIKE
                           '%' || UPPER (p_source_db) || '%'
                   AND NVL (fpo.end_date_active, SYSDATE + 1) > SYSDATE
                   AND fpov.level_id IN (10001, 10003, 10004);

        L_str_prf_1       NUMBER;
        l_end_prf_1       NUMBER;
        L_str_prf_2       NUMBER;
        l_end_prf_2       NUMBER;
        L_str_prf_3       NUMBER;
        l_end_prf_3       NUMBER;
        L_new_PRF_1       VARCHAR2 (240);
        L_new_PRF_3       VARCHAR2 (240);
        l_new_prf         VARCHAR2 (240);
        l_test_prf        VARCHAR2 (240);
        l_source          VARCHAR2 (16);
        L_new_db          VARCHAR2 (16);
        l_db              VARCHAR2 (16);
    BEGIN
        DBMS_OUTPUT.enable (NULL);
        v_all_message := NULL;

        build_log ('You entered Clone Source Database as ' || p_source_db);


        SELECT username
          INTO v_curr_user
          FROM sys.v_$session
         WHERE sid = (SELECT DISTINCT sid
                        FROM sys.v_$mystat);

        IF v_curr_user <> 'SYSTEM'
        THEN
            build_log (' You must login as SYSTEM, quit...');
            RETURN;
        END IF;

        IF p_source_db <> pr_source_db
        THEN
            build_log (
                ' You entered the wrong Source Database Name, quit...');
            RETURN;
        END IF;

        SELECT name INTO v_db_name
         --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        SELECT TO_CHAR (resetlogs_time, 'mm/dd/yyyy')
          INTO v_db_clone_date
          FROM v$database
         WHERE ROWNUM = 1;

        build_log (
               TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss')
            || ' Post Clone from '
            || p_source_db
            || ' to '
            || v_db_name
            || ' start... ');


        build_log (' ');

        disable_concurrent_prog ('=====>Step 2', p_result);

        build_log (' ');

        enable_concurrent_prog ('=====>Step 3', p_result);

        build_log (' ');

        update_directories ('=====>Step 4', p_source_db, p_result);

        build_log (' ');

        -- Profile:  FND: SMTP Host

        v_profile_value := 'smtptrusted.garmin.com';

        update_profile_value ('=====>Step 5',
                              p_result,
                              'FND_SMTP_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Garmin SMTP Server

        v_profile_value := 'smtptrusted.garmin.com';

        update_profile_value ('=====>Step 5.1',
                              p_result,
                              'GARMIN_SMTP_SERVER',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- IEX: SMTP Host

        v_profile_value := 'smtptrusted.garmin.com';

        update_profile_value ('=====>Step 5.2',
                              p_result,
                              'IEX_SMTP_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  IBY: ECAPP URL

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://orbdevr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://orbtstr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://orbqar12.garmin.com/OA_HTML/ibyecapp'
                   ELSE
                       NULL
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 6',
                              p_result,
                              'IBY_ECAPP_URL',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  ICX: Oracle Payment Server URL

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://orbdevr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://orbtstr12.garmin.com/OA_HTML/ibyecapp'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://orbqar12.garmin.com/OA_HTML/ibyecapp'
                   ELSE
                       NULL
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 6a',
                              p_result,
                              'ICX_PAY_SERVER',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- start of post clone additions for APM

        -- XXIBY: Adyen HOP Tokenization URL

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/viewTokens'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 6b',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- XXIBY: Adyen HOP Tokenization URL

        -- Query to get application id
        --SELECT application_short_name,
        --       APPLICATION_NAME,
        --       application_id
        --  FROM apps.fnd_application_vl

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/tokenization'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 6c',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'APPL',
                              222,                  ---Receivables application
                              NULL,
                              NULL);

        build_log (' ');

        -- XXIBY: Adyen HOP Tokenization URL

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/tokenization'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/tokenization'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/tokenization'
               END
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        update_profile_value ('=====>Step 6d',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'APPL',
                              695,                              ---Collections
                              NULL,
                              NULL);

        build_log (' ');

        -- XXIBY: Adyen HOP Tokenization URL

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://erp-services-test.garmin.com/adyenAPMERPWebservices/viewTokens'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://erp-services-staging.garmin.com/adyenAPMERPWebservices/viewTokens'
                   ELSE
                       'http://erp-services-dev.garmin.com/adyenAPMERPWebservices/viewTokens'
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0


        update_profile_value ('=====>Step 6e',
                              p_result,
                              'XXIBY_HOP_SECURE_TOKENIZATION_URL',
                              v_profile_value,
                              'APPL',
                              660,                         ---Order Management
                              NULL,
                              NULL);

        build_log (' ');

        -- End of post clone additions for APM

        -- Profile:  Database Wallet Directory

        SELECT '/acfsmounts/acfs1/wllet/' || LOWER (name)
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        update_profile_value ('=====>Step 6f',
                              p_result,
                              'FND_DB_WALLET_DIR',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Update Business Events REST Link

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'WFBES_REST_RESOURCE_BASE=https://servicesdev.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'WFBES_REST_RESOURCE_BASE=https://servicestest.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'WFBES_REST_RESOURCE_BASE=https://servicesstg.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
                   ELSE
                       'WFBES_REST_RESOURCE_BASE=https://servicesdev.garmin.com WFBES_REST_RESOURCE_PATH=erpBusinessEventMessagingService/message WFBES_REST_HTTP_VERB=POST WFBES_REST_CONTENT_TYPE=application/json'
               END
          INTO v_be_rest_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        update_be_rest_value ('=====>Step 6g', p_result, v_be_rest_value);

        -- End of REST link Change

        -- Update Garmin WSH Services Host

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://services-int-dev.garmin.com'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://services-int-test.garmin.com'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://services-int-stg.garmin.com'
                   ELSE
                       NULL
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        -- Profile:  Garmin WSH Services Host

        update_profile_value ('=====>Step 6h',
                              p_result,
                              'XX_WSH_SERVICES_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://services-kcg-dev.garmin.com'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://servicestest.garmin.com'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://servicesstg.garmin.com'
                   ELSE
                       NULL
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        -- Profile:  Garmin WSH Services Secondary Host

        update_profile_value ('=====>Step 6i',
                              p_result,
                              'XX_WSH_SERVICES_SEC_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Function Parameters:  XX_CUST_VALID_IMPORT_CZ, etc

        update_function_param (p_step => '=====>Step 6j',
                               p_result => p_result);

        build_log (' ');

        -- End of Garmin WSH Services Host

        -- Profile:  ICX: Discoverer Launcher
        --      v_profile_value := 'http://olaxqa-disc00.garmin.com:8090/discoverer/plus?Connect=[APPS_SECURE]';
        --
        --      update_profile_value ('=====>Step 5',
        --                            p_result,
        --                            'ICX_DISCOVERER_LAUNCHER',
        --                            v_profile_value,
        --                            'SITE',
        --                            NULL,
        --                            NULL,
        --                            NULL);

        --      build_log (' ');

        -- Profile:  ICX: Discoverer Viewer Launcher
        --      v_profile_value := 'http://olaxqa-disc00.garmin.com:8090/discoverer/viewer?Connect=[APPS_SECURE]';

        --      update_profile_value ('=====>Step 6',
        --                            p_result,
        --                            'ICX_DISCOVERER_VIEWER_LAUNCHER',
        --                            v_profile_value,
        --                            'SITE',
        --                            NULL,
        --                            NULL,
        --                            NULL);
        --
        ---      build_log (' ');

        -- Profile:  Site Name

        v_profile_value :=
               v_db_name
            || ' - Cloned from the '
            || v_db_clone_date
            || ' '
            || UPPER (p_source_db)
            || ' Backup';
        update_profile_value ('=====>Step 7',
                              p_result,
                              'SITENAME',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  Hide Diagnostics menu entry

        v_profile_value := 'N';
        update_profile_value ('=====>Step 8',
                              p_result,
                              'FND_HIDE_DIAGNOSTICS',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Utilities:Diagnostics

        v_profile_value := 'Y';
        update_profile_value ('=====>Step 8.1',
                              p_result,
                              'DIAGNOSTICS',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  AME:Installed
        --      v_profile_value := 'Y';
        --
        --      update_profile_value ('=====>Step 9',
        --                            p_result,
        --                            'AME_INSTALLED_FLAG',
        --                            v_profile_value,
        --                            'APPL',
        --                            200,                                                                  ---Payable application
        --                            NULL,
        --                            NULL);

        --      build_log (' ');

        -- Profile:  ICX: Forms Launcher
        --      SELECT HOST
        --        INTO v_web_form_host
        --        FROM apps.fnd_nodes
        --       WHERE support_forms = 'Y' AND support_web = 'Y' AND ROWNUM = 1;

        --      SELECT SUBSTR (
        --                TRIM (
        --                   TRANSLATE (fpov.profile_option_value,
        --                              'abcdefghijklmnopqrstuvwxyz://.ABCDEFGHIJKLMNOPQRSTUVWXYZ_',
        --                              ' ')),
        --                0,
        --                4)
        --                port
        --        INTO port_number
        --        FROM apps.fnd_profile_option_values fpov
        --       WHERE profile_option_id = '8017';
        --
        --      v_profile_value :=
        --         'http://' || v_web_form_host || '.garmin.com:' || port_number || '/dev60cgi/f60cgi?play=' || '&' || 'record=names';
        --
        --      update_profile_value ('=====>Step 10',
        --                            p_result,
        --                            'ICX_FORMS_LAUNCHER',
        --                            v_profile_value,
        --                            'USER',
        --                            16903,            --it is for the user TURNKEYUSER1, need to get port dynamically from Rinky
        --                            NULL,
        --                            NULL);
        --
        --      build_log (' ');

        -- Profile:  BNE UIX Physical Directory
        --      v_profile_value := '/' || v_db_name || '/applmgr/' || v_db_name || 'comn/html/cabo';

        --      update_profile_value ('=====>Step 11',
        --                            p_result,
        --                            'BNE_UIX_PHYSICAL_DIRECTORY',
        --                            v_profile_value,
        --                            'SITE',
        --                            NULL,
        --                            NULL,
        --                            NULL);
        --
        --      build_log (' ');

        -- ICX: Forms Launcher

        v_profile_value := NULL;

        update_profile_value ('=====>Step 10',
                              p_result,
                              'ICX_FORMS_LAUNCHER',
                              v_profile_value,
                              'USER',
                              0,                 --it is for the user SYSADMIN
                              NULL,
                              NULL);

        build_log (' ');

        -- WSH: BPEL Webservice URI for OTM

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://olaxda-otmint01.garmin.com:8001/soa-infra/services/default'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'http://olaxta-otmint03.garmin.com:8001/soa-infra/services/default'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'http://olaxqa-otmint04.garmin.com:8001/soa-infra/services/default'
                   ELSE
                       'http://olaxda-otmint01.garmin.com:8001/soa-infra/services/default'
               END
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        update_profile_value ('=====>Step 11.1',
                              p_result,
                              'WSH_OTM_OB_SERVICE_ENDPOINT',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- OTM: Servlet URI

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'http://otmdev637.garmin.com/GC3/glog.integration.servlet.WMServlet'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://otmtest637.garmin.com/GC3/glog.integration.servlet.WMServlet'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://otmqa637.garmin.com/GC3/glog.integration.servlet.WMServlet'
                   ELSE
                       'http://otmdev637.garmin.com/GC3/glog.integration.servlet.WMServlet'
               END
          INTO v_profile_value
         --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        update_profile_value ('=====>Step 11.2',
                              p_result,
                              'WSH_OTM_SERVLET_URI',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  MWA: Cache Personalized Metadata

        v_profile_value := '2';

        update_profile_value ('=====>Step 11.3',
                              p_result,
                              'MWA_METADATA_CACHE_ENABLED',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  Garmin Services Host

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://services-int-dev.garmin.com'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://services-int-test.garmin.com'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://services-int-stg.garmin.com'
                   ELSE
                       'https://services-int-dev.garmin.com'
               END
          INTO v_profile_value
           --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        update_profile_value ('=====>Step 11.4',
                              p_result,
                              'XX_SERVICES_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

        -- Profile:  Garmin Services Secondary Host

        SELECT CASE
                   WHEN name = 'ORBDEV'
                   THEN
                       'https://servicesdev.garmin.com'
                   WHEN NAME = 'ORBTST'
                   THEN
                       'https://servicestest.garmin.com'
                   WHEN NAME = 'ORBQA'
                   THEN
                       'https://servicesstg.garmin.com'
                   ELSE
                       'https://servicesdev.garmin.com'
               END
          INTO v_profile_value
          --  FROM v$database; --commented for version 1.0
        FROM (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0

        update_profile_value ('=====>Step 11.5',
                              p_result,
                              'XX_SERVICES_SEC_HOST',
                              v_profile_value,
                              'SITE',
                              NULL,
                              NULL,
                              NULL);

        build_log (' ');

      --  SELECT name INTO l_db FROM v$database; -- commented for version 1.0

        select apps.xx_db_util.get_dbname INTO l_db from dual; -- added for version 1.0

        FOR L_PRF_DB IN C_PRF_DB
        LOOP
            l_test_prf := L_PRF_DB.profile_option_value;

            LOOP
                L_str_prf_1 := 1;
                l_end_prf_1 :=
                    INSTR (UPPER (l_test_prf), UPPER (p_source_db), 1) - 1;

                IF l_end_prf_1 < 0
                THEN
                    EXIT;
                END IF;

                L_new_PRF_1 := SUBSTR (l_test_prf, L_str_prf_1, l_end_prf_1);
                L_str_prf_2 := L_str_prf_1 + l_end_prf_1;
                l_end_prf_2 := LENGTH (p_source_db);
                l_source := SUBSTR (l_test_prf, L_str_prf_2, l_end_prf_2);

                IF SUBSTR (l_source, 1, 1) = UPPER (SUBSTR (l_source, 1, 1))
                THEN
                    L_new_db := UPPER (SUBSTR (l_db, 1, 1));
                ELSE
                    L_new_db := LOWER (SUBSTR (l_db, 1, 1));
                END IF;

                IF SUBSTR (l_source, 2, 1) = UPPER (SUBSTR (l_source, 2, 1))
                THEN
                    L_new_db :=
                           L_new_db
                        || UPPER (SUBSTR (l_db, 2, (LENGTH (l_db) - 1)));
                ELSE
                    L_new_db :=
                           L_new_db
                        || LOWER (SUBSTR (l_db, 2, (LENGTH (l_db) - 1)));
                END IF;

                L_str_prf_3 := L_str_prf_2 + l_end_prf_2;
                l_end_prf_3 := LENGTH (l_test_prf) - L_str_prf_3 + 1;
                L_new_PRF_3 := SUBSTR (l_test_prf, L_str_prf_3, l_end_prf_3);
                l_new_prf := L_new_prf_1 || L_new_db || L_new_PRF_3;
                l_test_prf := l_new_prf;
            END LOOP;

            v_profile_value := l_new_prf;

            update_profile_value ('=====>Step 11.X',
                                  p_result,
                                  L_PRF_DB.profile_option_name,
                                  v_profile_value,
                                  L_PRF_DB.LEVEL_NAME,
                                  L_PRF_DB.level_value,
                                  L_PRF_DB.level_value_app_id,
                                  NULL);

            build_log (' ');
        END LOOP;



        update_fnd_user_email ('=====>Step 12', p_result);

        build_log (' ');

        remove_vendor_email ('=====>Step 13', p_result);

        build_log (' ');

        update_vendor_user_pref ('=====>Step 14', p_result);

        build_log (' ');

        remove_ci_email ('=====>Step 14.1', p_result);

        build_log (' ');

        disable_ci_lookup ('=====>Step 14.1.1', p_result);

        build_log (' ');

        remove_oeh_email ('=====>Step 14.2', p_result);

        build_log (' ');

        remove_pro_com_email ('=====>Step 14.3', p_result);

        build_log (' ');

        remove_qa_plan_email ('=====>Step 14.4', p_result); --4/17/20-BKL-added

        build_log (' ');

        close_wf_notifications ('=====>Step 15', p_result);

        build_log (' ');

        display_cm_tier_options ('=====>Step 16');

        build_log (' ');

        update_bip_temp_dir ('=====>Step 17', p_result);

        build_log (' ');

        update_global_name ('=====>Step 18', p_result); -- add this to the sql

        build_log (' ');


        update_wf_resource ('=====>Step 19', p_result);

        build_log (' ');

        alter_users ('=====>Step 20', p_result);

        build_log (' ');

        update_shipping_doc_set ('=====>Step 21', p_result);

        build_log (' ');

        grant_privileges ('=====>Step 22', p_result);

        build_log (' ');

        diable_xx_proact_comm_enable ('=====>Step 23', p_result);

        build_log (' ');

        update_xxroyaltyimport_para ('=====>Step 24', v_db_name, p_result);

        build_log (' ');

        update_conc_processes ('=====>Step 25', p_result);

        build_log (' ');

        disable_alert ('=====>Step 26', p_result);

        build_log (' ');

        disable_profile_printer_copies ('=====>Step 27', p_result);

        build_log (' ');

        update_loadtest_users ('=====>Step 28', p_result);

        build_log (' ');

        update_oaf_settings ('=====>Step 29', p_result);

        build_log (' ');

        update_docuware_lookup ('=====>Step 30', p_result);

        build_log (' ');


        build_log (
               ' Post Clone successfully completed at '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        --DBMS_OUTPUT.PUT_LINE ('NEW' || v_all_message);
        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       =>
                   ' Post Clone Log from '
                || UPPER (p_source_db)
                || ' to '
                || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_3_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || 'Main'
                || ' '
                || err_num
                || ' '
                || err_msg);
    END;

    -- it takes long to run, it will run individually step1.70

    PROCEDURE disable_customer_email
    IS
        err_num            NUMBER;
        err_msg            VARCHAR (100);
        procedure_name     VARCHAR2 (200) := 'disable_customer_email';
        backup_tbl         VARCHAR2 (200)
            := 'garmin.hz_contact_points_' || TO_CHAR (SYSDATE, 'hhmmss');
        backup_tbl2        VARCHAR2 (200)
            := 'garmin.HZ_PARTIES_' || TO_CHAR (SYSDATE, 'hhmmss');

        backup_statement   VARCHAR2 (1000);
        v_cnt              NUMBER := 1;
        v_total_cnt        NUMBER := 0;
        v_db_name          VARCHAR2 (100);
    BEGIN
      --  SELECT name INTO v_db_name FROM v$database; -- commented for version 1.0

        select apps.xx_db_util.get_dbname INTO v_db_name from dual; -- added for version 1.0

        build_log (
               procedure_name
            || ' begin...'
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        backup_statement :=
               'create TABLE '
            || backup_tbl
            || ' TABLESPACE xx_junk AS '
            || 'SELECT * '
            || 'FROM apps.hz_contact_points '
            || 'WHERE email_address IS NOT NULL ';

        build_log (' ' || backup_statement);


        EXECUTE IMMEDIATE backup_statement;

        build_log (
               '                  '
            || ' disable_customer hz_contact_points email begin...');

        UPDATE apps.hz_contact_points
           SET EMAIL_ADDRESS =
                   CASE
                       WHEN NVL (REGEXP_COUNT (EMAIL_ADDRESS,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (EMAIL_ADDRESS) NOT LIKE '%GARMIN%'
                            AND UPPER (EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || EMAIL_ADDRESS
                       ELSE
                           EMAIL_ADDRESS
                   END
         WHERE email_address IS NOT NULL;

        v_total_cnt := SQL%ROWCOUNT;
        COMMIT;

        build_log ('    hz_contact_points EMAIL_ADDRESS');
        build_log (
            '                  Rows updated: ' || TO_CHAR (v_total_cnt));

        backup_statement :=
               'create TABLE '
            || backup_tbl2
            || ' TABLESPACE xx_junk AS '
            || 'SELECT p.* '
            || 'FROM apps.hz_parties p '
            || 'WHERE    p.email_address IS NOT NULL ';

        build_log (' ' || backup_statement);


        EXECUTE IMMEDIATE backup_statement;

        build_log (
               '                  '
            || ' disable_customer hz_parties email begin...');

        UPDATE apps.hz_parties
           SET EMAIL_ADDRESS =
                   CASE
                       WHEN NVL (REGEXP_COUNT (EMAIL_ADDRESS,
                                               '@',
                                               1,
                                               'i'),
                                 0) > 1
                       THEN
                           'XX_MUTIPLE_EMAIL@GARMIN.COM'
                       WHEN     UPPER (EMAIL_ADDRESS) NOT LIKE '%GARMIN%'
                            AND UPPER (EMAIL_ADDRESS) NOT LIKE 'XX_%'
                       THEN
                           'XX_' || EMAIL_ADDRESS
                       ELSE
                           EMAIL_ADDRESS
                   END
         WHERE email_address IS NOT NULL;


        v_total_cnt := SQL%ROWCOUNT;
        COMMIT;

        build_log ('    hz_parties EMAIL_ADDRESS');
        build_log (
            '                  Rows updated: ' || TO_CHAR (v_total_cnt));


        build_log (
               procedure_name
            || ' successfully completed '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));
        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       => ' Post Clone Log for ' || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_1_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);

            --p_result := fail;
            RETURN;
    END;


    PROCEDURE post_enc_cc_scrub
    AS
        err_num                   NUMBER;
        err_msg                   VARCHAR (100);
        procedure_name            VARCHAR2 (200) := 'post_enc_cc_scrub';
        v_db_name                 VARCHAR2 (100);

        v_CCNUMBER                GARMIN.XX_CC_TEST_CC.CC_NUMBER%TYPE;
        V_MASKED_CC_NUMBER        GARMIN.XX_CC_TEST_CC.MASKED_CC_NUMBER%TYPE;
        V_EXPIRYDATE              GARMIN.XX_CC_TEST_CC.EXPIRYDATE%TYPE;
        V_CC_NUMBER_HASH1         GARMIN.XX_CC_TEST_CC.CC_NUMBER_HASH1%TYPE;
        V_CC_NUMBER_HASH2         GARMIN.XX_CC_TEST_CC.CC_NUMBER_HASH2%TYPE;
        V_CARD_ISSUER_CODE        GARMIN.XX_CC_TEST_CC.CC_VENDOR%TYPE;
        V_CC_ISSUER_RANGE_ID      GARMIN.XX_CC_TEST_CC.CC_ISSUER_RANGE_ID%TYPE;
        V_CC_NUM_SEC_SEGMENT_ID   GARMIN.XX_CC_TEST_CC.CC_NUM_SEC_SEGMENT_ID%TYPE;
        V_PRV_CARD_ISSUER_CODE    GARMIN.XX_CC_TEST_CC.CC_VENDOR%TYPE;
        V_CHK_CARD_ISSUER_CODE    GARMIN.XX_CC_TEST_CC.CC_VENDOR%TYPE;

        CC_COUNT                  NUMBER := 0;
        v_count                   PLS_INTEGER := 0;

        CURSOR c1 IS
            SELECT u.instrument_payment_use_id
              FROM iby_pmt_instr_uses_all u, iby_creditcard c
             WHERE     c.instrid = u.instrument_id
                   AND c.expiryDate = '30-SEP-9999'
                   AND U.instrument_type = 'CREDITCARD'
                   AND u.end_date IS NULL;



        --      CURSOR c_om
        --      IS
        --         SELECT header_id
        --           FROM apps.oe_order_headers_all
        --          WHERE     credit_card_number IS NOT NULL
        --                AND credit_card_number NOT IN (SELECT MASKED_CC_NUMBER  FROM garmin.xx_cc_test_cc);

        --      CURSOR c_op
        --      IS
        --         SELECT header_id
        --           FROM apps.oe_payments
        --          WHERE     credit_card_number IS NOT NULL
        --                AND credit_card_number NOT IN (SELECT MASKED_CC_NUMBER   FROM garmin.xx_cc_test_cc);

        --      CURSOR c_ap
        --      IS
        --         SELECT bank_account_id
        --           FROM ap_bank_accounts_all
        --          WHERE bank_branch_id = 1 AND bank_account_num NOT IN (SELECT MASKED_CC_NUMBER   FROM garmin.xx_cc_test_cc);

        CURSOR c_ib IS
            SELECT iss.sec_segment_id
              FROM apps.iby_security_segments iss
             WHERE     iss.sec_segment_id > 5
                   AND iss.sec_segment_id NOT IN
                           (SELECT xc.cc_num_sec_segment_id
                              FROM apps.xx_cc_test_cc xc);

        --      CURSOR c_ib_ba
        --      IS
        --         SELECT EXT_BANK_ACCOUNT_ID
        --           FROM IBY_EXT_BANK_ACCOUNTS
        --          WHERE BANK_ACCOUNT_NUM NOT IN (SELECT MASKED_CC_NUMBER  FROM garmin.xx_cc_test_cc);

        CURSOR c_ib_cc IS
              SELECT ic.INSTRID, ic.card_issuer_code
                FROM apps.iby_creditCard ic
               WHERE     ic.cc_num_sec_segment_id > 5
                     AND ic.cc_num_sec_segment_id NOT IN
                             (SELECT xc.cc_num_sec_segment_id
                                FROM apps.xx_cc_test_cc xc)
            ORDER BY ic.card_issuer_code;


        TYPE t_tab IS TABLE OF NUMBER;

        --      t_om             t_tab := t_tab ();
        --      t_op             t_tab := t_tab ();
        --      t_ap             t_tab := t_tab ();
        t_ib                      t_tab := t_tab ();
        --      t_ib_ba          t_tab := t_tab ();
        --      t_ib_cc          t_tab := t_tab ();
        i                         INTEGER;
    BEGIN
       -- SELECT name INTO v_db_name FROM v$database; -- commented for version 1.0

        select apps.xx_db_util.get_dbname INTO v_db_name from dual; -- added for version 1.0

        build_log (
               procedure_name
            || ' begin...'
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        --      OPEN c_om;

        --      LOOP
        --         FETCH c_om BULK COLLECT INTO t_om LIMIT 1000;

        --         FORALL i IN 1 .. t_om.COUNT
        --            UPDATE apps.oe_order_headers_all
        --               SET credit_card_number = v_cc, credit_card_expiration_date = '30-SEP-9999'
        --             WHERE header_id = t_om (i);

        --         COMMIT;

        --         EXIT WHEN c_om%NOTFOUND;
        --      END LOOP;

        --      CLOSE c_om;

        --      OPEN c_op;

        --      LOOP
        --         FETCH c_op BULK COLLECT INTO t_op LIMIT 1000;
        --         FORALL i IN 1 .. t_op.COUNT
        --            UPDATE apps.oe_payments
        --               SET credit_card_number = v_cc, credit_card_expiration_date = '30-SEP-9999'
        --             WHERE header_id = t_op (i);

        --         COMMIT;

        -- end loop;

        --         EXIT WHEN c_op%NOTFOUND;
        --      END LOOP;

        --      CLOSE c_op;

        --      OPEN c_ap;

        --      LOOP
        --         FETCH c_ap BULK COLLECT INTO t_ap LIMIT 1000;

        --         FORALL i IN 1 .. t_ap.COUNT
        --            UPDATE apps.ap_bank_accounts_all
        --               SET bank_account_num = v_cc, inactive_date = '30-SEP-9999'
        --             WHERE bank_account_id = t_ap (i);
        --
        --         COMMIT;
        -- end loop;
        --         EXIT WHEN c_ap%NOTFOUND;
        --      END LOOP;

        --      CLOSE c_ap;

        OPEN c_ib;

        LOOP
            FETCH c_ib BULK COLLECT INTO t_ib LIMIT 1000;

            FORALL i IN 1 .. t_ib.COUNT
                DELETE FROM iby_security_segments
                      WHERE sec_segment_id = t_ib (i);

            COMMIT;
            -- end loop;

            EXIT WHEN c_ib%NOTFOUND;
        END LOOP;

        CLOSE c_ib;

        --      OPEN c_ib_ba;

        --      LOOP
        --         FETCH c_ib_ba BULK COLLECT INTO t_ib_ba LIMIT 1000;

        --         FORALL i IN 1 .. t_ib_ba.COUNT
        --            UPDATE IBY_EXT_BANK_ACCOUNTS
        --               SET BANK_ACCOUNT_NUM = v_cc, BANK_ACCOUNT_NUM_ELECTRONIC = v_cc, MASKED_BANK_ACCOUNT_NUM = v_cc
        --             WHERE EXT_BANK_ACCOUNT_ID = t_ib_ba (i);

        --         COMMIT;
        -- end loop;

        --         EXIT WHEN c_ib_ba%NOTFOUND;
        --      END LOOP;

        --      CLOSE c_ib_ba;


        CC_COUNT := 0;
        V_PRV_CARD_ISSUER_CODE := 'XXXXXXXXX';

        FOR r_ib_cc IN c_ib_cc
        LOOP
            IF NVL (V_PRV_CARD_ISSUER_CODE, 'X') !=
               NVL (r_ib_cc.card_issuer_code, 'X')
            THEN
                BEGIN
                    SELECT x.CC_NUMBER,
                           x.MASKED_CC_NUMBER,
                           x.EXPIRYDATE,
                           x.CC_NUMBER_HASH1,
                           x.CC_NUMBER_HASH2,
                           x.CC_VENDOR,
                           x.CC_ISSUER_RANGE_ID,
                           x.CC_NUM_SEC_SEGMENT_ID
                      INTO v_CCNUMBER,
                           V_MASKED_CC_NUMBER,
                           V_EXPIRYDATE,
                           V_CC_NUMBER_HASH1,
                           V_CC_NUMBER_HASH2,
                           V_CARD_ISSUER_CODE,
                           V_CC_ISSUER_RANGE_ID,
                           V_CC_NUM_SEC_SEGMENT_ID
                      FROM garmin.xx_cc_test_cc x
                     WHERE     x.cc_vendor = r_ib_cc.card_issuer_code
                           AND ROWNUM = 1;
                EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                        --default to visa
                        V_CARD_ISSUER_CODE := 'VISA';

                        SELECT x.cc_number,
                               x.masked_cc_number,
                               x.expirydate,
                               x.cc_number_hash1,
                               x.cc_number_hash2,
                               x.cc_vendor,
                               x.cc_issuer_range_id,
                               x.cc_num_sec_segment_id
                          INTO v_CCNUMBER,
                               v_masked_cc_number,
                               v_expirydate,
                               v_cc_number_hash1,
                               v_cc_number_hash2,
                               V_CARD_ISSUER_CODE,
                               v_cc_issuer_range_id,
                               v_cc_num_sec_segment_id
                          FROM apps.xx_cc_test_cc x
                         WHERE     x.cc_vendor = V_CARD_ISSUER_CODE
                               AND ROWNUM = 1;
                END;

                V_PRV_CARD_ISSUER_CODE := NVL (r_ib_cc.card_issuer_code, 'X');
            END IF;

            UPDATE apps.iby_creditCard
               SET ccnumber = v_CCNUMBER,
                   masked_cc_number = V_MASKED_CC_NUMBER,
                   expirydate = V_EXPIRYDATE,
                   CC_NUMBER_HASH1 = V_CC_NUMBER_HASH1,
                   CC_NUMBER_HASH2 = V_CC_NUMBER_HASH2,
                   CARD_ISSUER_CODE = V_CARD_ISSUER_CODE,
                   CC_ISSUER_RANGE_ID = V_CC_ISSUER_RANGE_ID,
                   CC_NUM_SEC_SEGMENT_ID = V_CC_NUM_SEC_SEGMENT_ID,
                   active_flag = 'Y',
                   inactive_date = v_expirydate
             WHERE INSTRID = r_ib_cc.INSTRID;

            CC_COUNT := CC_COUNT + 1;

            IF CC_COUNT > 1000
            THEN
                COMMIT;
                CC_COUNT := 0;
            END IF;
        END LOOP;

        FOR x IN c1
        LOOP
            UPDATE iby_pmt_instr_uses_all
               SET end_date = SYSDATE,
                   LAST_UPDATED_BY = 0,
                   LAST_UPDATE_DATE = SYSDATE
             WHERE instrument_payment_use_id = x.instrument_payment_use_id;

            v_count := v_count + 1;

            IF MOD (v_count, 10000) = 0
            THEN
                COMMIT;
            END IF;
        END LOOP;

        COMMIT;


        build_log (
               procedure_name
            || ' successfully completed '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));
        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       => ' Post Clone Log for ' || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_2_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);
            RETURN;
    END;

    PROCEDURE AP_PROFILE
    AS
        err_num          NUMBER;
        err_msg          VARCHAR (100);
        procedure_name   VARCHAR2 (200) := 'AP_PROFILE';
        v_db_name        VARCHAR2 (100);

        CURSOR c1 IS
            SELECT SYSTEM_PROFILE_CODE,
                   DEFAULT_PRINTER,
                   OUTBOUND_PMT_FILE_DIRECTORY,
                   POSITIVE_PAY_FILE_DIRECTORY,
                   CASE
                       WHEN DEFAULT_PRINTER IS NOT NULL THEN 'noprint'
                       ELSE NULL
                   END    AS NEW_DEFAULT_PRINTER,
                   CASE
                       WHEN OUTBOUND_PMT_FILE_DIRECTORY IS NOT NULL
                       THEN
                              SUBSTR (OUTBOUND_PMT_FILE_DIRECTORY,
                                      1,
                                      (INSTR (OUTBOUND_PMT_FILE_DIRECTORY,
                                              '/',
                                              1,
                                              4)))
                          -- || (SELECT name FROM v$database) -- commented for version 1.0
                           ||(select apps.xx_db_util.get_dbname name from dual)
                           || SUBSTR (
                                  OUTBOUND_PMT_FILE_DIRECTORY,
                                  (INSTR (OUTBOUND_PMT_FILE_DIRECTORY,
                                          '/',
                                          1,
                                          5)),
                                  ((  LENGTH (OUTBOUND_PMT_FILE_DIRECTORY)
                                    - INSTR (OUTBOUND_PMT_FILE_DIRECTORY,
                                             '/',
                                             1,
                                             5)
                                    + 1)))
                       ELSE
                           NULL
                   END    AS NEW_OUTBOUND_PMT_FILE_DIR,
                   CASE
                       WHEN POSITIVE_PAY_FILE_DIRECTORY IS NOT NULL
                       THEN
                              SUBSTR (POSITIVE_PAY_FILE_DIRECTORY,
                                      1,
                                      (INSTR (POSITIVE_PAY_FILE_DIRECTORY,
                                              '/',
                                              1,
                                              4)))
                           || (SELECT name FROM v$database)
                           || SUBSTR (
                                  POSITIVE_PAY_FILE_DIRECTORY,
                                  (INSTR (POSITIVE_PAY_FILE_DIRECTORY,
                                          '/',
                                          1,
                                          5)),
                                  ((  LENGTH (POSITIVE_PAY_FILE_DIRECTORY)
                                    - INSTR (POSITIVE_PAY_FILE_DIRECTORY,
                                             '/',
                                             1,
                                             5)
                                    + 1)))
                       ELSE
                           NULL
                   END    AS NEW_POSITIVE_PAY_FILE_DIR
              FROM apps.IBY_SYS_PMT_PROFILES_B;

        CURSOR c2 IS
            SELECT itv.TRANSMIT_VALUE_ID,
                   itv.TRANSMIT_PARAMETER_CODE,
                   itv.TRANSMIT_VARCHAR2_VALUE,
                   CASE
                       WHEN itv.TRANSMIT_VARCHAR2_VALUE IS NOT NULL
                       THEN
                              SUBSTR (itv.TRANSMIT_VARCHAR2_VALUE,
                                      1,
                                      (INSTR (itv.TRANSMIT_VARCHAR2_VALUE,
                                              '/',
                                              1,
                                              5)))
                           -- || (SELECT name FROM v$database) -- commented for version 1.0
                           ||(select apps.xx_db_util.get_dbname name from dual)
                           || SUBSTR (
                                  itv.TRANSMIT_VARCHAR2_VALUE,
                                  (INSTR (itv.TRANSMIT_VARCHAR2_VALUE,
                                          '/',
                                          1,
                                          6)),
                                  ((  LENGTH (itv.TRANSMIT_VARCHAR2_VALUE)
                                    - INSTR (itv.TRANSMIT_VARCHAR2_VALUE,
                                             '/',
                                             1,
                                             6)
                                    + 1)))
                       ELSE
                           NULL
                   END    AS NEW_TRANSMIT_VARCHAR2_VALUE
              FROM apps.IBY_TRANSMIT_VALUES itv
             WHERE itv.TRANSMIT_PARAMETER_CODE = 'FILE_DIR';
    BEGIN
      --  SELECT name INTO v_db_name FROM v$database; -- commented for version 1.0

        select apps.xx_db_util.get_dbname INTO v_db_name from dual ; -- added for version 1.0

        build_log (
               procedure_name
            || ' begin...'
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        build_log (' ');
        build_log (
            'Update IBY_SYS_PMT_PROFILES -- DEFAULT_PRINTER, OUTBOUND_PMT_FILE_DIRECTORY, POSITIVE_PAY_FILE_DIRECTORY');

        FOR x IN c1
        LOOP
            BEGIN
                UPDATE apps.IBY_SYS_PMT_PROFILES_B
                   SET DEFAULT_PRINTER = x.NEW_DEFAULT_PRINTER,
                       OUTBOUND_PMT_FILE_DIRECTORY =
                           x.NEW_OUTBOUND_PMT_FILE_DIR,
                       POSITIVE_PAY_FILE_DIRECTORY =
                           x.NEW_POSITIVE_PAY_FILE_DIR
                 WHERE SYSTEM_PROFILE_CODE = x.SYSTEM_PROFILE_CODE;

                build_log (
                       procedure_name
                    || ' Profile Value updated '
                    || x.SYSTEM_PROFILE_CODE);
            EXCEPTION
                WHEN OTHERS
                THEN
                    build_log (
                           procedure_name
                        || ' Profile Value not updated --- ERROR '
                        || x.SYSTEM_PROFILE_CODE);
            END;
        END LOOP;

        COMMIT;

        build_log (' ');
        build_log (
            'Update IBY_TRANSMIT_VALUES -- itv.TRANSMIT_VARCHAR2_VALUE');

        FOR x IN c2
        LOOP
            BEGIN
                UPDATE apps.IBY_TRANSMIT_VALUES
                   SET TRANSMIT_VARCHAR2_VALUE =
                           x.NEW_TRANSMIT_VARCHAR2_VALUE
                 WHERE     TRANSMIT_VALUE_ID = x.TRANSMIT_VALUE_ID
                       AND TRANSMIT_PARAMETER_CODE =
                           x.TRANSMIT_PARAMETER_CODE;

                build_log (
                       procedure_name
                    || ' TRANSMIT_VALUE_ID Updated: '
                    || x.TRANSMIT_VALUE_ID
                    || ' TRANSMIT_PARAMETER_CODE: '
                    || x.TRANSMIT_PARAMETER_CODE);
            EXCEPTION
                WHEN OTHERS
                THEN
                    build_log (
                           procedure_name
                        || ' ERROR -- TRANSMIT_VALUE_ID Updated: '
                        || x.TRANSMIT_VALUE_ID
                        || ' TRANSMIT_PARAMETER_CODE: '
                        || x.TRANSMIT_PARAMETER_CODE);
            END;
        END LOOP;

        COMMIT;

        build_log (
               procedure_name
            || ' successfully completed '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));
        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       => ' Post Clone Log for ' || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_5_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);
            RETURN;
    END;

    -- start of post clone additions for APM
    PROCEDURE APM_PROFILE
    AS
        err_num           NUMBER;
        err_msg           VARCHAR (100);
        procedure_name    VARCHAR2 (200) := 'APM_PROFILE';
        v_db_name         VARCHAR2 (100);
        p_result          VARCHAR2 (200);
        v_profile_value   VARCHAR2 (500);


        -- Cursor of profiles to change
        CURSOR c0 IS
              SELECT prf.*,
                     CASE
                         WHEN prf.BASE_profile_option_value =
                              'GarminSwitzerlandGMBH'
                         THEN
                             CASE
                                 WHEN db.name = 'ORBDEV'
                                 THEN
                                     'GarminGMBHDev'
                                 WHEN db.name = 'ORBTST'
                                 THEN
                                     'GarminGMBHTest'
                                 WHEN db.name = 'ORBQA'
                                 THEN
                                     'GarminGMBHStaging'
                                 ELSE
                                     'GarminGMBHDev'
                             END
                         WHEN prf.BASE_profile_option_value =
                              'GarminSwitzerlandDistr'
                         THEN
                             CASE
                                 WHEN db.name = 'ORBDEV'
                                 THEN
                                     'GarminSwissDistrDev'
                                 WHEN db.name = 'ORBTST'
                                 THEN
                                     'GarminSwissDistrTest'
                                 WHEN db.name = 'ORBQA'
                                 THEN
                                     'GarminSwissDistrStaging'
                                 ELSE
                                     'GarminSwissDistrDev'
                             END
                         WHEN prf.BASE_profile_option_value =
                              'GarminDeutschlandGmbH'
                         THEN
                             CASE
                                 WHEN db.name = 'ORBDEV'
                                 THEN
                                     'GarminDeutschlandGmbH-EcomDev'
                                 WHEN db.name = 'ORBTST'
                                 THEN
                                     'GarminDeutschlandGmbH-EcomTest'
                                 WHEN db.name = 'ORBQA'
                                 THEN
                                     'GarminDeutschlandGmbH-EcomStaging'
                                 ELSE
                                     'GarminDeutschlandGmbH-EcomDev'
                             END
                         WHEN prf.BASE_profile_option_value = 'GarminAustria'
                         THEN
                             CASE
                                 WHEN db.name = 'ORBDEV'
                                 THEN
                                     'GarminAustria-EcomDev'
                                 WHEN db.name = 'ORBTST'
                                 THEN
                                     'GarminAustria-EcomTest'
                                 WHEN db.name = 'ORBQA'
                                 THEN
                                     'GarminAustria-EcomStaging'
                                 ELSE
                                     'GarminAustria-EcomDev'
                             END
                         ELSE
                             CASE
                                 WHEN db.name = 'ORBDEV'
                                 THEN
                                     prf.BASE_profile_option_value || 'Dev'
                                 WHEN db.name = 'ORBTST'
                                 THEN
                                     prf.BASE_profile_option_value || 'Test'
                                 WHEN db.name = 'ORBQA'
                                 THEN
                                     prf.BASE_profile_option_value || 'Staging'
                                 ELSE
                                     prf.BASE_profile_option_value || 'Dev'
                             END
                     END    AS NEW_profile_option_value
                FROM (SELECT fpot.USER_PROFILE_OPTION_NAME,
                             fpo.profile_option_name,
                             fpo.profile_option_id,
                             fpov.level_id,
                             CASE
                                 WHEN fpov.level_id = 10001 THEN 'SITE'
                                 WHEN fpov.level_id = 10002 THEN 'APPL'
                                 WHEN fpov.level_id = 10003 THEN 'RESP'
                                 WHEN fpov.level_id = 10004 THEN 'USER'
                                 WHEN fpov.level_id = 10005 THEN 'SERVER'
                                 WHEN fpov.level_id = 10006 THEN 'ORG'
                                 WHEN fpov.level_id = 10007 THEN 'SERVRESP'
                             END          AS LEVEL_NAME,
                             fpov.level_value,
                             fpov.LEVEL_VALUE_APPLICATION_ID,
                             CASE
                                 WHEN fpov.level_id = 10002
                                 THEN
                                     (SELECT fa.APPLICATION_NAME     FA
                                        FROM apps.fnd_application_vl FA
                                       WHERE fa.application_id =
                                             fpov.level_value)
                                 WHEN fpov.level_id = 10003
                                 THEN
                                     (SELECT fr.responsibility_key
                                        FROM apps.fnd_responsibility fr
                                       WHERE     fr.responsibility_id =
                                                 fpov.level_value
                                             AND fr.application_id =
                                                 fpov.LEVEL_VALUE_APPLICATION_ID)
                                 WHEN fpov.level_id = 10004
                                 THEN
                                     (SELECT fu.user_name
                                        FROM apps.fnd_user fu
                                       WHERE fu.user_id = fpov.level_value)
                                 WHEN fpov.level_id = 10006
                                 THEN
                                     (SELECT xle.OPERATING_UNIT_CODE
                                        FROM APPS.XX_LEGAL_ENTITY_V xle
                                       WHERE xle.organization_id =
                                             fpov.level_value)
                             END          NAME,
                             fpov.profile_option_value,
                             REPLACE (
                                 REPLACE (
                                     REPLACE (
                                         REPLACE (fpov.profile_option_value,
                                                  'Dev',
                                                  NULL),
                                         'Test',
                                         NULL),
                                     'Staging',
                                     NULL),
                                 '-Ecom',
                                 NULL)    AS BASE_profile_option_value
                        FROM apps.fnd_profile_options      fpo,
                             apps.fnd_profile_option_values fpov,
                             apps.FND_PROFILE_OPTIONS_TL   fpot
                       WHERE     fpo.profile_option_id = fpov.profile_option_id
                             AND fpot.PROFILE_OPTION_NAME =
                                 fpo.PROFILE_OPTION_NAME
                             AND fpot.LANGUAGE = USERENV ('LANG')) prf,
                     --v$database db
                     (select apps.xx_db_util.get_dbname name from dual) db
               WHERE     prf.level_name = 'ORG'
                     AND prf.profile_option_name =
                         'XXIBY_HOP_PAYMENT_SYSTEM_ACCOUNT'
            ORDER BY prf.level_value;

        -- Update apps.iby_routinginfo column BEPKEY and apps.iby_bepkeys column KEY
        CURSOR c1 IS
            SELECT ibz.bepid,
                   ibz.key,
                   ibz.BASE_BEPKEY,
                   ibz.bep_account_id,
                   ir.bepkey,
                   ibz.NEW_BEPKEY
              FROM (SELECT IBX.*,
                           CASE
                               WHEN IBX.BASE_BEPKEY = 'GarminEuropeEUR'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminEuropeDevEUR'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminEuropeTestEUR'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminEuropeStagingEUR'
                                       ELSE
                                           'GarminEuropeDevEUR'
                                   END
                               WHEN IBX.BASE_BEPKEY = 'GarminEuropeUSD'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminEuropeDevUSD'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminEuropeTestUSD'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminEuropeStagingUSD'
                                       ELSE
                                           'GarminEuropeDevUSD'
                                   END
                               WHEN IBX.BASE_BEPKEY = 'GarminEuropeGBP'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminEuropeDevGBP'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminEuropeTestGBP'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminEuropeStagingGBP'
                                       ELSE
                                           'GarminEuropeDevGBP'
                                   END
                               WHEN IBX.BASE_BEPKEY = 'GarminSwitzerlandGMBH'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminGMBHDev'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminGMBHTest'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminGMBHStaging'
                                       ELSE
                                           'GarminGMBHDev'
                                   END
                               WHEN IBX.BASE_BEPKEY =
                                    'GarminSwitzerlandDistr'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminSwissDistrDev'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminSwissDistrTest'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminSwissDistrStaging'
                                       ELSE
                                           'GarminSwissDistrDev'
                                   END
                               WHEN IBX.BASE_BEPKEY = 'GarminEuropeRON'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminEuropeDevRON'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminEuropeTestRON'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminEuropeStagingRON'
                                       ELSE
                                           'GarminEuropeDevRON'
                                   END
                               WHEN IBX.BASE_BEPKEY = 'GarminDeutschlandGmbH'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminDeutschlandGmbH-EcomDev'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminDeutschlandGmbH-EcomTest'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminDeutschlandGmbH-EcomStaging'
                                       ELSE
                                           'GarminDeutschlandGmbH-EcomDev'
                                   END
                               WHEN IBX.BASE_BEPKEY = 'GarminAustria'
                               THEN
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           'GarminAustria-EcomDev'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           'GarminAustria-EcomTest'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           'GarminAustria-EcomStaging'
                                       ELSE
                                           'GarminAustria-EcomDev'
                                   END
                               ELSE
                                   CASE
                                       WHEN db.name = 'ORBDEV'
                                       THEN
                                           IBX.BASE_BEPKEY || 'Dev'
                                       WHEN db.name = 'ORBTST'
                                       THEN
                                           IBX.BASE_BEPKEY || 'Test'
                                       WHEN db.name = 'ORBQA'
                                       THEN
                                           IBX.BASE_BEPKEY || 'Staging'
                                       ELSE
                                           IBX.BASE_BEPKEY || 'Dev'
                                   END
                           END    AS NEW_BEPKEY
                      FROM (SELECT ib.bepid,
                                   ib.bep_account_id,
                                   ib.key,
                                   REPLACE (
                                       REPLACE (
                                           REPLACE (
                                               REPLACE (ib.key, 'Dev', NULL),
                                               'Test',
                                               NULL),
                                           'Staging',
                                           NULL),
                                       '-Ecom',
                                       NULL)    AS BASE_BEPKEY
                              FROM apps.iby_bepkeys ib
                             WHERE     IB.KEY LIKE 'Garmin%'
                                   AND IB.KEY NOT LIKE '%DELETE%'
                                   AND IB.KEY NOT LIKE '%VeriSign%') IBX,
                          --v$database db
                     (select apps.xx_db_util.get_dbname name from dual) db
                           ) IBZ,
                   apps.iby_routinginfo  ir
             WHERE     ibz.bepid = ir.bepid
                   AND ibz.bep_account_id = ir.bep_account_id;


        --Update the apps.iby_bep_acct_opt_vals column account_option_value
        -- This need apps.iby_bepkeys updated to the new value -- done in cursor C1
        CURSOR c2 IS
            SELECT ib.bepid,
                   ib.key,
                   ib.bep_account_id,
                   ibaov.account_option_code,
                   ibaov.account_option_value,
                   CASE
                       WHEN ibaov.account_option_code = 'IDEAL_SOAP_SERVICE'
                       THEN
                           'https://pal-test.adyen.com/pal/servlet/soap/Payment'
                       WHEN ibaov.account_option_code = 'MERCHANT_ACCOUNT'
                       THEN
                           CASE
                               WHEN ib.key = 'GarminEuropeDevEUR'
                               THEN
                                   'GarminEuropeDev'
                               WHEN ib.key = 'GarminEuropeDevUSD'
                               THEN
                                   'GarminEuropeDev'
                               WHEN ib.key = 'GarminEuropeDevGBP'
                               THEN
                                   'GarminEuropeDev'
                               WHEN ib.key = 'GarminEuropeDevRON'
                               THEN
                                   'GarminEuropeDev'
                               WHEN ib.key = 'GarminEuropeTestEUR'
                               THEN
                                   'GarminEuropeTest'
                               WHEN ib.key = 'GarminEuropeTestUSD'
                               THEN
                                   'GarminEuropeTest'
                               WHEN ib.key = 'GarminEuropeTestGBP'
                               THEN
                                   'GarminEuropeTest'
                               WHEN ib.key = 'GarminEuropeTestRON'
                               THEN
                                   'GarminEuropeTest'
                               WHEN ib.key = 'GarminEuropeStagingEUR'
                               THEN
                                   'GarminEuropeStaging'
                               WHEN ib.key = 'GarminEuropeStagingGBP'
                               THEN
                                   'GarminEuropeStaging'
                               WHEN ib.key = 'GarminEuropeStagingRON'
                               THEN
                                   'GarminEuropeStaging'
                               WHEN ib.key = 'GarminEuropeStagingUSD'
                               THEN
                                   'GarminEuropeStaging'
                               ELSE
                                   ib.key
                           END
                       WHEN ibaov.account_option_code = 'MERCHANT_NAME'
                       THEN
                           ib.key
                       WHEN ibaov.account_option_code = 'PAYMENT_HOP_URL'
                       THEN
                           'https://test.adyen.com/hpp/pay.shtml'
                       WHEN ibaov.account_option_code =
                            'PAYMENT_JSON_SERVICE'
                       THEN
                           'https://pal-test.adyen.com/pal/servlet/Payment/v30/'
                       WHEN ibaov.account_option_code = 'PAYMENT_SKIN_CODE'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV' THEN 'Fu4l0Cyi'
                               WHEN db.name = 'ORBTST' THEN 'v1Qiar7p'
                               WHEN db.name = 'ORBQA' THEN 'TKcQDfzd'
                               ELSE 'Fu4l0Cyi'
                           END
                       WHEN ibaov.account_option_code = 'PAYMENT_SKIN_KEY'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'C4F8393B0656E18B50BB2458F0EEBCB66FBCF95B3A9B6FA9A24A9C83DED520AD'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   '24737FF3CCC7EEFFF363E8DE55A06744800258849F1A85DED1606CFBF0016EE1'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   '82C167EBDCCBCF8E0EB7EE6A06996B15CA1DB1F34AB6D5A03D09A69F2DF1E565'
                               ELSE
                                   'C4F8393B0656E18B50BB2458F0EEBCB66FBCF95B3A9B6FA9A24A9C83DED520AD'
                           END
                       WHEN ibaov.account_option_code =
                            'PAYMENT_SOAP_SERVICE'
                       THEN
                           'https://pal-test.adyen.com/pal/servlet/Payment/v30'
                       WHEN ibaov.account_option_code =
                            'RECURRING_JSON_SERVICE'
                       THEN
                           'https://pal-test.adyen.com/pal/servlet/Recurring/v30/'
                       WHEN ibaov.account_option_code = 'WEB_PASSWORD'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   '9h1919f1>^Zk7Xe5)L4(]wsy#'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   '9h1919f1>^Zk7Xe5)L4(]wsy#'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   '9h1919f1>^Zk7Xe5)L4(]wsy#'
                               ELSE
                                   '9h1919f1>^Zk7Xe5)L4(]wsy#'
                           END
                       WHEN ibaov.account_option_code = 'WEB_USERNAME'
                       THEN
                           'ws@Company.Garmin'
                       ELSE
                           ibaov.account_option_value
                   END    AS NEW_account_option_value
              FROM apps.iby_bepkeys            ib,
                   apps.iby_bep_acct_opt_vals  ibaov,
                  --v$database db
                     (select apps.xx_db_util.get_dbname name from dual) db
             WHERE     ib.bepid = ibaov.bepid
                   AND ib.bep_account_id = ibaov.bep_account_id
                   AND IB.KEY LIKE 'Garmin%'
                   AND IB.KEY NOT LIKE '%DELETE%'
                   AND IB.KEY NOT LIKE '%VeriSign%';

        --Update the apps.FND_LOOKUP_VALUES columns lookup_code, MEANING, description
        CURSOR c3 IS
            SELECT flvx.*,
                   CASE
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINEUROPEEUR'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINEUROPEDEVEUR'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINEUROPETESTEUR'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINEUROPESTAGINGEUR'
                               ELSE
                                   'GARMINEUROPEDEVEUR'
                           END
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINEUROPEGBP'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINEUROPEDEVGBP'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINEUROPETESTGBP'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINEUROPESTAGINGGBP'
                               ELSE
                                   'GARMINEUROPEDEVGBP'
                           END
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINEUROPERON'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINEUROPEDEVRON'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINEUROPETESTRON'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINEUROPESTAGINGRON'
                               ELSE
                                   'GARMINEUROPEDEVRON'
                           END
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINEUROPEUSD'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINEUROPEDEVUSD'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINEUROPETESTUSD'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINEUROPESTAGINGUSD'
                               ELSE
                                   'GARMINEUROPEDEVUSD'
                           END
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINSWITZERLANDGMBH'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINGMBHDEV'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINGMBHTEST'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINGMBHSTAGING'
                               ELSE
                                   'GARMINGMBHDEV'
                           END
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINSWITZERLANDDISTR'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINSWISSDISTRDEV'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINSWISSDISTRTEST'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINSWISSDISTRSTAGING'
                               ELSE
                                   'GARMINSWISSDISTRDEV'
                           END
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINDEUTSCHLANDGMBH'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINDEUTSCHLANDGMBH-ECOMDEV'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINDEUTSCHLANDGMBH-ECOMTEST'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINDEUTSCHLANDGMBH-ECOMSTAGING'
                               ELSE
                                   'GARMINDEUTSCHLANDGMBH-ECOMDEV'
                           END
                       WHEN flvx.BASE_LOOKUP_CODE = 'GARMINAUSTRIA'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GARMINAUSTRIA-ECOMDEV'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GARMINAUSTRIA-ECOMTEST'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GARMINAUSTRIA-ECOMSTAGING'
                               ELSE
                                   'GARMINAUSTRIA-ECOMDEV'
                           END
                       WHEN flvx.LOOKUP_CODE = 'GARMINEUROPEHOSTTEST'
                       THEN
                           flvx.LOOKUP_CODE
                       ELSE
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   flvx.BASE_LOOKUP_CODE || 'DEV'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   flvx.BASE_LOOKUP_CODE || 'TEST'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   flvx.BASE_LOOKUP_CODE || 'STAGING'
                               ELSE
                                   flvx.BASE_LOOKUP_CODE || 'DEV'
                           END
                   END    AS new_lookup_code,
                   CASE
                       WHEN flvx.BASE_MEANING = 'GarminEuropeEUR'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GarminEuropeDevEUR'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GarminEuropeTestEUR'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GarminEuropeStagingEUR'
                               ELSE
                                   'GarminEuropeDevEUR'
                           END
                       WHEN flvx.BASE_MEANING = 'GarminEuropeGBP'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GarminEuropeDevGBP'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GarminEuropeTestGBP'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GarminEuropeStagingGBP'
                               ELSE
                                   'GarminEuropeDevGBP'
                           END
                       WHEN flvx.BASE_MEANING = 'GarminEuropeRON'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GarminEuropeDevRON'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GarminEuropeTestRON'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GarminEuropeStagingRON'
                               ELSE
                                   'GarminEuropeDevRON'
                           END
                       WHEN flvx.BASE_MEANING = 'GarminEuropeUSD'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GarminEuropeDevUSD'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GarminEuropeTestUSD'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GarminEuropeStagingUSD'
                               ELSE
                                   'GarminEuropeDevUSD'
                           END
                       WHEN flvx.BASE_MEANING = 'GarminSwitzerlandGMBH'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GarminGMBHDev'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GarminGMBHTest'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GarminGMBHStaging'
                               ELSE
                                   'GarminGMBHDev'
                           END
                       WHEN flvx.BASE_MEANING = 'GarminDeutschlandGmbH'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GarminDeutschlandGmbH-EcomDev'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GarminDeutschlandGmbH-EcomTest'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GarminDeutschlandGmbH-EcomStaging'
                               ELSE
                                   'GarminDeutschlandGmbH-EcomDev'
                           END
                       WHEN flvx.BASE_MEANING = 'GarminAustria'
                       THEN
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   'GarminAustria-EcomDev'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   'GarminAustria-EcomTest'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   'GarminAustria-EcomStaging'
                               ELSE
                                   'GarminAustria-EcomDev'
                           END
                       WHEN flvx.MEANING = 'GARMINEUROPEHOSTTEST'
                       THEN
                           flvx.MEANING
                       ELSE
                           CASE
                               WHEN db.name = 'ORBDEV'
                               THEN
                                   flvx.BASE_MEANING || 'Dev'
                               WHEN db.name = 'ORBTST'
                               THEN
                                   flvx.BASE_MEANING || 'Test'
                               WHEN db.name = 'ORBQA'
                               THEN
                                   flvx.BASE_MEANING || 'Staging'
                               ELSE
                                   flvx.BASE_MEANING || 'Dev'
                           END
                   END    AS new_meaning
              FROM (SELECT flv.lookup_type,
                           flv.lookup_code,
                           flv.MEANING,
                           flv.description,
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (flv.lookup_code, 'DEV', NULL),
                                       'TEST',
                                       NULL),
                                   'STAGING',
                                   NULL),
                               '-ECOM',
                               NULL)    AS BASE_LOOKUP_CODE,
                           REPLACE (
                               REPLACE (
                                   REPLACE (
                                       REPLACE (flv.MEANING, 'Dev', NULL),
                                       'Test',
                                       NULL),
                                   'Staging',
                                   NULL),
                               '-Ecom',
                               NULL)    AS BASE_MEANING
                      FROM apps.FND_LOOKUP_VALUES_VL flv
                     WHERE     flv.lookup_type =
                               'XX_ADYEN_PMT_SYS_IDENTIFIERS'
                           AND flv.enabled_flag = 'Y'
                           AND NVL (flv.end_date_active, SYSDATE + 1) >
                               SYSDATE) flvx,
                   --v$database db
                     (select apps.xx_db_util.get_dbname name from dual) db
                   ;

        L_ADMINURL        apps.IBY_BEPINFO.ADMINURL%TYPE;
        L_BASEURL         apps.IBY_BEPINFO.BASEURL%TYPE;
    BEGIN
        -- SELECT name INTO v_db_name FROM v$database; -- commented for version 1.0

        select apps.xx_db_util.get_dbname INTO v_db_name from dual; -- added for version 1.0


        build_log (
               procedure_name
            || ' begin...'
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        IF v_db_name = 'ORBDEV'
        THEN
            L_ADMINURL := 'https://ca-test.adyen.com';
            L_BASEURL := 'http://soatestr12.garmin.com/oramipp_adn/';
        ELSIF v_db_name = 'ORBTST'
        THEN
            L_ADMINURL := 'https://ca-test.adyen.com';
            L_BASEURL := 'http://soatestr12.garmin.com/oramipp_adn/';
        ELSIF v_db_name = 'ORBQA'
        THEN
            L_ADMINURL := 'https://ca-test.adyen.com';
            L_BASEURL := 'http://soaqar12.garmin.com/oramipp_adn/';
        ELSE
            L_ADMINURL := 'https://ca-test.adyen.com';
            L_BASEURL := 'http://soatestr12.garmin.com/oramipp_adn/';
        END IF;

        UPDATE APPS.IBY_BEPINFO I
           SET I.ADMINURL = L_ADMINURL, I.BASEURL = L_BASEURL
         WHERE I.NAME = 'Adyen';

        COMMIT;

        build_log (' ');
        build_log ('IBY_BEPINFO Adyen Update  ADMINURL/BASEUSR');

        build_log (' ');
        build_log ('Update Organization Profile Values');

        FOR L_C0 IN C0
        LOOP
            IF L_C0.NEW_profile_option_value IS NOT NULL
            THEN
                build_log (' ');
                update_profile_value ('=====>Step 1.x',
                                      p_result,
                                      L_C0.profile_option_name,
                                      L_C0.NEW_profile_option_value,
                                      'ORG',
                                      L_C0.level_value,
                                      NULL,
                                      NULL);
                build_log (
                       'Profile Value update: '
                    || L_C0.profile_option_name
                    || ' '
                    || L_C0.LEVEL_NAME
                    || ' '
                    || TO_CHAR (L_C0.level_value)
                    || ' '
                    || L_C0.NAME
                    || ' New Value '
                    || L_C0.NEW_profile_option_value);
            ELSE
                build_log (' ');
                build_log (
                       'Profile Value Warning No New Value set Value not changed: '
                    || L_C0.profile_option_name
                    || ' '
                    || L_C0.LEVEL_NAME
                    || ' '
                    || TO_CHAR (L_C0.level_value)
                    || ' Base Value '
                    || l_C0.BASE_profile_option_value
                    || ' ********** WARNING **********');
            END IF;
        END LOOP;

        build_log (' ');
        build_log ('Update apps.iby_bepkeys');

        FOR L_C1 IN C1
        LOOP
            IF l_c1.NEW_BEPKEY IS NOT NULL
            THEN
                UPDATE apps.iby_bepkeys ib
                   SET ib.key = l_c1.NEW_BEPKEY,
                       ib.LAST_UPDATED_BY = 0,
                       ib.LAST_UPDATE_DATE = SYSDATE
                 WHERE     ib.bepid = L_c1.bepid
                       AND ib.bep_account_id = l_c1.bep_account_id;

                UPDATE apps.iby_routinginfo ir
                   SET ir.bepkey = l_c1.NEW_BEPKEY,
                       ir.LAST_UPDATED_BY = 0,
                       ir.LAST_UPDATE_DATE = SYSDATE
                 WHERE     ir.bepid = l_c1.bepid
                       AND ir.bep_account_id = l_c1.bep_account_id;

                build_log ('iby_bepkeys update new Key ' || l_c1.NEW_BEPKEY);
            ELSE
                build_log (
                       'FAILED iby_bepkeys update new Key IS NULL, Old key = '
                    || l_c1.key);
            END IF;
        END LOOP;

        COMMIT;

        build_log (' ');
        build_log ('Update apps.iby_bep_acct_opt_vals');

        FOR L_C2 IN C2
        LOOP
            IF l_c2.NEW_account_option_value IS NOT NULL
            THEN
                UPDATE apps.iby_bep_acct_opt_vals ibaov
                   SET ibaov.account_option_value =
                           l_c2.NEW_account_option_value,
                       ibaov.LAST_UPDATED_BY = 0,
                       ibaov.LAST_UPDATE_DATE = SYSDATE
                 WHERE     ibaov.bepid = l_c2.bepid
                       AND ibaov.bep_account_id = l_c2.bep_account_id
                       AND ibaov.account_option_code =
                           l_c2.account_option_code;

                build_log (
                       'Options Update key: '
                    || l_c2.key
                    || ' Option Code: '
                    || l_c2.account_option_code
                    || ' New Value: '
                    || l_c2.NEW_account_option_value);
            ELSE
                build_log (
                       'FAILED Options Update key: '
                    || l_c2.key
                    || ' Option Code: '
                    || l_c2.account_option_code);
            END IF;
        END LOOP;

        COMMIT;

        build_log (' ');
        build_log (
            'Update apps.FND_LOOKUP_VALUES - XX_ADYEN_PMT_SYS_IDENTIFIERS');

        --Update the apps.FND_LOOKUP_VALUES columns lookup_code, MEANING, description

        FOR L_C3 IN C3
        LOOP
            BEGIN
                IF     L_C3.new_lookup_code IS NOT NULL
                   AND L_C3.new_meaning IS NOT NULL
                THEN
                    UPDATE apps.FND_LOOKUP_VALUES flv
                       SET flv.lookup_code = L_C3.new_lookup_code,
                           flv.MEANING = L_C3.new_meaning,
                           flv.description = L_C3.new_meaning,
                           flv.LAST_UPDATED_BY = 0,
                           flv.LAST_UPDATE_DATE = SYSDATE
                     WHERE     flv.lookup_type =
                               'XX_ADYEN_PMT_SYS_IDENTIFIERS'
                           AND flv.enabled_flag = 'Y'
                           AND NVL (flv.end_date_active, SYSDATE + 1) >
                               SYSDATE
                           AND flv.lookup_code = L_C3.lookup_code;

                    build_log (
                           'lookup code Update: '
                        || L_C3.lookup_code
                        || ' New lookup code: '
                        || L_C3.new_lookup_code
                        || ' New meaning/descriptioon: '
                        || L_C3.new_meaning);
                ELSE
                    build_log (
                           'FAILED New Values Null?? lookup code Update: '
                        || L_C3.lookup_code
                        || ' meaning/descriptioon:  '
                        || L_C3.meaning);
                END IF;
            EXCEPTION
                WHEN OTHERS
                THEN
                    build_log (
                           'Failed lookup code Update: '
                        || L_C3.lookup_code
                        || ' New lookup code: '
                        || L_C3.new_lookup_code
                        || ' New meaning/descriptioon: '
                        || L_C3.new_meaning);
            END;
        END LOOP;

        COMMIT;

        build_log (' ');

        build_log (
               procedure_name
            || ' successfully completed '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));
        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       => ' Post Clone Log for ' || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_6_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);
            RETURN;
    END;

    -- end of post clone additions for APM

    -- This submit does not work
    -- But left it in code because I think it is close to working.
    -- It seems to error on FND_SUBMIT.submit_set
    --  SELECT rs.request_set_name,
    --         fa.application_short_name,
    --         CP.concurrent_program_name,
    --         CP.enabled_flag,
    --         RSS.stage_name,
    --         RSP.sequence
    --    FROM apps.fnd_request_sets RS,
    --         apps.fnd_request_set_stages RSS,
    --         apps.fnd_concurrent_programs CP,
    --         apps.fnd_request_set_programs RSP,
    --         apps.fnd_application fa
    --   WHERE     RSS.set_application_id = RS.application_id
    --         AND RSS.request_set_id = RS.request_set_id
    --         AND RSP.set_application_id = RSS.set_application_id
    --         AND RSP.request_set_id = RSS.request_set_id
    --         AND RSP.request_set_stage_id = RSS.request_set_stage_id
    --         AND RSP.program_application_id = CP.application_id(+)
    --         AND RSP.concurrent_program_id = CP.concurrent_program_id(+)
    --         AND rs.application_id = fa.application_id
    --         AND rs.request_set_name = 'XX_GATHER_99_ON_CERTAIN_SCHEMA'
    --         AND CP.concurrent_program_name = 'FNDGSCST'
    --ORDER BY RSP.sequence;
    PROCEDURE SUBMIT_GATHER_STATS
    IS
        err_num                NUMBER;
        err_msg                VARCHAR (100);
        procedure_name         VARCHAR2 (200) := 'SUBMIT_GATHER_STATS';
        v_db_name              VARCHAR2 (100);
        v_user_name            VARCHAR2 (40) := 'SYSADMIN';
        v_resp_description     VARCHAR2 (240) := 'System Administrator';
        v_user_id              NUMBER;
        v_responsibility_id    NUMBER;
        v_application_id       NUMBER;
        V_REQUEST_SET_NAME     apps.fnd_request_sets.request_set_name%TYPE;
        V_REQUEST_SET_APPL     apps.fnd_application.application_short_name%TYPE;
        V_SET_MODE             BOOLEAN := FALSE;
        V_REQUEST_SET_EXIST    BOOLEAN := FALSE;
        V_SET_SUBMIT_PROGRAM   BOOLEAN := FALSE;
        v_set_interval         BOOLEAN := FALSE;
        v_req_id               NUMBER;
        V_ERROR_MSG            VARCHAR2 (200);
        V_START_DATE           DATE;
    BEGIN
        SELECT db.name
          INTO v_db_name
          FROM     (select apps.xx_db_util.get_dbname name from dual) db; -- added for version 1.0
          --v$database db  -- commented for version 1.0


        build_log (
               procedure_name
            || ' begin...'
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

        BEGIN
            SELECT user_id
              INTO v_user_id
              FROM apps.fnd_user
             WHERE user_name = v_user_name;

            build_log ('User found: ' || v_user_name);
        EXCEPTION
            WHEN OTHERS
            THEN
                build_log ('User not found: ' || v_user_name);
        END;

        BEGIN
            SELECT application_id, responsibility_id
              INTO v_application_id, v_responsibility_id
              FROM apps.fnd_responsibility_vl
             WHERE RESPONSIBILITY_NAME = v_resp_description;

            build_log ('Responsibility found: ' || v_resp_description);
        EXCEPTION
            WHEN OTHERS
            THEN
                build_log (
                    'Responsibility not found: ' || v_resp_description);
        END;

        apps.fnd_global.apps_initialize (user_id        => v_user_id,
                                         resp_id        => v_responsibility_id,
                                         resp_appl_id   => v_application_id);

        --      APPS.MO_GLOBAL.INIT('SYSADMIN');
        --      APPS.MO_GLOBAL.set_policy_context('S',82);


        BEGIN
            SELECT rs.request_set_name, fa.application_short_name
              INTO V_REQUEST_SET_NAME, V_REQUEST_SET_APPL
              FROM apps.fnd_request_sets rs, apps.fnd_application fa
             WHERE     rs.application_id = fa.application_id
                   AND rs.request_set_name = 'XX_GATHER_99_ON_CERTAIN_SCHEMA';

            build_log ('Found request set: XX_GATHER_99_ON_CERTAIN_SCHEMA');
        EXCEPTION
            WHEN OTHERS
            THEN
                V_ERROR_MSG :=
                    'Failed to find request set: XX_GATHER_99_ON_CERTAIN_SCHEMA';
                build_log (V_ERROR_MSG);
                RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        END;

        V_set_mode := apps.fnd_submit.set_mode (FALSE);

        IF (NOT V_SET_MODE)
        THEN
            V_ERROR_MSG := ' apps.fnd_submit.set_mode Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log (' apps.fnd_submit.set_mode Success');
        END IF;

        V_REQUEST_SET_EXIST :=
            apps.FND_SUBMIT.SET_REQUEST_SET (
                application   => V_REQUEST_SET_APPL,
                request_set   => V_REQUEST_SET_NAME);

        IF (NOT V_REQUEST_SET_EXIST)
        THEN
            V_ERROR_MSG := 'FND_SUBMIT.SET_REQUEST_SET Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('FND_SUBMIT.SET_REQUEST_SET Success');
        END IF;

        V_SET_SUBMIT_PROGRAM :=
            fnd_submit.submit_program (application   => 'FND',
                                       program       => 'FNDGSCST',
                                       stage         => 'XX_10',
                                       argument1     => 'ALL',
                                       argument2     => '30',
                                       argument3     => '16',
                                       argument4     => 'NOBACKUP',
                                       argument5     => NULL,
                                       argument6     => 'LASTRUN',
                                       argument7     => 'GATHER',
                                       argument8     => NULL,
                                       argument9     => 'Y');

        IF (NOT V_SET_SUBMIT_PROGRAM)
        THEN
            V_ERROR_MSG := 'fnd_submit.submit_program 1 Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_submit.submit_program 1 Success');
        END IF;

        V_SET_SUBMIT_PROGRAM :=
            fnd_submit.submit_program (application   => 'FND',
                                       program       => 'FNDGSCST',
                                       stage         => 'XX_10',
                                       argument1     => 'KEWILL',
                                       argument2     => '30',
                                       argument3     => '16',
                                       argument4     => 'NOBACKUP',
                                       argument5     => NULL,
                                       argument6     => 'LASTRUN',
                                       argument7     => 'GATHER',
                                       argument8     => NULL,
                                       argument9     => 'Y');

        IF (NOT V_SET_SUBMIT_PROGRAM)
        THEN
            V_ERROR_MSG := 'fnd_submit.submit_program 2 Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_submit.submit_program 2 Success');
        END IF;

        V_SET_SUBMIT_PROGRAM :=
            fnd_submit.submit_program (application   => 'FND',
                                       program       => 'FNDGSCST',
                                       stage         => 'XX_10',
                                       argument1     => 'GARMIN',
                                       argument2     => '99',
                                       argument3     => '16',
                                       argument4     => 'NOBACKUP',
                                       argument5     => NULL,
                                       argument6     => 'LASTRUN',
                                       argument7     => 'GATHER',
                                       argument8     => NULL,
                                       argument9     => 'Y');

        IF (NOT V_SET_SUBMIT_PROGRAM)
        THEN
            V_ERROR_MSG := 'fnd_submit.submit_program 3 Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_submit.submit_program 3 Success');
        END IF;

        V_SET_SUBMIT_PROGRAM :=
            fnd_submit.submit_program (application   => 'FND',
                                       program       => 'FNDGSCST',
                                       stage         => 'XX_10',
                                       argument1     => 'EUL4_US',
                                       argument2     => '30',
                                       argument3     => '16',
                                       argument4     => 'NOBACKUP',
                                       argument5     => NULL,
                                       argument6     => 'LASTRUN',
                                       argument7     => 'GATHER',
                                       argument8     => NULL,
                                       argument9     => 'Y');

        IF (NOT V_SET_SUBMIT_PROGRAM)
        THEN
            V_ERROR_MSG := 'fnd_submit.submit_program 4 Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_submit.submit_program 4 Success');
        END IF;

        V_SET_SUBMIT_PROGRAM :=
            fnd_submit.submit_program (application   => 'FND',
                                       program       => 'FNDGSCST',
                                       stage         => 'XX_10',
                                       argument1     => 'VERTEX',
                                       argument2     => '30',
                                       argument3     => '16',
                                       argument4     => 'NOBACKUP',
                                       argument5     => NULL,
                                       argument6     => 'LASTRUN',
                                       argument7     => 'GATHER',
                                       argument8     => NULL,
                                       argument9     => 'Y');

        IF (NOT V_SET_SUBMIT_PROGRAM)
        THEN
            V_ERROR_MSG := 'fnd_submit.submit_program 5 Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_submit.submit_program 5 Success');
        END IF;

        V_SET_SUBMIT_PROGRAM :=
            fnd_submit.submit_program (application   => 'FND',
                                       program       => 'FNDGSCST',
                                       stage         => 'XX_10',
                                       argument1     => 'EDIGIS',
                                       argument2     => '30',
                                       argument3     => '16',
                                       argument4     => 'NOBACKUP',
                                       argument5     => NULL,
                                       argument6     => 'LASTRUN',
                                       argument7     => 'GATHER',
                                       argument8     => NULL,
                                       argument9     => 'Y');

        IF (NOT V_SET_SUBMIT_PROGRAM)
        THEN
            V_ERROR_MSG := 'fnd_submit.submit_program 6 Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_submit.submit_program 6 Success');
        END IF;

        v_set_interval := apps.fnd_request.set_options ('YES');

        IF (NOT V_set_interval)
        THEN
            V_ERROR_MSG := 'fnd_request.set_options Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_request.set_options Success');
        END IF;

        V_set_interval :=
            apps.fnd_request.set_repeat_options (repeat_time       => NULL,
                                                 repeat_interval   => 7,
                                                 repeat_unit       => 'DAYS',
                                                 repeat_type       => 'START',
                                                 repeat_end_time   => NULL);

        IF (NOT V_set_interval)
        THEN
            V_ERROR_MSG := 'fnd_request.set_repeat_options Failed';
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log ('fnd_request.set_repeat_options Success');
        END IF;

        -- Find Friday

        V_START_DATE := SYSDATE;

        LOOP
            IF (TO_CHAR (V_START_DATE, 'd') = '6')
            THEN
                EXIT;
            END IF;

            V_START_DATE := V_START_DATE + 1;
        END LOOP;

        build_log (
               'friday '
            || TO_CHAR (V_START_DATE, 'DD-MON-YYYY HH24:MI:SS')
            || ' Success');

        -- Set Friday start time to 9PM
        V_START_DATE := TRUNC (V_START_DATE) + (21 / 24);
        build_log (
               'friday 9PM '
            || TO_CHAR (V_START_DATE, 'DD-MON-YYYY HH24:MI:SS')
            || ' Success');

        v_req_id :=
            FND_SUBMIT.submit_set (
                start_time    =>
                    TO_CHAR (V_START_DATE, 'DD-MON-YYYY HH24:MI:SS'),
                sub_request   => FALSE);

        --      v_req_id := FND_SUBMIT.submit_set (start_time    => NULL,
        --                                         sub_request   => FALSE);

        IF (v_req_id = 0)
        THEN
            V_ERROR_MSG :=
                'FND_SUBMIT.submit_set Failed ' || apps.fnd_message.get;
            build_log (V_ERROR_MSG);
            RAISE_APPLICATION_ERROR (-20000, V_ERROR_MSG);
        ELSE
            build_log (V_ERROR_MSG || ' Success');
        END IF;

        build_log (' ');

        build_log (
               procedure_name
            || ' successfully completed '
            || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));
        send_mail (
            p_to            => dba_email_address,
            p_cc            => dba_email_address_cc,
            p_from          => g_email_from,
            p_subject       => ' Post Clone Log for ' || v_db_name,
            p_text_msg      =>
                   'DBA, '
                || CHR (10)
                || CHR (10)
                || CHR (10)
                || 'Please save the attached log file and open it in Wordpad!'
                || CHR (10)
                || CHR (10)
                || 'Post Clone Robot (DEVMONKEY)',
            p_attach_name   =>
                   v_db_name
                || '_POST_CLONE_LOG_7_'
                || TO_CHAR (SYSDATE, 'yyyymmdd')
                || '.txt',
            p_attach_mime   => 'text/plain',
            p_attach_clob   => v_all_message,                    --clob object
            p_smtp_host     => 'smtp.garmin.com');
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            err_num := SQLCODE;
            err_msg := SUBSTR (SQLERRM, 1, 100);

            build_log (
                   '                  '
                || 'Failed in '
                || procedure_name
                || ' '
                || err_num
                || ' '
                || err_msg);
            RETURN;
    END;

   PROCEDURE xx_concurrent
   AS
      procedure_name        VARCHAR2 (200) := 'XX_CONCURRENT';
      v_db_name             VARCHAR2 (100);

   BEGIN

     -- SELECT name INTO v_db_name FROM v$database; -- commented for version 1.0

         select apps.xx_db_util.get_dbname INTO v_db_name  from dual; -- added for version 1.0

      build_log (procedure_name || ' begin...' || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

      build_log (' ');

      schedule_fndwfbg_daily ('=====>Step 40');

      build_log (' ');

      schedule_fndwfbg_5_minutes ('=====>Step 41');

      build_log (' ');

      schedule_fndwfpr ('=====>Step 42');

      build_log (' ');

      schedule_fndwfbes_control_qc ('=====>Step 43');

      build_log (' ');

      schedule_fndscprg ('=====>Step 44');

      build_log (' ');

      schedule_fndcppur ('=====>Step 45');

      build_log (' ');

      schedule_cmctcm_5_minutes ('=====>Step 46');

      build_log (' ');

      schedule_wictms_5_minutes ('=====>Step 47');

      build_log (' ');

      schedule_wscmtm_5_minutes ('=====>Step 48');

      build_log (' ');

      schedule_inctcm_5_minutes ('=====>Step 49');

      build_log (' ');

      build_log (procedure_name || ' PLAN Post Clone successfully completed ' || TO_CHAR (SYSDATE, 'yyyy-mm-dd hh:mi:ss'));

      send_mail (
         p_to            => dba_email_address,
         p_cc            => dba_email_address_cc,
         p_from          => g_email_from,
         p_subject       => ' Post Clone Log for ' || v_db_name,
         p_text_msg      =>    'DBA, '
                            || CHR (10)
                            || CHR (10)
                            || CHR (10)
                            || 'Please save the attached log file and open it in Wordpad!'
                            || CHR (10)
                            || CHR (10)
                            || 'Post Clone Robot (DEVMONKEY)',
         p_attach_name   => v_db_name || '_POST_CLONE_LOG_2_' || TO_CHAR (SYSDATE, 'yyyymmdd') || '.txt',
         p_attach_mime   => 'text/plain',
         p_attach_clob   => v_all_message,                                                                 --clob object
         p_smtp_host     => 'smtp.garmin.com');
      COMMIT;
   END;
END xx_post_clone_steps;
/
