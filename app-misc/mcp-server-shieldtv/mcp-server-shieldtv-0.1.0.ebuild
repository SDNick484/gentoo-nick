# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-shieldtv
inherit mcp-server

DESCRIPTION="MCP server for NVIDIA Shield TV (Android TV Remote protocol v2)"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/adb-shell-0.4.4[${PYTHON_USEDEP}]
	>=dev-python/androidtvremote2-0.3.2[${PYTHON_USEDEP}]
	>=dev-python/zeroconf-0.130[${PYTHON_USEDEP}]
"
mcp-server_add_deps
