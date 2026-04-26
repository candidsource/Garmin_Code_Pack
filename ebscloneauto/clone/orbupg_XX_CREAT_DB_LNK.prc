/* Formatted on 2/12/2013 4:37:42 PM (QP5 v5.227.12220.39724) */
/********************************************************************************************
     *
     * Created By: Shuai Wang.
     * Creation Date: 12-05-2011.
     *
     * This package is used and maintained by DBA to automate the post-cloned steps
     *
     * $Header: /cvs/orbit/sql/Post_Clone/XX_CREAT_DB_LNK.prc,v 1.2 2013-02-12 23:33:04 wangs Exp $
 ******************************************************************************************************/

CREATE OR REPLACE PROCEDURE apps.xx_cre_db_lnk (
   drop_dbl_statement         VARCHAR2,
   create_dbl_statement       VARCHAR2,
   p_result               OUT VARCHAR2)
AS
   err_num          NUMBER;
   err_msg          VARCHAR (100);
   procedure_name   VARCHAR2 (200) := 'apps.xx_cre_db_lnk';
BEGIN
   DBMS_OUTPUT.put_line ('                  ' || drop_dbl_statement);

   BEGIN
      EXECUTE IMMEDIATE drop_dbl_statement;
   EXCEPTION
      WHEN OTHERS
      THEN
         err_num := SQLCODE;
         err_msg := SUBSTR (SQLERRM, 1, 100);

         DBMS_OUTPUT.put_line (' ' || err_num || ' ' || err_msg);
   END;

   DBMS_OUTPUT.put_line ('                  ' || create_dbl_statement);

   EXECUTE IMMEDIATE create_dbl_statement;

   DBMS_OUTPUT.put_line (
      '                  ' || 'apps.xx_cre_db_lnk successfully');
   p_result := 'success';
   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      err_num := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 100);

      DBMS_OUTPUT.put_line (
         '  Failed in ' || procedure_name || ' ' || err_num || ' ' || err_msg);

      p_result := 'fail';
      RETURN;
END xx_cre_db_lnk;
/

CREATE OR REPLACE PROCEDURE garmin.xx_cre_db_lnk (
   drop_dbl_statement         VARCHAR2,
   create_dbl_statement       VARCHAR2,
   p_result               OUT VARCHAR2)
AS
   err_num          NUMBER;
   err_msg          VARCHAR (100);
   procedure_name   VARCHAR2 (200) := 'garmin.xx_cre_db_lnk';
BEGIN
   DBMS_OUTPUT.put_line ('                  ' || drop_dbl_statement);

   BEGIN
      EXECUTE IMMEDIATE drop_dbl_statement;
   EXCEPTION
      WHEN OTHERS
      THEN
         err_num := SQLCODE;
         err_msg := SUBSTR (SQLERRM, 1, 100);

         DBMS_OUTPUT.put_line (' ' || err_num || ' ' || err_msg);
   END;

   DBMS_OUTPUT.put_line ('                  ' || create_dbl_statement);

   EXECUTE IMMEDIATE create_dbl_statement;

   DBMS_OUTPUT.put_line (
      '                  ' || 'garmin.xx_cre_db_lnk successfully');
   p_result := 'success';
   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      err_num := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 100);

      DBMS_OUTPUT.put_line (
         '  Failed in ' || procedure_name || ' ' || err_num || ' ' || err_msg);

      p_result := 'fail';
      RETURN;
END xx_cre_db_lnk;
/

CREATE OR REPLACE PROCEDURE selapps.xx_cre_db_lnk (
   drop_dbl_statement         VARCHAR2,
   create_dbl_statement       VARCHAR2,
   p_result               OUT VARCHAR2)
AS
   err_num          NUMBER;
   err_msg          VARCHAR (100);
   procedure_name   VARCHAR2 (200) := 'selapps.xx_cre_db_lnk';
BEGIN
   DBMS_OUTPUT.put_line ('                  ' || drop_dbl_statement);

   BEGIN
      EXECUTE IMMEDIATE drop_dbl_statement;
   EXCEPTION
      WHEN OTHERS
      THEN
         err_num := SQLCODE;
         err_msg := SUBSTR (SQLERRM, 1, 100);

         DBMS_OUTPUT.put_line (' ' || err_num || ' ' || err_msg);
   END;

   DBMS_OUTPUT.put_line ('                  ' || create_dbl_statement);

   EXECUTE IMMEDIATE create_dbl_statement;

   DBMS_OUTPUT.put_line (
      '                  ' || 'selapps.xx_cre_db_lnk successfully');
   p_result := 'success';
   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      err_num := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 100);

      DBMS_OUTPUT.put_line (
         '  Failed in ' || procedure_name || ' ' || err_num || ' ' || err_msg);

      p_result := 'fail';
      RETURN;
END xx_cre_db_lnk;
/