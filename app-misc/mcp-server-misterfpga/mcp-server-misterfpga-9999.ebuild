# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-mister
MCP_SERVER_SERVICES=( ${PN} ${PN}-track )
inherit mcp-server

DESCRIPTION="MCP server for MiSTer FPGA devices (Zaparoo Core, MiSTer.ini and saves over SSH)"
# Live ebuild: no KEYWORDS. Accept it with ** in package.accept_keywords.

RDEPEND="
	>=dev-python/aiohttp-3.9[${PYTHON_USEDEP}]
	>=dev-python/aiomqtt-2.3[${PYTHON_USEDEP}]
	>=dev-python/asyncssh-2.17[${PYTHON_USEDEP}]
"
mcp-server_add_deps
