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
export ORACLE_SID1=${ORACLE_SID1:-"TDB185A"}
export ORACLE_SID2=${ORACLE_SID2:-"TDB122A"}
export ORADBA_TEMPLATE_PREFIX=${ORADBA_TEMPLATE_PREFIX:-"custom_"}

# - End of Customization ----------------------------------------------------
# - Environment Variables ---------------------------------------------------
export ORADBA_BIN="/opt/oradba/bin"
# define variables for OS setup
SETUP_JAVA="01_setup_os_java.sh"
SETUP_OUD="10_setup_oud_12c.sh"
SETUP_OUDSM="10_setup_oudsm_12c.sh"
SETUP_OUDBASE="20_setup_oudbase.sh"

# - EOF Environment Variables -----------------------------------------------
# - Functions ---------------------------------------------------------------
# - EOF Functions -----------------------------------------------------------

# - Main --------------------------------------------------------------------
echo "--- Start OUD setup part 2 ---------------------------------------------"
echo "--- Setup Java ---------------------------------------------------------"
# Setup Java
su -l oracle -c "${ORADBA_BIN}/${SETUP_JAVA}"

echo "--- Setup OUD ----------------------------------------------------------"
# Install OUD Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUD}"

echo "--- Setup OUDSM --------------------------------------------------------"
# Install OUDSM Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUDSM}"

echo "--- OUD Base ----------------------------------------------------------"
# Install OUD Base
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUDBASE}"

# get the git stuff
echo "--- Get git stuff -----------------------------------------------------"
su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/doag2018 doag2018"
su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/trivadislabs.com trivadislabs.com"
su -l oracle -c "echo \"alias git_lab='cd $cdl/trivadislabs.com;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/oudenv_custom.conf"
su -l oracle -c "echo \"alias git_doag='cd $cdl/doag2018;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/oudenv_custom.conf"

echo "--- Finished OUD setup part 2 -----------------------------------------"
echo "--- Finished setup VM $(hostname) ----------------------------"
# --- EOF --------------------------------------------------------------------