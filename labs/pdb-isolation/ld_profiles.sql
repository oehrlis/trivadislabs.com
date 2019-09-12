----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: ld_profiles.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.08.19
--  Usage.....: @ld_profiles
--  Purpose...: Displays information about lockdown profiles.
--  Notes.....: 
--  Reference.: https://oracle-base.com/dba/script?category=18c&file=lockdown_profiles.sql
--  License...: Licensed under the Universal Permissive License v 1.0 as 
--              shown at http://oss.oracle.com/licenses/upl.
----------------------------------------------------------------------------
--  Modified..:
--  see git revision history for more information on changes/updates
----------------------------------------------------------------------------
SET LINESIZE 180 PAGESIZE 200

COLUMN con_id FORMAT 999999
COLUMN pdb_name FORMAT A10
COLUMN profile_name FORMAT A13
COLUMN rule_type FORMAT A10
COLUMN rule FORMAT A25
COLUMN clause FORMAT A30
COLUMN clause_option FORMAT A45
COLUMN option_value FORMAT A20
COLUMN min_value FORMAT A9
COLUMN max_value FORMAT A9
COLUMN list FORMAT A20

SELECT lp.con_id,
       p.pdb_name,
       lp.profile_name,
       lp.rule_type,
       lp.rule,
       lp.clause,
       lp.clause_option,
       --lp.option_value,
       --lp.users,
       --lp.except_users,
       --lp.list,
       lp.status,
       lp.min_value,
       lp.max_value
FROM   cdb_lockdown_profiles lp
       LEFT OUTER JOIN cdb_pdbs p ON lp.con_id = p.con_id
ORDER BY 1,3,4,5,6,7,8;
-- EOF ---------------------------------------------------------------------