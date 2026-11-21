# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
MCP_SERVER_USER=mcp-onkyo
inherit mcp-server

DESCRIPTION="MCP server for Onkyo AV receivers over eISCP"
# Live ebuild: no KEYWORDS. Accept it with ** in package.accept_keywords.

mcp-server_add_deps
