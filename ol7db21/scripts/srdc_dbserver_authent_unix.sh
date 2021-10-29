#!/bin/bash
instance=$ORACLE_SID
FAILING_USER="SYS"
echo "Enter 1 if 'sysdba OS authentication' fails." 
echo "Enter 2 if 'sysdba password authentication' fails."
echo "Enter 3 if 'non-sysdba password authentication' fails with ORA-1017."
echo "Enter 4 if 'non-sysdba password authentication' fails with ORA-28000  :"
read MY_CHOICE
if [ $MY_CHOICE == 3 ] || [ $MY_CHOICE == 4 ]; then
 echo "Enter the DB username of failing connection :" 
 read FAILING_USER
  if [ "$FAILING_USER" = "" ];  then
    echo "DB username is required. Exiting.."
    exit -1
  fi
fi 
if  [ "$MY_CHOICE" != 1 ] && [ "$MY_CHOICE" != 2 ] && [ "$MY_CHOICE" != 3 ]  &&  [ "$MY_CHOICE" != 4 ]; then
 echo "Wrong value. Exiting.." 
 exit -1
fi 

if [ "$MY_CHOICE" == 1 ]; then
  failing_conn=" sysdba OS authentication fails "
fi
if [ "$MY_CHOICE" == 2 ]; then
  failing_conn=" sysdba password authentication fails "
fi  
if [ "$MY_CHOICE" == 3 ]; then
  failing_conn=" non-sysdba password authentication fails with ORA-1017 "
fi  
if [ "$MY_CHOICE" == 4 ] ; then
  failing_conn=" non-sysdba password authentication fails with ORA-28000 "
fi  
echo "Generating htm file"

exec &> "SRDC_DBSERVER_AUTHENT_UNIX_${instance}_$(date +"%Y%m%d_%H%M%S").htm"

echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=US-ASCII\"><meta name=\"generator\" content=\"SQL*Plus 11.2.0\">"
echo "<style type='text/css'> body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} p {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} table,tr,td {font:10pt Arial,Helvetica,sans-serif; color:Black; background:#f7f7e7; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} th {font:bold 10pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} h1 {font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;-"
echo "} h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}</style><title>SQL*Plus Report</title>"
echo "</head><body>"

echo "<table><tr><th>HEADER</th></tr>" 
echo "<tr><td>----------------------------------------------------</td></tr>"
echo "<tr><td>Diagnostic-Name : DBSERVER_AUTHENT_UNIX</td></tr>"
echo "<tr><td>Machine : $(hostname)</td></tr>"
echo "<tr><td>Timestamp : $(date +"%Y-%m-%d %H%M%S %Z%:z")</td></tr>"
echo "<tr><td>Database : $ORACLE_SID</td></tr>"
echo "<tr><td>-----------------------------------------------------</td></tr>"
echo "</table>"

echo "<br>*** Failing connection ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "ID"
echo "</th>"
echo "<th>"
echo "FAILING_CONNECTION"
echo "</th>"
echo "<th>"
echo "FAILING_USER"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td>" 
echo "$MY_CHOICE"
echo "</td>"
echo "<td>" 
echo "$failing_conn"
echo "</td>"
echo "<td>"
echo "$FAILING_USER"
echo "</td>"
echo "</tr>"
echo "</table>"
echo "<br>==================================================" 

# list owner of listener process ref. note 352191.1
echo "<br>*** Environment Variables ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "ENVIRONMENT_VAR"
echo "</th>"
echo "<th>"
echo "UNAME"
echo "</th>"
echo "<th>"
echo "TNSLSNR_PS"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>"
env | grep ORA
env | grep TNS
env | grep TWO_TASK
env | grep PATH
env | grep USER
env | grep NAME 
echo "</pre></td>"
echo "<td><pre>"
echodo uname -a
echo "</pre></td>"
echo "<td><pre>"
ps -ef | grep tnslsnr | grep -v grep
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>=================================================="

# expected passwordfile
# utlize new 12c describe option (ignore error message in previous versions)
echo "<br>*** ORAPW File Details ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "ORAPW_FILE_LIST"
echo "</th>"
echo "<th>"
echo "ORAPW_FILE_FORMAT"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
echodo ls -l $ORACLE_BASE/dbs/orapw$ORACLE_SID 2>/dev/null
echo "</pre></td>"
echo "<td><pre>"
orapwd describe file=$ORACLE_HOME/dbs/orapw$ORACLE_SID | grep Description
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>=================================================="

# To get the OS passwordfile location from srvctl settings in case of RAC DB
# look for �password file� , �Database unique name� values in srvctl output
echo "<br>*** srvctl OS passwordfile location ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "SRVCTL_CONFIG"
echo "</th>"
echo "<th>"
echo "SRVCTL_PASSFILE_ASM"
echo "</th>"
echo "<th>"
echo "SRVCTL_PASSFILE_OS"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
srvctl config database -d $ORACLE_UNQNAME
echo "--------"
srvctl getenv database -d $ORACLE_UNQNAME
echo "</pre></td>"
echo "<td><pre>" 
srvctl config database -d $ORACLE_UNQNAME | grep Password | grep -oP '[^\/]*$' | xargs -I % sh -c "asmcmd find '*' %"
echo "</pre></td>"
echo "<td><pre>" 
srvctl config database -d $ORACLE_UNQNAME | grep Password | grep -oP 'Password\s*file\s*:\s*\K[^\n]*' | xargs -I % sh -c "find %"
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>=================================================="


echo "<br>*** ORATAB Entries ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "ETC_ORATAB_ENTRY"
echo "</th>"
echo "<th>"
echo "ORACLE_ORATAB_ENTRY"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
cat /etc/oratab 2>/dev/null | grep -v \#
echo "</pre></td>"
echo "<td><pre>"
cat /var/opt/oracle/oratab 2>/dev/null | grep -v \#
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>==================================================" 

echo "<br>*** Current User and Group IDs ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "CURRENT_OS_USER"
echo "</th>"
echo "<th>"
echo "CURRENT_OS_GROUP"
echo "</th>"
echo "<th>"
echo "OS_GROUP_ELIGIBLE"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
echodo id
echo "</pre></td>"
echo "<td><pre>"
echodo groups
echo "</pre></td>"
echo "<td><pre>"
echodo osdbagrp
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>==================================================" 

echo "<br>*** ORACLE File Details ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "ORACLE_FILE_LS"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
echodo ls -l $ORACLE_HOME/bin/oracle*
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>=================================================="

echo "<br>*** CONFIG File Contents ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "CONFIG_CS_FILE_CONTENT_LIST"
echo "</th>"
echo "<th>"
echo "CONFIG_TIMESTAMP_CHECK"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
echodo cat $ORACLE_HOME/rdbms/lib/config.[cs]
echo "--------"
echodo ls -l $ORACLE_HOME/rdbms/lib/config.[cso]
echo "</pre></td>"
echo "<td><pre>"
find $ORACLE_HOME/rdbms/lib/config.o -newer $ORACLE_HOME/rdbms/lib/config.[cs]
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>==================================================" 

echo "<br>*** SQLNET.ORA Contents ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "ORACLE_HOME"
echo "</th>"
echo "<th>"
echo "TNS_ADMIN"
echo "</th>"
echo "<th>"
echo "SRVTCL_TNS_ADMIN"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
echodo cat $ORACLE_HOME/network/admin/sqlnet.ora 2>/dev/null | grep -v \#
echo "</pre></td>"
echo "<td><pre>"
echodo cat $TNS_ADMIN/sqlnet.ora  2>/dev/null | grep -v \#  2>/dev/null
echo "</pre></td>"
echo "<td><pre>"
srvctl getenv database -d $ORACLE_UNQNAME -t "TNS_ADMIN" |grep -oP 'TNS_ADMIN=\K[^\n]*' |xargs -I % sh -c "cat %/sqlnet.ora"  2>/dev/null | grep -v \#  2>/dev/null
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>==================================================" 

echo "<br>*** Passwd, Group details ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "ETC_PASSWD"
echo "</th>"
echo "<th>"
echo "ETC_GROUPS"
echo "</th>"
echo "<th>"
echo "YPCAT_GROUP"
echo "</th>"
echo "<th>"
echo "GROUP_IN_NSSWITCH"
echo "</th>"
echo "<th>"
echo "NSCD"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
ls -l /etc/passwd
echo "--------"
egrep `whoami` /etc/passwd
echo "</pre></td>"
echo "<td><pre>"
ls -l /etc/group
echo "--------"
for R in `groups`
do
   egrep $R /etc/group
done
echo "</pre></td>"
echo "<td><pre>"
ypcat group 2>/dev//null
echo "</pre></td>"
echo "<td><pre>"
cat /etc/nsswitch.conf | grep group | grep -v \#
echo "</pre></td>"
echo "<td><pre>"
ps -ef | grep nscd | grep -v grep
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>==================================================" 

# connect as sysdba may fail if sqlplus version unequal to db version
echo "<br>*** Mount_nosuid, SQLPlus ***"
echo "<table>"
echo "<tr>"
echo "<th>"
echo "MOUNT_NOSUID"
echo "</th>"
echo "<th>"
echo "SQLPLUS_VERSION"
echo "</th>"
echo "</tr>"
echo "<tr>"
echo "<td><pre>" 
mount | grep nosuid
echo "</pre></td>"
echo "<td><pre>"
type sqlplus 
sqlplus -version
echo "</pre></td>"
echo "</tr>"
echo "</table>"
echo "<br>==================================================" 
echo "<br>"

sqlplus /nolog << EOF1
set sqlprompt " "
set pagesize 1000
set sqlnumber off
set heading on echo off feedback off verify off underline on timing off

connect / as sysdba

set markup html on 


prompt *** Database Version, Status, and Role ***
select VERSION, (SELECT DB_UNIQUE_NAME FROM v\$database) "DB_Name",INSTANCE_NAME, DATABASE_STATUS, INSTANCE_ROLE, HOST_NAME, STATUS,(SELECT OPEN_MODE FROM v\$database) "Open_Mode" from v\$instance;
prompt ==================================================

-- check parameters remote_login_password_file, local_listener, remote_listener, sec_case_sensitive_logon, _notify_crs(Doc ID 2150270.1)
prompt *** DB Parameter List *** 
show parameters 
prompt ===================================================

-- list users granted sysdba, sysoper (, sysasm)
prompt *** List of Users from gv\$pwfile_users ***
select INST_ID, USERNAME, SYSDBA, SYSOPER, SYSASM from GV\$PWFILE_USERS order by inst_id;
prompt ===================================================

prompt *** Ignore below error in OS passwordfile of 11g DB and below***
select inst_id, con_id, common, USERNAME, SYSDBA, SYSOPER, SYSASM, SYSBACKUP, SYSDG, SYSKM, ACCOUNT_STATUS, PASSWORD_PROFILE, LAST_LOGIN, LOCK_DATE, EXPIRY_DATE, EXTERNAL_NAME, AUTHENTICATION_TYPE from GV\$PWFILE_USERS order by inst_id;


prompt ==================================================
prompt *** Value of _asmsid Hidden Parameter ***
select x.ksppinm parameter, y.ksppstvl value
        from   x\$ksppi  x , x\$ksppcv y
        where  x.indx = y.indx
        and    x.ksppinm = '_asmsid' 
       order  by x.ksppinm;
prompt ==================================================

-- Collect details for non-sysdba login error ORA-1017, ORA-28000, ORA-28001
-- Also look for SQLNET.ALLOWED_LOGON_VERSION_SERVER/CLIENT values in sqlnet.ora file
prompt *** List of DB users and their password version, account_status ***
prompt *** For 11g DB non-CDB ***
select a.username username, a.account_status, a.password_versions, a.authentication_type, to_char(a.lock_date,'DD-MON-YYYY HH24:MI:SS') lock_date, to_char(a.expiry_date,'DD-MON-YYYY HH24:MI:SS') expiry_date, a.profile profile, to_char(b.ptime,'DD-MON-YYYY HH24:MI:SS') ptime
from dba_users a , sys.user\$ b
where a.user_id = b.user#
and a.username = UPPER('$FAILING_USER')
order by a.username;
prompt ==================================================

-- Collect details for non-sysdba login error ORA-1017, ORA-28000, ORA-28001
-- Also look for SQLNET.ALLOWED_LOGON_VERSION_SERVER/CLIENT values in sqlnet.ora file
prompt *** Ignore below error in 11g DB ***
select a.username username, a.account_status, a.password_versions, a.authentication_type, to_char(a.lock_date,'DD-MON-YYYY HH24:MI:SS') lock_date, to_char(a.expiry_date,'DD-MON-YYYY HH24:MI:SS') expiry_date, a.profile profile, to_char(b.ptime,'DD-MON-YYYY HH24:MI:SS') ptime, a.common common, a.con_id con_id
from cdb_users a , sys.user\$ b
where a.user_id = b.user#
and a.username = UPPER('$FAILING_USER')
order by a.username;
prompt ==================================================

-- Collect details for DG standby DB (read-only mode) user login issue - ORA-28000
-- V$RO_USER_ACCOUNT view available from 12.2 DB. If this view is queried from the root in a multitenent container database (CDB), then only common users and the SYS user are returned.
-- If this view is queried from a pluggable database (PDB), only rows that pertain to the current PDB are returned.
-- PASSW_LOCKED - Indicates whether the account is locked (1) or not (0) 
-- PASSW_LOCK_UNLIM - Indicates whether the account is locked for an unlimited time (1) or not (0) 
prompt *** List of DB users of read-only DB in locked status ***
prompt *** For 11g DB ***
 select du.username username, rua.userid, rua.PASSW_LOCKED, rua.PASSW_LOCK_UNLIM, to_char(rua.PASSW_LOCK_TIME,'DD-MON-YYYY HH24:MI:SS') locked_date
 from GV\$RO_USER_ACCOUNT rua, dba_users du 
 where rua.userid=du.user_id 
   and (rua.PASSW_LOCKED = 1 OR rua.PASSW_LOCK_UNLIM = 1)
   and du.username=UPPER('$FAILING_USER')
 order by du.username;
prompt ==================================================

prompt *** Ignore below error in 11g DB read-only DB ***
 select rua.con_id, du.username username, rua.userid, rua.PASSW_LOCKED, rua.PASSW_LOCK_UNLIM, to_char(rua.PASSW_LOCK_TIME,'DD-MON-YYYY HH24:MI:SS') locked_date
 from GV\$RO_USER_ACCOUNT rua, cdb_users du 
 where rua.userid=du.user_id 
   and (rua.PASSW_LOCKED = 1 OR rua.PASSW_LOCK_UNLIM = 1)
   and du.username=UPPER('$FAILING_USER')
 order by rua.con_id, du.username; 
prompt ==================================================

EOF1

echo "</body></html>"
