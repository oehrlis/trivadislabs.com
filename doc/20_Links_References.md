
# Links und Referenzen

## OUD EUS Workshop

Unterlagen und Skripte zum Workshop

* Übungsskripte zum DOAG Schulungstag [doag2018](https://github.com/oehrlis/doag2018)
* Vagrant Setup zum Aufbau der Trivadis LAB Umgebung [oehrlis/trivadislabs.com](https://github.com/oehrlis/trivadislabs.com)
* Setup Skripte für die Konfiguration der Umgebung (Cloud, Vagrant, Docker) [oehrlis/oradba_init](https://github.com/oehrlis/oradba_init) 
* OUD Base Umgebungsskripte für Oracle Unified Directory [oehrlis/oudbase](https://github.com/oehrlis/oudbase) 

## Oracle Dokumentation

* Oracle Online Dokumentation 18c https://docs.oracle.com/en/database/oracle/oracle-database/18/books.html
* Oracle Enterprise User Security https://docs.oracle.com/en/database/oracle/oracle-database/18/dbimi/index.html 
* Oracle Centrally Managed User https://docs.oracle.com/en/database/oracle/oracle-database/18/dbseg/integrating_mads_with_oracle_database.html 
* Oracle EUSM Utility https://docs.oracle.com/en/database/oracle/oracle-database/18/dbimi/enterprise-user-security-manager-eusm-command-summary.html 

## Software und Tools

### Betriebsystem und Virtualizierung

* Oracle VM Virtualbox [virtualbox](https://www.virtualbox.org/wiki/Downloads) 
* HashiCorp Vagrant [vagrant](https://www.vagrantup.com)
* Oracle Enterprise Linux 7.5
    * Oracle Vagrant Boxes [vagrant image](http://yum.oracle.com/boxes). Predefined Image von Oracle für die Nutzung mit Virtualbox und Vagrant. Das Vagrant Image wird bei einem ``vagrant up`` falls nicht vorhanden direkt herunter geladen.
    * Oracle Software Delivery Cloud [iso](http://edelivery.oracle.com/linux). Basis Setup iso File, falls individuell ein Oracle Linux Server installiert werden soll.
* Microsoft Windows Server 2016
    * Vagrant Box [StefanScherer/windows_2016](https://app.vagrantup.com/StefanScherer/boxes/windows_2016). Vagrant Image aus der Vagrant Cloud. Erstellt von Stefan Scherer für die Nutzung mit Virtualbox und Vagrant. Das Vagrant Image wird bei einem ``vagrant up`` falls nicht vorhanden direkt herunter geladen.
    * Evaluation 2016 [iso](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016). Basis Setup iso File, falls individuell ein Windows Server installiert werden soll.
* Trivadis BasEnv Test [basenv-18.05.final.b.zip](http://docker.oradba.ch/basenv-18.05.final.b.zip) 

### Oracle Datenbank Binaries

* Oracle Base Releases 12c Release 2 und 18c [Oracle Technology Network](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html)
* Oktober Critical Patch Update Oracle Database 18c
    * DATABASE RELEASE UPDATE 18.4.0.0.0 [28655784](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28655784)
    * OJVM RELEASE UPDATE: 18.4.0.0.181016 [28502229](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28502229) 
* Oktober Critical Patch Update Oracle Database 12c Release 2
    * DATABASE OCT 2018 RELEASE UPDATE 12.2.0.1.181016 [28662603](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28662603)
    * OJVM RELEASE UPDATE 12.2.0.1.181016 [28440725](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28440725)
* Oracle OPatch Utility 12.2.0.1.13 for DB 12.2.0.x and DB 18.x [6880880](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=6880880) 

### Oracle Unified Directory Binaries

* Java Server 1.8 u192 [28414856](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28414856)
* Oracle Fusion Middleware 12.2.1.3.0 Oracle Unified Directory [26270957](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=26270957)
* OUD BUNDLE PATCH 12.2.1.3.0(ID:180829.0419) [28569189](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28569189)
* Oracle Fusion Middleware 12.2.1.3.0 Fusion Middleware Infrastructure [26269885](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=26269885)
* WLS PATCH SET UPDATE 12.2.1.3.181016 Oracle WLS 12.2.1.3.0 [28298734](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28298734)
* OPatch Utility für WLS [28186730](https://updates.oracle.com/ARULink/PatchDetails/process_form?patch_num=28186730)
* OUD Base Umgebungsskripte für Oracle Unified Directory [oehrlis/oudbase](https://github.com/oehrlis/oudbase) 

### Tools Active Directory Server

* Oracle Clients
    * Oracle Clients [Oracle Technology Network](https://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html)
    * Oracle Instant Clients [Oracle Technology Network](https://www.oracle.com/technetwork/database/database-technologies/instant-client/downloads/index.html)
* Apache Directory Studio LDAP Browser [Home](https://directory.apache.org/studio/)
* Putty SSH Utility [Putty Home](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)  
* WinSCP SFTP client und FTP Client für Microsoft Windows [WinSCP Home](https://winscp.net/eng/index.php) 
