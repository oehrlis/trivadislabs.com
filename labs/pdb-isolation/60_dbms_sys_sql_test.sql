----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 60_dbms_sys_sql_test.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @60_dbms_sys_sql_test
--  Purpose...: Script to verify DBMS_SYS_SQL
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
-- default values
DEFINE def_pdb_admin_user = "pdbadmin"
DEFINE def_pdb_admin_pwd  = "LAB01schulung"
DEFINE def_pdb_db_name    = "pdbsec"

-- define a default value for parameter if argument 1,2 or 3 is empty
SET FEEDBACK OFF
SET VERIFY OFF
COLUMN 1 NEW_VALUE 1 NOPRINT
COLUMN 2 NEW_VALUE 2 NOPRINT
COLUMN 3 NEW_VALUE 3 NOPRINT
SELECT '' "1" FROM dual WHERE ROWNUM = 0;
SELECT '' "2" FROM dual WHERE ROWNUM = 0;
SELECT '' "3" FROM dual WHERE ROWNUM = 0;
DEFINE pdb_db_name    = &1 &def_pdb_db_name
DEFINE pdb_admin_user = &2 &def_pdb_admin_user
DEFINE pdb_admin_pwd  = &3 &def_pdb_admin_pwd
COLUMN pdb_db_name NEW_VALUE pdb_db_name NOPRINT
COLUMN username FORMAT a30
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;
SET PAGESIZE 200 LINESIZE 160

-- Cleanup and remove old credentials if they do exists
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=&pdb_db_name;
DECLARE
    vcount INTEGER :=0;
BEGIN
    SELECT count(1) INTO vcount FROM dba_users WHERE username = 'SYS_SQL_TEST';
    IF vcount != 0 THEN
        EXECUTE IMMEDIATE ('DROP USER sys_sql_test CASCADE');
    END IF;
END;
/

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- 60_dbms_sys_sql_test.sql : test to execute DBMS_SYS_SQL
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
SHOW USER
SHOW CON_NAME
---------------------------------------------------------------------------
-- execute DBMS_SYS_SQL as PDBADMIN
DECLARE
    l_cursors dbms_sql.number_table;
    l_result NUMBER;
BEGIN
    l_cursors(0):=dbms_sys_sql.open_cursor;
    dbms_sys_sql.parse_as_user(
        c => l_cursors(0),
        statement => 'GRANT sysdba TO sys_sql_test IDENTIFIED BY manager',
        language_flag => dbms_sql.native,
        userid => 0
    );
    --remove the job by executing
    l_result:=dbms_sys_sql.execute(l_cursors(0));
END;
/
PAUSE
---------------------------------------------------------------------------
-- List password file user
SELECT username, sysdba FROM v$pwfile_users;
PAUSE
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- set container to pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
SHOW USER
SHOW CON_NAME
---------------------------------------------------------------------------
-- execute DBMS_SYS_SQL as SYSDBA
DECLARE
    l_cursors dbms_sql.number_table;
    l_result NUMBER;
BEGIN
    l_cursors(0):=dbms_sys_sql.open_cursor;
    dbms_sys_sql.parse_as_user(
        c => l_cursors(0),
        statement => 'GRANT sysdba TO sys_sql_test IDENTIFIED BY manager',
        language_flag => dbms_sql.native,
        userid => 0
    );
    --remove the job by executing
    l_result:=dbms_sys_sql.execute(l_cursors(0));
END;
/
PAUSE
---------------------------------------------------------------------------
-- List password file user
SELECT username, sysdba FROM v$pwfile_users;
PAUSE
---------------------------------------------------------------------------
-- DROP the user sys_sql_test
DROP USER sys_sql_test CASCADE;
---------------------------------------------------------------------------
-- List password file user
SELECT username, sysdba FROM v$pwfile_users;
PAUSE

---------------------------------------------------------------------------
-- 60_dbms_sys_sql_test.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF --------------------------------------------------------------------
