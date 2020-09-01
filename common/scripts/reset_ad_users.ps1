# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: reset_ad_users.ps1
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
$password = ConvertTo-SecureString -AsPlainText 'LAB01schulung' -Force
# - EOF Variables -----------------------------------------------------------

# - Configure Domain --------------------------------------------------------
Import-Module ActiveDirectory

# Update group membership of Trivadis LAB Users
Write-Host 'Add group Trivadis LAB Users to ORA_VFR_11G...'
Add-ADPrincipalGroupMembership -Identity "Trivadislabs Users" -MemberOf ORA_VFR_11G
# ORA_VFR_12C should yet not been used for EUS. Make sure you clarify the SHA512 issues on the DB first.
#Add-ADPrincipalGroupMembership -Identity "Trivadis LAB Users" -MemberOf ORA_VFR_12C

# reset passwords
Write-Host 'Reset all User Passwords...'
Set-ADAccountPassword -Reset -NewPassword $password -Identity lynd
Set-ADAccountPassword -Reset -NewPassword $password -Identity rider
Set-ADAccountPassword -Reset -NewPassword $password -Identity tanner
Set-ADAccountPassword -Reset -NewPassword $password -Identity gartner
Set-ADAccountPassword -Reset -NewPassword $password -Identity fleming
Set-ADAccountPassword -Reset -NewPassword $password -Identity bond
Set-ADAccountPassword -Reset -NewPassword $password -Identity walters
Set-ADAccountPassword -Reset -NewPassword $password -Identity renton
Set-ADAccountPassword -Reset -NewPassword $password -Identity leitner
Set-ADAccountPassword -Reset -NewPassword $password -Identity blake
Set-ADAccountPassword -Reset -NewPassword $password -Identity dent
Set-ADAccountPassword -Reset -NewPassword $password -Identity ward
Set-ADAccountPassword -Reset -NewPassword $password -Identity moneypenny
Set-ADAccountPassword -Reset -NewPassword $password -Identity scott
Set-ADAccountPassword -Reset -NewPassword $password -Identity smith
Set-ADAccountPassword -Reset -NewPassword $password -Identity adams
Set-ADAccountPassword -Reset -NewPassword $password -Identity prefect
Set-ADAccountPassword -Reset -NewPassword $password -Identity blofeld
Set-ADAccountPassword -Reset -NewPassword $password -Identity miller
Set-ADAccountPassword -Reset -NewPassword $password -Identity clark
Set-ADAccountPassword -Reset -NewPassword $password -Identity king

# --- EOF --------------------------------------------------------------------