# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-webos
inherit mcp-server

DESCRIPTION="MCP server for LG webOS TVs (SSAP over WebSocket, via aiowebostv)"
# Live ebuild: no KEYWORDS. Accept it with ** in package.accept_keywords.

RDEPEND="
	>=dev-python/aiowebostv-0.9.2[${PYTHON_USEDEP}]
	<dev-python/aiowebostv-0.11[${PYTHON_USEDEP}]
"
mcp-server_add_deps
