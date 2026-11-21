# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="Server-Sent Events for Starlette and FastAPI"
HOMEPAGE="
	https://github.com/sysid/sse-starlette
	https://pypi.org/project/sse-starlette/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/anyio-4.7.0[${PYTHON_USEDEP}]
	>=dev-python/starlette-0.49.1[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/httpx[${PYTHON_USEDEP}]
		dev-python/uvicorn[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( anyio pytest-asyncio )
distutils_enable_tests pytest

# Both import tests/anyio_compat.py, which the sdist doesn't ship.
EPYTEST_IGNORE=(
	tests/test_issue167.py
	tests/test_sse.py
)
