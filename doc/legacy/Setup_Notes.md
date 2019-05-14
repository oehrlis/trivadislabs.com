* sqlnet.ora files auf ad und server sowie lab folder
* tnsnames.ora files auf ad und server sowie lab folder
* dsi.ora files auf ad und server sowie lab folder
* krb5.conf files auf ad und server sowie lab folder
* certificate files auf ad und server sowie lab folder DONE
* ports in FW für alles öffnen 1521, 7001,7002, 1389, 1636, etc
* user db.trivadislabs.com sowie oracle18c voranlegen
* short cut cmd.exe auf desktop DONE
* install CA auf AD Server DONE



alter system set events '28033 trace name context forever, level 9';

SQL> create user "adams@TRIVADISLABS.COM" identified externally;

User created.

SQL> grant connect to "adams@TRIVADISLABS.COM";

Grant succeeded.

SQL> grant select on v_$session to "adams@TRIVADISLABS.COM";


krb5 file auf dem server anlegen
####krb5.conf DB Server



sqlnet.ora file

```bash
##########################################################################
# Kerberos Configuration
##########################################################################
SQLNET.AUTHENTICATION_SERVICES = (BEQ,KERBEROS5)
SQLNET.FALLBACK_AUTHENTICATION = TRUE
SQLNET.KERBEROS5_KEYTAB = /u00/app/oracle/network/admin/db.trivadislabs.com.keytab
SQLNET.KERBEROS5_REALMS = /u00/app/oracle/network/admin/krb.realms
SQLNET.KERBEROS5_CC_NAME = /u00/app/oracle/network/admin/krbcache
SQLNET.KERBEROS5_CONF = /u00/app/oracle/network/admin/krb5.conf
SQLNET.KERBEROS5_CONF_MIT=TRUE
SQLNET.AUTHENTICATION_KERBEROS5_SERVICE = oracle

```

Create the keytab file

```batch
ktpass.exe -princ oracle/db.trivadislabs.com@TRIVADISLABS.COM \
    -mapuser db.trivadislabs.com -pass manager \
    -crypto ALL -ptype KRB5_NT_PRINCIPAL \
    -out C:\u00\app\oracle\network\db.trivadislabs.com.keytab
```

```bash
ktpass.exe -princ oracle/db.trivadislabs.com@TRIVADISLABS.COM -mapuser db.trivadislabs.com -pass manager -crypto ALL -ptype KRB5_NT_PRINCIPAL  -out C:\u00\app\oracle\network\db.trivadislabs.com.keytab
```

Kaffeepause Vormittag
Kerberos Troubleshooting
- was gibts so für Probleme
    - Namesauflösung und DNS Probleme
    - Zeit Differenzen
    - Keytab File falsch z.B. falscher Algorithmus, vno Nummer etc
    - 
- welche Möglichkeiten für die Problemanalyse stehen zur Verfügung
- SQLNet Trace
- Wireshark
- TRACE File