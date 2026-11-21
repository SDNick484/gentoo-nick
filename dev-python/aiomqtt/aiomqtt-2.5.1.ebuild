# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )
inherit distutils-r1 pypi

DESCRIPTION="The idiomatic asyncio MQTT client, wrapped around paho-mqtt"
HOMEPAGE="
	https://github.com/empicano/aiomqtt
	https://pypi.org/project/aiomqtt/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/paho-mqtt-2.1.0[${PYTHON_USEDEP}]
	<dev-python/paho-mqtt-3[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( anyio )
distutils_enable_tests pytest

python_test() {
	# Tests marked "network" talk to test.mosquitto.org.
	epytest -m "not network"
}
