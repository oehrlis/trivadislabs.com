# ---------------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ---------------------------------------------------------------------------
# Name.......: setup_ad_choco_install.ps1
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2018.09.27
# Revision...: 
# Purpose....: Script to install choco package
# Notes......: ...
# Reference..: 
# License....: Licensed under the Universal Permissive License v 1.0 as 
#              shown at http://oss.oracle.com/licenses/upl.
# ---------------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# ---------------------------------------------------------------------------

# - Variables ---------------------------------------------------------------

# - EOF Variables -----------------------------------------------------------

# - Install choco packages --------------------------------------------------
choco install -y winscp
choco install -y putty
choco install -y totalcommander
choco install -y apacheds
choco install -y ldapadmin
choco install -y git
choco install -y vscode
choco install -y github-desktop
# --- EOF --------------------------------------------------------------------