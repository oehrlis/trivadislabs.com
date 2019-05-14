# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 11_config_dns.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to configure DNS server
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
        get-dnsserver | Out-Null
        break
    } catch {
        Write-Host 'Wait 30 seconds to get DNS ready...'
        Start-Sleep -Seconds 30
    }
}

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

# - Variables ---------------------------------------------------------------
$adDomain   = Get-ADDomain
$domain     = $adDomain.DNSRoot
$REALM      = $adDomain.DNSRoot.ToUpper()
$domainDn   = $adDomain.DistinguishedName
$hostfile   = "c:\vagrant\config\hosts.csv"
# - EOF Variables -----------------------------------------------------------

# - Configure Domain --------------------------------------------------------
# - Main --------------------------------------------------------------------
Write-Host '= Start setup part 11 ======================================'
Write-Host '- Configure active directory -------------------------------'
Write-Host "Domain              : $domain"
Write-Host "REALM               : $REALM"
Write-Host "Base DN             : $domainDn"
Write-Host "Host File           : $hostfile"

Write-Host 'Create reverse lookup zone...'
# create reverse lookup zone
Add-DnsServerPrimaryZone -NetworkID "10.0.0.0/24" -ReplicationScope "Forest"

# temporary remove AD server record
Remove-DnsServerResourceRecord -ZoneName $domain -RRType "A" -Name "win2016ad" -Force

#...and import hosts
Write-Host 'Process hosts from CSV ...'
$HostList = Import-Csv -Path $hostfile   
foreach ($HostRecord in $HostList)
{
    $IP         = $HostRecord.IP
    $IPv4Name   = $IP.Split(".")[3]
    $Hostname   = $HostRecord.Name
    $FQDN       = $Hostname + '.'+ $domain
    $Keytabfile = 'C:\vagrant_common\config\tnsadmin\' + $FQDN + '.keytab'
    $Zone       = "0.0.10.in-addr.arpa"

    Write-Host "Add DNS Resource Record A for Host $Hostname with IP $IP ..."
    Add-DnsServerResourceRecordA -Name $Hostname -ZoneName $domain -AllowUpdateAny -IPv4Address $IP -TimeToLive 01:00:00
    Write-Host "Add DNS PTR resource record for Host $Hostname for $FQDN"
    Add-DnsServerResourceRecordPtr -Name $IPv4Name -ZoneName $Zone -AllowUpdateAny -TimeToLive 01:00:00 -AgeRecord -PtrDomainName $FQDN
    if ( $Hostname -Match "db") {
        Write-Host "Generate keytab file for host $Hostname ..."
        $cmd = 'ktpass -princ oracle/' + $FQDN + '@' + $REALM + ' -mapuser ' + $FQDN + ' -pass ' + $PlainPassword + ' -crypto ALL -ptype KRB5_NT_PRINCIPAL -out ' + $Keytabfile
        $output = cmd /c $cmd 2>&1
        # print command
        Write-Host $cmd
        # print output off command
        Write-Host $output
    } else {
        Write-Host "Skip keytab file generation for host $Hostname ..."
    }
}

# add CNAME records for ad, db and oud
Add-DnsServerResourceRecordCName -Name "ad" -HostNameAlias "win2016ad.$domain" -ZoneName $domain
Add-DnsServerResourceRecordCName -Name "oud" -HostNameAlias "ol7oud12.$domain" -ZoneName $domain
Add-DnsServerResourceRecordCName -Name "db" -HostNameAlias "ol7db19.$domain" -ZoneName $domain

# get the IP Address of the NAT Network
$NAT_IP=(Get-WmiObject -Class Win32_NetworkAdapterConfiguration | where {$_.DefaultIPGateway -ne $null}).IPAddress | select-object -first 1
$NAT_HOSTNAME=hostname

# get DNS Server Records
Get-DnsServerResourceRecord -ZoneName $domain -Name $NAT_HOSTNAME

Write-Host '= Finish part 11 ==========================================='
# --- EOF --------------------------------------------------------------------