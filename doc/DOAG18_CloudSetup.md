# Oracle Ravelle Cloud Umgebung

Installation von fail2ban gemäss Blog Post Martin Berger.

# Setup Database Server

Setup des Oracle DB Servers erfolgt basierend auf einem initialen Oracle Linux setup. Im Anschluss an das Setup erfolgt die Konfiguration mithilfe der [oehrlis/oradba_init](https://github.com/oehrlis/oradba_init) scripts.
ssh public key für Root kopieren

## Basis Konfiguration

Setup root Zugriff via SSH. Kopieren des localen Public Key's

```bash
ssh-copy-id root@130.61.65.229
```

Anpassung des *root* Passwortes.

```bash
passwd
```

Installation der [oehrlis/oradba_init](https://github.com/oehrlis/oradba_init) Scripte.

```bash
GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin"
mkdir -p /tmp/download

# get the latest install script for OraDBA init from GitHub repository
curl -Lsf ${GITHUB_URL}/00_setup_oradba_init.sh -o /tmp/download/00_setup_oradba_init.sh

# install the OraDBA init scripts
chmod 755 /tmp/download/00_setup_oradba_init.sh
/tmp/download/00_setup_oradba_init.sh
```

Software in das Stage Verzeichnis kopieren. Von einem lokalen Stage Verzeichnis oder via ``curl`` direkt von OTN / MOS.

```bash
scp *.zip root@130.61.65.229:/opt/stage/

ssh root@130.61.65.229

echo "machine login.oracle.com login cpureport@trivadis.com password tr1vad1$" >/opt/stage/.netrc

nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28655784_180000_Linux-x86-64.zip?aru=22509982&patch_file=p28655784_180000_Linux-x86-64.zip" -o p28655784_180000_Linux-x86-64.zip >p28655784_180000_Linux-x86-64.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28502229_180000_Linux-x86-64.zip?aru=22435400&patch_file=p28502229_180000_Linux-x86-64.zip" -o p28502229_180000_Linux-x86-64.zip >p28502229_180000_Linux-x86-64.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p6880880_122010_Linux-x86-64.zip?aru=22116395&patch_file=p6880880_122010_Linux-x86-64.zip" -o p6880880_122010_Linux-x86-64.zip >p6880880_122010_Linux-x86-64.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28440725_122010_Linux-x86-64.zip?aru=22431985&patch_file=p28440725_122010_Linux-x86-64.zip" -o p28440725_122010_Linux-x86-64.zip >p28440725_122010_Linux-x86-64.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28662603_122010_Linux-x86-64.zip?aru=22485591&patch_file=p28662603_122010_Linux-x86-64.zip" -o p28662603_122010_Linux-x86-64.zip >p28662603_122010_Linux-x86-64.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28880433_184000DBRU_Linux-x86-64.zip?aru=22556075&patch_file=p28880433_184000DBRU_Linux-x86-64.zip" -o p28880433_184000DBRU_Linux-x86-64.zip >p28880433_184000DBRU_Linux-x86-64.log 2>&1 &

nohup curl "https://download.oracle.com/otn/linux/oracle18c/180000/LINUX.X64_180000_db_home.zip?AuthParam=1542642730_6a167ba6bc76b16ce0ea414d4f91f4a3" -o LINUX.X64_180000_db_home.zip >LINUX.X64_180000_db_home.zip.log 2>&1 &

rm -rf /opt/stage/.netrc /opt/stage/*.log
```

Oracle Benutzer anlegen und benötigte YUM Packages installieren.

```bash
/opt/oradba/bin/01_setup_os_db.sh
```

Konfiguration von sudo für Oracle 

```bash
echo "## Allow sudo for user oracle" > /etc/sudoers.d/oracle
echo "oracle    ALL=(ALL)   NOPASSWD:   ALL" >> /etc/sudoers.d/oracle
```

Anpassung des *oracle* Passwortes.

```bash
ssh root@130.61.65.191
passwd oracle
```

Setup oracle Zugriff via SSH. Kopieren des localen Public Key's

```bash
ssh-copy-id oracle@130.61.65.191
```

DOAG 2018 Training Key erstellen und verteilen.

```bash
ssh-keygen -C "DOAG 2018 Training" -b 4096
sudo cp /home/oracle/.ssh/id_rsa.pub /root/.ssh
sudo cp /home/oracle/.ssh/id_rsa /root/.ssh
```

Install git tools

```bash
yum -y install git
```

Disable root login via SSH

```bash
vi /etc/ssh/sshd_config
```

Configure Firewall Ports

```bash
firewall-cmd --list-ports
iptables -L -n 
firewall-cmd --zone=public --add-port=1521/tcp
firewall-cmd --list-ports
iptables -L -n 
```

Installation von fail2ban gemäss Blog Post Martin Berger.

## Installation Oracle Binaries

Installation von Oracle 18c (18.4.0.0)

```bash
su -l oracle -c "/opt/oradba/bin/10_setup_db_18.4.sh"
```

Root Skripte ausführen

```bash
/u00/app/oraInventory/orainstRoot.sh
/u00/app/oracle/product/18.4.0.0/root.sh
```

Installation vom CMU Patch

```bash
su - oracle
unzip /opt/stage/p28880433_184000DBRU_Linux-x86-64.zip -d /tmp
cd /tmp/28880433/
/u00/app/oracle/product/18.4.0.0/OPatch/opatch apply
cd 
rm -rf /tmp/28880433
```

export ORACLE_HOME=/u00/app/oracle/product/12.2.0.1
[oracle@db lib]$ cd $ORACLE_HOME/rdbms/lib
[oracle@db lib]$ make -f ins_rdbms.mk uniaud_on ioracle


Installation von Oracle 12c R2 (12.2.0.1)

```bash
su -l oracle -c "/opt/oradba/bin/10_setup_db_12.2.sh"
```

/u00/app/oracle/product/12.2.0.1/root.sh

export ORACLE_HOME=/u00/app/oracle/product/12.2.0.1
[oracle@db lib]$ cd $ORACLE_HOME/rdbms/lib
[oracle@db lib]$ make -f ins_rdbms.mk uniaud_on ioracle

## Install BasEnv

## Setup Databases

### Setup TDB184A

```bash
export ORACLE_SID1=${ORACLE_SID1:-"TDB184A"}
export ORADBA_TEMPLATE_PREFIX=${ORADBA_TEMPLATE_PREFIX:-"custom_"}
. ${ORACLE_BASE}/local/dba/bin/oraenv.ksh rdbms18000
nohup /opt/oradba/bin/52_create_database.sh TDB184A > /tmp/TDB184A.log 2>&1 &
```

### Setup TDB122A

```bash
export ORACLE_SID2=${ORACLE_SID2:-"TDB122A"}
export ORADBA_TEMPLATE_PREFIX=${ORADBA_TEMPLATE_PREFIX:-"custom_"}
. ${ORACLE_BASE}/local/dba/bin/oraenv.ksh rdbms18000
nohup /opt/oradba/bin/52_create_database.sh TDB122A > /tmp/TDB122A.log 2>&1 &
```

# Setup Oracle Unified Directory Server

Setup des Oracle OUD Servers erfolgt basierend auf einem initialen Oracle Linux setup. Im Anschluss an das Setup erfolgt die Konfiguration mithilfe der [oehrlis/oradba_init](https://github.com/oehrlis/oradba_init) scripts.
ssh public key für Root kopieren

## Basis Konfiguration

Setup root Zugriff via SSH. Kopieren des localen Public Key's

```bash
ssh-copy-id root@130.61.13.230
```

Anpassung des *root* Passwortes.

```bash
passwd
```

Installation der [oehrlis/oradba_init](https://github.com/oehrlis/oradba_init) Scripte.

```bash
GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin"
mkdir -p /tmp/download

# get the latest install script for OraDBA init from GitHub repository
curl -Lsf ${GITHUB_URL}/00_setup_oradba_init.sh -o /tmp/download/00_setup_oradba_init.sh

# install the OraDBA init scripts
chmod 755 /tmp/download/00_setup_oradba_init.sh
/tmp/download/00_setup_oradba_init.sh
```

Software in das Stage Verzeichnis kopieren. Von einem lokalen Stage Verzeichnis oder via ``curl`` direkt von OTN / MOS.

```bash
scp *.zip root@130.61.65.229:/opt/stage/

ssh root@130.61.65.229

echo "machine login.oracle.com login cpureport@trivadis.com password tr1vad1$" >/opt/stage/.netrc



nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28414856_180192_Linux-x86-64.zip?aru=22500985&patch_file=p28414856_180192_Linux-x86-64.zip" -o p28414856_180192_Linux-x86-64.zip >p28414856_180192_Linux-x86-64.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p26270957_122130_Generic.zip?aru=21504981&patch_file=p26270957_122130_Generic.zip" -o p26270957_122130_Generic.zip >p26270957_122130_Generic.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28569189_122130_Generic.zip?aru=22414848&patch_file=p28569189_122130_Generic.zip" -o p28569189_122130_Generic.zip >p28569189_122130_Generic.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28298734_122130_Generic.zip?aru=22379215&patch_file=p28298734_122130_Generic.zip" -o p28298734_122130_Generic.zip >p28298734_122130_Generic.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p26269885_122130_Generic.zip?aru=21502041&patch_file=p26269885_122130_Generic.zip" -o p26269885_122130_Generic.zip >p26269885_122130_Generic.log 2>&1 &
nohup curl --netrc-file /opt/stage/.netrc --cookie-jar cookie-jar.txt --location-trusted "https://updates.oracle.com/Orion/Services/download/p28186730_139400_Generic.zip?aru=22310944&patch_file=p28186730_139400_Generic.zip" -o p28186730_139400_Generic.zip >p28186730_139400_Generic.log 2>&1 &

rm -rf /opt/stage/.netrc /opt/stage/*.log
```

Oracle Benutzer anlegen und benötigte YUM Packages installieren.

```bash
/opt/oradba/bin/01_setup_os_oud.sh
```

Konfiguration von sudo für Oracle 

```bash
echo "## Allow sudo for user oracle" > /etc/sudoers.d/oracle
echo "oracle    ALL=(ALL)   NOPASSWD:   ALL" >> /etc/sudoers.d/oracle
```

Anpassung des *oracle* Passwortes.

```bash
ssh root@130.61.65.191
passwd oracle
```

Setup oracle Zugriff via SSH. Kopieren des localen Public Key's

```bash
ssh-copy-id oracle@130.61.65.191
```

DOAG 2018 Training Key erstellen, kopieren oder verteilen.

```bash
ssh-keygen -C "DOAG 2018 Training" -b 4096
sudo cp /home/oracle/.ssh/id_rsa.pub /root/.ssh
sudo cp /home/oracle/.ssh/id_rsa /root/.ssh

vi /root/.ssh/id_rsa.pub
vi /root/.ssh/id_rsa

cp /root/.ssh/id_rsa.pub /home/oracle/.ssh/id_rsa.pub
cp /root/.ssh/id_rsa /home/oracle/.ssh/id_rsa
```

Install git tools

```bash
yum -y install git
```

Disable root login via SSH

```bash
vi /etc/ssh/sshd_config
```

Configure Firewall Ports

```bash
firewall-cmd --list-ports
iptables -L -n 
firewall-cmd --zone=public --add-port=7001/tcp
firewall-cmd --zone=public --add-port=7002/tcp
firewall-cmd --zone=public --add-port=1389/tcp
firewall-cmd --zone=public --add-port=1636/tcp
firewall-cmd --zone=public --add-port=4444/tcp
firewall-cmd --list-ports
iptables -L -n 
```

Installation von fail2ban gemäss Blog Post Martin Berger.

## Installation Oracle Binaries

Installation von Oracle Java 1.8 (update 192)

```bash
su -l oracle -c "/opt/oradba/bin/01_setup_os_java.sh"
```

Installation von Oracle Unified Directory 12c (12.2.1.3.0)

```bash
su -l oracle -c "/opt/oradba/bin/10_setup_oud_12c.sh"
```

Installation von Oracle Unified Directory Services Manager 12c (12.2.1.3.0)

```bash
su -l oracle -c "/opt/oradba/bin/10_setup_oudsm_12c.sh"
```