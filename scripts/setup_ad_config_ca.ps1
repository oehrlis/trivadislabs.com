# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: setup_ad_config_ca.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to configure Certification Autority
# Notes......: ...
# Reference..: https://github.com/StefanScherer/adfs2
#              http://technet.microsoft.com/de-de/library/dd378937%28v=ws.10%29.aspx
#              http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/29/powertip-create-an-organizational-unit-with-powershell.aspx
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# install the AD services and administration tools.
Write-Host 'Install Role ADCS-Cert-Authority...'
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

$caCommonName = 'Trivadis LAB Enterprise Root CA'

# configure the CA DN using the default DN suffix (which is based on the
# current Windows Domain, trivadislabs.com) to:
#
#   CN=Example Enterprise Root CA,DC=trivadislabs,DC=com
#
# NB to install a EnterpriseRootCa the current user must be on the
#    Enterprise Admins group. 
Write-Host 'Configure ADCS-Cert-Authority...'
Write-Host 'Automatic delployment does not yet work...'

# Install-AdcsCertificationAuthority `
#     -CAType EnterpriseRootCa  `
#     -CACommonName $caCommonName `
#     -CryptoProviderName "RSA#Microsoft Software Key Storage Provider"  `
#     -KeyLength 4096 `
#     -HashAlgorithmName SHA256 `
#     -ValidityPeriod Years `
#     -ValidityPeriodUnits 5 `
#     -Force
# --- EOF --------------------------------------------------------------------