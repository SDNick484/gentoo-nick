# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MCP_SERVER_USER=mcp-steam-backlog
inherit mcp-server

DESCRIPTION="MCP server for Steam Backlog Triage: what to play next, search and triage"
# Live ebuild: no KEYWORDS. Accept it with ** in package.accept_keywords.

RDEPEND="
	>=dev-python/aiomqtt-2.3[${PYTHON_USEDEP}]
	<dev-python/aiomqtt-3[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.27[${PYTHON_USEDEP}]
	<dev-python/httpx-1[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.7[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
"
mcp-server_add_deps

src_prepare() {
	distutils-r1_src_prepare

	# _build.py gets the commit from git archive (export-subst); a git-r3
	# checkout leaves the placeholder, so fill it in.
	sed -i -e "s/[$]Format:%h[$]/${EGIT_VERSION:0:7}/" \
		src/steam_backlog_mcp/_build.py || die
}
