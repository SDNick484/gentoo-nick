# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-sofabaton
inherit mcp-server

DESCRIPTION="MCP server for Sofabaton universal remote hubs (X2 MQTT or sofabaton-x-server)"
# Live ebuild: no KEYWORDS. Accept it with ** in package.accept_keywords.

RDEPEND="
	>=dev-python/aiomqtt-2.3[${PYTHON_USEDEP}]
	<dev-python/aiomqtt-3[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27[${PYTHON_USEDEP}]
"
mcp-server_add_deps

# test_config.py imports the sofabaton-x library (to check our copy of its
# button codes), which is not packaged.
EPYTEST_IGNORE=( tests/test_config.py )
