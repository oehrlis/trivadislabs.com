# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: config_ad.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to configure Active Directory Domain
# Notes......: ...
# Reference..: https://github.com/StefanScherer/adfs2
#              http://technet.microsoft.com/de-de/library/dd378937%28v=ws.10%29.aspx
#              http://blogs.technet.com/b/heyscriptingguy/archive/2013/10/29/powertip-create-an-organizational-unit-with-powershell.aspx
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------
# - Variables ---------------------------------------------------------------
$adDomain = Get-ADDomain
$domain = $adDomain.DNSRoot
$domainDn = $adDomain.DistinguishedName
# - EOF Variables -----------------------------------------------------------

# add DNS Recoreds
Write-Host 'Update DNS records...'
Remove-DnsServerResourceRecord -ZoneName $domain -RRType "A" -Name "ad" -Force
Add-DnsServerResourceRecordA -Name "ad" -ZoneName $domain -AllowUpdateAny -IPv4Address "10.0.0.4" -TimeToLive 01:00:00
Add-DnsServerResourceRecordA -Name "db" -ZoneName $domain -AllowUpdateAny -IPv4Address "10.0.0.3" -TimeToLive 01:00:00
Add-DnsServerResourceRecordA -Name "oud" -ZoneName $domain -AllowUpdateAny -IPv4Address "10.0.0.5" -TimeToLive 01:00:00

Write-Host 'Wait 120 seconds before trying to set reverse lookup zone...'
Start-Sleep -Seconds 120
# create reverse lookup zone
Add-DnsServerPrimaryZone -NetworkID "10.0.0.0/24" -ReplicationScope "Forest"
Add-DnsServerResourceRecordPtr -Name "4" -ZoneName "0.0.10.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "ad.$domain"
Add-DnsServerResourceRecordPtr -Name "5" -ZoneName "0.0.10.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "oud.$domain"
Add-DnsServerResourceRecordPtr -Name "3" -ZoneName "0.0.10.in-addr.arpa" -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName "db.$domain"