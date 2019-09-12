----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 50_create_lockdown_profiles.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @50_create_lockdown_profiles
--  Purpose...: Script to create lockdown profiles
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
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;
-- define environment stuff
COLUMN tablespace_name FORMAT a25
COLUMN file_name FORMAT a100
SET PAGESIZE 200 LINESIZE 160

---------------------------------------------------------------------------
-- 50_create_lockdown_profiles.sql : prepare the PDB pdbsec
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
-- remove existing lockdown profiles
DECLARE
    vcount        INTEGER := 0;
    TYPE table_varchar IS
        TABLE OF VARCHAR2(128);
    profiles   table_varchar := table_varchar('SC_BASE','SC_DEFAULT','SC_JVM','SC_JVM_OS','SC_RESTRICTED','SC_SPARE','SC_APP','SC_OLTP','SC_DWH','SC_TRACE');

BEGIN  
    FOR i IN 1..profiles.count LOOP
        SELECT
            COUNT(1)
        INTO vcount
        FROM
            dba_lockdown_profiles
        WHERE
            profile_name = profiles(i);
        IF vcount != 0 THEN
            EXECUTE IMMEDIATE ('DROP LOCKDOWN PROFILE '||profiles(i));
        END IF; 
    END LOOP;
END;
/

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- Create lockdown profile sc_base 
CREATE LOCKDOWN PROFILE sc_base;
-- Enable all option except DATABASE QUEUING
ALTER LOCKDOWN PROFILE sc_base ENABLE OPTION ALL EXCEPT = ('DATABASE QUEUING');
PAUSE
---------------------------------------------------------------------------
-- Create lockdown profile sc_default based on sc_base
CREATE LOCKDOWN PROFILE sc_default FROM sc_base;
---------------------------------------------------------------------------
-- Disable a couple of feature bundles and features
ALTER LOCKDOWN PROFILE sc_default ENABLE OPTION ALL EXCEPT = ('DATABASE QUEUING');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('CONNECTIONS');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('CTX_LOGGING');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('NETWORK_ACCESS');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('OS_ACCESS');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('JAVA_RUNTIME');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('JAVA');
ALTER LOCKDOWN PROFILE sc_default DISABLE FEATURE = ('JAVA_OS_ACCESS');
---------------------------------------------------------------------------
-- Enable simple OS access
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('COMMON_SCHEMA_ACCESS');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('AWR_ACCESS');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('LOB_FILE_ACCESS');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('TRACE_VIEW_ACCESS');
ALTER LOCKDOWN PROFILE sc_default ENABLE FEATURE = ('UTL_FILE');
---------------------------------------------------------------------------
-- Restrict ALTER DATABASE statement
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER DATABASE') USERS=LOCAL;
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER DATABASE')
  CLAUSE = ('CLOSE') USERS=LOCAL;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER DATABASE')
  CLAUSE = ('OPEN') USERS=LOCAL;
---------------------------------------------------------------------------
-- disable ALTER SYSTEM in general
ALTER LOCKDOWN PROFILE sc_default DISABLE STATEMENT = ('ALTER SYSTEM') USERS=LOCAL;
ALTER LOCKDOWN PROFILE sc_default ENABLE STATEMENT = ('ALTER SYSTEM') CLAUSE = ('SET') OPTION = ('OPEN_CURSORS') ;
PAUSE
---------------------------------------------------------------------------
-- Create lockdown profile sc_trace 
CREATE LOCKDOWN PROFILE sc_trace FROM sc_default;
---------------------------------------------------------------------------
-- disable trace file access
ALTER LOCKDOWN PROFILE sc_trace DISABLE FEATURE = ('TRACE_VIEW_ACCESS');
PAUSE
---------------------------------------------------------------------------
-- Create lockdown profile sc_jvm 
CREATE LOCKDOWN PROFILE sc_jvm FROM sc_default;
---------------------------------------------------------------------------
-- enable JVM / JVM runtime
ALTER LOCKDOWN PROFILE sc_jvm ENABLE FEATURE = ('JAVA_RUNTIME');
ALTER LOCKDOWN PROFILE sc_jvm ENABLE FEATURE = ('JAVA');
PAUSE
---------------------------------------------------------------------------
-- Create lockdown profile sc_jvm_os 
CREATE LOCKDOWN PROFILE sc_jvm_os;
---------------------------------------------------------------------------
-- enable OS access
ALTER LOCKDOWN PROFILE sc_jvm_os ENABLE FEATURE = ('JAVA_RUNTIME');
ALTER LOCKDOWN PROFILE sc_jvm_os ENABLE FEATURE = ('JAVA');
ALTER LOCKDOWN PROFILE sc_jvm_os ENABLE FEATURE = ('OS_ACCESS');

-- ALTER LOCKDOWN PROFILE sc_jvm_os DISABLE FEATURE ALL EXCEPT = ('JAVA','JAVA_RUNTIME','JAVA_OS_ACCESS');
ALTER LOCKDOWN PROFILE sc_jvm_os ENABLE FEATURE = ('JAVA_OS_ACCESS');
PAUSE
---------------------------------------------------------------------------
-- enable the sc_default lockdown profile
ALTER SYSTEM SET pdb_lockdown=sc_default SCOPE=BOTH;
SHOW PARAMETER pdb_lockdown
SHOW CON_NAME
---------------------------------------------------------------------------
-- 50_create_lockdown_profiles.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------
