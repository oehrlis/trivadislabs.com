#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 14_create_oud_instance.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Wrapper script to create oud instance.
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
CREATE_DB="52_create_database.sh"
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
export DEFAULT_DOMAIN=${domain_name:-"trivadislabs.com"}
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 20 ======================================================="

if [ -n "${ORACLE_SID1}" ]; then
    echo "- Create DB CDB ${ORACLE_SID1} ----------------------------------------"
    # Create DB container DB
    su -l oracle -c "${ORADBA_BIN}/${CREATE_DB} ${ORACLE_SID1} PDB1 TRUE"

    # install the TVD_HR schema
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; sqlplus /nolog @$TVD_HR_CONTAINER"
fi

if [ -n "${ORACLE_SID2}" ]; then
    echo "- Create DB 2DB ${ORACLE_SID2} ----------------------------------------"
    # Create DB single tenant DB
    su -l oracle -c "${ORADBA_BIN}/${CREATE_DB} ${ORACLE_SID2} PDB1 FALSE"

    # install the TVD_HR schema
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; sqlplus /nolog @$TVD_HR"
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; sqlplus / as sysdba @?/rdbms/admin/utlsampl.sql"
fi
echo "--- Configure Oracle Service ------------------------------------------"
cp ${ORACLE_BASE}/local/dba/etc/oracle.service /usr/lib/systemd/system/
systemctl --system daemon-reload
systemctl enable oracle

# change all DB to autostart in oratab
sed -i "s/N$/Y/" /etc/oratab

echo "= Finish part 20 ======================================================"
# --- EOF --------------------------------------------------------------------