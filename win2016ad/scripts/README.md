# Local Lab Setup

This directory contains local LAB setup scripts. The following table provide a short overview of the different scripts.

| Script Name                                                  | Type       | Description                                            |
|--------------------------------------------------------------|------------|--------------------------------------------------------|
| [01_install_ad.ps1](01_install_ad.ps1)                       | PowerShell | Script to install Active Directory Role                |
| [02_install_chocolatey.ps1](02_install_chocolatey.ps1)       | PowerShell | Script to install Chocolatey package manager           |
| [10_config_ad.ps1](10_config_ad.ps1)                         | PowerShell | Script to configure Active Directory                   |
| [11_config_dns.ps1](11_config_dns.ps1)                       | PowerShell | Script to configure DNS server                         |
| [12_config_ca.ps1](12_config_ca.ps1)                         | PowerShell | Script to configure Certification Autority             |
| [20_install_tools.ps1](20_install_tools.ps1)                 | PowerShell | Script to install tools via chocolatey package         |
| [30_config_cmu.ps1](30_config_cmu.ps1)                       | PowerShell | Script to configure CMU on Active Directory            |
| [40_install_oracle_client.ps1](40_install_oracle_client.ps1) | PowerShell | Script to install the Oracle Client                    |
| [99_sum_up_ad.ps1](99_sum_up_ad.ps1)                         | PowerShell | Script to display a summary of Active Directory Domain |

Although the script [30_config_cmu.ps1](30_config_cmu.ps1) and [40_install_oracle_client.ps1](40_install_oracle_client.ps1) are just skeletons. They do not yet install any thing.
