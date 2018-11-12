#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: install_oud.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to initialize and install Vagrant box oud.trivadislabs.com.
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
export OPT_DIR="/opt"
export ORADBA_BIN="/opt/oradba/bin"
# define variables for OS setup
DOWNLOAD="/tmp/download"
GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin"
SETUP_INIT="00_setup_oradba_init.sh"
SETUP_OS="01_setup_os_oud.sh"
SETUP_JAVA="01_setup_os_java.sh"
SETUP_OUD="10_setup_oud_12c.sh"
SETUP_OUDSM="10_setup_oudsm_12c.sh"
SETUP_OUDBASE="20_setup_oudbase.sh"

# - EOF Environment Variables -----------------------------------------------
# - Functions ---------------------------------------------------------------
# - EOF Functions -----------------------------------------------------------

# - Main --------------------------------------------------------------------
echo "--- Prepare OraDBA init setup -----------------------------------------"
# prepare a download directory
mkdir -p ${DOWNLOAD}

# get the latest install script for OraDBA init from GitHub repository
curl -Lsf ${GITHUB_URL}/${SETUP_INIT} -o ${DOWNLOAD}/${SETUP_INIT}

# install the OraDBA init scripts
chmod 755 ${DOWNLOAD}/${SETUP_INIT}
${DOWNLOAD}/${SETUP_INIT}

# link stage to vagrant stage folder
rm -rf /opt/stage
ln -s /vagrant/stage /opt/stage
cd ${DOWNLOAD}

echo "--- Setup OS ----------------------------------------------------------"
# Setup OS
${ORADBA_BIN}/${SETUP_OS}

echo "--- Configure OS ------------------------------------------------------"
# add Oracle to vagrant group to allow sudo
usermod -a -G vagrant oracle

echo "--- Setup Java --------------------------------------------------------"
# Setup Java
su -l oracle -c "${ORADBA_BIN}/${SETUP_JAVA}"

echo "--- Setup OUD ---------------------------------------------------------"
# Install OUD Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUD}"

echo "--- Setup OUDSM -------------------------------------------------------"
# Install OUDSM Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUDSM}"

echo "--- OUD Base ---------------------------------------------------------"
# Install OUD Base
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUDBASE}"
# --- EOF --------------------------------------------------------------------