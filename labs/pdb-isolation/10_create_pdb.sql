----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 01_create_pdb.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.08.19
--  Usage.....: @01_create_pdb
--  Purpose...: Create a PDB (pdbsec) used for PDB security engineering
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
---------------------------------------------------------------------------

-- alter the SQL*Plus environment
SET VERIFY ON
SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON

---------------------------------------------------------------------------
-- 01_create_pdb.sql : prepare the PDB pdbsec
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- create a PDB pdbsec
CREATE PLUGGABLE DATABASE pdbsec 
    ADMIN USER pdbadmin IDENTIFIED BY LAB01schulung ROLES=(dba)
    PATH_PREFIX = '/u01/oradata/PDBSEC/directories/'
    CREATE_FILE_DEST = '/u01/oradata/PDBSEC/';
---------------------------------------------------------------------------
-- Adjust directory access privileges.
HOST chmod 755 /u01/oradata
HOST chmod -R 755 /u01/oradata/PDBSEC
---------------------------------------------------------------------------
-- open PDB pdbsec
ALTER PLUGGABLE DATABASE pdbsec OPEN;
---------------------------------------------------------------------------
-- save state of PDB pdbsec
ALTER PLUGGABLE DATABASE pdbsec SAVE STATE;
---------------------------------------------------------------------------
-- connect as PDBADMIN user 
CONNECT pdbadmin/LAB01schulung@pdbsec
---------------------------------------------------------------------------
-- create a tablespace USERS
CREATE TABLESPACE users;
---------------------------------------------------------------------------
-- 01_create_pdb.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------
