#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: setup_oud_part2.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to initialize and install Vagrant box db.trivadislabs.com.
# Notes......: ...
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
# - just add/update any kind of customized environment variable here
export ORACLE_ROOT=${ORACLE_ROOT:-"/u00"}   # root folder for ORACLE_BASE and binaries
export ORACLE_DATA=${ORACLE_DATA:-"/u01"}   # Oracle data folder eg volume for docker
export ORACLE_ARCH=${ORACLE_ARCH:-"/u02"}   # Oracle arch folder eg volume for docker
export DEFAULT_DOMAIN=${DEFAULT_DOMAIN:-"trivadislabs.com"} 
export ORACLE_BASE=${ORACLE_BASE:-${ORACLE_ROOT}/app/oracle}
export ORACLE_INVENTORY=${ORACLE_INVENTORY:-${ORACLE_ROOT}/app/oraInventory}
export PORT=${PORT:-1521}
export PORT_CONSOLE=${PORT_CONSOLE:-5500}
export ORACLE_SID1=${ORACLE_SID1:-"TDB184A"}
export ORACLE_SID2=${ORACLE_SID2:-"TDB122A"}
export ORADBA_TEMPLATE_PREFIX=${ORADBA_TEMPLATE_PREFIX:-"custom_"}
# - End of Customization ----------------------------------------------------
# - Environment Variables ---------------------------------------------------
export ORADBA_BIN="/opt/oradba/bin"
export VAGRANT_BIN="/vagrant/bin"
export VAGRANT_ETC="/vagrant/etc"
# define variables for OS setup
DOWNLOAD="/tmp/download"
SETUP_DB_184="10_setup_db_18.4.sh"
SETUP_DB_122="10_setup_db_12.2.sh"
SETUP_BASENV="20_setup_basenv.sh"
ORAENV="${ORACLE_BASE}/local/dba/bin/oraenv.ksh"
CREATE_DB="52_create_database.sh"
# Demo Schema
TVD_HR="@/vagrant/conf/db/setup/02_create_tvd_hr.sql"
# - EOF Environment Variables -----------------------------------------------
# - Functions ---------------------------------------------------------------
# - EOF Functions -----------------------------------------------------------

# - Main --------------------------------------------------------------------
echo "--- Start DB setup part 2 ---------------------------------------------"
echo "--- Install Oracle 18.4.0.0 -------------------------------------------"
# Install DB Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_DB_184}"

# root scripts
/u00/app/oraInventory/orainstRoot.sh
${ORACLE_BASE}/product/18.4.0.0/root.sh

echo "--- Install Oracle 12.2.0.1 -------------------------------------------"
# Install DB Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_DB_122}"

# root scripts
${ORACLE_BASE}/product/12.2.0.1/root.sh

echo "--- Install TVD-Basenv ------------------------------------------------"
# Install TVD-Basenv
su -l oracle -c "${ORADBA_BIN}/${SETUP_BASENV}"

# copy network files
for i in sqlnet.ora ldap.ora tnsnames.ora dsi.ora krb5.conf; do
    if [ -f "${VAGRANT_ETC}/$i" ]; then
        su -l oracle -c "cp -v ${VAGRANT_ETC}/$i ${ORACLE_BASE}/network/admin"
    fi
done

echo "--- Create DB TDB184A (18.4.0.0) --------------------------------------"
# Create DB 18.4.0.0
su -l oracle -c " . ${ORAENV} rdbms18000; ${ORADBA_BIN}/${CREATE_DB} ${ORACLE_SID1} ${ORACLE_PDB} ${CONTAINER}"

# install the TVD_HR schema
su -l oracle -c " . ${ORAENV} ${ORACLE_SID1}; sqlplus \"/ as sysdba\" $TVD_HR"

echo "--- Create DB TDB224A (12.2.0.1) --------------------------------------"
# Create DB 12.2.0.1
su -l oracle -c " . ${ORAENV} rdbms12201; ${ORADBA_BIN}/${CREATE_DB} ${ORACLE_SID2} ${ORACLE_PDB} ${CONTAINER}"

# install the TVD_HR schema
su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; sqlplus \"/ as sysdba\" $TVD_HR"

echo "--- Configure Oracle Service ------------------------------------------"
cp ${ORACLE_BASE}/local/dba/etc/oracle.service /usr/lib/systemd/system/
systemctl --system daemon-reload
systemctl enable oracle

# change all DB to autostart in oratab
sed -i "s/N$/Y/" /etc/oratab

# get the git stuff
echo "--- Get git stuff -----------------------------------------------------"
su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/doag2018 doag2018"
su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/trivadislabs.com trivadislabs.com"
su -l oracle -c "echo \"alias git_lab='cd $cdl/trivadislabs.com;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/basenv.conf"
su -l oracle -c "echo \"alias git_doag='cd $cdl/doag2018;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/basenv.conf"

echo "--- Finished OUD setup part 2 -----------------------------------------"
echo "--- Finished setup VM $(hostname) -----------------------------"
# --- EOF --------------------------------------------------------------------