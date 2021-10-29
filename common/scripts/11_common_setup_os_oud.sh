#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 11_common_setup_os_oud.sh
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to initialize and install Vagrant box OUD.
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
export IP=${public_ip:-"127.0.0.1"}
# define variables for OS setup
SETUP_INIT="00_setup_oradba_init.sh"
SETUP_OS="01_setup_os_oud.sh"
# - EOF Environment Variables -----------------------------------------------

# - Main --------------------------------------------------------------------
echo "= Start part 01 ======================================================="
echo "--- Prepare OraDBA init setup -----------------------------------------"

# prepare a download directory
mkdir -p ${DOWNLOAD}

# get the latest install script for OraDBA init from GitHub repository
curl -Lsf ${GITHUB_URL}/bin/${SETUP_INIT} -o ${DOWNLOAD}/${SETUP_INIT}

# install the OraDBA init scripts
chmod 755 ${DOWNLOAD}/${SETUP_INIT}
${DOWNLOAD}/${SETUP_INIT}
rm -rf ${OPT_DIR}/oradba/oradba_init-master

# link software to vagrant stage folder
rm -rf /opt/stage
ln -s /vagrant/software /opt/stage
cd /tmp

echo "--- Setup OS ----------------------------------------------------------"
# Setup OS
${ORADBA_BIN}/${SETUP_OS}

echo "--- Configure OS ------------------------------------------------------"
# add Oracle to vagrant group to allow sudo
usermod -a -G vagrant oracle

# workaround for issue #131 https://github.com/oracle/vagrant-boxes/issues/131
YUM="yum --disablerepo=ol7_developer"
# install dhcp and git
${YUM} install dhcp xauth libXrender libXtst git -y

# install UEK kernel devel/headers
${YUM} install kernel-uek-devel kernel-headers kernel-devel -y

# adjust DHCP config
echo "supersede domain-name-servers ${dns}" /etc/dhcp/dhcpd.conf
# get the default gatway
#GATEWAY_ADDRESS=$(ip r|grep -i default|grep -E -o '(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')

# update /etc/sysconfig/network
echo "HOSTNAME=$(hostname -s).${DEFAULT_DOMAIN}"    >>/etc/sysconfig/network
echo "DNS1=${dns}"             >>/etc/sysconfig/network
echo "DNS2=${public_dns1}"     >>/etc/sysconfig/network

# update /etc/hosts
sed -i "s/127.0.0.1.*${HOSTNAME}/127.0.0.1 ${HOSTNAME}.${DEFAULT_DOMAIN} ${HOSTNAME}/" /etc/hosts
echo "${IP} $(hostname -s).${DEFAULT_DOMAIN} $(hostname -s)" >>/etc/hosts

# change peer DNS setting
sed -i "s/^PEERDNS.*/PEERDNS=no/" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i -n -e '/^DOMAIN=/!p' -e '$aDOMAIN='${DEFAULT_DOMAIN} /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i -n -e '/^DOMAIN=/!p' -e '$aDOMAIN='${DEFAULT_DOMAIN} /etc/sysconfig/network-scripts/ifcfg-eth1

echo "= Finish part 01 ======================================================"
# --- EOF --------------------------------------------------------------------