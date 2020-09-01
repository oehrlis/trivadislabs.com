# Common Lab Setup Scripts

This directory contains common LAB setup scripts. The following list does provide a short overview of the different scripts.

- [00_init_environment.sh](00_init_environment.sh) 
- [01_common_setup_os_db.sh](01_common_setup_os_db.sh) Bash script to initialize and setup the OS for a DB vagrant box.
- [02_install_db_binaries.sh](02_install_db_binaries.sh) Bash script to install Oracle DB binaries.
- [03_install_basenv.sh](03_install_basenv.sh) Bash wrapper script to instal TVD-BasEnv.
- [04_config_tnsadmin.sh](04_config_tnsadmin.sh) Bash script to configure SQLNET and TNS.
- [05_create_databases.sh](05_create_databases.sh) Bash wrapper script to create the databases.
- [11_common_setup_os_oud.sh](11_common_setup_os_oud.sh) Bash script to initialize and setup the OS for a OUD vagrant box.
- [12_install_oud_binaries.sh](12_install_oud_binaries.sh) Bash script to install Oracle OUD binaries.
- [13_config_oudbase.sh](13_config_oudbase.sh) Bash wrapper script to instal OUD Base.
- [14_create_oud_instance.sh](14_create_oud_instance.sh) Bash wrapper script to create the OUD instances.
- [15_create_oudsm_domain.sh](15_create_oudsm_domain.sh) Bash wrapper script to create the OUDSM domain.
- [21_install_ad.ps1](21_install_ad.ps1) PowerShell script to install Active Directory Role
- [22_install_chocolatey.ps1](22_install_chocolatey.ps1) PowerShell script to install Chocolatey package manager
- [23_config_ad.ps1](23_config_ad.ps1) PowerShell script to configure Active Directory
- [24_config_dns.ps1](11_config_dns.ps1) PowerShell script to configure DNS server
- [25_config_ca.ps1](25_config_ca.ps1) PowerShell script to configure Certification Autority
- [26_install_tools.ps1](26_install_tools.ps1) PowerShell script to install tools via chocolatey package
- [27_config_cmu.ps1](27_config_cmu.ps1) PowerShell script to configure CMU on Active Directory
- [28_config_misc.ps1](28_config_misc.ps1) PowerShell script to configure NAT zone records for AD domain
- [29_sum_up_ad.ps1](29_sum_up_ad.ps1) PowerShell script to display a summary of Active Directory Domain and install Windows updates
- [reset_ad_users.ps1](reset_ad_users.ps1) PowerShell script to reset all domain user password

Although the script [30_config_cmu.ps1](30_config_cmu.ps1) and [40_install_oracle_client.ps1](40_install_oracle_client.ps1) are just skeletons. They do not yet install any thing.
