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
# Purpose....: Script to install DB binaries in Vagrant box db.trivadislabs.com.
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
export ORACLE_HOME_NAME="18.0.0.0"
SETUP_DB="10_setup_db_18.6.sh"
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 10 ======================================================="
echo "- Install Oracle Binaries -------------------------------------------"
# Install DB Software
su -l oracle -c "export ORACLE_HOME_NAME=${ORACLE_HOME_NAME}; \
${ORADBA_BIN}/${SETUP_DB}"

# root scripts
/u00/app/oraInventory/orainstRoot.sh
${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/root.sh
echo "= Finish part 10 ======================================================"
# --- EOF --------------------------------------------------------------------