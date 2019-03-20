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
# Reference..: https://github.com/rgl/windows-domain-controller-vagrant
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# TODO:
# - AD language setting
# - AD OS update
# - Install tools like putty, winscp, oracle client, shortcuts etc
# - domain as parameter
# - AD ssh server https://www.ntweekly.com/2017/12/22/install-openssh-windows-server-2016-1709/
# - Finish CA configuration
# - Customization -----------------------------------------------------------
# Domain Controller
DOMAIN_NAME     = "trivadislabs.com"
GATEWAY_ADDRESS = "10.0.0.1"
DB_HOST_NAME    = "db"
DB_ADDRESS      = "10.0.0.3"
DB_HOST_FQDN    = DB_HOST_NAME + "." + DOMAIN_NAME
AD_HOST_NAME    = "ad"
AD_ADDRESS      = "10.0.0.4"
AD_HOST_FQDN    = AD_HOST_NAME + "." + DOMAIN_NAME
OUD_HOST_NAME   = "oud"
OUD_ADDRESS     = "10.0.0.5"
OUD_HOST_FQDN   = OUD_HOST_NAME + "." + DOMAIN_NAME
# - End of Customization ----------------------------------------------------

# install missing vagrant plugin
unless Vagrant.has_plugin?("vagrant-reload")
    puts 'Installing vagrant-reload Plugin...'
    system('vagrant plugin install vagrant-reload')
end

Vagrant.configure("2") do |config|
# - Domain controller -------------------------------------------------------
    config.vm.define AD_HOST_NAME do |cfg|
        cfg.vm.box      = "StefanScherer/windows_2016"
        cfg.vm.define   AD_HOST_FQDN
    
        # change memory size
        cfg.vm.provider "virtualbox" do |v|
            v.memory    = 1024
            v.name      = AD_HOST_FQDN
        end
  
        # VM hostname
        cfg.vm.hostname = AD_HOST_NAME
        # use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        #    after the domain controller is installed.
        #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        cfg.winrm.transport = :plaintext
        cfg.winrm.basic_auth_only = true

        cfg.vm.communicator = "winrm"
        cfg.vm.network :private_network, ip: AD_ADDRESS, gateway: GATEWAY_ADDRESS, dns: AD_ADDRESS

        # Provision everything on the first run
        cfg.vm.provision "shell", path: "bin/setup_ad_install_ad.ps1",      privileged: false
        cfg.vm.provision :reload
        cfg.vm.provision "shell", path: "bin/setup_ad_config_ad.ps1",       privileged: false
        cfg.vm.provision "shell", path: "bin/setup_ad_config_dns.ps1",      privileged: false
        cfg.vm.provision "shell", path: "bin/setup_ad_config_ca.ps1",       privileged: false
        cfg.vm.provision "shell", path: "bin/setup_ad_choco_install.ps1",   privileged: false
        cfg.vm.provision "shell", path: "bin/setup_ad_sum.ps1",             privileged: false
    end

# - DB server ---------------------------------------------------------------
    config.vm.define DB_HOST_NAME do |cfg|
        cfg.vm.box      = "ol7-latest"
        cfg.vm.box_url  = "https://yum.oracle.com/boxes/oraclelinux/latest/ol7-latest.box"
        cfg.vm.define   DB_HOST_FQDN
        
        cfg.vm.box_check_update = false
        
        # change memory size
        cfg.vm.provider "virtualbox" do |v|
            v.memory    = 4096
            v.name      = DB_HOST_FQDN
        end
        
        # VM hostname
        cfg.vm.hostname = DB_HOST_FQDN
        
        # Oracle port forwarding
        cfg.vm.network :forwarded_port, guest: 22,   host: 2223
        cfg.vm.network :forwarded_port, guest: 1521, host: 1521
        cfg.vm.network :forwarded_port, guest: 5500, host: 5500
        cfg.vm.network :private_network, ip: DB_ADDRESS

        # Provision everything on the first run 
        # start part 1 of the setup
        cfg.vm.provision "shell", path: "bin/setup_db_part1.sh", env:
        {
            "AD_IP_ADDRESS"         => AD_ADDRESS
        }
        # reload the VM
        cfg.vm.provision :reload
        # start part 2 of the setup
        cfg.vm.provision "shell", path: "bin/setup_db_part2.sh", env:
        {
            "DEFAULT_DOMAIN"        => DOMAIN_NAME,            
            "ORACLE_SID1"           => "TDB185A",
            "ORACLE_SID2"           => "TDB122A",
            "ORACLE_CHARACTERSET"   => "AL32UTF8",
        }
    end
# - OUD server --------------------------------------------------------------
    config.vm.define OUD_HOST_NAME do |cfg|
        cfg.vm.box      = "ol7-latest"
        cfg.vm.box_url  = "https://yum.oracle.com/boxes/oraclelinux/latest/ol7-latest.box"
        cfg.vm.define   OUD_HOST_FQDN

        cfg.vm.box_check_update = false
        
        # change memory size
        cfg.vm.provider "virtualbox" do |v|
            v.memory            = 1024
            v.name              = OUD_HOST_FQDN
        end
        
        # VM hostname
        cfg.vm.hostname = OUD_HOST_FQDN
        
        # Oracle port forwarding
        cfg.vm.network :forwarded_port, guest: 22,      host: 2225
        cfg.vm.network :forwarded_port, guest: 1389,    host: 1389
        cfg.vm.network :forwarded_port, guest: 1636,    host: 1636
        cfg.vm.network :forwarded_port, guest: 4444,    host: 4444
        cfg.vm.network :forwarded_port, guest: 7001,    host: 7001
        cfg.vm.network :forwarded_port, guest: 7002,    host: 7002
        cfg.vm.network :forwarded_port, guest: 8080,    host: 8080
        cfg.vm.network :forwarded_port, guest: 10443,   host: 10443
        cfg.vm.network :forwarded_port, guest: 8444,    host: 8444
        cfg.vm.network :private_network, ip: OUD_ADDRESS

        # Provision everything on the first run 
        # start part 1 of the setup
        cfg.vm.provision "shell", path: "bin/setup_oud_part1.sh", env:
        {
            "AD_IP_ADDRESS"        => AD_ADDRESS
        }
        # reload the VM
        cfg.vm.provision :reload
        # start part 2 of the setup
        cfg.vm.provision "shell", path: "bin/setup_oud_part2.sh", env:
        {
            "DEFAULT_DOMAIN"       => DOMAIN_NAME
        }
    end
end
# --- EOF -------------------------------------------------------------------