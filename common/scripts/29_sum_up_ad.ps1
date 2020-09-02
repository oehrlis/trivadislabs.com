# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 29_sum_up_ad.ps1
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
    [string]$domain = "trivadislabs.com"
 )

$NAT_HOSTNAME=hostname

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
Write-Host ' Successfully finish setup AD VM '
Write-Host "  Host      : $NAT_HOSTNAME"
Write-Host "  Domain    : $domain"
Write-Host '============================================================'
# --- EOF --------------------------------------------------------------------