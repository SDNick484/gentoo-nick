# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-batocera
inherit mcp-server

DESCRIPTION="MCP server for Batocera cabinets (EmulationStation API, RetroArch commands)"
# Live ebuild: no KEYWORDS. Accept it with ** in package.accept_keywords.

RDEPEND="
	>=dev-python/httpx-0.27[${PYTHON_USEDEP}]
"
mcp-server_add_deps

src_install() {
	mcp-server_src_install

	# The play tracker runs on the cabinet itself, not here: copy it over.
	insinto /usr/share/${PN}
	doins -r playtracker
}
