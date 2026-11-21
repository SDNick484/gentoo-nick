# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="Model Context Protocol message types, used by dev-python/mcp"
HOMEPAGE="
	https://modelcontextprotocol.io/
	https://github.com/modelcontextprotocol/python-sdk
	https://pypi.org/project/mcp-types/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
# The sdist has no tests; they are in the mcp sdist.

RDEPEND="
	>=dev-python/pydantic-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.13.0[${PYTHON_USEDEP}]
"
BDEPEND="dev-python/uv-dynamic-versioning[${PYTHON_USEDEP}]"

src_configure() {
	# The version comes from git tags; an sdist has none.
	export UV_DYNAMIC_VERSIONING_BYPASS=${PV}
	distutils-r1_src_configure
}
