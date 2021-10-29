#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 04_config_tnsadmin.sh 
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
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# source values from vagrant YAML file
. /vagrant_common/scripts/00_init_environment.sh
export DEFAULT_DOMAIN=${domain_name:-"trivadislabs.com"}
export ORACLE_SID1=${oracle_sid_cdb:-"TDB180C"} 
export ORACLE_SID2=${oracle_sid_sdb:-"TDB180S"}
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 12 ======================================================="
echo "- Configure TNSADMIN  -------------------------------------------------"

# copy network files
KeytabFile="$(hostname).${DEFAULT_DOMAIN}.keytab"
RootCAFile="RootCA_${DEFAULT_DOMAIN}.cer"
echo "- Copy templates ------------------------------------------------------"
for i in sqlnet.ora ldap.ora tnsnames.ora dsi.ora krb5.conf ${RootCAFile} ${KeytabFile}; do
    if [ -f "${VAGRANT_COMMON_ETC}/tnsadmin/$i" ]; then
        su oracle -c "cp -v ${VAGRANT_COMMON_ETC}/tnsadmin/$i ${ORACLE_BASE}/network/admin"
    fi
done

echo "- Update config files -------------------------------------------------"
DC1=$(echo ${DEFAULT_DOMAIN}|cut -d. -f2)
DC2=$(echo ${DEFAULT_DOMAIN}|cut -d. -f1)
REALM=${DEFAULT_DOMAIN^^}
sed -i "s|^NAMES.DEFAULT_DOMAIN.*|NAMES.DEFAULT_DOMAIN=${DEFAULT_DOMAIN}|" ${ORACLE_BASE}/network/admin/sqlnet.ora
sed -i "s|^SQLNET.KERBEROS5_KEYTAB.*|SQLNET.KERBEROS5_KEYTAB = /u00/app/oracle/network/admin/${KeytabFile}|" ${ORACLE_BASE}/network/admin/sqlnet.ora
sed -i "s|^DIRECTORY_SERVERS.*|DIRECTORY_SERVERS = (oud.${DEFAULT_DOMAIN}:1389:1636)|" ${ORACLE_BASE}/network/admin/ldap.ora
sed -i "s|^DEFAULT_ADMIN_CONTEXT.*|DEFAULT_ADMIN_CONTEXT = dc=${DC2},dc=${DC1}|" ${ORACLE_BASE}/network/admin/ldap.ora
sed -i "s|^DSI_DIRECTORY_SERVERS.*|DSI_DIRECTORY_SERVERS = (ad.${DEFAULT_DOMAIN}:389:636)|" ${ORACLE_BASE}/network/admin/ldap.ora
sed -i "s|^DSI_DEFAULT_ADMIN_CONTEXT.*|DSI_DEFAULT_ADMIN_CONTEXT = dc=${DC2},dc=${DC1}|" ${ORACLE_BASE}/network/admin/ldap.ora
sed -i "s|trivadislabs.com|${DEFAULT_DOMAIN}|g" ${ORACLE_BASE}/network/admin/krb5.conf
sed -i "s|TRIVADISLABS.COM|${REALM}|g" ${ORACLE_BASE}/network/admin/krb5.conf
sed -i "s|trivadislabs.com|${DEFAULT_DOMAIN}|g" ${ORACLE_BASE}/network/admin/tnsnames.ora
sed -i "s|TDB185A|${ORACLE_SID1}|g" ${ORACLE_BASE}/network/admin/tnsnames.ora
sed -i "s|TDB122A|${ORACLE_SID2}|g" ${ORACLE_BASE}/network/admin/tnsnames.ora

echo "= Finish part 12 ======================================================"
# --- EOF --------------------------------------------------------------------