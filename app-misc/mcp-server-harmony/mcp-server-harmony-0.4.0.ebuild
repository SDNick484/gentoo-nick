# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-harmony
inherit mcp-server

DESCRIPTION="MCP server for the Logitech Harmony Hub (local websocket API)"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/aioharmony-1.0.10[${PYTHON_USEDEP}]
	<dev-python/aioharmony-2[${PYTHON_USEDEP}]
	>=dev-python/aiohttp-3.9[${PYTHON_USEDEP}]
"
mcp-server_add_deps
