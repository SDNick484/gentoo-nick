# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="Library to interact with the Android TV Remote protocol v2"
HOMEPAGE="
	https://github.com/tronikos/androidtvremote2
	https://pypi.org/project/androidtvremote2/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/aiofiles-0.8[${PYTHON_USEDEP}]
	>=dev-python/cryptography-3[${PYTHON_USEDEP}]
	>=dev-python/protobuf-4.21[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( pytest-asyncio )
distutils_enable_tests pytest
