# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 optfeature pypi

DESCRIPTION="Model Context Protocol SDK"
HOMEPAGE="
	https://modelcontextprotocol.io/
	https://github.com/modelcontextprotocol/python-sdk
	https://pypi.org/project/mcp/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
# The suite needs pytest-examples, inline-snapshot, logfire, strict-no-cover
# and mcp-example-stories, which ::gentoo doesn't have. The mcp-server-*
# packages' own suites exercise the client, server and transports.
RESTRICT="test"

# mcp-types is released in lockstep: the dependency is ==${PV}.
# pyjwt[crypto] is cryptography.
RDEPEND="
	>=dev-python/anyio-4.10[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	>=dev-python/httpx2-2.10.0[${PYTHON_USEDEP}]
	>=dev-python/jsonschema-4.20.0[${PYTHON_USEDEP}]
	~dev-python/mcp-types-${PV}[${PYTHON_USEDEP}]
	>=dev-python/opentelemetry-api-1.28.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.10.1[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.9[${PYTHON_USEDEP}]
	>=dev-python/sse-starlette-3.0.0[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.48.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
	>=dev-python/typing-inspection-0.4.1[${PYTHON_USEDEP}]
	>=dev-python/uvicorn-0.31.1[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/uv-dynamic-versioning[${PYTHON_USEDEP}]"

src_configure() {
	# The version (and the mcp-types==version dependency it templates) comes
	# from git tags; an sdist has none.
	export UV_DYNAMIC_VERSIONING_BYPASS=${PV}
	distutils-r1_src_configure
}

pkg_postinst() {
	optfeature "the mcp command line tool" "dev-python/typer dev-python/python-dotenv"
	optfeature "colorized log output" dev-python/rich
}
