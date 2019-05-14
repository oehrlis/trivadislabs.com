#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 10_install_binaries.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to install OUD binaries in Vagrant box oud.trivadislabs.com.
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
# define variables for OS setup
SETUP_JAVA="01_setup_os_java.sh"
SETUP_OUD="10_setup_oud_12c.sh"
SETUP_OUDSM="10_setup_oudsm_12c.sh"
SETUP_OUDBASE="20_setup_oudbase.sh"
JAVA_PKG="p29565620_180212_Linux-x86-64.zip"
# - End of Customization ----------------------------------------------------
# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
export DEFAULT_DOMAIN=${domain_name:-"trivadislabs.com"} 
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 10 ======================================================="
echo "- Setup Java -----------------------------------------------------------"
# Setup Java
su -l oracle -c "export JAVA_PKG=${JAVA_PKG}; ${ORADBA_BIN}/${SETUP_JAVA}"

echo "- Setup OUD -----------------------------------------------------------"
# Install OUD Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUD}"

echo "- Setup OUDSM ---------------------------------------------------------"
# Install OUDSM Software
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUDSM}"

echo "- OUD Base ------------------------------------------------------------"
# Install OUD Base
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUDBASE}"

# get the git stuff
# echo "--- Get git stuff -----------------------------------------------------"
# su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/doag2018 doag2018"
# su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/trivadislabs.com trivadislabs.com"
# su -l oracle -c "echo \"alias git_lab='cd $cdl/trivadislabs.com;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/oudenv_custom.conf"
# su -l oracle -c "echo \"alias git_doag='cd $cdl/doag2018;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/oudenv_custom.conf"

echo "= Finish part 10 ======================================================"
# --- EOF --------------------------------------------------------------------