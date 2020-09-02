# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 28_config_misc.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to display a summary of Active Directory Domain
# Notes......: ...
# Reference..: 
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# processing commandline parameter
param (
    [string]$domain = "trivadislabs.com",
    [string]$ip = "10.0.0.4"
 )

# - Main --------------------------------------------------------------------
# get the IP Address of the NAT Network
$NAT_IP=(Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.DefaultIPGateway -ne $null}).IPAddress | select-object -first 1
$NAT_HOSTNAME=hostname

Write-Host '= Start setup part 8 ======================================='
Write-Host "Domain              : $domain"
Write-Host "IP                  : $ip"
Write-Host "NAT IP              : $NAT_IP"
Write-Host "NAT Hostname        : $NAT_HOSTNAME"

# get DNS Server Records
Get-DnsServerResourceRecord -ZoneName $domain -Name $NAT_HOSTNAME -RRType "A" 

$NAT_RECORD = Get-DnsServerResourceRecord -ZoneName $domain -Name $NAT_HOSTNAME -RRType "A" | where {$_.RecordData.IPv4Address -EQ $NAT_IP}
$IP_RECORD  = Get-DnsServerResourceRecord -ZoneName $domain -Name $NAT_HOSTNAME -RRType "A" | where {$_.RecordData.IPv4Address -EQ $ip}
if($NAT_RECORD -eq $null){
    Write-Host "No NAT DNS record found"
} else {
    if($IP_RECORD -ne $null){
        # remove the DNS Record for the NAT Network
        Write-Host " remove DNS record $NAT_IP for host $NAT_HOSTNAME in zone $domain"
        Remove-DnsServerResourceRecord -ZoneName $domain -RRType "A" -Name $NAT_HOSTNAME -RecordData $NAT_IP -force
    } else {
        Write-Host "NAT DNS record not removed"
    }
}

Get-DnsServerResourceRecord -ZoneName $domain -Name $NAT_HOSTNAME

Write-Host '- Configure Windows Update -------------------------------------'
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
Get-Package -Name PSWindowsUpdate
# Install windows updates currently does not work
# Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot

Write-Host '= Finish part 8 ============================================='
# --- EOF --------------------------------------------------------------------