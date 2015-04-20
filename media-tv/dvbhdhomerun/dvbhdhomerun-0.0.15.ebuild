# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils linux-mod

DESCRIPTION="A linux DVB driver for the HDHomeRun"
HOMEPAGE="http://sourceforge.net/apps/trac/dvbhdhomerun/wiki"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="virtual/linux-sources
		sys-kernel/linux-headers
		media-libs/libhdhomerun"
RDEPEND=""

MODULE_NAMES="dvb_hdhomerun(dvb/hdhomerun:kernel) \
			dvb_hdhomerun_core(dvb/hdhomerun:kernel) \
			dvb_hdhomerun_fe(dvb/frontends:kernel)"
CMAKE_BUILD_DIR=${S}/userhdhomerun
CMAKE_USE_DIR=${S}/userhdhomerun

# TODO: check the proper kernel config options are enabled
# ie dvb_core and others?

pkg_setup() {
		linux-mod_pkg_setup
		BUILD_TARGETS="dvb_hdhomerun"
		BUILD_PARAMS="KERNEL_DIR=/usr/src/linux-${KV_FULL}"
}

src_prepare() {
		# fix path to hdhomerun.h
		sed -i "s:/usr/lib/libhdhomerun:/usr/include/libhdhomerun:" userhdhomerun/CMakeLists.txt || die "failed to sed"
		epatch "${FILESDIR}"/${PN}-userhdhomerun-hdhomerun_tuner.patch
		epatch "${FILESDIR}"/${PN}-kernel.patch
}

src_compile() {
		linux-mod_src_compile
		cmake-utils_src_compile
}

src_install() {
		insinto /etc
		doins "${S}"/etc/dvbhdhomerun

		insinto /lib/udev/rules.d
		doins "${FILESDIR}"/99-hdhomerun.rules

		#Init scripts
		newconfd "${FILESDIR}/${PN}.conf" "${PN}"
		newinitd "${FILESDIR}/${PN}.init" "${PN}"

		dodoc AUTHORS build.txt readme.txt

		linux-mod_src_install
		cmake-utils_src_install
}

pkg_postinst() {
		einfo "it is *highly* recommended to add"
		einfo "\"rc_need='dvbhdhomerun'\" to any"
		einfo "/etc/conf.d/* files which may depend"
		einfo "on dvbhdhomerun such as tvheadend, mythtv"
		einfo "etc"
}
