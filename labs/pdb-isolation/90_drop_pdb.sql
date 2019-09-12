----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 90_drop_pdb.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.08.19
--  Usage.....: @90_drop_pdb
--  Purpose...: Drop PDB (pdbsec) used for PDB security engineering
--  Notes.....: 
--  Reference.: 
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
---------------------------------------------------------------------------

-- alter the SQL*Plus environment
SET VERIFY OFF
SET FEEDBACK ON
SET ECHO ON

---------------------------------------------------------------------------
-- 90_drop_pdb.sql : clean up and remove the PDB pdbsec
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- close PDB pdbsec
ALTER PLUGGABLE DATABASE pdbsec CLOSE;
---------------------------------------------------------------------------
-- drop PDB pdbsec
DROP PLUGGABLE DATABASE pdbsec INCLUDING DATAFILES;
---------------------------------------------------------------------------
-- PDB_OS_CREDENTIAL via parameter file
ALTER SESSION SET CONTAINER=cdb$root;
SHUTDOWN IMMEDIATE;
CREATE PFILE='/tmp/pfile.txt' FROM SPFILE;
HOST sed -i '/pdb_os_credential/d' /tmp/pfile.txt
CREATE SPFILE FROM PFILE='/tmp/pfile.txt';
STARTUP;
---------------------------------------------------------------------------
-- 90_drop_pdb.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------
