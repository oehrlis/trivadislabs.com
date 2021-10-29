#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 12_install_oud_binaries.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to install OUD binaries in Vagrant box oud.trivadislabs.com.
# Notes......: ...
# Reference..: --
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
# - just add/update any kind of customized environment variable here
# define variables for OS setup
SETUP_JAVA="01_setup_os_java.sh"
SETUP_OUD="10_setup_oud.sh"
SETUP_OUDSM="10_setup_oudsm_12c.sh"
SETUP_OUDBASE="20_setup_oudbase.sh"
OUD_VERSION="12"
OUD_TYPE="OUDSM12" 

# - End of Customization ----------------------------------------------------
# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
export DEFAULT_DOMAIN=${domain_name:-"trivadislabs.com"} 
# set the software packages for OUD and OUDSM
export JAVA_PKG=${JAVA_PKG:-"p30425892_180241_Linux-x86-64.zip"}
export OUD_BASE_PKG=${OUD_BASE_PKG:-"p30188352_122140_Generic.zip"}
export FMW_BASE_PKG=${FMW_BASE_PKG:-"fmw_12.2.1.4.0_infrastructure_Disk1_1of1.zip"}
export OUD_PATCH_PKG=${OUD_PATCH_PKG:-""}
export FMW_PATCH_PKG=${FMW_PATCH_PKG:-"p30689820_122140_Generic.zip"}
export OUD_OPATCH_PKG=${OUD_OPATCH_PKG:-""}
export OUI_PATCH_PKG=${OUI_PATCH_PKG:-""}
export OUD_ORACLE_HOME_NAME=${OUD_ORACLE_HOME_NAME:-"oud12.2.1.4.0"}
export OUDSM_ORACLE_HOME_NAME=${OUDSM_ORACLE_HOME_NAME:-"fmw12.2.1.4.0"}

# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 10 ======================================================="
echo "- Setup Java -----------------------------------------------------------"
# Setup Java
su -l oracle -c "JAVA_PKG=${JAVA_PKG} ${ORADBA_BIN}/${SETUP_JAVA}"

echo "- Config Java ----------------------------------------------------------"
JAVA_DIR=$(ls -1 -d ${ORACLE_BASE}/product/jdk*|tail -1)
su -l oracle -c "cp /vagrant/config/java.security ${JAVA_DIR}/jre/lib/security/java.security"

echo "- Setup OUD -----------------------------------------------------------"
# Install OUD Software
su -l oracle -c "ORACLE_HOME_NAME=${OUD_ORACLE_HOME_NAME} \
OUD_TYPE=OUD12 \
OUD_BASE_PKG=${OUD_BASE_PKG}  \
OUD_PATCH_PKG=${OUD_PATCH_PKG}  \
OUD_OPATCH_PKG=${OUD_OPATCH_PKG}  \
OUI_PATCH_PKG=${OUI_PATCH_PKG} \
${ORADBA_BIN}/${SETUP_OUD}"

echo "- Setup OUDSM ---------------------------------------------------------"
# Install OUDSM Software
su -l oracle -c "ORACLE_HOME_NAME=${OUDSM_ORACLE_HOME_NAME} \
OUD_TYPE=OUDSM12 \
OUD_BASE_PKG=${OUD_BASE_PKG} \
FMW_BASE_PKG=${FMW_BASE_PKG} \
OUD_PATCH_PKG=${OUD_PATCH_PKG} \
FMW_PATCH_PKG=${FMW_PATCH_PKG} \
OUD_OPATCH_PKG=${OUD_OPATCH_PKG} \
OUI_PATCH_PKG=${OUI_PATCH_PKG} \
${ORADBA_BIN}/${SETUP_OUD}"

echo "- OUD Base ------------------------------------------------------------"
# Install OUD Base
su -l oracle -c "${ORADBA_BIN}/${SETUP_OUDBASE}"

echo "oud_eus:1389:1636:4444:8989:OUD:Y" >> ${ORACLE_DATA}/etc/oudtab
echo "oudsm_domain:7001:7002:::OUDSM:Y" >> ${ORACLE_DATA}/etc/oudtab

# get the git stuff
# echo "--- Get git stuff -----------------------------------------------------"
su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/doag2018 doag2018"
su -l oracle -c "cd ${ORACLE_BASE}/local;git clone https://github.com/oehrlis/trivadislabs.com trivadislabs.com"
su -l oracle -c "echo \"alias git_lab='cd $cdl/trivadislabs.com;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/oudenv_custom.conf"
su -l oracle -c "echo \"alias git_doag='cd $cdl/doag2018;git pull; cd -'\" >>${ORACLE_BASE}/local/oudbase/etc/oudenv_custom.conf"

echo "= Finish part 10 ======================================================"
# --- EOF --------------------------------------------------------------------