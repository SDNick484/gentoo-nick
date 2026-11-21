# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-group

DESCRIPTION="Group for app-misc/mcp-server-pixelcade"
# Overlay: allocate the GID dynamically.
ACCT_GROUP_ID=-1
