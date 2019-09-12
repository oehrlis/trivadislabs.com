----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 30_create_datafile.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @30_create_datafile
--  Purpose...: Script to create datafiles
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
SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- 30_create_datafile.sql : test to create some data files
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- create a datafile with wrong path
CREATE TABLESPACE wrong_prefix DATAFILE '/tmp/wrong_prefix.dbf' SIZE 1M;
PAUSE
---------------------------------------------------------------------------
-- create datafile with correct prefix
CREATE TABLESPACE right_prefix DATAFILE
    '/u01/oradata/PDBSEC/right_prefix.dbf' SIZE 1M;
PAUSE
---------------------------------------------------------------------------
-- create datafile without a prefix
CREATE TABLESPACE no_prefix datafile SIZE 1M;
PAUSE
---------------------------------------------------------------------------
-- check datafiles and tablespaces
SELECT file_name,tablespace_name FROM dba_data_files;
---------------------------------------------------------------------------
-- 30_create_datafile.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------