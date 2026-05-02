---   DO_ANY_SQL.SQL

---   &1 is the target schema under which the supplied command is to be executed

---   &2 is the command to be executed.  There should be no semicolon at the
---          end of this command.

---   Example usage:

---   SQL>  @ do_any_sql ASM "grant select on ASM_GROUP_PART_LOCS to APPS"


set verify off

CREATE PROCEDURE &1..ANY_SQL 
                       (SQL_COMMAND IN VARCHAR2) AS
 CURSOR_VAR     INTEGER;
 RETURN_VAL     INTEGER;
BEGIN
  CURSOR_VAR := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(CURSOR_VAR,SQL_COMMAND,DBMS_SQL.NATIVE);
  RETURN_VAL := DBMS_SQL.EXECUTE(CURSOR_VAR);
  DBMS_SQL.CLOSE_CURSOR(CURSOR_VAR);
END;
/

EXECUTE &1..ANY_SQL ('&2');

drop procedure &1..ANY_SQL 
/
