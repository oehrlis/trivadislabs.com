# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 12_config_ca.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.05.13
# Revision...: 
# Purpose....: Script to configure Certification Autority
# Notes......: ...
# Reference..: 
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# wait until we can access the AD. this is needed to prevent errors like:
#   Unable to find a default server with Active Directory Web Services running.
while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    } catch {
        Write-Host 'Wait 15 seconds to get DNS ready...'
        Start-Sleep -Seconds 15
    }
}

# - Variables ---------------------------------------------------------------
$adDomain   = Get-ADDomain
$domain     = $adDomain.DNSRoot
$domainDn   = $adDomain.DistinguishedName
$company    = (Get-Culture).textinfo.totitlecase($adDomain.Name)
$RootCAFile = "C:\vagrant_common\config\tnsadmin\RootCA_" + $domain + ".cer"
# - EOF Variables -----------------------------------------------------------

# - Configure Domain --------------------------------------------------------
# - Main --------------------------------------------------------------------
Write-Host '= Start setup part 12 ======================================'
Write-Host '- Configure Cert-Authority ---------------------------------'
Write-Host "Domain              : $domain"
Write-Host "Base DN             : $domainDn"
Write-Host "Company             : $company"

Write-Host 'Install Role ADCS-Cert-Authority...'
Install-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools

$caCommonName = "$company Enterprise Root CA"

# configure the CA DN using the default DN suffix (which is based on the
# current Windows Domain, trivadislabs.com) to:
#
#   CN=Example Enterprise Root CA,DC=trivadislabs,DC=com
#
# NB to install a EnterpriseRootCa the current user must be on the
#    Enterprise Admins group. 
Write-Host 'Configure ADCS-Cert-Authority...'

Install-AdcsCertificationAuthority `
    -CAType EnterpriseRootCa  `
    -CACommonName $caCommonName `
    -CryptoProviderName "RSA#Microsoft Software Key Storage Provider"  `
    -KeyLength 4096 `
    -HashAlgorithmName SHA256 `
    -ValidityPeriod Years `
    -ValidityPeriodUnits 5 `
    -Force

Write-Host 'Export root CA to $RootCAFile ...'
$cmd = 'certutil -ca.cert ' + $RootCAFile
$output = cmd /c $cmd 2>&1
# print command
Write-Host $cmd
# print output off command
Write-Host $output

Write-Host '= Finish part 12 ==========================================='
# --- EOF --------------------------------------------------------------------