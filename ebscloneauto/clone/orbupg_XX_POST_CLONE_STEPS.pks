CREATE OR REPLACE PACKAGE APPS.xx_post_clone_steps
/********************************************************************************************
    *
    * Created By: Shuai Wang.
    * Creation Date: 12-05-2011.
    *
    * $Header: /cvs/orbit/sql/Post_Clone/XX_POST_CLONE_STEPS.pks,v 1.7 2013-02-19 20:08:49 wangs Exp $
-- R12 July 13, 2015 Roger Wolf Added AP_PROFILE Email changes -- ERPPJ-9914 Automate Post Clone steps in AP
--     December 9, 2015 Roger Wolf EBA-4302 Post clone steps for APM phase2
--                                 added APM_PROFILE
******************************************************************************************************/
AS
   v_debug      VARCHAR2 (1) := 'Y';
   test_count   NUMBER := 1;

   fail         VARCHAR2 (30) := 'FAIL';
   success      VARCHAR2 (30) := 'SUCCESS';


   PROCEDURE main (p_source_db        VARCHAR2,
                   p_garmin_pass      VARCHAR2,
                   p_apps_pass        VARCHAR2,
                   p_selapps_pass     VARCHAR2,
                   pr_source_db       VARCHAR2,    --confirm p_source_db again
                   pr_garmin_pass     VARCHAR2,  --confirm p_garmin_pass again
                   pr_apps_pass       VARCHAR2,    --confirm p_apps_pass again
                   pr_selapps_pass    VARCHAR2); --confirm p_selapps_pass again;


   PROCEDURE starting (p_source_db VARCHAR2, pr_source_db VARCHAR2); --confirm p_selapps_pass again;

   PROCEDURE disable_customer_email;

   PROCEDURE remove_vendor_email (p_step VARCHAR2, p_result OUT VARCHAR2);

   PROCEDURE update_loadtest_users (p_step VARCHAR2, p_result OUT VARCHAR2);

   PROCEDURE post_enc_cc_scrub;

   PROCEDURE AP_PROFILE;

   PROCEDURE APM_PROFILE;
   
   PROCEDURE SUBMIT_GATHER_STATS;

   PROCEDURE xx_validate(P_RESULT OUT VARCHAR2);

   PROCEDURE xx_concurrent;

END xx_post_clone_steps;
/