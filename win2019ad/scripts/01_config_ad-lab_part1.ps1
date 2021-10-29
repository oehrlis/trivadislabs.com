# ------------------------------------------------------------------------------
# Trivadis - Part of Accenture, Platform Factory - Transactional Data Platform
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ------------------------------------------------------------------------------
# Name.......: 01_config_ad-lab_part1.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2021.08.17
# Revision...: 
# Purpose....: Script to config the AD-LAB part I based on the GitHub repository
# Notes......: ...
# Reference..: 
# License....: Apache License Version 2.0, January 2004 as shown
#              at http:\\www.apache.org\licenses\
# ------------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes\updates
# ------------------------------------------------------------------------------

# - Variables ------------------------------------------------------------------
$StageFolder            = "C:\stage"
$LogFolder              = "$StageFolder\logs"
# - EOF Variables --------------------------------------------------------------

# - Main -----------------------------------------------------------------------
Write-Host '= Start AD-Lab config part I ======================================='
New-Item -ItemType Directory -Force -Path $LogFolder
Start-Transcript -OutputDirectory $LogFolder

Write-Host "INFO: Config Values ------------------------------------------------" 
Write-Host "Stage folder        : $StageFolder"
Write-Host "Log folder          : $LogFolder"

# Download AD Scripts
Write-Host '- call 01_install_ad_role script -----------------------------------'
& "$StageFolder\ad-lab\scripts\01_install_ad_role.ps1" 
Write-Host '- call 22_install_chocolatey script --------------------------------'
& "$StageFolder\ad-lab\scripts\22_install_chocolatey.ps1"

Stop-Transcript
Write-Host '= Finish AD-Lab config part I ======================================'
# --- EOF ----------------------------------------------------------------------