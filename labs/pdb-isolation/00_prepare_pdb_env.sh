#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 00_prepare_pdb_env.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to add a tnsname entry for the PDB PDBSEC.
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
PDB_NAME="pdbsec"
PDB_TNSNAME="${PDB_NAME}.$(hostname -d)"
ORACLE_BASE=${ORACLE_BASE:-"/u00/app/oracle"}
TNS_ADMIN=${TNS_ADMIN:-"${ORACLE_BASE}/network/admin"}
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
#. /vagrant_common/scripts/00_init_environment.sh
#export DEFAULT_PASSWORD=${default_password:-"LAB01schulung"}
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Prepare PDB Environment ============================================="

# add the tnsnames entry
if [ $( grep -ic $PDB_TNSNAME ${TNS_ADMIN}/tnsnames.ora) -eq 0 ]; then
    echo "Add $PDB_TNSNAME to ${TNS_ADMIN}/tnsnames.ora."
    echo "${PDB_TNSNAME}=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$(hostname))(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=${PDB_NAME})))">>${TNS_ADMIN}/tnsnames.ora
else
    echo "TNS name entry ${PDB_TNSNAME} does exists."
fi

echo "create PATH_PREFIX folder /u01/oradata/PDBSEC"
mkdir -p /u01/oradata/PDBSEC
echo "= Finish PDB Environment =============================================="
# --- EOF --------------------------------------------------------------------