#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 05_create_databases.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Wrapper script to create databases.
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
TVD_HR_CONTAINER="/vagrant_common/scripts/80_create_tvd_hr_pdbhr.sql"
TVD_HR="/vagrant_common/scripts/81_create_tvd_hr.sql"
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
export DEFAULT_DOMAIN=${domain_name:-"trivadislabs.com"}
export ORACLE_SID1=${oracle_sid_cdb} 
export ORACLE_SID2=${oracle_sid_sdb}
export ORACLE_PDB=${ORACLE_PDB:-"PDBHR"}
ORAENV="${ORACLE_BASE}/local/dba/bin/oraenv.ksh"

# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 20 ======================================================="
if [ -n "${ORACLE_SID2}" ]; then
    echo "- Create DB SDB ${ORACLE_SID2} ----------------------------------------"
    # Create DB single tenant DB
    su -l oracle -c "ORACLE_SID=${ORACLE_SID2} \
CUSTOM_RSP=${CUSTOM_RSP} \
ORADBA_DBC_FILE=${ORADBA_DBC_FILE} \
ORADBA_RSP_FILE=${ORADBA_RSP_FILE} \
CONTAINER=FALSE \
${ORADBA_BIN}/${CREATE_DB}"
  
    # install the TVD_HR schema
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; sqlplus /nolog @$TVD_HR"
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; sqlplus / as sysdba @?/rdbms/admin/utlsampl.sql"
fi

if [ -n "${ORACLE_SID1}" ]; then
    echo "- Create DB CDB ${ORACLE_SID1} ----------------------------------------"
    # Create DB container DB
    su -l oracle -c "ORACLE_SID=${ORACLE_SID1} \
CUSTOM_RSP=${CUSTOM_RSP} \
ORADBA_DBC_FILE=${ORADBA_DBC_FILE} \
ORADBA_RSP_FILE=${ORADBA_RSP_FILE} \
ORACLE_PDB=${ORACLE_PDB} \
CONTAINER=TRUE \
${ORADBA_BIN}/${CREATE_DB}"

    # install the TVD_HR schema
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID1}; sqlplus /nolog @$TVD_HR_CONTAINER"
fi

echo "--- Configure Oracle Service ------------------------------------------"
cp ${ORACLE_BASE}/local/dba/etc/oracle.service /usr/lib/systemd/system/
systemctl --system daemon-reload
systemctl enable oracle

# change all DB to autostart in oratab
sed -i "s/N$/Y/" /etc/oratab

echo "= Finish part 20 ======================================================"
# --- EOF --------------------------------------------------------------------