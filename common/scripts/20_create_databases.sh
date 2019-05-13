#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 20_create_databases.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Wrapper script to create databases.
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
CREATE_DB="52_create_database.sh"
ORAENV="${ORACLE_BASE}/local/dba/bin/oraenv.ksh"
TVD_HR_CONTAINER="/vagrant_common/scripts/80_create_tvd_hr_pdb1.sql"
TVD_HR="/vagrant_common/scripts/81_create_tvd_hr.sql"
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
export DEFAULT_DOMAIN=${domain_name:-"trivadislabs.com"}
export ORACLE_SID1=${oracle_sid_cdb} 
export ORACLE_SID2=${oracle_sid_sdb}
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 20 ======================================================="

if [ -n "${ORACLE_SID1}" ]; then
    echo "- Create DB CDB ${ORACLE_SID1} ----------------------------------------"
    # Create DB container DB
    su -l oracle -c "${ORADBA_BIN}/${CREATE_DB} ${ORACLE_SID1} PDB1 TRUE"

    # install the TVD_HR schema
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; ${ORACLE_SID1}; sqlplus \"/ as sysdba\" $TVD_HR_CONTAINER"
fi

if [ -n "${ORACLE_SID2}" ]; then
    echo "- Create DB 2DB ${ORACLE_SID2} ----------------------------------------"
    # Create DB single tenant DB
    su -l oracle -c "${ORADBA_BIN}/${CREATE_DB} ${ORACLE_SID2} PDB1 FALSE"

    # install the TVD_HR schema
    su -l oracle -c " . ${ORAENV} ${ORACLE_SID2}; sqlplus \"/ as sysdba\" $TVD_HR"
fi
echo "--- Configure Oracle Service ------------------------------------------"
cp ${ORACLE_BASE}/local/dba/etc/oracle.service /usr/lib/systemd/system/
systemctl --system daemon-reload
systemctl enable oracle

# change all DB to autostart in oratab
sed -i "s/N$/Y/" /etc/oratab

echo "= Finish part 20 ======================================================"
# --- EOF --------------------------------------------------------------------