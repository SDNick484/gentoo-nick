# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="Asyncio library for the Logitech Harmony Hub"
HOMEPAGE="
	https://github.com/Harmony-Libs/aioharmony
	https://pypi.org/project/aioharmony/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/aiohttp-3.11[${PYTHON_USEDEP}]
	>=dev-python/async-timeout-4[${PYTHON_USEDEP}]
	>=dev-python/slixmpp-1.10[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest

python_test() {
	# addopts asks for pytest-cov.
	epytest -o addopts=
}
