----------------------------------------------------------------------------
--  Trivadis AG, Infrastructure Managed Services
--  Saegereistrasse 29, 8152 Glattbrugg, Switzerland
----------------------------------------------------------------------------
--  Name......: 51_verify_lockdown_profiles.sql
--  Author....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
--  Editor....: Stefan Oehrli
--  Date......: 2019.03.18
--  Usage.....: @51_verify_lockdown_profiles
--  Purpose...: Script to verify the lockdown profiles
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
COLUMN rule_type FORMAT A10
COLUMN rule FORMAT A25
COLUMN clause FORMAT A10
COLUMN clause_option FORMAT A20
COLUMN pdb_name FORMAT A10
SET PAGESIZE 200 LINESIZE 160
---------------------------------------------------------------------------
-- 51_verify_lockdown_profiles.sql : prepare the PDB pdbsec
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- set container to pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
---------------------------------------------------------------------------
-- reset the lockdown profiles
ALTER SYSTEM RESET pdb_lockdown SCOPE=BOTH;
---------------------------------------------------------------------------
-- remove java permissions
DECLARE
    vcount INTEGER :=0;
BEGIN
    FOR java_pol IN (SELECT * FROM DBA_JAVA_POLICY WHERE GRANTEE=upper('&pdb_admin_user'))
LOOP
    dbms_java.revoke_permission(
        grantee=>java_pol.grantee,
        permission_type=>java_pol.type_schema ||':' ||java_pol.type_name,
        permission_name=>java_pol.name,
        permission_action=>java_pol.action);
    dbms_java.delete_permission(java_pol.seq);
END LOOP;
END;
/

SET FEEDBACK ON
CLEAR SCREEN
SET ECHO ON
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- set container to pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
---------------------------------------------------------------------------
-- enable the sc_trace lockdown profile
ALTER SYSTEM SET pdb_lockdown=sc_trace SCOPE=BOTH;
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- current user, container and lockdown profile
SHOW USER
SHOW CON_NAME
SHOW PARAMETER PDB_LOCKDOWN
---------------------------------------------------------------------------
-- query v$diag_trace_file_contents
SELECT trace_filename,count(1) FROM v$diag_trace_file_contents 
GROUP BY trace_filename;
PAUSE
---------------------------------------------------------------------------
-- show lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.clause,
        lr.clause_option,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
ORDER BY 1,2,3,4,6;
PAUSE
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- set container to pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
---------------------------------------------------------------------------
-- enable the sc_default lockdown profile
ALTER SYSTEM SET pdb_lockdown=sc_default SCOPE=BOTH;
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- current user, container and lockdown profile
SHOW USER
SHOW CON_NAME
SHOW PARAMETER PDB_LOCKDOWN
PAUSE
---------------------------------------------------------------------------
-- query v$diag_trace_file_contents
SELECT trace_filename,count(1) FROM v$diag_trace_file_contents 
GROUP BY trace_filename;
PAUSE
---------------------------------------------------------------------------
-- show lockdown rules
SELECT  lr.rule_type,
        lr.rule,
        lr.clause,
        lr.clause_option,
        lr.users,
        lr.status,
        lr.con_id,
        p.pdb_name
FROM    v$lockdown_rules lr
        LEFT OUTER JOIN cdb_pdbs p ON lr.con_id = p.con_id
ORDER BY 1,2,3,4,6;
PAUSE
---------------------------------------------------------------------------
-- Test JVM by creating a simple java source
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED JavaCalc AS
public class JavaCalc
{
    public static void main(String args []) {
        int a = Integer.parseInt(args[0]);
        int b = Integer.parseInt(args[1]);
        System.out.println ("Simple JVM test...");
        System.out.println ("Calculating "+ a + "*" + b + "=" + (a * b));
   }
}
/
show errors java source "JavaCalc"
PAUSE
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- set container to pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
---------------------------------------------------------------------------
-- enable the sc_jvm lockdown profile
ALTER SYSTEM SET pdb_lockdown=sc_jvm SCOPE=BOTH;
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- current user, container and lockdown profile
SHOW USER
SHOW CON_NAME
SHOW PARAMETER PDB_LOCKDOWN
PAUSE
---------------------------------------------------------------------------
-- Test JVM by creating a simple java source
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED JavaCalc AS
public class JavaCalc
{
    public static void main(String args []) {
        int a = Integer.parseInt(args[0]);
        int b = Integer.parseInt(args[1]);
        System.out.println ("Simple JVM test...");
        System.out.println ("Calculating "+ a + "*" + b + "=" + (a * b));
   }
}
/
show errors java source "JavaCalc"
PAUSE
---------------------------------------------------------------------------
-- Create a PL/SQL procedure to run the java class
CREATE OR REPLACE PROCEDURE JavaCalcSP (wid IN varchar2,wpos IN
varchar2)
AS LANGUAGE JAVA 
NAME 'JavaCalc.main(java.lang.String[])';
/
show errors;
PAUSE
---------------------------------------------------------------------------
-- Do a few tests
SET SERVEROUTPUT ON SIZE 1000000
EXEC dbms_java.set_output(1000000);
EXEC JavaCalcSP(2,21);
EXEC JavaCalcSP(9,5);
PAUSE
---------------------------------------------------------------------------
-- Create a JAVA store procedure respectively java class to run an OS command
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED "Host" AS
import java.io.*;

public class Host {
    public static void executeCommand(String command) {
        try {
            String[] finalCommand;
            finalCommand = new String[3];
            System.out.println("OS Arch     : " + System.getProperty("os.arch"));
            System.out.println("OS Name     : " + System.getProperty("os.name"));
            System.out.println("OS Version  : " + System.getProperty("os.version"));

            if (isLinux()) {
                finalCommand[0] = "/bin/bash";
                finalCommand[1] = "-c";
                finalCommand[2] = command;
            } else {
                System.out.println("Execute OS command not supported on " + System.getProperty("os.name"));
                return;
            }

            final Process pr = Runtime.getRuntime().exec(finalCommand);
            pr.waitFor();

            new Thread(new Runnable() {
                public void run() {
                    BufferedReader br_in = null;
                    try {
                        br_in = new BufferedReader(new InputStreamReader(pr.getInputStream()));
                        String buff = null;
                        while ((buff = br_in.readLine()) != null) {
                            System.out.println("Process out :" + buff);
                            try {
                                Thread.sleep(100);
                            } catch (Exception e) {
                            }
                        }
                        br_in.close();
                    } catch (IOException ioe) {
                        System.out.println("Exception caught printing process output.");
                        ioe.printStackTrace();
                    } finally {
                        try {
                            br_in.close();
                        } catch (Exception ex) {
                        }
                    }
                }
            }).start();

            new Thread(new Runnable() {
                public void run() {
                    BufferedReader br_err = null;
                    try {
                        br_err = new BufferedReader(new InputStreamReader(pr.getErrorStream()));
                        String buff = null;
                        while ((buff = br_err.readLine()) != null) {
                            System.out.println("Process err :" + buff);
                            try {
                                Thread.sleep(100);
                            } catch (Exception e) {
                            }
                        }
                        br_err.close();
                    } catch (IOException ioe) {
                        System.out.println("Exception caught printing process error.");
                        ioe.printStackTrace();
                    } finally {
                        try {
                            br_err.close();
                        } catch (Exception ex) {
                        }
                    }
                }
            }).start();
        } catch (Exception ex) {
            System.out.println(ex.getLocalizedMessage());
        }
    }

    public static boolean isLinux() {
        if (System.getProperty("os.name").toLowerCase().indexOf("linux") != -1)
            return true;
        else
            return false;
    }
};
/
show errors java source "Host"
----------------------------------------------------------------------------
-- Create a PL/SQL procedure to run the java class
CREATE OR REPLACE PROCEDURE host_command (p_command  IN  VARCHAR2)
AS LANGUAGE JAVA 
NAME 'Host.executeCommand (java.lang.String)';
/
PAUSE
----------------------------------------------------------------------------
-- grant the java privs to tvd_java as sysdba
EXEC dbms_java.grant_permission(upper('&pdb_admin_user'),'SYS:java.io.FilePermission', '/bin/bash', 'execute' )
SELECT * FROM DBA_JAVA_POLICY WHERE GRANTEE=upper('&pdb_admin_user');
----------------------------------------------------------------------------
-- Test OS command /usr/bin/id
SET SERVEROUTPUT ON SIZE 1000000
EXEC dbms_java.set_output(1000000);
EXEC host_command (p_command => '/usr/bin/id');
PAUSE
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- set container to pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
---------------------------------------------------------------------------
-- enable the sc_jvm lockdown profile
ALTER SYSTEM SET pdb_lockdown=sc_jvm_os SCOPE=BOTH;
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- current user, container and lockdown profile
SHOW USER
SHOW CON_NAME
SHOW PARAMETER PDB_LOCKDOWN
PAUSE
----------------------------------------------------------------------------
-- Test OS command /usr/bin/id
SET SERVEROUTPUT ON SIZE 1000000
EXEC dbms_java.set_output(1000000);
EXEC host_command (p_command => '/usr/bin/id');
PAUSE
---------------------------------------------------------------------------
-- connect as SYSDBA to the root container
CONNECT / as SYSDBA
---------------------------------------------------------------------------
-- set container to pdbsec
ALTER SESSION SET CONTAINER=pdbsec;
---------------------------------------------------------------------------
-- enable the sc_default lockdown profile
ALTER SYSTEM SET pdb_lockdown=sc_default SCOPE=BOTH;
---------------------------------------------------------------------------
-- connect to PDB as PDBADMIN
CONNECT &pdb_admin_user/&pdb_admin_pwd@&pdb_db_name
---------------------------------------------------------------------------
-- current user, container and lockdown profile
SHOW USER
SHOW CON_NAME
SHOW PARAMETER PDB_LOCKDOWN
PAUSE
---------------------------------------------------------------------------
-- Do a few tests
SET SERVEROUTPUT ON SIZE 1000000
EXEC dbms_java.set_output(1000000);
EXEC JavaCalcSP(2,21);
PAUSE
---------------------------------------------------------------------------
-- Try to drop the java source
DROP JAVA SOURCE JavaCalc;
PAUSE
---------------------------------------------------------------------------
-- Try to grant sysdba
GRANT sysdba to &pdb_admin_user;
PAUSE
---------------------------------------------------------------------------
-- Just describe a couple of critical packages
DESCRIBE dbms_sys_sql;
DESCRIBE dbms_backup_restore;
PAUSE
---------------------------------------------------------------------------
-- 51_verify_lockdown_profiles.sql : finished
---------------------------------------------------------------------------
SET ECHO OFF
-- EOF ---------------------------------------------------------------------
