
# Demo- und Lab Umgebung

issue und manuelle konfig
* dns
* resolve dns search
* putty / ssh keys
* oracle vagrant gruppe


## Architektur

Für die praktischen Arbeiten im Rahmen des DOAG 2018 Schulungstages, steht pro zweiter Team eine einfach Testumgebung zur Verfügung. Die Umgebung läuft für die Dauer der Schulung in der [Oracle Ravello Cloud](https://cloud.oracle.com/en_US/ravello) und besteht, wie in der folgenden Abbildung ersichtlich aus folgenden Servern respektive VMs:

* **db.trivadislabs.com** Oracle Datenbank Server mit Oracle 12c R2 sowie 18c
* **oud.trivadislabs.com** Oracle Directory Server mit Oracle Unified Directory 12c
* **ad.trivadislabs.com** MS Windows Server 2012 R2 mit Active Directory

!["Training Environment"](images/LabEnvironment.png)
*Abb. 2: Architektur Schulungsumgebung*

Die Umgebung ist soweit vorbereitet, dass direkt mit den Übungen gestartet werden kann. 

Die zentrale Benutzerverwaltung mit _Oracle Centrally Managed Users_ oder _Oracle Enterprise User Security_ sind komplexe Themen, welche nicht abschliessend am Schulungstag diskutiert werden können. Aus diesem Grund gibt es für das Selbststudium die Möglichkeit, eine Testumgebung analog dem Schulungstag aufzubauen. Diese Umgebung wird Skript gestützt mit [Vagrant](https://www.vagrantup.com) auf [Virtualbox](https://www.virtualbox.org/wiki/Downloads) aufgebaut. Man benötigt lediglich die entsprechenden Software Images für die Oracle Datenbank 12c R2 + 18c, Oracle Unified Directory sowie die Umgebungsscripte. Anschliessend lässt sich die Umgebung nahezu voll automatisch aufbauen. Eine entsprechende Anleitung für den Aufbau der Trivadis LAB Umgebung sowie die dazugehörigen _Vagrant Files_, _Skripte_ etc. findet man im GitHub Repository [oehrlis/trivadislabs.com](https://github.com/oehrlis/trivadislabs.com).

## Oracle Datenbank Server

### Generelle Server Konfiguration

Der Oracle Datenbank Server ist wie folgt konfiguriert:

* **Host Name :** db.trivadislabs.com
* **Interne IP Adresse :** 10.0.0.3
* **Externe IP Adresse :** gemäss Liste
* **Betriebssystem :** Oracle Enterprise Linux Server Release 7.5
* **Oracle Datenbank Software :**
    * Oracle 12c Release 2 Enterprise Edition (12.2.0.1) mit Release Update vom Oktober 2018
    * Oracle 18c Enterprise Edition (18.4.0.0) mit Release Update vom Oktober 2018
* **Oracle Datenbanken :**
    * **TDB122A** Oracle 12cR2 Enterprise Edition Single Instance für die Übungen mit EUS
    * **TDB184A** Oracle 18c Enterprise Edition Single Instance für die Übungen mit CMU
* **Betriebsystem Benutzer :** 
    * oracle / PASSWORT
    * root / PASSWORT
* **Datenbank Benutzer :** 
    * sys / manager
    * system / manager
    * scott / tiger
    * tvd_hr / tvd_hr

### Trivadis BasEnv

Das Trivadis Base Environment (TVD-BasenvTM) ermöglicht einfaches Navigieren in der Directory Struktur und zwischen den verschiedenen Datenbanken. In der folgenden Tabelle sind die Aliases für den OS Benutzer *oracle* aufgelistet, welche am häufigsten verwendet werden.

| Alias Name | Beschreibung                                                              |
|------------|---------------------------------------------------------------------------|
| cda        | zum Admin Verzeichnis der aktuell gesetzten Datenbank                     |
| cdh        | zum Oracle Home                                                           |
| cdob       | zum Oracle Base                                                           |
| cdt        | zum TNS_ADMIN                                                             |
| sqh        | startet SQLPlus mit „sqlplus / as sysdba“ inklusive Befehlshistory        |
| sta        | Statusanzeige für die aktuell gesetzte Datenbank                          |
| taa        | öffnet das Alertlog der aktuell gesetzten Datenbank mit ``tail -f``       |
| TDB122A    | setzt die Umgebung im Terminal für die Datenbank *TDB122A*                |
| TDB184A    | setzt die Umgebung im Terminal für die Datenbank *TDB184A*                |
| u          | Statusanzeige für alle Oracle Datenbanken und Listener (z.B. open, mount) |
| via        | öffnet das Alertlog der aktuell gesetzten Datenbank in vi                 |

Die Installation ist nach dem OFA (Optimal Flexible Architecture) Standard vorgenommen worden – Beispiel für die Installation auf der Datenbank-VM für die Datenbank - *TDB122A*:

| Mount Point / Directory                  | Beschreibung                             |
|------------------------------------------|------------------------------------------|
| ``/u00/app/oracle/admin/TDB122A/adump``  | Oracle Audit Files                       |
| ``/u00/app/oracle/admin/TDB122A/backup`` | Oracle Backup                            |
| ``/u00/app/oracle/admin/TDB122A/dpdump`` | Data Pump Dateien                        |
| ``/u00/app/oracle/admin/TDB122A/etc``    | Oracle Backup Konfig Dateien             |
| ``/u00/app/oracle/admin/TDB122A/log``    | Log Dateien (z.B. Backup, Export, etc.)  |
| ``/u00/app/oracle/admin/TDB122A/pfile``  | Parameter- und Password-Datei            |
| ``/u00/app/oracle/admin/TDB122A/wallet`` | Oracle Wallet                            |
| ``/u00/app/oracle/etc``                  | oratab und diverse Konfigurationsdateien |
| ``/u00/app/oracle/local/dba``            | Environment Tools (TVD-Basenv)           |
| ``/u00/app/oracle/network/admin``        | Oracle Net Konfigurationsdateien         |
| ``/u00/app/oracle/product/12.2.0.1``     | Oracle 12.2.0.1 Home                     |
| ``/u00/app/oracle/product/18.4.0.0 ``    | Oracle 18.4.0.0 Home                     |
| ``/u01/oradata/TDB122A``                 | Datenbank Dateien, Redo Log Files, CTL   |
| ``/u02/fast_recovery_area/TDB122A``      | Fast Recovery Area                       |
| ``/u02/oradata/TDB122A``                 | Redo Log Files, CTL                      |

### Übungschema TVD_HR

In den Datenbanken ist neben dem Scott Demo Schema zusätzlich das Beispiel Schema *TVD_HR*. Das Schema *TVD_HR* basiert auf dem bekannten Oracle *HR* Beispiel Schema. Der wesentliche Unterschied zum regulären *HR* Schema ist, dass die Abteilungen sowie Mitarbeiter den Mitarbeitern im Active Directory entspricht.

Erklärung zu den Tabellen basierend auf den Kommentaren vom *HR* Schema:

* **REGIONS** Tablle, welche Regionsnummern und -namen enthält. Verweise auf die Tabelle *LOCATION*.
* **LOCATIONS** Tablle, die die spezifische Adresse eines bestimmten Büros, Lagers und/oder Produktionsstandortes eines Unternehmens enthält. Speichert keine Adressen von Kundenstandorten.
* **DEPARTMENTS** Tabelle, die Details zu den Abteilungen zeigt, in denen die Mitarbeiter arbeiten. Verweise auf Standorte, Mitarbeiter und Job History Tabellen.
* **JOB_HISTORY** Tabelle, in der die Beschäftigungshistorie der Mitarbeiter gespeichert ist. Wenn ein Mitarbeiter innerhalb der Stelle die Abteilung wechselt oder die Stelle innerhalb der Abteilung wechselt, werden neue Zeilen in diese Tabelle mit alten Stelleninformationen des Mitarbeiters eingefügt. Verweise auf Tabellen mit Jobs, Mitarbeitern und Abteilungen.
* **COUNTRIES** Tabelle. Verweise mit der Tabelle der Standorte.
* **JOBS** Tabelle mit Jobbezeichnungen und Gehaltsgruppen. Verweise auf Mitarbeiter und Job History Tabelle.
* **EMPLOYEES** Tabelle. Verweise mit Abteilungen, Jobs, Job History Tabellen. Enthält eine Selbstreferenz.

Zukünftige Versionen von TVD_HR werden zusätzlich entsprechend VPD Policies enthalten.

## Oracle Unified Directory Server

### Generelle Server Konfiguration

Der Directory Server ist wie folgt konfiguriert:

* **Host Name :** oud.trivadislabs.com
* **Interne IP Adresse :** 10.0.0.5
* **Externe IP Adresse :** gemäss Liste
* **Betriebssystem :** Oracle Enterprise Linux Server Release 7.5
* **Java :** Oracle JAVA Server JRE 1.8 u192
* **Oracle Fusion Middleware Software :**
    * Oracle Unified Directory (12.2.1.3) mit dem Bundle Patch vom Oktober 2018
    * Oracle Fusion Middleware Infrastructure Directory (12.2.1.3) mit dem Bundle Patch vom Oktober 2018
* **Oracle Home oud12.2.1.3 :** Oracle Unified Directory *standalone* Installation.
* **Oracle Home fmw12.2.1.3 :** Oracle Unified Directory *collocated* Installation mit Oracle Fusion Middleware Infrastructure.
* **Betriebsystem Benutzer :** 
    * oracle / PASSWORT
    * root / PASSWORT
  
### Trivadis OUD Base

Analog zu der Datenbank Umgebung, gibt es auch für Oracle Unified Directory entsprechende Umgebungsscripte. Diese Umgebungsscripte, kurz auch OUD Base genannt, werden unteranderem in [OUD Docker images](https://github.com/oracle/docker-images/tree/master/OracleUnifiedDirectory) verwendet. Aus diesem Grund ist OUD Base etwas "leichter" aufgebaut als TVD-Basenv und basiert zu 100% auf Bash. OUD Base ist via GitHub Projekt [oehrlis/oudbase](https://github.com/oehrlis/oudbase) als Open Source verfügbar. 

 In der folgenden Tabelle sind die Aliases für den OS Benutzer *oracle* aufgelistet, welche am häufigsten verwendet werden.

| Alias Name | Beschreibung                                                                     |
|------------|----------------------------------------------------------------------------------|
| cda        | zum Admin Verzeichnis der aktuell OUD Instanz                                    |
| cdh        | zum Oracle Home                                                                  |
| cdih       | zum OUD Instanz Home Verzeichnis                                                 |
| cdil       | zum OUD Instanz Log Verzeichnis                                                  |
| cdob       | zum Oracle Base                                                                  |
| dsc        | aufruf von dsconfig inklusive Host Name, ``$PORT_ADMIN`` und ``$PWD_FILE``       |
| oud_ad     | setzt die Umgebung im Terminal für die OUD Instanz *oud_ad*                      |
| taa        | öffnet das Access Log der aktuell gesetzten OUD Instanz mit ``tail -f``          |
| u          | Statusanzeige für alle OUD Instanz inkl entsprechender Ports                     |
| version    | Anzeiden der Version von OUD base inklusive geänderten Dateien in ``$OUD_LOCAL`` |
| vio        | öffnet die oudtab Datei. ``${ETC_BASE}/oudtab``                                  |

Die Installation ist an den OFA (Optimal Flexible Architecture) Standard angelegt. Die Software, Konfiguration sowie Instanzen werden explizit von einander getrennt. Beispiel für die Installation auf der OUD-VM für die OUD Instanz - *oud_ad*:

| Mount Point / Directory                   | Beschreibung                                      |
|-------------------------------------------|---------------------------------------------------|
| ``/u00/app/oracle/local/oudbase``         | Environment Tools (OUD Base)                      |
| ``/u00/app/oracle/product/fmw12.2.1.3.0`` | Oracle Unified Directory 12.2.1.3 Collocated Home |
| ``/u00/app/oracle/product/jdk1.8.0_192``  | Oracle Java 1.8 update 192                        |
| ``/u00/app/oracle/product/oud12.2.1.3.0`` | Oracle Unified Directory 12.2.1.3 Standalone Home |
| ``/u01/admin/oud_ad``                     | Instance Admin Verzeichnis                        |
| ``/u01/backup``                           | Standard Backup Verzeichnis                       |
| ``/u01/etc``                              | oudtab und diverse Konfigurationsdateien          |
| ``/u01/instances/oud_ad/OUD/config``      | Instanz Konfigurations Verzeichnis                |
| ``/u01/instances/oud_ad/OUD/logs``        | Instanz Log Verzeichnis                           |
| ``/u01/instances/oud_ad``                 | Instanz Home Verzeichnis                          |

## MS Active Directory Server

### Generelle Server Konfiguration

Der Active Directory Server basiert auf einer Windows Server 2012 R2 Umgebung (Windows Server 2016 für on-premises Setup) und ist wie folgt konfiguriert:

* **Host Name :** ad.trivadislabs.com
* **Interne IP Adresse :** 10.0.0.4
* **Externe IP Adresse :** gemäss Liste
* **Betriebssystem :** MS Windows Server 2012 R2
* **Installiere Server Roles :**
    * Active Directory Server
    * DNS Server mit Active Directory Integration
    * Certification Autority
* **Zusatz Software :** nur auf der Cloud VM
    * Putty für SSH Verbindungen mit dem OUD und DB Server
    * MobaXTerm für SSH Verbindungen mit dem OUD und DB Server
    * WinSCP für den File Transfer DB Server <=> AD Server
    * SQL Developer
    * Oracle 12c R2 und 18c Clients 
    * MS Visual Studio Code als universellen Texteditor
    * Predefined SSH Keys für den OUD und DB Server
* **Betriebsystem Benutzer :** 
    * Administrator / PASSWORT
    * root / PASSWORT
    * Trivadis LAB User / LAB01schulung

### AD Domain TRIVADISLAB

Damit eine mehr oder weniger praxis nahe Anbindung an das Active Directory möglich ist, wurde für die fiktive Firma *Trivadis LAB* eine einfache AD Struktur aufgebaut. Die folgende Abbildung zeigt das Organigram inklusive Abteilungen und Mitarbeiter für *Trivadis LAB*. Sämtlich aufgeführte Benutzer können als Testbenutzer verwendet werden. Wobei der Loginname jeweils dem klein geschriebenen Nachname entspricht. Passwort ist für alle Benutzer *LAB01schulung*.

!["Trivadis LAB Company"](images/OrgChart.png)
*Abb. 3: Organigram Trivadis LAB Company*

Das fiktive Unternehmen hat folgende Abteilungen:

| ID | Abteilung              | Distinguished Name (DN)                                        | Beschreibung       |
|----|------------------------|----------------------------------------------------------------|--------------------|
| 10 | Senior Management      | ``ou=Senior Management,ou=People,dc=trivadislabs,dc=com``      | Geschäftsleitung   |
| 20 | Accounting             | ``ou=Accounting,ou=People,dc=trivadislabs,dc=com``             | Finanzen           |
| 30 | Research               | ``ou=Research,ou=People,dc=trivadislabs,dc=com``               | Forschung          |
| 40 | Sales                  | ``ou=Sales,ou=People,dc=trivadislabs,dc=com``                  | Verkauf + Vertrieb |
| 50 | Operations             | ``ou=Operations,ou=People,dc=trivadislabs,dc=com``             | Betriebsabteilung  |
| 60 | Information Technology | ``ou=Information Technology,ou=People,dc=trivadislabs,dc=com`` | IT Abteilung       |
| 70 | Human Resources        | ``ou=Human Resources,ou=People,dc=trivadislabs,dc=com``        | Personalabteilung  |

Zusätzlich wurden folgende Gruppen definiert:

| Gruppe                     | Distinguished Name (DN)                                            | Beschreibung                           |
|----------------------------|--------------------------------------------------------------------|----------------------------------------|
| Trivadis LAB APP Admins    | ``ou=Trivadis LAB APP Admins,ou=Groups,dc=trivadislabs,dc=com``    | Applikations Administratoren           |
| Trivadis LAB DB Admins     | ``ou=Trivadis LAB DB Admins,ou=Groups,dc=trivadislabs,dc=com``     | DB Admins aus der IT Abteilung         |
| Trivadis LAB Developers    | ``ou=Trivadis LAB Developers,ou=Groups,dc=trivadislabs,dc=com``    | Entwickler aus der Forschungsabteilung |
| Trivadis LAB Management    | ``ou=Trivadis LAB Management,ou=Groups,dc=trivadislabs,dc=com``    | Geschäftsleitung und Manager           |
| Trivadis LAB System Admins | ``ou=Trivadis LAB System Admins,ou=Groups,dc=trivadislabs,dc=com`` | System Admins aus der IT Abteilung     |
| Trivadis LAB Users         | ``ou=Trivadis LAB Users,ou=Groups,dc=trivadislabs,dc=com``         | Alle Benutzter                         |
