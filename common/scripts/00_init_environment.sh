#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 00_init_environment.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to initialize environment and set default values.
# Notes......: Has to be source in the vagrant provisioning bash scripts to load
#              environment and default values based on vagrant.yml 
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
# - just add/update any kind of customized environment variable here
# export ORACLE_ROOT="/u00"   # root folder for ORACLE_BASE and binaries
# export ORACLE_DATA="/u01"   # Oracle data folder eg volume for docker
# export ORACLE_ARCH="/u02"   # Oracle arch folder eg volume for docker
# export ORACLE_BASE="${ORACLE_ROOT}/app/oracle"
# export ORACLE_INVENTORY="${ORACLE_ROOT}/app/oraInventory"
# - End of Customization ----------------------------------------------------

# - Environment Variables ---------------------------------------------------
# define default values 
export VAGRANT_CONF="/vagrant_common/config/vagrant.yml" # Vagrant config YAML file
export ORACLE_ROOT=${ORACLE_ROOT:-"/u00"}   # root folder for ORACLE_BASE and binaries
export ORACLE_DATA=${ORACLE_DATA:-"/u01"}   # Oracle data folder eg volume for docker
export ORACLE_ARCH=${ORACLE_ARCH:-"/u02"}   # Oracle arch folder eg volume for docker
export ORACLE_BASE=${ORACLE_BASE:-${ORACLE_ROOT}/app/oracle}
export ORACLE_INVENTORY=${ORACLE_INVENTORY:-${ORACLE_ROOT}/app/oraInventory}
export PORT=${PORT:-1521}
export PORT_CONSOLE=${PORT_CONSOLE:-5500}
export ORADBA_TEMPLATE_PREFIX=${ORADBA_TEMPLATE_PREFIX:-"custom_"}

# vagrant default folders
export VAGRANT_COMMON_BIN="/vagrant_common/scripts"
export VAGRANT_COMMON_ETC="/vagrant_common/config"
export VAGRANT_BIN="/vagrant/scripts"
export VAGRANT_ETC="/vagrant/config"

# define the oradba url and package name
export GITHUB_URL="https://raw.githubusercontent.com/oehrlis/oradba_init/master"
export ORADBA_PKG="oradba_init.zip"

# define the defaults for software, download etc
export OPT_DIR=${OPT_DIR:-"/opt"}
export ORADBA_BIN=${ORADBA_BIN:-"${OPT_DIR}/oradba/bin"}
export SOFTWARE=${SOFTWARE:-"${OPT_DIR}/stage"} # local software stage folder
export SOFTWARE_REPO=${SOFTWARE_REPO:-""}       # URL to software for curl fallback
export DOWNLOAD=${DOWNLOAD:-"/tmp/download"}    # temporary download location
export CLEANUP=${CLEANUP:-true}                 # Flag to set yum clean up
# - EOF Environment Variables -----------------------------------------------

# - Functions ---------------------------------------------------------------
function parse_yaml {
# Purpose....: parse a simpl YAML file
# -----------------------------------------------------------------------
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}
# - EOF Functions -----------------------------------------------------------

# check if script is sourced and return/exit
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    echo " Script ${BASH_SOURCE[0]} is sourced from ${0}"

    # load common values from vagrant YAML file
    echo " - Load common variables from vagrant YAML file -----------------------"
    for i in $(parse_yaml ${VAGRANT_CONF}|grep -i common); do
        j=${i##common_}
        VARIABLE=$(echo $j|cut -d= -f1)
        VALUE=$(echo $j|cut -d= -f2|sed 's/"//g')
        eval ${VARIABLE}=$VALUE
    done
    # load host values from vagrant YAML file
    echo " - Load host $HOSTNAME variables from vagrant YAML file ---------------"
    for i in $(parse_yaml ${VAGRANT_CONF}|grep -i $HOSTNAME); do
        j=${i##${HOSTNAME}_}
        VARIABLE=$(echo $j|cut -d= -f1)
        VALUE=$(echo $j|cut -d= -f2|sed 's/"//g')
        eval export ${VARIABLE}=$VALUE
    done
else
    echo "Script ${BASH_SOURCE[0]} is executed. No action is performed"
fi
# --- EOF --------------------------------------------------------------------