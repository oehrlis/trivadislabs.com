# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 99_sum_up_ad.ps1
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
    [string]$netbiosDomain = "TRIVADISLABS",
    [string]$DomainMode = "Win2012R2",
    [string]$ip = "10.0.0.4",
    [string]$dns1 = "8.8.8.8",
    [string]$dns2 = "4.4.4.4"
 )

# get default password from file
$DefaultPWDFile="C:\vagrant\config\default_pwd_win2016ad.txt"
if ((Test-Path $DefaultPWDFile)) {
    Write-Host "Get default password from $DefaultPWDFile"
    $PlainPassword=Get-Content -Path  $DefaultPWDFile -TotalCount 1
    $PlainPassword=$PlainPassword.trim()

} else {
    Write-Error "Can not access $DefaultPWDFile"
    $PlainPassword=""
}

# get the IP Address of the NAT Network
$NAT_IP=(Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.DefaultIPGateway -ne $null}).IPAddress | select-object -first 1
$NAT_HOSTNAME=hostname
Write-Host "NAT IP          => $NAT_IP"
Write-Host "NAT HOSTNAME    => $NAT_HOSTNAME"

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

# list OS information.
Write-Host '- OS Details -----------------------------------------------'
New-Object -TypeName PSObject -Property @{
    Is64BitOperatingSystem = [Environment]::Is64BitOperatingSystem
} | Format-Table -AutoSize
[Environment]::OSVersion | Format-Table -AutoSize

# list all the installed Windows features.
echo 'Installed Windows Features:'
Write-Host '- Installed Windows Features -------------------------------'
Get-WindowsFeature | Where Installed | Format-Table -AutoSize | Out-String -Width 2000


# see https://gist.github.com/IISResetMe/36ef331484a770e23a81
function Get-MachineSID {
    param(
        [switch]$DomainSID
    )

    # Retrieve the Win32_ComputerSystem class and determine if machine is a Domain Controller  
    $WmiComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $IsDomainController = $WmiComputerSystem.DomainRole -ge 4

    if ($IsDomainController -or $DomainSID) {
        # We grab the Domain SID from the DomainDNS object (root object in the default NC)
        $Domain    = $WmiComputerSystem.Domain
        $SIDBytes = ([ADSI]"LDAP://$Domain").objectSid | %{$_}
        New-Object System.Security.Principal.SecurityIdentifier -ArgumentList ([Byte[]]$SIDBytes),0
    } else {
        # Going for the local SID by finding a local account and removing its Relative ID (RID)
        $LocalAccountSID = Get-WmiObject -Query "SELECT SID FROM Win32_UserAccount WHERE LocalAccount = 'True'" | Select-Object -First 1 -ExpandProperty SID
        $MachineSID      = ($p = $LocalAccountSID -split "-")[0..($p.Length-2)]-join"-"
        New-Object System.Security.Principal.SecurityIdentifier -ArgumentList $MachineSID
    }
}

echo "This Computer SID is $(Get-MachineSID)"
Write-Host ''
Write-Host '============================================================'
Write-Host '  Successfully finish setup AD VM'
Write-Host '------------------------------------------------------------'
Write-Host "Domain              : $domain"
Write-Host "Netbios Domain      : $netbiosDomain"
Write-Host "Domain Mode         : $DomainMode"
Write-Host "IP                  : $ip"
Write-Host "DNS 1               : $dns1"
Write-Host "DNS 2               : $dns2"
Write-Host "Default Password    : $PlainPassword"
Write-Host '============================================================'
# --- EOF --------------------------------------------------------------------