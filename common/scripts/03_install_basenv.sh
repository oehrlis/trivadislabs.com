#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 03_install_basenv.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to install DB binaries in Vagrant box db.trivadislabs.com.
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
SETUP_BASENV="20_setup_basenv.sh"
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
export DEFAULT_DOMAIN=${domain_name:-"trivadislabs.com"} 
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 11 ======================================================="
echo "- Install TVD-Basenv --------------------------------------------------"
# Install TVD-Basenv
su -l oracle -c "export DEFAULT_DOMAIN=${DEFAULT_DOMAIN}; \
${ORADBA_BIN}/${SETUP_BASENV}"
echo "= Finish part 11 ======================================================"
# --- EOF --------------------------------------------------------------------