----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 41_create_ext_table.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @41_create_ext_table
--  Purpose...: Script to configure table pre-processors
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
COLUMN dir_path NEW_VALUE dir_path FORMAT a80
COLUMN directory_name FORMAT a25
COLUMN directory_path FORMAT a80
COLUMN id FORMAT a80
SELECT upper('&pdb_db_name') pdb_db_name FROM dual;
SET PAGESIZE 200 LINESIZE 160

-- Cleanup and remove old credentials if they do exists
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=&pdb_db_name;
ALTER SESSION SET CURRENT_SCHEMA=&pdb_admin_user;
DECLARE
  vcount INTEGER :=0;
BEGIN
  SELECT count(1) INTO vcount FROM dba_tables WHERE table_name = 'ID';
  IF vcount != 0 THEN
    EXECUTE IMMEDIATE ('DROP TABLE id');
  END IF;
END;
/

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- 41_create_ext_table.sql : test to create external table pre-processor
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- create a directory for the external table pre-processor
CREATE OR REPLACE DIRECTORY ext_table AS 'ext_table';
SELECT directory_name,directory_path dir_path FROM dba_directories
WHERE origin_con_id=(SELECT con_id FROM v$pdbs) AND directory_name='EXT_TABLE';
PAUSE
---------------------------------------------------------------------------
-- create an OS script
HOST mkdir -p &dir_path
HOST echo "/usr/bin/date | /usr/bin/tee -a &dir_path/run_id.log"  >&dir_path/run_id.sh
HOST echo "/usr/bin/id   | /usr/bin/tee -a &dir_path/run_id.log"  >>&dir_path/run_id.sh
HOST chmod 755 &dir_path/run_id.sh
-- prepare the log file for the OS script 
HOST rm -f &dir_path/run_id.log
HOST touch &dir_path/run_id.log
HOST chmod 666 &dir_path/run_id.log
PAUSE
---------------------------------------------------------------------------
-- create an external table
CREATE TABLE id (id VARCHAR2(2000)) 
  ORGANIZATION EXTERNAL( 
    TYPE ORACLE_LOADER 
    DEFAULT DIRECTORY ext_table 
    ACCESS PARAMETERS( 
      RECORDS DELIMITED BY NEWLINE 
      PREPROCESSOR ext_table:'run_id.sh') 
    LOCATION(ext_table:'run_id.sh') 
  ); 
PAUSE
---------------------------------------------------------------------------
-- Show current setting for PDB_OS_CREDENTIAL
SHOW PARAMETER PDB_OS_CREDENTIAL
PAUSE
---------------------------------------------------------------------------
-- query the external table
SELECT * FROM id;
PAUSE
---------------------------------------------------------------------------
-- Reset PDB_OS_CREDENTIAL as SYSDBA
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=&pdb_db_name;
ALTER SYSTEM RESET pdb_os_credential SCOPE=SPFILE;
STARTUP FORCE;
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
SHOW PARAMETER PDB_OS_CREDENTIAL
PAUSE
---------------------------------------------------------------------------
-- query the external table
SELECT * FROM id;
PAUSE
---------------------------------------------------------------------------
-- check log file
HOST cat &dir_path/run_id.log
---------------------------------------------------------------------------
-- Change PDB_OS_CREDENTIAL back in pdbsec
CONNECT / AS SYSDBA
ALTER SESSION SET CONTAINER=&pdb_db_name;
ALTER SYSTEM SET pdb_os_credential=PDBSEC_OS_USER scope=spfile;
STARTUP FORCE;
SHOW PARAMETER PDB_OS_CREDENTIAL
---------------------------------------------------------------------------
-- 41_create_ext_table.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------