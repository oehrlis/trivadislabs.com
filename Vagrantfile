#!/bin/bash
# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: Vagrantfile.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.04.11
# Revision...:  
# Purpose....: Vagrant file to setup and configure ad.trivadislabs.com
# Notes......: 
# Reference..: --
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# TODO:
# - DNS config db,oud, ad
# - Domain setup
# - kerberos und cmu user
# - CA setup
# - system registration DNS
# - ad language setting
# - ad update
# - domain as parameter

# - Customization -----------------------------------------------------------
# Domain Controller
AD = "ad"
AD_FQDN = "ad.trivadislabs.com"

# DB Server
DB = "db"
DB_FQDN = "db.trivadislabs.com"

# OUD Server
OUD = "oud"
OUD_FQDN = "oud.trivadislabs.com"
# - End of Customization ----------------------------------------------------

Vagrant.configure("2") do |config|
# - Domain controller -------------------------------------------------------
    config.vm.define AD do |cfg|
        cfg.vm.box = "StefanScherer/windows_2016"
        cfg.vm.define AD_FQDN
    
        # change memory size
        cfg.vm.provider "virtualbox" do |v|
            v.memory = 1024
            v.name = AD_FQDN
        end
  
        # VM hostname
        cfg.vm.hostname = AD
        # use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        #    after the domain controller is installed.
        #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        cfg.winrm.transport = :plaintext
        cfg.winrm.basic_auth_only = true

        cfg.vm.communicator = "winrm"
        cfg.vm.network :private_network, ip: "10.0.0.4", gateway: "10.0.0.1", dns: "10.0.0.4"

        # Provision everything on the first run
        cfg.vm.provision "shell", path: "scripts/install_ad.ps1", privileged: false
        cfg.vm.provision "reload"
        cfg.vm.provision "shell", path: "scripts/config_ad.ps1", privileged: false
        cfg.vm.provision "shell", path: "scripts/sum_ad.ps1", privileged: false
    end

# - DB server ---------------------------------------------------------------
    config.vm.define DB do |cfg|
        cfg.vm.box = "ol7-latest"
        cfg.vm.box_url = "https://yum.oracle.com/boxes/oraclelinux/latest/ol7-latest.box"
        cfg.vm.define DB_FQDN
        
        cfg.vm.box_check_update = false
        
        # change memory size
        cfg.vm.provider "virtualbox" do |v|
            v.memory = 4096
            v.name = DB_FQDN
        end
        
        # VM hostname
        cfg.vm.hostname = DB
        
        # Oracle port forwarding
        cfg.vm.network :forwarded_port, guest: 22,   host: 2223
        cfg.vm.network :forwarded_port, guest: 1521, host: 1521
        cfg.vm.network :forwarded_port, guest: 5500, host: 5500
        cfg.vm.network :private_network, ip: "10.0.0.3", auto_config: false

        # Provision everything on the first run
        cfg.vm.provision "shell", path: "scripts/install_db.sh", env:
            {
            "ORACLE_SID1"          => "TDB184A",
            "ORACLE_SID2"          => "TDB122A",
            "DEFAULT_DOMAIN"       => "trivadislabs.com",
            "ORACLE_CHARACTERSET" => "AL32UTF8",
            }
    end
# - OUD server --------------------------------------------------------------
    config.vm.define OUD do |cfg|
        cfg.vm.box = "ol7-latest"
        cfg.vm.box_url = "https://yum.oracle.com/boxes/oraclelinux/latest/ol7-latest.box"
        cfg.vm.define OUD_FQDN
        
        cfg.vm.box_check_update = false
        
        # change memory size
        cfg.vm.provider "virtualbox" do |v|
            v.memory = 1024
            v.name = OUD_FQDN
        end
        
        # VM hostname
        cfg.vm.hostname = OUD
        
        # Oracle port forwarding
        cfg.vm.network :forwarded_port, guest: 22,   host: 2225
        cfg.vm.network :forwarded_port, guest: 1389, host: 1389
        cfg.vm.network :forwarded_port, guest: 1636, host: 1636
        cfg.vm.network :forwarded_port, guest: 4444, host: 4444
        cfg.vm.network :forwarded_port, guest: 7001, host: 7001
        cfg.vm.network :forwarded_port, guest: 7002, host: 7002
        cfg.vm.network :forwarded_port, guest: 8080, host: 8080
        cfg.vm.network :forwarded_port, guest: 10443, host: 10443
        cfg.vm.network :forwarded_port, guest: 8444, host: 8444
        cfg.vm.network :private_network, ip: "10.0.0.5", auto_config: false

        # Provision everything on the first run
        cfg.vm.provision "shell", path: "scripts/install_oud.sh", env:
            {
            "DEFAULT_DOMAIN"       => "trivadislabs.com"
            }
    end
end
# --- EOF -------------------------------------------------------------------