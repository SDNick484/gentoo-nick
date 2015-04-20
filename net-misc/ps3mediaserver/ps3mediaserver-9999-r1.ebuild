# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit subversion java-pkg-2 java-ant-2

DESCRIPTION="DLNA compliant UPNP server for streaming media to Playstation 3"
HOMEPAGE="http://code.google.com/p/ps3mediaserver"
SRC_URI="http://www.smlabs.net/tsMuxer/tsMuxeR_1.10.6.tar.gz"

ESVN_REPO_URI="http://ps3mediaserver.googlecode.com/svn/trunk/"
ESVN_PROJECT="ps3mediaserver"
EANT_BUILD_TARGET="PMS"

SLOT="0"
KEYWORDS=""
IUSE="transcode non-free"

LICENSE="GPL-2"

RDEPEND=">=virtual/jre-1.6
		transcode? ( media-video/mplayer[encode] )
	media-libs/libmediainfo"
DEPEND="${RDEPEND}
	>=virtual/jdk-1.6"

src_unpack(){
	subversion_src_unpack
	unpack "${A}"
	# Upgrade tsMuxeR
	cp "${S}/tsMuxeR" "${S}/ps3mediaserver/linux/tsMuxeR"
	cp "${S}/licence.txt" "${S}/ps3mediaserver/linux/tsMuxeR_license.txt"
	cd "${S}"
}

src_compile() {
	cd "${S}/ps3mediaserver"
        local mem
        use amd64 && mem="256"
        use x86   && mem="192"
        use ppc   && mem="192"
        use ppc64 && mem="256"
        export ANT_OPTS="-Xmx${mem}m"
        java-pkg-2_src_compile

}

src_install(){
	cd "${S}/ps3mediaserver"
	einfo "Installing ${PN}"
	sed 's/DIRNAME=`dirname $0`/DIRNAME=\/usr\/share\/pms/g' < PMS.sh > pms.old
	echo "#/bin/bash" > pms
	echo "" >> pms
	echo "if [ -d \$HOME/.ps3mediaserver ]; then" >> pms
	echo "cd \$HOME/.ps3mediaserver" >> pms
	echo "else" >> pms
	echo "mkdir \$HOME/.ps3mediaserver" >> pms
	echo "cd \$HOME/.ps3mediaserver" >> pms
	echo "fi" >> pms
	echo "if [ ! -e \$HOME/.ps3mediaserver/WEB.conf ]; then" >> pms
	echo "cp /usr/share/pms/WEB.conf \$HOME/.ps3mediaserver" >> pms
	echo "fi" >> pms
	echo "if [ ! -d \$HOME/.ps3mediaserver/linux ]; then" >> pms
	echo "cp -R /usr/share/pms/linux \$HOME/.ps3mediaserver" >> pms
	echo "chmod +x \$HOME/.ps3mediaserver/linux/tsMuxeR" >> pms
	echo "fi" >> pms
	cat pms.old >> pms
	dobin pms
	dodoc CHANGELOG FAQ README
	if ! use non-free ; then
		einfo "Removing tsMuxeR"
		rm linux/tsMuxeR linux/tsMuxeR_licence.txt
	fi
	mkdir ${D}usr/share/pms
	cp -R linux pms.jar WEB.conf ${D}usr/share/pms
}

pkg_postinst(){
	if ! use non-free ; then
		ewarn
		ewarn "tsMuxeR has been removed from install due to to its licensing."
		ewarn "If you require it then rebuild with the 'non-free' use flag."
		ewarn "Also be sure to disable it in your transcoding settings"
		ewarn
	fi
	ewarn
	ewarn "Don't forget to disable transcoding engines for software"
	ewarn "that you don't have installed (such as having the VLC"
	ewarn "transcoding engine enabled when you only have mencoder)."
	ewarn
}
