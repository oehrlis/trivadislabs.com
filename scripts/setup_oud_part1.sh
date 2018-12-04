#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: setup_oud_part1.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to initialize and install Vagrant box oud.trivadislabs.com.
# Notes......: ...
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Customization -----------------------------------------------------------
export AD_IP_ADDRESS=${AD_IP_ADDRESS:-"10.0.0.4"} 
# - End of Customization ----------------------------------------------------
# - Environment Variables ---------------------------------------------------
export OPT_DIR="/opt"
export ORADBA_BIN="/opt/oradba/bin"
# define variables for OS setup
DOWNLOAD="/tmp/download"
GITHUB_URL="https://github.com/oehrlis/oradba_init/raw/master/bin"
SETUP_INIT="00_setup_oradba_init.sh"
SETUP_OS="01_setup_os_oud.sh"
# - EOF Environment Variables -----------------------------------------------
# - Functions ---------------------------------------------------------------
# - EOF Functions -----------------------------------------------------------

# - Main --------------------------------------------------------------------
echo "--- Start OUD setup ---------------------------------------------------"
echo "--- Start OUD setup part 1 --------------------------------------------"
echo "--- Prepare OraDBA init setup -----------------------------------------"
# prepare a download directory
mkdir -p ${DOWNLOAD}

# get the latest install script for OraDBA init from GitHub repository
curl -Lsf ${GITHUB_URL}/${SETUP_INIT} -o ${DOWNLOAD}/${SETUP_INIT}

# install the OraDBA init scripts
chmod 755 ${DOWNLOAD}/${SETUP_INIT}
${DOWNLOAD}/${SETUP_INIT}

# link stage to vagrant stage folder
rm -rf /opt/stage
ln -s /vagrant/stage /opt/stage
cd /tmp

echo "--- Setup OS ----------------------------------------------------------"
# Setup OS
${ORADBA_BIN}/${SETUP_OS}

echo "--- Configure OS ------------------------------------------------------"
# add Oracle to vagrant group to allow sudo
usermod -a -G vagrant oracle

# install dhcp and git
yum install dhcp git -y

# adjust DHCP config
echo "supersede domain-name-servers ${AD_IP_ADDRESS}" /etc/dhcp/dhcpd.conf
# get the default gatway
GATEWAY_ADDRESS=$(ip r|grep -i default|grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')
GOOGLE_DNS="8.8.8.8"
HOST_NAME=$(hostname)
# update /etc/sysconfig/network
echo "HOSTNAME=${HOST_NAME}"    >>/etc/sysconfig/network
echo "DNS1=${AD_IP_ADDRESS}"    >>/etc/sysconfig/network
echo "DNS2=${GATEWAY_ADDRESS}"  >>/etc/sysconfig/network

# change peer DNS setting
sed -i "s/^PEERDNS.*/PEERDNS=no/" /etc/sysconfig/network-scripts/ifcfg-eth0
echo "--- Finished OUD setup part 1 -----------------------------------------"
# --- EOF --------------------------------------------------------------------