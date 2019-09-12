#!/bin/bash
# -----------------------------------------------------------------------
# Trivadis AG, Business Development & Support (BDS)
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# -----------------------------------------------------------------------
# Name.......: 01_add_pdb_os_user.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.08.22
# Usage......: 01_add_pdb_os_user
# Purpose....: Script to add a PDB OS user.
# Notes......: has to be execuded as user root
# Reference..: 
# License...: Licensed under the Universal Permissive License v 1.0 as 
#             shown at http://oss.oracle.com/licenses/upl.
# -----------------------------------------------------------------------
# Modified...:
# see git revision history with git log for more information on changes
# -----------------------------------------------------------------------

# - Customization -------------------------------------------------------
PDB_OS_USERS="orapdb orapdbsec orapdb1 orapdb2 orapdb3"
PDB_OS_USER=orapdb
PDB_OS_PASSWD=LAB01schulung
PDB_OS_GRP=restricted
# - End of Customization ------------------------------------------------

# Make sure only root can run our script
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# if neccessary install the password utility
if [ -n "$(command -v passwd)" ]; then 
    echo "Found passwd utility"
else 
    echo "Install passwd and set password for ${PDB_OS_USER}:"
    yum install -y passwd
    yum clean all
    rm -rf /var/cache/yum
fi

# create OS group

if [ $(getent group ${PDB_OS_GRP}) ]; then
    echo "Skip, group ${PDB_OS_USER} exists."
else
    echo "Add PDB OS group ${PDB_OS_GRP}:"
    groupadd ${PDB_OS_GRP}
fi
 
# create a bunch of OS user
for i in ${PDB_OS_USERS}; do
    PDB_OS_USER=${i}

    if [ $(getent passwd ${PDB_OS_USER}) ]; then
        echo "Skip, user ${PDB_OS_USER} exists."
    else
        echo "Add PDB OS user ${PDB_OS_USER}:"
        useradd --create-home --gid ${PDB_OS_GRP} --shell /bin/bash ${PDB_OS_USER}
    fi
    # set 
    echo "${PDB_OS_PASSWD}" | passwd ${PDB_OS_USER} --stdin 
done
# --- EOF --------------------------------------------------------------------