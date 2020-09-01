# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: 27_config_cmu.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2019.05.13
# Revision...: 
# Purpose....: Script to configure CMU on Active Directory
# Notes......: ...
# Reference..: 
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# - Main --------------------------------------------------------------------
Write-Host '= Start setup part 7 ========================================'

# - Variables ---------------------------------------------------------------
$adDomain   = Get-ADDomain
# - EOF Variables -----------------------------------------------------------

# - Configure Domain --------------------------------------------------------
Write-Host '- Configure AD password filter -----------------------------'
Write-Host " not yet implemented"

Write-Host '= Finish part 7 ============================================='
# --- EOF --------------------------------------------------------------------