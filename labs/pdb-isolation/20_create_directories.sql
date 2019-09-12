----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 20_create_directories.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @20_create_directories
--  Purpose...: Script to create directory
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
COLUMN directory_name FORMAT a25
COLUMN directory_path FORMAT a80
SET PAGESIZE 200 LINESIZE 160
SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- 20_create_directories.sql : test to create some directories
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- create a directory with wrong path / absolute path
CREATE OR REPLACE DIRECTORY wrong_prefix AS '/tmp/test';
PAUSE
---------------------------------------------------------------------------
-- create directory without a prefix
CREATE OR REPLACE DIRECTORY no_prefix AS 'no_prefix';
PAUSE
---------------------------------------------------------------------------
-- create directory in a subpath
CREATE OR REPLACE DIRECTORY sub_dir AS 'sub/test';
PAUSE
---------------------------------------------------------------------------
-- check the current directories
SELECT directory_name, directory_path FROM dba_directories
WHERE origin_con_id=(SELECT con_id FROM v$pdbs);
PAUSE
---------------------------------------------------------------------------
-- verify the directories with HOST ls -al
-- CREATE DIRECTORY does not create folders on OS!
--
---------------------------------------------------------------------------
-- 20_create_directories.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------
