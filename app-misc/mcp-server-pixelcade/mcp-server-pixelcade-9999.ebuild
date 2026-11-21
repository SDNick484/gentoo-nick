# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-pixelcade
inherit mcp-server

DESCRIPTION="MCP server for Pixelcade LED marquees and Pixelcade Pulse (pixelweb API)"
# Live ebuild: no KEYWORDS. Accept it with ** in package.accept_keywords.

RDEPEND="
	>=dev-python/httpx-0.27[${PYTHON_USEDEP}]
"
mcp-server_add_deps
