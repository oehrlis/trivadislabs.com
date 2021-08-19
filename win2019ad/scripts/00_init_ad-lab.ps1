# ------------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 00_init_ad-lab.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2021.08.17
# Revision...: 
# Purpose....: Script to init the AD-LAB based on the GitHub repository
# Notes......: ...
# Reference..: 
# License....: Apache License Version 2.0, January 2004 as shown
#              at http://www.apache.org/licenses/
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ------------------------------------------------------------------------------

# processing commandline parameter
param (
    [string]$domain     = "trivadislabs.com",
    [string]$DomainMode = "Default",
    [string]$ip         = "10.0.1.4",
    [string]$dns1       = "8.8.8.8",
    [string]$dns2       = "4.4.4.4",
    [string]$PlainPassword
 )

# - Variables ------------------------------------------------------------------
$StageFolder            = "C:\stage"
$LogFolder              = "$StageFolder\logs"
$GitHubURL              = "https://github.com/oehrlis/ad-lab/archive/refs/heads/main.zip"
$DefaultConfigFile      = "$StageFolder\ad-lab\config\default_configuration.txt"
# - EOF Variables --------------------------------------------------------------

# - Main -----------------------------------------------------------------------
Write-Host '= Start AD-Lab initialization ======================================'
New-Item -ItemType Directory -Force -Path $LogFolder
Start-Transcript -OutputDirectory $LogFolder

Write-Host "INFO: Config Values ------------------------------------------------" 
Write-Host "Stage folder        : $StageFolder"
Write-Host "Log folder          : $LogFolder"
Write-Host "GitHub URL          : $GitHubURL"
Write-Host "IP                  : $ip"
Write-Host "DNS 1               : $dns1"
Write-Host "DNS 2               : $dns2"
Write-Host "Default Password    : $PlainPassword"

# Download AD Scripts
Write-Host '- GIT download AD scripts ------------------------------------------'
New-Item -ItemType Directory -Force -Path $StageFolder
Invoke-WebRequest -Uri $GitHubURL -OutFile "$StageFolder\main.zip"
Expand-Archive -LiteralPath "$StageFolder\main.zip" -DestinationPath $StageFolder
Copy-Item -Path "$StageFolder\ad-lab-main" -Destination "$StageFolder\ad-lab" -Recurse

# write default config to file
Write-Host '- Store parameter to default config file ---------------------------'
Copy-Item $DefaultConfigFile -Destination "$DefaultConfigFile.bck"

# Network Domain Name
if ($domain) { 
    $line = Get-Content $DefaultConfigFile | Select-String NetworkDomainName | Select-Object -ExpandProperty Line
    if ($null -eq $line) {
        Write-Host "INFO: skip update of NetworkDomainName"
        exit
    } else {
        Write-Host "INFO: NetworkDomainName to $domain"
        $content = Get-Content $DefaultConfigFile
        $content | ForEach-Object {$_ -replace $line,"NetworkDomainName       = $domain"} | Set-Content $DefaultConfigFile
    }
}
# AD Domain Mode
if ($domain) { 
    $line = Get-Content $DefaultConfigFile | Select-String ADDomainMode | Select-Object -ExpandProperty Line
    if ($null -eq $line) {
        Write-Host "INFO: skip update of ADDomainMode"
        exit
    } else {
        Write-Host "INFO: ADDomainMode to $DomainMode"
        $content = Get-Content $DefaultConfigFile
        $content | ForEach-Object {$_ -replace $line,"ADDomainMode            = $DomainMode"} | Set-Content $DefaultConfigFile
    }
}

# Host IP Address
if ($ip) { 
    $line = Get-Content $DefaultConfigFile | Select-String ServerAddress | Select-Object -ExpandProperty Line
    if ($null -eq $line) {
        Write-Host "INFO: skip update of ServerAddress"
        exit
    } else {
        Write-Host "INFO: ServerAddress to $ip"
        $content = Get-Content $DefaultConfigFile
        $content | ForEach-Object {$_ -replace $line,"ServerAddress           = $ip"} | Set-Content $DefaultConfigFile
    }
}

# First DNS Server
if ($dns1) { 
    $line = Get-Content $DefaultConfigFile | Select-String DNS1ClientServerAddress | Select-Object -ExpandProperty Line
    if ($null -eq $line) {
        Write-Host "INFO: skip update of DNS1ClientServerAddress"
        exit
    } else {
        Write-Host "INFO: DNS1ClientServerAddress to $dns1"
        $content = Get-Content $DefaultConfigFile
        $content | ForEach-Object {$_ -replace $line,"DNS1ClientServerAddress = $dns1"} | Set-Content $DefaultConfigFile
    }
}

# Second DNS Server
if ($dns2) { 
    $line = Get-Content $DefaultConfigFile | Select-String DNS2ClientServerAddress | Select-Object -ExpandProperty Line
    if ($null -eq $line) {
        Write-Host "INFO: skip update of DNS2ClientServerAddress"
        exit
    } else {
        Write-Host "INFO: DNS2ClientServerAddress to $dns2"
        $content = Get-Content $DefaultConfigFile
        $content | ForEach-Object {$_ -replace $line,"DNS2ClientServerAddress = $dns2"} | Set-Content $DefaultConfigFile
    }
}

# Plain Password
if ($PlainPassword) { 
    $line = Get-Content $DefaultConfigFile | Select-String PlainPassword | Select-Object -ExpandProperty Line
    if ($null -eq $line) {
        Write-Host "INFO: skip update of PlainPassword"
        exit
    } else {
        Write-Host "INFO: PlainPassword to $PlainPassword"
        $content = Get-Content $DefaultConfigFile
        $content | ForEach-Object {$_ -replace $line,"PlainPassword           = $PlainPassword"} | Set-Content $DefaultConfigFile
    }
}

Get-Content $DefaultConfigFile

Stop-Transcript
Write-Host '= Finish AD-Lab initialization ====================================='
# --- EOF ----------------------------------------------------------------------