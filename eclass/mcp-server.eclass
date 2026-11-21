# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mcp-server.eclass
# @MAINTAINER:
# Nick Andrade <SDNick484@users.noreply.github.com>
# @SUPPORTED_EAPIS: 8
# @PROVIDES: distutils-r1
# @BLURB: Common code for the SDNick484/mcp-server-* MCP servers
# @DESCRIPTION:
# The mcp-server-* repositories under github.com/SDNick484 are built the
# same way: a Python package with one console script, the shared Cloudflare
# Access and logging code (from mcp-server-shared, copied into each repo),
# an anyio pytest suite, and an Alpine deployment in deploy/alpine/ (run.sh,
# one or more OpenRC init scripts and env.example).  This eclass fetches the
# tagged release (or the git repository for live ebuilds), adds the
# dependencies every server has, and installs the OpenRC service with its
# paths pointed at /usr instead of the Alpine virtualenv in /opt.
#
# The service runs as its own user, MCP_SERVER_USER, from acct-user and
# acct-group packages of the same name.  Settings are where the upstream
# README puts them: /etc/${PN}/env for HTTP and Cloudflare Access, and the
# server's own config directory for devices.
#
# Usage:
# @CODE
# EAPI=8
#
# MCP_SERVER_USER=mcp-onkyo
# inherit mcp-server
#
# DESCRIPTION="MCP server for Onkyo AV receivers"
# KEYWORDS="~amd64"
#
# RDEPEND="dev-python/aiohttp[${PYTHON_USEDEP}]"
# mcp-server_add_deps
# @CODE

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ -z ${_MCP_SERVER_ECLASS} ]]; then
_MCP_SERVER_ECLASS=1

# @ECLASS_VARIABLE: MCP_SERVER_USER
# @PRE_INHERIT
# @REQUIRED
# @DESCRIPTION:
# The user and group the OpenRC service runs as; the same name the upstream
# deploy/alpine/install.sh creates (e.g. mcp-onkyo, mcp-mister).  The
# acct-user and acct-group packages of this name are added to the
# dependencies by mcp-server_add_deps.

# @ECLASS_VARIABLE: MCP_SERVER_SERVICES
# @PRE_INHERIT
# @DESCRIPTION:
# OpenRC services to install, by name: each is deploy/alpine/<name>.initd
# upstream and becomes /etc/init.d/<name>.  Defaults to ( ${PN} ).

[[ -n ${MCP_SERVER_USER} ]] || die "${ECLASS}: set MCP_SERVER_USER before inherit"
if [[ ${MCP_SERVER_SERVICES@a} != *a* ]]; then
	MCP_SERVER_SERVICES=( "${PN}" )
fi

# Upstream CI covers 3.11 to 3.14; ::gentoo no longer has 3.11.
if [[ ${PYTHON_COMPAT@a} != *a* ]]; then
	PYTHON_COMPAT=( python3_{12..14} )
fi
: "${DISTUTILS_USE_PEP517:=setuptools}"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SDNick484/${PN}.git"
else
	SRC_URI="https://github.com/SDNick484/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
fi

inherit distutils-r1

HOMEPAGE="https://github.com/SDNick484/${PN}"
LICENSE="MIT"
SLOT="0"

# @FUNCTION: mcp-server_add_deps
# @DESCRIPTION:
# Add the dependencies every server has to RDEPEND (the MCP SDK, the
# Cloudflare Access verifier and the HTTP transport) and the service's
# acct packages, then enable the pytest suite.  Call it in global scope
# after setting RDEPEND, like acct-user_add_deps: distutils_enable_tests
# copies RDEPEND into the test dependencies when it is called.
mcp-server_add_deps() {
	debug-print-function ${FUNCNAME} "$@"

	local acct="
		acct-group/${MCP_SERVER_USER}
		acct-user/${MCP_SERVER_USER}
	"
	RDEPEND+="
		${acct}
		>=dev-python/mcp-2.3[${PYTHON_USEDEP}]
		<dev-python/mcp-3[${PYTHON_USEDEP}]
		dev-python/cryptography[${PYTHON_USEDEP}]
		>=dev-python/pyjwt-2.10[${PYTHON_USEDEP}]
		>=dev-python/typing-extensions-4.7[${PYTHON_USEDEP}]
		>=dev-python/uvicorn-0.31[${PYTHON_USEDEP}]
	"
	# fowners in src_install looks the group up on the build host.
	DEPEND+=" ${acct}"
	# The tests drive the HTTP transport with httpx2. Only the logsafe
	# property tests use hypothesis (they skip without it).
	BDEPEND+="
		test? (
			dev-python/httpx2[${PYTHON_USEDEP}]
			dev-python/hypothesis[${PYTHON_USEDEP}]
		)
	"

	EPYTEST_PLUGINS=( anyio )
	distutils_enable_tests pytest

	_MCP_SERVER_ADD_DEPS_CALLED=1
}

# @FUNCTION: mcp-server_src_install
# @DESCRIPTION:
# Install the Python package, then the upstream OpenRC deployment:
# deploy/alpine/run.sh as /usr/libexec/${PN}/run.sh (it loads
# /etc/${PN}/env and execs the server), each MCP_SERVER_SERVICES init
# script, and env.example as /etc/${PN}/env.
mcp-server_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	[[ -n ${_MCP_SERVER_ADD_DEPS_CALLED} ]] ||
		die "${ECLASS}: mcp-server_add_deps was not called"

	distutils-r1_src_install
	[[ -f CHANGELOG.md ]] && dodoc CHANGELOG.md

	local deploy=deploy/alpine
	# The Alpine install uses a virtualenv in /opt/${PN}.
	local sed_args=(
		-e "s|/opt/${PN}/venv/bin/|${EPREFIX}/usr/bin/|g"
		-e "s|/opt/${PN}/run.sh|${EPREFIX}/usr/libexec/${PN}/run.sh|g"
	)

	sed "${sed_args[@]}" "${deploy}/run.sh" > "${T}/run.sh" || die
	exeinto "/usr/libexec/${PN}"
	doexe "${T}/run.sh"

	local svc
	mkdir -p "${T}/initd" || die
	for svc in "${MCP_SERVER_SERVICES[@]}"; do
		sed "${sed_args[@]}" "${deploy}/${svc}.initd" > "${T}/initd/${svc}" || die
		doinitd "${T}/initd/${svc}"
	done

	if grep -q "/opt/${PN}" "${T}/run.sh" "${T}"/initd/*; then
		eqawarn "${ECLASS}: upstream deploy files still mention /opt/${PN}"
	fi

	# Same ownership as upstream's install.sh: readable by the service only.
	insinto "/etc/${PN}"
	newins "${deploy}/env.example" env
	fowners "root:${MCP_SERVER_USER}" "/etc/${PN}" "/etc/${PN}/env"
	fperms 0750 "/etc/${PN}"
	fperms 0640 "/etc/${PN}/env"
}

# @FUNCTION: mcp-server_pkg_postinst
# @DESCRIPTION:
# Say how to run the server: stdio from an MCP client, or the service.
mcp-server_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	[[ -n ${REPLACING_VERSIONS} ]] && return

	elog "From an MCP client over stdio (Claude Code, Claude Desktop), run:"
	elog "    ${PN} serve"
	elog "Try '${PN} doctor' first; the README has the device configuration."
	elog
	elog "As a Streamable HTTP service (user ${MCP_SERVER_USER}), set it up in"
	elog "${EROOT}/etc/${PN}/env, then:"
	local svc
	for svc in "${MCP_SERVER_SERVICES[@]}"; do
		elog "    rc-update add ${svc} default && rc-service ${svc} start"
	done
	elog "A non-loopback bind needs Cloudflare Access (CF_ACCESS_* in the env file)."
}

fi

EXPORT_FUNCTIONS src_install pkg_postinst
