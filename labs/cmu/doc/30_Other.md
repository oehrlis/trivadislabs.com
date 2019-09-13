
# Übungen: Datenbank Authentifizierung und Password Verifier

**Übungsziele:** Kennenlernen der Übungsumgebung, BasEnv sowie der Datenbanken. Festigen der Kenntnisse im Bereich Passwort Authentifizierung und Password Hashes.

Arbeitsumgebung für die Übung

* **Server:** db.trivadislabs.com
* **DB:** TDB122A oder TDB184A

Die folgenden Aufgaben und Beispiele werden auf der DB TDB184A durchgeführt. Grundsätzlich können diese aber auch auf TDB122A ausgeführt werden.

## Überprüfung der aktuellen Password Verifier

1. Prüfen Sie was aktuell für Passwort Hashes in der Datenbank vorhanden sind. Welche Hashes gibt es? Wieso sind bei gewissen Benutzer keine Angaben in *password_versions*?

```SQL
set linesize 120 pagesize 200
col USERNAME for a25
SELECT username, password_versions FROM dba_users;
```

2. Prüfen Sie wie die VIEW *dba_users* auf die Information zu *password_versions* kommt. Im Code zum View *dba_users* findet man entsprechende *decode* Funktionen wo auf die Spalten *u.password* und *u.spare4* zugegriffen wird.

```SQL
set linesize 120 pagesize 200
set long 200000
SELECT text FROM dba_views WHERE view_name='DBA_USERS';
```

3. Was für Passwort Hashes hat der Benutzer SCOTT effektiv?

```SQL
set linesize 120 pagesize 200
col password for a16
col spare4 for a40
SELECT password, spare4 FROM user$ WHERE name='SCOTT';
```

4. Kontrollieren Sie was in der Datei ``sqlnet.ora`` für die Parameter *ALLOWED_LOGON_VERSION_** definiert wurde. Verwenden Sie alternative ``cat``, ``less``, ``more`` oder ``vi`` um den Inhalt von ``sqlnet.ora`` anzuzeigen.

```bash
less $cdn/admin/sqlnet.ora

cat $cdn/admin/sqlnet.ora|grep -i ALLOWED_LOGON_VERSION
```

5. Prüfen Sie was von SQLNet effektive verwendet wird. 

* Einschalten des SQLNet Tracing auf der Client Seite. Setzen von *DIAG_ADR_ENABLED* und *TRACE_LEVEL_CLIENT*. Anbei manuell mit ``vi`` oder alternativ direkt mit ``sed`` ersetzten lassen.

```bash
vi $cdn/admin/sqlnet.ora
DIAG_ADR_ENABLED=OFF
TRACE_LEVEL_CLIENT=SUPPORT
```

```bash
sed -i "s|DIAG_ADR_ENABLED.*|DIAG_ADR_ENABLED=OFF|" $cdn/admin/sqlnet.ora
sed -i "s|TRACE_LEVEL_CLIENT.*|TRACE_LEVEL_CLIENT=SUPPORT|" $cdn/admin/sqlnet.ora
```

* Löschen Sie allfällige alte Trace Dateien.

```bash
rm $cdn/trc/sqlnet_client_*.trc
```

* Verbinden als Benutzer Scott

```bash
sqlplus scott/tiger

show user
```

* Kontrollieren Sie die Trace Datei. Was ist für ALLOWED_LOGON_VERSION gesetzt? Falls nichts gesetzt ist, was für ein Wert gilt?

```bash
ls -rtl $cdn/trc
less $cdn/trc/sqlnet_client_*.trc

grep -i ALLOWED_LOGON_VERSION $cdn/trc/sqlnet_client_*.trc
```

* Schalten Sie das Tracing wieder aus.

```bash
vi $cdn/admin/sqlnet.ora
DIAG_ADR_ENABLED=ON
TRACE_LEVEL_CLIENT=OFF
```

```bash
sed -i "s|DIAG_ADR_ENABLED.*|DIAG_ADR_ENABLED=ON|" $cdn/admin/sqlnet.ora
sed -i "s|TRACE_LEVEL_CLIENT.*|TRACE_LEVEL_CLIENT=OFF|" $cdn/admin/sqlnet.ora
```

## Anpassen der Password Verifier

1. Löschen Sie den Oracle 12c Password Hash vom Benutzer Scott. Respektive setzen Sie explizit den 11g Hashes.

```SQL
SELECT spare4 FROM user$ WHERE name='SCOTT';

set linesize 170
col 11G_HASH for a62

SELECT 
    REGEXP_SUBSTR(spare4,'(S:[[:alnum:]]+)') "11G_HASH"
FROM user$ WHERE name='SCOTT';

col 12C_HASH for a162
SELECT 
    REGEXP_SUBSTR(spare4,'(T:[[:alnum:]]+)') "12C_HASH"
FROM user$ WHERE name='SCOTT';

ALTER USER scott IDENTIFIED BY VALUES 'S:54A0B23AE639D4E0E22963A65A380DD496B8FCB65D1A5F9CC910EE625D8C';
```

2. Kontrolle der *password_versions* vom Benutzer *SCOTT*.

```SQL
col username for a30
SELECT username,password_versions FROM dba_users WHERE username='SCOTT';
```

3. Anpassen des SQLNet Parameter *ALLOWED_LOGON_VERSION_SERVER* uns setzen des 12a Authentifizierungsprotokolls.

```bash
sed -i "s|#SQLNET.ALLOWED_LOGON_VERSION_SERVER.*|SQLNET.ALLOWED_LOGON_VERSION_SERVER=12a|" $cdn/admin/sqlnet.ora
sed -i "s|SQLNET.ALLOWED_LOGON_VERSION_SERVER.*|SQLNET.ALLOWED_LOGON_VERSION_SERVER=12a|" $cdn/admin/sqlnet.ora
```

4. Als User Scott verbinden. Kann man sich überhaupt verbinden?

```bash
sqlplus scott/tiger

show user
```

1. Anpassen des SQLNet Parameter *ALLOWED_LOGON_VERSION_CLIENT* und *ALLOWED_LOGON_VERSION_SERVER*, setzen des 11 Authentifizierungsprotokolls.

```bash
sed -i "s|#ALLOWED_LOGON_VERSION_CLIENT.*|SQLNET.ALLOWED_LOGON_VERSION_CLIENT=11|" $cdn/admin/sqlnet.ora
sed -i "s|SQLNET.ALLOWED_LOGON_VERSION_CLIENT.*|SQLNET.ALLOWED_LOGON_VERSION_CLIENT=11|" $cdn/admin/sqlnet.ora
sed -i "s|#SQLNET.ALLOWED_LOGON_VERSION_SERVER.*|SQLNET.ALLOWED_LOGON_VERSION_SERVER=11|" $cdn/admin/sqlnet.ora
sed -i "s|SQLNET.ALLOWED_LOGON_VERSION_SERVER.*|SQLNET.ALLOWED_LOGON_VERSION_SERVER=11|" $cdn/admin/sqlnet.ora
```

6. Als User Scott verbinden. Kann man sich überhaupt verbinden?

```bash
sqlplus scott/tiger

show user
```

7. Was passiert wenn man als *SYS* das Passwort von *SCOTT* neu setzt? Welcher Passwort Hash hat *SCOTT* nun?

```SQL
connect / as sysdba

ALTER USER scott IDENTIFIED BY tiger;

set linesize 120 pagesize 200
col USERNAME for a25
col password for a16
col spare4 for a40
SELECT username, password_versions FROM dba_users WHERE username='SCOTT';
SELECT password, spare4 FROM user$ WHERE name='SCOTT';
```

## Zusatzaufgaben

Falls noch Zeit übrig ist, bieten sich folgende Zusatzaufgaben an:

* Setzten von *ALLOWED_LOGON_VERSION_CLIENT* und *ALLOWED_LOGON_VERSION_SERVER* auf Werte kleiner 11 z.B 10, 9 oder 8. Was bekommt der Benutzer *SCOTT* für Passwort Hashes wenn man als *SYS* das Passwort mit *ALTER USER* neu setzt?
* Welches Passwort wird beim Login verwendet?

# Übungen: Kerberos Authentifizierung

**Übungsziele:** Konfiguration der Kerberos Authentifizierung für die Datenbanken TDB122A und TDB184. Erstellen eines Benutzers mit Kerberos Authentifizierung sowie erfolgreichem Login lokal (Linux VM) und remote (Windows VM).

## Service Principle und Keytab Datei

Arbeitsumgebung für die Übung

* **Server:** ad.trivadislabs.com
* **Benutzer:** Administrator

Für die Kerberos Authentifizierung wird ein Service Principle benötigt. Der Entsprechende Benutzer Account wurde vorbereitet. Kontrollieren Sie in auf dem Server *ad.trivadislabs.com* mit dem Tool *Active Directory User and Computers* ob der Benutzer *db.trivadislabs.com* existiert. Falls ja, was hat der Benutzer für Einstellungen bezüglich Login Name und Account optionen? Passen Sie ggf noch die Account Optionen an uns setzen *Kerberos AES 128* und *Kerberos AES 256*. Die folgende Abbildung zeigt ein Beispiel. Optional können Sie den Benutzer auch löschen und neu anlegen.

!["Benutzereigenschaften"](images/User_Account_Preferences_King.png)  

Nachdem die Account Optionen angepasst wurden, ist für diesen Benutzer eine Keytab Datei zu erstellen. Öffnen Sie dazu ein Command Prompt (``cmd.exe``) und führen ``ktpass.exe`` aus.

```bash
ktpass.exe -princ oracle/db.trivadislabs.com@TRIVADISLABS.COM -mapuser db.trivadislabs.com -pass LAB01schulung -crypto ALL -ptype KRB5_NT_PRINCIPAL  -out C:\u00\app\oracle\network\admin\db.trivadislabs.com.keytab
```

Überprüfen Sie anschliessend den Service Principle Names (SPN) mit ``setspn``

```bash
setspn -L db.trivadislabs.com
```

Kopieren Sie die Keytab Datei mit WinSCP auf den Datenbank Sever in das Verzeichnis ``$cdn/admin``. Achten Sie darauf, dass die Datei als Binärdatei kopiert wird. Alternativ können Sie auch das unten aufgeführte Putty SCP Kommando verwenden.

```bash
"C:\Program Files\PuTTY\pscp.exe" C:\u00\app\oracle\network\admin\db.trivadislabs.com.keytab db.trivadislabs.com:/u00/app/oracle/network/admin
```

## SQLNet Konfiguration

Arbeitsumgebung für die Übung:

* **Server:** db.trivadislabs.com
* **Benutzer:** oracle

Ergänzen Sie die ``sqlnet.ora`` Datei mit folgenden Parametern. Eine Beispiel Konfigurationsdatei ist im Verzeichnis ``$cdl/doag2018/lab/03_krb`` vorhanden.

```bash
cp $cdl/doag2018/lab/03_krb/sqlnet.ora $cdn/admin/sqlnet.ora
vi $cdn/admin/sqlnet.ora
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

Erstellen Sie die Kerberos Konfigurationsdatei ``krb5.conf`` mit folgendem Inhalt. Eine Beispiel Konfigurationsdatei ist im Verzeichnis ``$cdl/doag2018/lab/03_krb`` vorhanden.

```bash
cp $cdl/doag2018/lab/03_krb/krb5.conf $cdn/admin/krb5.conf
vi $cdn/admin/krb5.conf 
[libdefaults]
 default_realm = TRIVADISLABS.COM
 clockskew=300
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 TRIVADISLABS.COM = {
   kdc = ad.trivadislabs.com
   admin_server = ad.trivadislabs.com
}

[domain_realm]
.trivadislabs.com = TRIVADISLABS.COM
trivadislabs.com = TRIVADISLABS.COM
```

Nachdem die Keytab Datei auf dem Datenbank Server kopiert worden ist, kann mit ``oklist`` überprüft werden was die Datei für Crypto Algorithmen untersützt. Somit wird zudem indirekt geprüft ob die Keytab Datei verwendet werden kann.

```bash
oklist -e -k $cdn/admin/db.trivadislabs.com.keytab
```

Kontrollieren Sie ob die Namensauflösung wie gewünscht funktioniert.

```bash
nslookup ad.trivadislabs.com
nslookup 10.0.0.4
nslookup db.trivadislabs.com
nslookup 10.0.0.5
```

Erstellen Sie anschliessend mit``okinit`` manuell ein Session Ticket.

```Bash
okinit king@TRIVADISLABS.COM

oklist
```

## Kerberos Authentifizierung

Arbeitsumgebung für die Übung:

* **Server:** db.trivadislabs.com
* **Benutzer:** oracle
  
Passen Sie den init.ora Parameter OS Prefix an. Für die Kerberos Authentifizierung muss dieser leer sein.

```SQL
sqh
Show parameter os_authent_prefix
ALTER SYSTEM SET os_authent_prefix='' SCOPE=spfile;
STARTUP FORCE;
```

Erstellen Sie einen Kerberos Benutzers für den Mitarbeiter King. Verwenden Sie dazu die Variante mit dem Kerberos Principal Name.

```SQL
CREATE USER king IDENTIFIED EXTERNALLY AS 'king@TRIVADISLABS.COM';
GRANT CONNECT TO king;
GRANT SELECT ON v_$session TO king;
```

Login als Benutzer King mit dem zuvor generierten Session Ticket und anzeigen der Informationen zur aktuellen Session.

```SQL

connect /@TDB184A

show user

@sousrinf

SELECT sys_context('USERENV','AUTHENTICATION_TYPE') FROM DUAL;
SELECT sys_context('USERENV','AUTHENTICATION_METHOD') FROM DUAL;
SELECT sys_context('USERENV','AUTHENTICATED_IDENTITY') FROM DUAL;
```

## Zusatzaufgaben

Falls noch Zeit übrig ist, bieten sich folgende Zusatzaufgaben an:

* Versuchen Sie einen weiteren Kerberos Benutzer in der Datebank zu erstellen (z.B. *adams*). Dabei nutzen Sie aber den UPN als Benutzernamen. Wie setzt sich dieser genau zusammen? Wie wird dieser bei einem ``CREATE USER`` geschreiben, damit die Authentifizierung klappt?
* Kombinieren Sie Kerberos Authentifizierung mit Proxy Authentifizierung.
* Locken Sie im AD den Benutzer und versuchen erneut mit der Datenbank zu verbinden.
* Versuchen Sie sich als Benutzer *king* am Active directory Server anzumelden und eine SQLPlus Verbindung auf den Datenbank Server zu öffnen. Hierzu müssen Sie vorgänging noch die Kerberos Client Konfiguration erstellen (sqlnet.ora sowie die krb5.conf Datei erstellen).

# Übungen: Centrally Managed User 18c

**Übungsziele:** Konfiguration von Centrally Managed Users für die Datenbank TDB184. Erweitern des Active Directory Schemas inklusive der Installation des Password Filter Plugins. Erstellen von Mappings für Benutzer und Rollen sowie erfolgreichem Login mit Passwort sowie Kerberos Authentifizierung.

## Active Directory

Arbeitsumgebung für die Übung:

* **Server:** ad.trivadislabs.com
* **Benutzer:** Administrator

Die folgenden Arbeiten werden in der Regel in zusammenarbeit mit dem Windows respektive Active Directory Administrator durchgeführt. Je nach Unternehmensgrösse sind allenfalls noch weiter IT Bereich mit involviert.

Für das Oracle Wallet wird das Root Zertifikat vom Active Directory Server benötigt. Diesen kann in der Übungsumgebung einfach via Commandline exportiert werden. Öffnen Sie dazu ein Command Prompt (``cmd.exe``) und exportieren das Root Zertifikat. Das exportiert Root Zertifikat müssen Sie anschliessend mit WinSCP auf den Datenbank Server kopieren in das Verzeichnis ``/u00/app/oracle/network/admin`` kopieren. Alternativ können Sie auch das unten aufgeführte Putty SCP Kommando verwenden.

```bash
certutil -ca.cert c:\u00\app\oracle\network\admin\Trivadis_LAB_root.cer

"C:\Program Files\PuTTY\pscp.exe" c:\u00\app\oracle\network\admin\Trivadis_LAB_root.cer db.trivadislabs.com:/u00/app/oracle/network/admin
```

Um Oracle CMU mit Passwort Authentifizierung verwenden zu können, muss Active Directory entsprechend angepasst werden. Dazu wird muss mit WinSCP die Datei ``opwdintg.exe`` auf den Active Directory Server kopiert werden. Auf dem Datenbank Server liegt die Datei im Oracle 18c Home ``$ORACLE_HOME/bin/opwdintg.exe``. Alternativ können Sie auch das unten aufgeführte Putty SCP Kommando verwenden.

```bash
"C:\Program Files\PuTTY\pscp.exe" db.trivadislabs.com:/u00/app/oracle/product/18.4.0.0/bin/opwdintg.exe c:\u00\app\oracle\network\admin\
```

Anschliessend muss die Datei auf dem Active Directory ausgeführt werden, um das AD Schema zu erweitern und das Passwort Filter Plugin zu installieren. Öffnen Sie dazu ein Command Prompt (``cmd.exe``) und führen ``opwdintg.exe`` aus. 

```bash
c:\u00\app\oracle\network\admin\opwdintg.exe
```

Bei der Installstion sind folgende Fragen mit Ja respektive Yes zu beantworten:

* Do you want to extend AD schema? [Yes/No]: 
* Schema extension for this domain will be permanent. Continue? [Yes/No]:
* Do you want to install Oracle password filter?[Yes/No]: 
* The change requires machine reboot. Do you want to reboot now?[Yes/No]:

Nachdem der Active Directory Server neu gestartet wurde, müssen zum Abschluss die neu erstellten Gruppen für die Passwort Verifier entsprechend vergeben werden. Entsprechende Benutzer, welche sich an der Datenbank anmelden, müssen dazu ein Oracle Password Hash haben. Dieser wird vom Password Filter bei allen Benutzer erstellt, welche in der Gruppe *ORA_VFR_11G* respektive *ORA_VFR_12C* sind. Zudem müssen diese Benutzer ihr Passwort neu setzten, damit das Passwort Filter Plugin auch effektive das Attribut *orclCommonAttribute* setzt.

**Variante 1:** Passen Sie die Gruppe *Trivadis LAB Users* manuell an fügen bei dieser Gruppe neu MemberOf *ORA_VFR_11G* respektive *ORA_VFR_12C* hinzu.

* Starten Sie *Active Directory Users and Computers*.
* Wählen Sie im Container Groups die Gruppe *Trivadis LAB Users* aus.
* Öffnen Sie mit rechtem Mausklick die *Properties*.
* Im Tab *Member Of* clicken Sie *Add...*
* Fügen Sie die Gruppe *ORA_VFR_11G* respektive *ORA_VFR_12C* hinzu.
* Schliessen Sie die Dialoge mit *Ok*.
  
Passen Sie manuell die Passwörter der gewünschten Benutzer an. Dazu müssen Sie in *Active Directory Users and Computers* jeweils auf dem Benutzer mit rechtem Mausklick *Reset Password...* wählen und ein neues Passwort setzten.

**Variante 2:** Öffnen Sie ein PowerShell Fenster und führen das Script ``c:\doag2018\lab\04_cmu\reset_ad_users.ps1`` aus. Das Script passt sowohl die Gruppe an und änder die Passwörter aller Benutzer. 

```bash
C:\u00\app\oracle\local\doag2018\lab\04_cmu\reset_ad_users.ps1
```

Prüfen Sie zur Kontrolle bei einem Benutzer, ob das das Attribut *orclCommonAttribute* gesetzt ist. Die folgende Abbildung zeigt die Properties vom Benutzer King und das Attribut *orclCommonAttribute*.

!["Benutzereigenschaften Benutzer King"](images/User_Account_Preferences_King.png)  

## Server und Datenbank Konfiguration

Arbeitsumgebung für die Übung:

* **Server:** db.trivadislabs.com
* **Benutzer:** oracle
* **Datenbank:** TDB184A

Erstellen Sie ein SQLNet Konfigurationsdatei ``dsi.ora`` mit den folgenden Informationen zum Aktive Directory Server. Eine Beispiel Konfigurationsdatei ist im Verzeichnis ``$cdl/doag2018/lab/04_cmu`` vorhanden.

```bash
cp $cdl/doag2018/lab/04_cmu/dsi.ora $cdn/admin/dsi.ora
vi $cdn/admin/dsi.ora
DSI_DIRECTORY_SERVERS = (ad.trivadislabs.com:389:636)
DSI_DEFAULT_ADMIN_CONTEXT = "dc=trivadislabs,dc=com"
DSI_DIRECTORY_SERVER_TYPE = AD
```

Erstellen Sie ein neues Oracle Wallet für die Datenbank TDB184A.

```bash
mkdir $ORACLE_BASE/admin/$ORACLE_SID/wallet
orapki wallet create -wallet $ORACLE_BASE/admin/$ORACLE_SID/wallet -auto_login
```

Fügen Sie die Einträge für den Benutzername, Passwort und den Distinguished Name hinzu.

```bash
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.USERNAME oracle18c

mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.DN CN=oracle18c,CN=Users,DC=trivadislabs,DC=com

mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.PASSWORD LAB01schulung
```

Laden Sie abschliessend noch das Root Zertifikat vom Active Directory Server in das Wallet

```bash
orapki wallet add -wallet $ORACLE_BASE/admin/$ORACLE_SID/wallet -cert $TNS_ADMIN/Trivadis_LAB_root.cer -trusted_cert
```

Mit folgenden Befehlen läst sich prüfen, wass nun effektiv im Wallet steht.

```bash
orapki wallet display -wallet $ORACLE_BASE/admin/$ORACLE_SID/wallet

Oracle PKI Tool Release 18.0.0.0.0 - Production
Version 18.1.0.0.0
Copyright (c) 2004, 2017, Oracle and/or its affiliates. All rights reserved.

Requested Certificates: 
User Certificates:
Oracle Secret Store entries: 
ORACLE.SECURITY.DN
ORACLE.SECURITY.PASSWORD
ORACLE.SECURITY.USERNAME
Trusted Certificates: 
Subject:        CN=Trivadis LAB Enterprise Root CA,DC=trivadislabs,DC=com
```

```bash
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -list
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.DN
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.PASSWORD
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.USERNAME
```

Mit dem LDAP Search Befehl läst sich zudem Prüfen, ob der Zugriff auf das Active Directory mit dem Wallet funktioniert. Der folgende Befehl sucht nach einem *sAMAccountName=blo*. **Achtung!** Die Passwörter für den Benutzer oracle18c sowie das Wallet Passwort werden hier auf dem Commandline angegeben.

```bash
ldapsearch -h ad.trivadislabs.com -p 389 \
    -D "CN=oracle18c,CN=Users,DC=trivadislabs,DC=com" \
    -w LAB01schulung -U 2 \
    -W "file:/u00/app/oracle/admin/TDB184A/wallet" \
    -P LAB01schulung -b "OU=People,DC=trivadislabs,DC=com" \
    -s sub "(sAMAccountName=blo*)" dn orclCommonAttribute
```

## Benutzer und Rollen

Arbeitsumgebung für die Übung:

* **Server:** db.trivadislabs.com
* **Benutzer:** oracle
* **Datenbank:** TDB184A

Als letzter Konfigurationspunkt für Centrally Managed User müssen neben dem Mapping entsprechende init.ora Parameter angepasst werden. Starten Sie ein sqlplus als SYSDBA und setzen Sie die beiden Parameter *ldap_directory_access* und *ldap_directory_sysauth*.

```sql
ALTER SYSTEM SET ldap_directory_access = 'PASSWORD';
ALTER SYSTEM SET ldap_directory_sysauth = YES SCOPE=SPFILE;
STARTUP FORCE;
```

Erstellen Sie einen gobalen shared Benutzer *tvd_global_users*, der für alle Mitarbeiter gilt. Also für alle Benutzer in der Gruppe *cn=Trivadis LAB Users,ou=Groups,dc=trivadislabs,dc=com*. Zudem sollen sich alle Benutzer verbinden können.

```sql
CREATE USER tvd_global_users IDENTIFIED GLOBALLY AS 'cn=Trivadis LAB Users,ou=Groups,dc=trivadislabs,dc=com';
GRANT create session TO tvd_global_users ;
GRANT SELECT ON v_$session TO tvd_global_users ;
```

Verbinden Sie sich als Benutzer Blofeld und prüfen Sie die detail Informationen zu dieser Session wie Authentifizierung, Identity etc.

```sql
connect "blofeld@TRIVADISLABS.COM"@TDB184A

show user
@sousrinf
```

Nun können sich alle AD Benutzer der Gruppe *Trivadis LAB Users* mit der Datenbank TDB184A verbinden. Sie erhalten dabei die basis Rechte, welche wir zuvor dem Datenbank Account *tvd_global_users* gegeben haben. Interessant wird es, wenn die Benutzer aus den verschiedenen Abteilungen unterschiedliche Rechte oder Rollen erhalten. Dazu erstellen wir entsprechende Rollen mit einem Mapping auf die Active Directory Gruppe oder Organisation Unit. 

```sql
CONNECT / AS SYSDBA

CREATE ROLE mgmt_role IDENTIFIED GLOBALLY AS
'CN=Trivadis LAB Management,OU=Groups,DC=trivadislabs,DC=com';

CREATE ROLE rd_role IDENTIFIED GLOBALLY AS
'CN=Trivadis LAB Developers,OU=Groups,DC=trivadislabs,DC=com';
```

Prüfen Sie nun die verschiedenen Rechte / Rollen der einzelnen Mitarbeitern aus diesem Abteilungen.

```sql
CONNECT "moneypenny@TRIVADISLABS.COM"/LAB01schulung@TDB184A
SELECT * FROM session_roles;

CONNECT "smith@TRIVADISLABS.COM"/LAB01schulung@TDB184A
SELECT * FROM session_roles;

CONNECT "blofeld@TRIVADISLABS.COM"/LAB01schulung@TDB184A
SELECT * FROM session_roles;
```

Wie ist das jetzt mit Kerberos? Wenn Sie die Übung zu Kerberos erfolgreich abgeschlossen haben, können sich die Benutzer nun auch mit Kerberos Authentifizieren. Ein Versuch mit dem Benutzer *Bond* schaft hier klarheit. Generieren sie zuerst manuell ein Ticket Granting Ticket mit ``okinit``. Die Passwortabfrage umgehen wir bei diesem Beispiel einfach indem wir das Passwort mit einem ``echo |`` via STDIN an  ``okinit`` schicken. Mit dem Skript ``sousrinf.sql`` sehen wir anschliessend detailierte Informationen zur Authentifizierung.

```bash
sqh
host echo LAB01schulung|okinit bond
connect /@TDB184A
SELECT * FROM session_roles;

show user
@sousrinf.sql
```

```bash
echo LAB01schulung|okinit bond
sqlplus /@TDB184A
SELECT * FROM session_roles;

show user
@sousrinf.sql
```

## Zusatzaufgabe: Rollen und Admininistratoren

Falls noch Zeit übrig ist, bieten sich folgende Zusatzaufgaben an. Erstellen Sie ein global private Schema für den Benutzer Adams. Was für ein DB Benutzer wird jetzt verwendet, wenn sich der Benutzer Adams anmeldet? Welche Rollen sind Aktiv?

```sql
CREATE USER adams IDENTIFIED GLOBALLY AS 'CN=Douglas Adams,OU=Research,OU=People,DC=trivadislabs,DC=com';
GRANT create session TO adams ;
GRANT SELECT ON v_$session TO adams ;

sqlplus "adams@TRIVADISLABS.COM"/LAB01schulung@TDB184A
SELECT * FROM session_roles;
show user
@sousrinf
```

Erstellen Sie ein Mapping für die DBA's, welche sich auch als SYSDBA anmelden sollen. Prüfen Sie dazu als erstest das Format der Oracle Password Datei. Voraussetzung für das Mapping von Administratoren ist die Passwort Datei Version 12.2.

```bash
orapwd describe file=$cdh/dbs/orapwTDB184A
```

Migrieren Sie die aktuelle Passwort Datei in das Format 12.2. Alternativ können Sie die Passwort Datei auch neu anlegen.

```bash
mv $cdh/dbs/orapwTDB184A $cdh/dbs/orapwTDB184A_format12
orapwd format=12.2 input_file=$cdh/dbs/orapwTDB184A_format12 file=$cdh/dbs/orapwTDB184A
orapwd describe file=$cdh/dbs/orapwTDB184A
```

Erstellen Sie ein Mapping für den DBA Ian Fleming *CN=Ian Fleming,OU=Information Technology,OU=People,DC=trivadislabs,DC=com*

```sql
CREATE USER fleming IDENTIFIED GLOBALLY AS
'CN=Ian Fleming,OU=Information Technology,OU=People,DC=trivadislabs,DC=com';
GRANT SYSDBA TO fleming;
GRANT connect TO fleming;
GRANT SELECT ON v_$session TO fleming;
```

Verbinden Sie sich mit und ohne SYSDB als Ian Fleming. Was für Rechte sowie Authentifizerungsinformationen finden Sie?

```sql
CONNECT "fleming@TRIVADISLABS.COM"/LAB01schulung@TDB184A
SELECT * FROM session_roles;
show user
@sousrinf
```

```sql
CONNECT "fleming@TRIVADISLABS.COM"/LAB01schulung@db.trivadislabs.com:1521/TDB184A as sysdba
SELECT * FROM session_roles;
show user
@sousrinf
```

Versuchen Sie ein weiteres Mapping auf einen anderen global shared Datenbankbenutzer zu machen. Funktioniert das? Was gibt dies für Probleme? 

# Übungen: Oracle Unified Directory

**Übungsziele:** Erstellen OUD Directory Server Instanz sowie einer OUD Proxy Server Instanz für die Active Directory Integration. Die Proxy Server Instanz wird im Folgenden für die Übungen mit Enterprise User Security benötigt.

Arbeitsumgebung für die Übung:

* **Server:** oud.trivadislabs.com
* **Benutzer:** oracle

## Oracle Unified Directory Server Instanz

Erstellen Sie eine OUD Directory Server Instanz mit ``oud-setup``. Wenn ein X11 Client vorhanden ist, wird das Tool im GUI Mode gestartet. Falls kein X11 Client wird automatisch in den Character mode gewechselt. 

```bash
export ORACLE_HOME=/u00/app/oracle/product/oud12.2.1.3.0
cd $ORACLE_HOME/oud
./oud-setup
```

Verwenden Sie für die OUD Instanz folgende Angaben:

* Instance Path : **/u01/instances/oud_doag/OUD**
* Do you want to enable the LDAP administration port? Note that some of the OUD
tools require this port to be enabled (yes / no) [yes]: **yes**
* On which port would you like the LDAP Administration Connector to accept connections? [4444]: **5444**
* Do you want to enable the HTTP administration port? (yes / no) [no]: **no**
* What would you like to use as the initial root user DN for the Directory Server? [cn=Directory Manager]: **cn=Directory Manager**
* Please provide the password to use for the initial root user: **LAB01schulung**
* Do you want to enable LDAP? (yes / no) [yes]: **yes**
* On which port would you like the Directory Server to accept connections from LDAP clients? [1389]: **2389**
* Do you want to enable Start TLS on LDAP Port '2389'? (yes / no) [no]: **yes**
* Do you want to enable HTTP? (yes / no) [no]: **no**
* Do you want to enable LDAPS? (yes / no) [no]: **yes**
* On which port would you like the Directory Server to accept connections from LDAPS clients? [1636]: **2636**
* Do you want to enable HTTPS? (yes / no) [no]: **no**
* Select Certificate server options: **1**
* Provide the fully-qualified host name or IP address that will be used to generate the self-signed certificate [oud.trivadislabs.com]: **oud.trivadislabs.com**
* Do you want to create base DNs in the server? (yes / no) [yes]: **yes**
* Provide the base DN for the directory data: [dc=example,dc=com]: **dc=trivadislabs,dc=com**
* Options for populating the database: **1**
* Specify the Oracle components with which the server integrates: **1** EUS wird später als Zusatzaufgabe manuell konfiguriert.
* How do you want the OUD server to be tuned? **2**
* How do you want the off-line tools (import-ldif, export-ldif, verify-index and rebuild-index) to be tuned? **3**
* Do you want to start the server when the configuration is completed? (yes / no) [yes]: **yes**
* What would you like to do? **1**, **2** oder **3** Wobei dann effektiv 1 gewählt werden muss um die Instanz anzulegen.

Erstellen Sie einen Eintrag in der oudtab Datei. Diese wird für das Setzen der Umgebung mit OUD base benötigt.

```bash
echo "oud_doag:2389:2636:5444::OUD:N" >> ${ETC_BASE}/oudtab
mkdir -p /u01/admin/oud_doag/etc/
echo "LAB01schulung" >/u01/admin/oud_doag/etc/oud_doag_pwd.txt
```

Laden Sie die Umgebung für die Instanz oud_doag neu.

```bash
. oudenv.sh oud_doag
```

Wir haben nun eine simple OUD Directory Server Instanz erstellt. Die Instanz enthält aktuell nichts weiteres als den Basis Eintrag *dc=trivadislabs,dc=com*. Im Rahmen der Zusatzaufgaben wird diese Instanz weiter genutzt.

## Oracle Unified Directory Proxy Instanz

Für die Konfiguration der Proxy besteht die Möglichkeit den GUI Mode zu verwenden oder direkt ``oud-proxy-setup`` mit cli Parameter. Im folgenden werden wir die OUD Proxy Instanz schrittweise mit Scripten konfigurieren.

1. Vorbereiten der Umgebung. Erstellen eines OUDTAB Eintrages und laden der Umgebung.

```bash
echo "oud_adproxy:1389:1636:4444::OUD:Y" >> ${ETC_BASE}/oudtab 
mkdir -p /u01/admin/oud_adproxy/etc
echo "LAB01schulung" >/u01/admin/oud_adproxy/etc/oud_adproxy_pwd.txt
. oudenv.sh oud_adproxy
```

2. Kopieren der Template Scripte von OUD Base

```bash
cp $cdl/doag2018/lab/05_oud/??_* /u01/admin/oud_adproxy/create
```

3. Anpassen respektive Prüfen der Parameter in ``00_init_environment``. 

```bash
vi /u01/admin/oud_adproxy/create/00_init_environment
```

4. Erstellen der OUD Instanz *oud_adproxy* durch Aufrufen von ``01_create_eus_proxy_instance.sh``. Das Wrapper Skript erstellt mit ``oud-proxy-setup`` eine OUD Proxy Instanz mit AD Integration. Schauen Sie sich das Script vor der Ausfürhung kurz an.

```bash
less /u01/admin/oud_adproxy/create/01_create_eus_proxy_instance.sh
/u01/admin/oud_adproxy/create/01_create_eus_proxy_instance.sh
```

5. Anpassen der Konfiguration für die Instanz *oud_adproxy* durch Aufrufen von ``02_config_eus_context.sh``. Das Wrapper Skript führt die ``dsconfig`` Kommandos aus der Datei ``02_config_eus_context.conf`` im Batch Mode aus. Mit den dsconfig Kommandos werden die Workflows für die AD Integration angepasst sowie Transformation Workflows für die AD spezifischen Attributte erstellt. Im GUI Mode wird dies vom GUI direkt gemacht. Schauen Sie sich das Script und die Konfig Datei vor der Ausfürhung kurz an.

```bash
less /u01/admin/oud_adproxy/create/02_config_eus_context.conf
less /u01/admin/oud_adproxy/create/02_config_eus_context.sh
/u01/admin/oud_adproxy/create/02_config_eus_context.sh
```

1. Mit dem folgenden Script wird der Oracle Context angepasst. Es werden sowohl die Standartwerte für die Benutzer sowie Gruppen Suche festgelegt. Dieser Schritt muss unabhängig ob CLI oder GUI Mode immer manuell ausgeführt werden.

```bash
less /u01/admin/oud_adproxy/create/03_config_eus_realm.ldif
less /u01/admin/oud_adproxy/create/03_config_eus_realm.sh
/u01/admin/oud_adproxy/create/03_config_eus_realm.sh
```

7. Anpassen der OUD Instanz. Neben den verschiedenen Logger werden unter anderem zwei Punkte angepasst, welche in der MOS Notes 2001851.1 ausführlicher beschrieben wird.

```bash
less /u01/admin/oud_adproxy/create/04_config_oud_ad_proxy.conf
less /u01/admin/oud_adproxy/create/04_config_oud_ad_proxy.sh
/u01/admin/oud_adproxy/create/04_config_oud_ad_proxy.sh
```

8. Oracle Enterprise User Security respektive das ``eusm`` Tool führt jeweils eine SASL Authentifizierung aus. Damit dies auch mit dem ``dbca`` sowie ``eusm`` klappt, muss das Passwort des verwendeten Benutzers mit einem *reversable* Passwort Hash abgelegt sein. D.h. in dem Fall *AES*. Aktuell verwenden wir den Benutzer *cn=Directory Manager*. Im Folgenden Skript wird die Passwort Policy erweitert und anschliessend das Passwort vom Benutzer *cn=Directory Manager* neu gesetzt.

```bash
less /u01/admin/oud_adproxy/create/05_update_directory_manager.sh
/u01/admin/oud_adproxy/create/05_update_directory_manager.sh
```

9. Abschliessend legen wir noch weitere Admin benutzer für die OUD administration an.

```bash
less /u01/admin/oud_adproxy/create/06_create_root_users.ldif
less /u01/admin/oud_adproxy/create/06_create_root_users.sh
less /u01/admin/oud_adproxy/create/07_create_eusadmin_users.sh
/u01/admin/oud_adproxy/create/07_create_eusadmin_users.sh
/u01/admin/oud_adproxy/create/06_create_root_users.sh
```

Mit den Scripts haben wir nun ein OUD AD Proxy instanz erstellt. Sie können Sich den Inhalt mit dem Directory Manager oder im folgenden mit dem OUDSM.

## Oracle Unified Directory Services Manager

Oracle Unified Directory Services Manager (OUDSM) wird dient als Weboberfläche für die OUD Instanzen. Mit dem OUDSM sind eine einfache Administration sowie der Zugriff auf den LDAP Baum möglich. OUDSM wird mit einer entsprechenden Python Procedure und dem ``wlst.sh`` Tool erstellt. Das passende Python Script ``create_oudsm_domain.py`` steht im Verzeichnis ``$cdl/doag2018/lab/05_oud/`` zur Verfügung.

1. Setzen eines Admin Passwortes in ``create_oudsm_domain.py``

```bash
sed -i -e "s|ADMIN_PASSWORD|LAB01schulung|g" $cdl/doag2018/lab/05_oud/create_oudsm_domain.py
```

2. Oracle Home auf die Oracle collocated Installation setzten und die OUDSM Domain erstellen.

```bash
export DOMAIN_NAME="oudsm_domain"
export DOMAIN_HOME="/u01/domains/oudsm_domain"
export PORT=7001
export PORT_SSL=7002
export ADMIN_USER="weblogic"
export ORACLE_HOME="/u00/app/oracle/product/fmw12.2.1.3.0"

${ORACLE_HOME}/oracle_common/common/bin/wlst.sh \
    -skipWLSModuleScanning $cdl/doag2018/lab/05_oud/create_oudsm_domain.py
```

3. OUDTAB Eintrag für OUDSM erstellen und Umgebung mit OUDBase setzten.

```bash
echo "oudsm_domain:7001:7002:::OUDSM:N" >> ${ETC_BASE}/oudtab
. oudenv.sh oudsm_domain
```

4. Starten von OUDSM mit nohup. Nach einigen Minuten kann vom Active Directory Server auf die URL [http://oud.trivadislabs.com:7001/oudsm](http://oud.trivadislabs.com:7001/oudsm) vom OUDSM zugeriffen werden. Status im OUDSM Logfile respektive nohup.out File muss auf *RUNNING* stehen.

```bash
. oudenv.sh oudsm_domain
nohup /u01/domains/oudsm_domain/startWebLogic.sh &
```

## Zusatzaufgaben: Administration, Hochverfügbarkeit und Backup & Recovery

Stoppen und Starten einer OUD Instanz.

```bash
. oudenv.sh oud_ad
stop-ds

start-ds
```

Anzeigen des Instanz Status. Mit OUD Base Alias *u* respektive *oud_up* oder mit dem OUD *status* Tool.

```bash
u
oud_up
. oudenv.sh oud_doag
status

status --bindDN "cn=Directory Manager" --bindPasswordFile $PWD_FILE
```

Anzeigen der definierten Backends zu einer OUD Instanz.

```bash
. oudenv.sh oud_doag
list-backends
```

Sichern aller Backends mit ``backup``. Dabei soll ein Fullbackup in das Verzeichnis ``/u01/backup/oud_doag`` gemacht werden. Zusätzlich wird das Backup noch komprimiert. Damit dass backup nicht interactiv erstellt werden muss, wird zudem dass Passwort in ein File abgespeichert.

```bash
echo "LAB01schulung" >/u01/admin/oud_doag/etc/oud_doag_pwd.txt
chmod 600 /u01/admin/oud_doag/etc/oud_doag_pwd.txt
. oudenv.sh oud_doag
mkdir -p /u01/backup/oud_doag

backup --bindPasswordFile $PWD_FILE \
    --backUpAll --trustAll --compress \
    --backupDirectory /u01/backup/oud_doag/
```

Alternativ lässt sich das gleich Backup auch mit dem Skript ``oud_backup.sh`` aus OUD Base erstellen. Das Skript bietet zudem 2-3 zusätzliche Features wie Backup mehrerer Instanzen, Versand von e-Mails etc.

```bash
oud_backup.sh -h

oud_backup.sh -v
```

Falls noch Zeit übrig ist, bieten sich folgende Zusatzaufgaben an:

* Anpassen weitere 
* LDIF Export des ganzen Directories oder eines Teilbaumes
* Erstellen einer weiteren Instanz für den Aufbau einer Replikationsumgebung
    * Zweite Instanz anlegen analog oud_doag oder oud_adproxy. Entsprechend andere Ports und Instanz Name wählen
    * Konfiguration der Replikation mit ``dsreplication`` oder via OUDSM.
* Erstellen Sie mit ``create-suffix`` manuell einen EUS Suffix in der OUD Instanz. Was benötigt man noch, damit dieser Suffix auf für EUS verwendet werden kann. 

# Übungen: Oracle Enterprise User Security

**Übungsziele:** Konfiguration von Enterprise User Security auf dem Datenbank Server. Erst von Mappings für verschieden Anwendungsfälle. Authentifizierung und Autorisierung mit Enterprise User Security sowie erfolgreichem Login mit Passwort sowie Kerberos Authentifizierung.

## SQLNet Konfiguration Enterprise User Security

Anpassen der SQLNet Konfiguration für die DB TDB122A respektive für alle Datenbanken auf diesem Server.

```bash
cp $cdl/doag2018/lab/06_eus/ldap.ora $cdn/admin/ldap.ora
vi $cdn/admin/ldap.ora

DIRECTORY_SERVERS = (oud.trivadislabs.com:1389:1636)
DEFAULT_ADMIN_CONTEXT = "dc=trivadislabs,dc=com"
DIRECTORY_SERVER_TYPE = OID
```

## Enterprise User Security Datenbank Konfiguration

Registrierung der DB TDB122A mit dem DBCA

```bash
TDB122A

dbca -configureDatabase -sourceDB $ORACLE_SID -registerWithDirService true \
    -dirServiceUserName "cn=Directory Manager" -dirServicePassword LAB01schulung \
    -walletPassword LAB01schulung -silent
```

## Oracle Enterprise User Security Mappings

* Erstellen Sie ein shared global Schema EUS_USERS

```sql
CREATE USER eus_user IDENTIFIED GLOBALLY;
GRANT connect TO eus_user;
GRANT SELECT ON v_$session TO eus_user;
```

* Erstellen Sie ein Mapping für die User in der Gruppe *Trivadis LAB Users*.

```bash
eusm createMapping database_name="$ORACLE_SID" \
    realm_dn="dc=trivadislabs,dc=com" map_type=SUBTREE \
    map_dn="ou=People,dc=trivadislabs,dc=com" schema=EUS_USERS \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"  
```

* Testen Sie die Verbinung als Benutzer Blofeld.

```sql
CONNECT blofeld/LAB01schulung@TDB122A

show user
@sousrinf
SELECT * FROM session_roles;
```

* Erstellen Sie ein global private Schema

```sql
CONNECT / AS SYSDBA
CREATE USER king IDENTIFIED GLOBALLY;
GRANT connect TO king;
GRANT SELECT ON v_$session TO king;
```

* Erstellen Sie ein Mapping für den Benutzer King.

```bash
eusm createMapping database_name="$ORACLE_SID" \
    realm_dn="dc=trivadislabs,dc=com" map_type=ENTRY \
    map_dn="cn=Ben King,ou=Senior Management,ou=People,dc=trivadislabs,dc=com" \
    schema=KING \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

* Testen Sie die Verbinung als Benutzer King.

```sql
CONNECT king/LAB01schulung@TDB122A

show user
@sousrinf
SELECT * FROM session_roles;
```

* Testen Sie die Verbinung als Benutzer King mit Kerberos

```sql
okinit king

sqlplus /@TDB122A

@sousrinf
SELECT * FROM session_roles;
```

* Prüfen Sie mit dem OUDSM oder Apache Directory Studio den Inhalt des OUD Proxy.
* Prüfen Sie die Mappings mit EUSM

```bash
eusm listMappings database_name="$ORACLE_SID" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

## Oracle Enterprise User Security Rollen

* Erstellen Sie eine globale Datenbank Rolle hr_clerk und hr_mgr.

```sql
CONNECT / AS SYSDBA
CREATE ROLE hr_clerk IDENTIFIED GLOBALLY;
GRANT SELECT ON tvd_hr.employees TO hr_clerk;
GRANT SELECT ON tvd_hr.jobs TO hr_clerk;
GRANT SELECT ON tvd_hr.job_history TO hr_clerk;
GRANT SELECT ON tvd_hr.regions TO hr_clerk;
GRANT SELECT ON tvd_hr.countries TO hr_clerk;
GRANT SELECT ON tvd_hr.locations TO hr_clerk;
GRANT SELECT ON tvd_hr.departments TO hr_clerk;

CREATE ROLE hr_mgr IDENTIFIED GLOBALLY;
GRANT INSERT,UPDATE,DELETE ON tvd_hr.employees TO hr_mgr;
GRANT INSERT,UPDATE,DELETE ON tvd_hr.jobs TO hr_mgr;
GRANT INSERT,UPDATE,DELETE ON tvd_hr.job_history TO hr_mgr;
GRANT INSERT,UPDATE,DELETE ON tvd_hr.locations TO hr_mgr;
GRANT INSERT,UPDATE,DELETE ON tvd_hr.departments TO hr_mgr;
```

* Erstellen Sie eine Enterprise Rolle *HR Clerk* und *HR Management*.

```bash
eusm createRole enterprise_role="HR Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"

eusm createRole enterprise_role="HR Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

* Zuweisen der Enterprise Rollen zu der globalen Rolle. Weisen Sie der Einterprise Rolle *HR Management* sowohl *hr_clerk* also auch *hr_mgr* zu.
  
```bash
eusm addGlobalRole enterprise_role="HR Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" database_name="$ORACLE_SID" \
    global_role="hr_clerk" dbuser="system" dbuser_password="LAB01schulung" \
    dbconnect_string="db.trivadislabs.com:1521:$ORACLE_SID" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"

eusm addGlobalRole enterprise_role="HR Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" database_name="$ORACLE_SID" \
    global_role="hr_clerk" dbuser="system" dbuser_password="LAB01schulung" \
    dbconnect_string="db.trivadislabs.com:1521:$ORACLE_SID" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"

eusm addGlobalRole enterprise_role="HR Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" database_name="$ORACLE_SID" \
    global_role="hr_mgr" dbuser="system" dbuser_password="LAB01schulung" \
    dbconnect_string="db.trivadislabs.com:1521:$ORACLE_SID" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

* Weisen Sie die Rolle Benutzer zu. Erstellen Sie zuerst im AD eine neue Gruppe für HR. Anschliessend nehmen Sie die HR Gruppe für *HR Clerk* und *Honey Rider* für *HR Management*.

```bash
eusm grantRole enterprise_role="HR Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    group_dn="CN=Trivadis LAB HR,OU=Groups,DC=trivadislabs,DC=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"

eusm grantRole enterprise_role="HR Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    user_dn="CN=Honey Rider,OU=Human Resources,OU=People,DC=trivadislabs,DC=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

* Loggen Sie siche als *Honey Rider* und *Vesper Lynd* ein. Was haben Sie für Rollen?

```sql
CONNECT rider/LAB01schulung@TDB122A
SELECT sys_context('userenv','ENTERPRISE_IDENTITY') FROM DUAL;
SELECT * FROM session_roles;

CONNECT lynd/LAB01schulung@TDB122A
show user
SELECT sys_context('userenv','ENTERPRISE_IDENTITY') FROM DUAL;
SELECT * FROM session_roles;
```

* Was Stellen Sie fest? Stimmen die Rollen von *Vesper Lynd*?
* Weisen Sie im AD *Vesper Lynd* die Richtige Rolle zu und loggen sich sich erneut ein.

```sql
CONNECT lynd/LAB01schulung@TDB122A
show user
SELECT sys_context('userenv','ENTERPRISE_IDENTITY') FROM DUAL;
SELECT * FROM session_roles;
```

* Anzeigen der Enterprise Rollen mit EUSM

```bash
eusm listEnterpriseRoles domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"

eusm listEnterpriseRoleInfo enterprise_role="HR Management" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"

eusm listEnterpriseRoleInfo enterprise_role="HR Clerk" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

## Oracle Enterprise User Security Proxy Authentifizierung

Die Entwickler aus der Entwicklungsabteilung sollen das Recht Erhalten sich als Proxy auf das TVD_HR Schema anzumelden.

* Erstellen der Proxy Berechtigung in der Datenbank-

```sql
CONNECT / AS SYSDBA
ALTER USER tvd_hr GRANT CONNECT THROUGH ENTERPRISE USERS;
```

* Erstellen des Enterprise Proxy Recht

```bash
eusm createProxyPerm proxy_permission="TVD HR Devel" \
    domain_name="OracleDefaultDomain" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

* Weisen Sie das Proxy Recht der AD Gruppe *Trivadis LAB Developers* zu.
  
```bash
eusm grantProxyPerm proxy_permission="TVD HR Devel" \
    domain_name="OracleDefaultDomain" \
    group_dn="CN=Trivadis LAB Developers,OU=Groups,DC=trivadislabs,DC=com" \
    realm_dn="dc=trivadislabs,dc=com" \
    ldap_host="oud.trivadislabs.com" ldap_port=1389 \
    ldap_user_dn="cn=Directory Manager" \
    ldap_user_password="LAB01schulung"
```

* Prüfen Sie die Verbindung normal und als proxy mit einem Mitarbeiter aus dem Development Team. *Douglas Adams, Ernst Blofeld, Henry Ford, James Scott, Paul Smith.*

```sql
CONNECT ford/LAB01schulung@TDB122A
show user
@sousrinf
SELECT * FROM session_roles;

CONNECT blofeld[tvd_hr]/LAB01schulung@TDB122A
show user
@sousrinf
SELECT * FROM session_roles;
```
