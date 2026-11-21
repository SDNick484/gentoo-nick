# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="Asyncio library to control LG webOS TVs"
HOMEPAGE="
	https://github.com/home-assistant-libs/aiowebostv
	https://pypi.org/project/aiowebostv/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
# The sdist has no tests.

RDEPEND=">=dev-python/aiohttp-3.11[${PYTHON_USEDEP}]"
