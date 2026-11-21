# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="Python implementation of ADB with shell and FileSync functionality"
HOMEPAGE="
	https://github.com/JeffLIrion/adb_shell
	https://pypi.org/project/adb-shell/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# aiofiles and async-timeout are the "async" extra (adb_device_async).
RDEPEND="
	dev-python/aiofiles[${PYTHON_USEDEP}]
	dev-python/async-timeout[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/pyasn1[${PYTHON_USEDEP}]
	dev-python/rsa[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/libusb1[${PYTHON_USEDEP}]
		dev-python/pycryptodome[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests unittest
