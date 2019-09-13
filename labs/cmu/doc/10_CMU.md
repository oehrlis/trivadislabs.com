
# Centrally Managed User 18c

**Ziele:** Konfiguration von Centrally Managed Users für die Datenbank TDB180S. Erweitern des Active Directory Schemas inklusive der Installation des Password Filter Plugins. Erstellen von Mappings für Benutzer und Rollen sowie erfolgreichem Login mit Passwort Authentifizierung.

## Active Directory Konfiguration

Arbeitsumgebung:

* **Server:** win2016ad.trivadislabs.com
* **Benutzer:** Administrator

Die folgenden Arbeiten werden in der Regel in Zusammenarbeit mit dem Windows respektive Active Directory Administrator durchgeführt. Je nach Unternehmensgrösse sind allenfalls noch weiter IT Bereich mit involviert.

Für das Oracle Wallet wird das Root Zertifikat vom Active Directory Server benötigt. Diesen kann in der LAB Umgebung einfach via Commandline exportiert werden. Dazu öffnet man ein Command Prompt (``cmd.exe``) und exportieren das Root Zertifikat. Das exportiert Root Zertifikat muss anschliessend mit WinSCP auf den Datenbank Server in das Verzeichnis ``/u00/app/oracle/network/admin`` kopiert werden. Alternativ kann man das unten aufgeführte Putty SCP Kommando verwenden. 

```bash
certutil -ca.cert c:\vagrant_common\config\tnsadmin\RootCA_trivadislabs.com.cer

"C:\Program Files\PuTTY\pscp.exe" c:\vagrant_common\config\tnsadmin\RootCA_trivadislabs.com.cer ol7db18.trivadislabs.com:/u00/app/oracle/network/admin
```

In der Vagrant VM Umgebung ist zudem das Verzeichnis ``c:\vagrant_common\`` auf allen Systemen verfügbar. Somit lässt sich die Datei einfach auf dem Datenbank Server nutzen.

```
cp /vagrant_common/config/tnsadmin/RootCA_trivadislabs.com.cer /u00/app/oracle/network/admin
```

Um Oracle CMU mit Passwort Authentifizierung verwenden zu können, muss Active Directory entsprechend angepasst werden. Dazu muss mit WinSCP die Datei ``opwdintg.exe`` auf den Active Directory Server kopiert werden. Auf dem Datenbank Server liegt die Datei im Oracle 19c Home ``$ORACLE_HOME/bin/opwdintg.exe``. Alternativ man das unten aufgeführte Putty SCP Kommando verwenden.

```bash
"C:\Program Files\PuTTY\pscp.exe" ol7db18.trivadislabs.com:/u00/app/oracle/product/19.0.0.0/bin/opwdintg.exe c:\vagrant_common\config\tnsadmin\
```

In der Vagrant VM Umgebung ist zudem das Verzeichnis ``c:\vagrant_common\`` auf allen Systemen verfügbar. Somit lässt sich die Datei einfach auf dem Datenbank Server kopieren.

```
ls -alh $ORACLE_HOME/bin/opwdintg.exe
cp $ORACLE_HOME/bin/opwdintg.exe /vagrant_common/config/tnsadmin
```

Anschliessend muss die Datei auf dem Active Directory ausgeführt werden, um das AD Schema zu erweitern und das Passwort Filter Plugin zu installieren. Dazu wird ``opwdintg.exe`` direkt in einem Command Shell (``cmd.exe``) ausgeführt. 

```bash
c:\vagrant_common\config\tnsadmin\opwdintg.exe
```

Bei der Installstion sind folgende Fragen mit Ja respektive Yes zu beantworten:

* Do you want to extend AD schema? [Yes/No]: 
* Schema extension for this domain will be permanent. Continue? [Yes/No]:
* Do you want to install Oracle password filter?[Yes/No]: 
* The change requires machine reboot. Do you want to reboot now?[Yes/No]:

Nachdem der Active Directory Server neu gestartet wurde, müssen zum Abschluss die neu erstellten Gruppen für die Passwort Verifier entsprechend vergeben werden. Entsprechende Benutzer, welche sich an der Datenbank anmelden, müssen dazu ein Oracle Password Hash haben. Dieser wird vom Password Filter bei allen Benutzer erstellt, welche in der Gruppe *ORA_VFR_11G* respektive *ORA_VFR_12C* sind. Zudem müssen diese Benutzer ihr Passwort neu setzten, damit das Passwort Filter Plugin auch effektive das Attribut *orclCommonAttribute* setzt.

**Variante 1:** Anpassen der Gruppe *Trivadislabs Users* und manuelles hinzufügen von *ORA_VFR_11G* respektive *ORA_VFR_12C* zu MemberOf.

* Starten von *Active Directory Users and Computers*.
* Auswahl der Gruppe *Trivadislabs Users* im Container Groups.
* Öffnen der *Properties* mit rechtem Mausklick.
* Im Tab *Member Of* *Add...* auswählen.
* Hinzufügen der Gruppe *ORA_VFR_11G* respektive *ORA_VFR_12C*.
* Schliessen der Dialoge mit *Ok*.
  
Anschliessend manuelles Anpassen der Passwörter für die gewünschten Benutzer. Dazu muss man in *Active Directory Users and Computers* jeweils den Benutzer auswählen und mit rechtem Mausklick *Reset Password...* starten, um ein neues Passwort zu setzten.

**Variante 2:** Öffnen eines PowerShell Fenster und ausführen des Scripts ``c:\aoug\lab\04_cmu\reset_ad_users.ps1``. Das Script passt sowohl die Gruppe an und ändert die Passwörter aller Benutzer. 

```bash
C:\vagrant\scripts\reset_ad_users.ps1
```

Kontrolle ob das Attribut *orclCommonAttribute* gesetzt ist. Die folgende Abbildung zeigt die Properties vom Benutzer King und das Attribut *orclCommonAttribute*.

!["Benutzereigenschaften Benutzer King"](images/User_Account_Preferences_King.png)  

Benutzer ``oracle`` für die CMU intergration

## Server und Datenbank Konfiguration

Arbeitsumgebung für diesen Abschnitt:

* **Server:** ol7db18.trivadislabs.com
* **Benutzer:** oracle
* **Datenbank:** TDB180S

CMU benötigt in allen Oracle 18c Versionen einen Patch. Siehe auch Oracle MOS Note [2462012.1](https://support.oracle.com/epmos/faces/DocumentDisplay?id=2462012.1) *How To Configure Authentication For The Centrally Managed Users In An 18c Database* und Oracle Support Bug OUD 12C: DIGEST-MD5 SASL AUTHENTICATION FAILS IF ORACLECONTEXT ENTRY AND LDAPS [29034231](https://support.oracle.com/epmos/faces/BugDisplay?id=29034231). Bevor CMU genutzt werden kann ist zu prüfen ob der Patch installiert ist.

```bash
$cdh/OPatch/opatch lsinventory

$cdh/OPatch/opatch lsinventory |grep -i 28994890
```

Erstellen der SQLNet Konfigurationsdatei ``dsi.ora`` mit den folgenden Informationen zum Aktive Directory Server. Eine Beispiel Konfigurationsdatei ist im Verzeichnis ``$cdl/aoug/lab`` vorhanden.

```bash
cp $cdl/aoug/lab/dsi.ora $cdn/admin/dsi.ora
vi $cdn/admin/dsi.ora
DSI_DIRECTORY_SERVERS = (win2016ad.trivadislabs.com:389:636)
DSI_DEFAULT_ADMIN_CONTEXT = "dc=trivadislabs,dc=com"
DSI_DIRECTORY_SERVER_TYPE = AD
```

Erstellen eines neuen Oracle Wallet für die Datenbank TDB180S.

```bash
mkdir $ORACLE_BASE/admin/$ORACLE_SID/wallet
orapki wallet create -wallet $ORACLE_BASE/admin/$ORACLE_SID/wallet -auto_login
```

Hinzufügen der Einträge für den Benutzername, Passwort und den Distinguished Name.

```bash
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.USERNAME oracle

mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.DN CN=oracle,CN=Users,DC=trivadislabs,DC=com

mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.PASSWORD LAB01schulung
```

Copy/Paste Variante für die Live Demo

```bash
echo LAB01schulung|mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.USERNAME oracle

echo LAB01schulung|mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.DN CN=oracle,CN=Users,DC=trivadislabs,DC=com

echo LAB01schulung|mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -createEntry ORACLE.SECURITY.PASSWORD LAB01schulung
```

Laden des Root Zertifikat vom Active Directory Server in das Wallet.

```bash
orapki wallet add -wallet $ORACLE_BASE/admin/$ORACLE_SID/wallet -cert $TNS_ADMIN/RootCA_trivadislabs.com.cer -trusted_cert
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

Oder der Inhalt vom Wallet mit mkstore

```bash
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -list
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.DN
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.PASSWORD
mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.USERNAME
```

```bash
echo LAB01schulung|mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -list
echo LAB01schulung|mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.DN
echo LAB01schulung|mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.PASSWORD
echo LAB01schulung|mkstore -wrl $ORACLE_BASE/admin/$ORACLE_SID/wallet -viewEntry ORACLE.SECURITY.USERNAME
```

Mit dem LDAP Search Befehl läst sich zudem Prüfen, ob der Zugriff auf das Active Directory mit dem Wallet funktioniert. Der folgende Befehl sucht nach einem *sAMAccountName=blo*. **Achtung!** Die Passwörter für den Benutzer oracle18c sowie das Wallet Passwort werden hier auf dem Commandline angegeben.

```bash
ldapsearch -h win2016ad.trivadislabs.com -p 389 \
    -D "CN=oracle,CN=Users,DC=trivadislabs,DC=com" \
    -w LAB01schulung -U 2 \
    -W "file:/u00/app/oracle/admin/$ORACLE_SID/wallet" \
    -P LAB01schulung -b "OU=People,DC=trivadislabs,DC=com" \
    -s sub "(sAMAccountName=blo*)" dn orclCommonAttribute
```

## Benutzer und Rollen

Arbeitsumgebung für die Übung:

* **Server:** ol7db18.trivadislabs.com
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
CREATE USER tvd_global_users IDENTIFIED GLOBALLY AS 'CN=Trivadislabs Users,OU=Groups,DC=trivadislabs,DC=com';
GRANT create session TO tvd_global_users ;
GRANT SELECT ON v_$session TO tvd_global_users ;
```

Verbinden Sie sich als Benutzer Blofeld und prüfen Sie die detail Informationen zu dieser Session wie Authentifizierung, Identity etc.

```sql
connect "blofeld@TRIVADISLABS.COM"@TDB180S

show user
@sousrinf
```

Nun können sich alle AD Benutzer der Gruppe *Trivadis LAB Users* mit der Datenbank TDB184A verbinden. Sie erhalten dabei die basis Rechte, welche wir zuvor dem Datenbank Account *tvd_global_users* gegeben haben. Interessant wird es, wenn die Benutzer aus den verschiedenen Abteilungen unterschiedliche Rechte oder Rollen erhalten. Dazu erstellen wir entsprechende Rollen mit einem Mapping auf die Active Directory Gruppe oder Organisation Unit. 

```sql
CONNECT / AS SYSDBA

CREATE ROLE mgmt_role IDENTIFIED GLOBALLY AS
'CN=Trivadislabs Management,OU=Groups,DC=trivadislabs,DC=com';

CREATE ROLE rd_role IDENTIFIED GLOBALLY AS
'CN=Trivadislabs Developers,OU=Groups,DC=trivadislabs,DC=com';
```

Prüfen Sie nun die verschiedenen Rechte / Rollen der einzelnen Mitarbeitern aus diesem Abteilungen.

```sql
CONNECT "moneypenny@TRIVADISLABS.COM"/LAB01schulung@TDB180S
SELECT * FROM session_roles;

CONNECT "smith@TRIVADISLABS.COM"/LAB01schulung@TDB180S
SELECT * FROM session_roles;

CONNECT "blofeld@TRIVADISLABS.COM"/LAB01schulung@TDB180S
SELECT * FROM session_roles;
```

## Zusatzaufgabe: Rollen und Admininistratoren

Falls noch Zeit übrig ist, bieten sich folgende Zusatzaufgaben an. Erstellen Sie ein global private Schema für den Benutzer Adams. Was für ein DB Benutzer wird jetzt verwendet, wenn sich der Benutzer Adams anmeldet? Welche Rollen sind Aktiv?

```sql
CONNECT / AS SYSDBA

CREATE USER adams IDENTIFIED GLOBALLY AS 'CN=Douglas Adams,OU=Research,OU=People,DC=trivadislabs,DC=com';
GRANT create session TO adams ;
GRANT SELECT ON v_$session TO adams ;

connect "adams@TRIVADISLABS.COM"/LAB01schulung@TDB180S
SELECT * FROM session_roles;
show user
@sousrinf
```

Erstellen Sie ein Mapping für die DBA's, welche sich auch als SYSDBA anmelden sollen. Prüfen Sie dazu als erstest das Format der Oracle Password Datei. Voraussetzung für das Mapping von Administratoren ist die Passwort Datei Version 12.2.

```bash
orapwd describe file=$cdh/dbs/orapwTDB180S
```

Migrieren Sie die aktuelle Passwort Datei in das Format 12.2. Alternativ können Sie die Passwort Datei auch neu anlegen.

```bash
mv $cdh/dbs/orapwTDB180S $cdh/dbs/orapwTDB180S_format12
orapwd format=12.2 input_file=$cdh/dbs/orapwTDB180S_format12 file=$cdh/dbs/orapwTDB180S
orapwd describe file=$cdh/dbs/orapwTDB180S
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
CONNECT "fleming@TRIVADISLABS.COM"/LAB01schulung@TDB180S
SELECT * FROM session_roles;
show user
@sousrinf
```

```sql
CONNECT "fleming@TRIVADISLABS.COM"/LAB01schulung@ol7db18.trivadislabs.com:1521/TDB180S as sysdba
SELECT * FROM session_roles;
show user
@sousrinf
```
