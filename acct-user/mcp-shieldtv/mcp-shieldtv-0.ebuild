# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for app-misc/mcp-server-shieldtv"
# Overlay: allocate the UID dynamically.
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( mcp-shieldtv )
# The service's state (paired devices, MQTT state); the init script also
# keeps it 0700 or 0750, as upstream's install.sh does.
ACCT_USER_HOME=/var/lib/mcp-server-shieldtv
ACCT_USER_HOME_PERMS=0700

acct-user_add_deps
