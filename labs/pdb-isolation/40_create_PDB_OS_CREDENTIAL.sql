----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 40_create_PDB_OS_CREDENTIAL.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @40_create_PDB_OS_CREDENTIAL
--  Purpose...: Script to configure PDB_OS_CREDENTIAL
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
-- 40_create_PDB_OS_CREDENTIAL.sql : configure PDB_OS_CREDENTIAL
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
-- Cleanup and remove old credentials if they do exists
DECLARE
    vcount        INTEGER := 0;
    TYPE table_varchar IS
        TABLE OF VARCHAR2(128);
    credentials   table_varchar := table_varchar('GENERIC_PDB_OS_USER', 'PDBSEC_OS_USER', 'PDB1_OS_USER', 'PDB2_OS_USER', 'PDB3_OS_USER'
    );
BEGIN
    FOR i IN 1..credentials.count LOOP
        SELECT
            COUNT(1)
        INTO vcount
        FROM
            dba_credentials
        WHERE
            credential_name = credentials(i);

        IF vcount != 0 THEN
            dbms_credential.drop_credential(credential_name => credentials(i));
        END IF;
    END LOOP;
END;
/

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- Create a credential used as generic credential
BEGIN
    dbms_credential.create_credential(
      credential_name => 'GENERIC_PDB_OS_USER',
      username => 'orapdb',
      password => 'manager');
END;
/
PAUSE
---------------------------------------------------------------------------
-- Create a credential used as a PDB specific credential
BEGIN
    dbms_credential.create_credential(
      credential_name => 'PDBSEC_OS_USER',
      username => 'orapdbsec',
      password => 'manager');
END;
/
PAUSE
---------------------------------------------------------------------------
-- Show current setting for PDB_OS_CREDENTIAL
SHOW PARAMETER PDB_OS_CREDENTIAL
PAUSE
---------------------------------------------------------------------------
-- Try to change PDB_OS_CREDENTIAL in cdb$root
SHOW CON_NAME
ALTER SYSTEM SET pdb_os_credential=GENERIC_PDB_OS_USER scope=spfile;
PAUSE
---------------------------------------------------------------------------
-- Change PDB_OS_CREDENTIAL in CDB via parameter file
SHUTDOWN IMMEDIATE;
CREATE PFILE='/tmp/pfile.txt' FROM SPFILE;
HOST echo "*.pdb_os_credential=GENERIC_PDB_OS_USER" >> /tmp/pfile.txt
CREATE SPFILE FROM PFILE='/tmp/pfile.txt';
STARTUP;
SHOW PARAMETER PDB_OS_CREDENTIAL
PAUSE
---------------------------------------------------------------------------
-- Show current setting for PDB_OS_CREDENTIAL in container pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
SHOW PARAMETER PDB_OS_CREDENTIAL
PAUSE
---------------------------------------------------------------------------
-- Create a local credential used as a PDB specific credential
BEGIN
    dbms_credential.create_credential(
      credential_name => 'PDBSEC_LOCAL_OS_USER',
      username => 'orapdbsec',
      password => 'manager');
END;
/
PAUSE
---------------------------------------------------------------------------
-- Change PDB_OS_CREDENTIAL in pdbsec
SHOW CON_NAME
ALTER SYSTEM SET pdb_os_credential=PDBSEC_OS_USER scope=spfile;
STARTUP FORCE;
PAUSE
---------------------------------------------------------------------------
-- Show current setting for PDB_OS_CREDENTIAL in container pdbsecx
SHOW PARAMETER PDB_OS_CREDENTIAL
---------------------------------------------------------------------------
-- 40_create_PDB_OS_CREDENTIAL.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------
-- commands to reset pdb_os_credential via parameter file
-- ALTER SESSION SET CONTAINER=pdbsec;
-- ALTER SYSTEM RESET pdb_os_credential scope=spfile;
-- ALTER SESSION SET CONTAINER=cdb$root;
-- SHUTDOWN IMMEDIATE;
-- CREATE PFILE='/tmp/pfile.txt' FROM SPFILE;
-- HOST sed -i '/pdb_os_credential/d' /tmp/pfile.txt
-- CREATE SPFILE FROM PFILE='/tmp/pfile.txt';
-- STARTUP;
-- EOF ---------------------------------------------------------------------
