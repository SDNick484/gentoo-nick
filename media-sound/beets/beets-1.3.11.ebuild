# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="sqlite"

inherit distutils-r1 eutils

MY_PV=${PV/_beta/-beta.}
MY_P=${PN}-${MY_PV}

DESCRIPTION="A media library management system for obsessive-compulsive music geeks"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
HOMEPAGE="http://beets.radbox.org/ http://pypi.python.org/pypi/beets"

KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="MIT"
IUSE_PLUGINS="beatport bpd chroma convert discogs echonest echonest_tempo fetchart lastgenre mpdstats replaygain web"
IUSE="doc test $IUSE_PLUGINS"

RDEPEND="
	dev-python/munkres[${PYTHON_USEDEP}]
	>=dev-python/python-musicbrainz-ngs-0.4[${PYTHON_USEDEP}]
	dev-python/unidecode[${PYTHON_USEDEP}]
	>=media-libs/mutagen-1.24[${PYTHON_USEDEP}]
        dev-python/enum34[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	doc? ( dev-python/sphinx )

	beatport? ( dev-python/requests[${PYTHON_USEDEP}] )
	bpd? ( dev-python/bluelet[${PYTHON_USEDEP}] dev-python/gst-python:0.10[${PYTHON_USEDEP}] )
	chroma? ( dev-python/pyacoustid[${PYTHON_USEDEP}] )
	convert? ( virtual/ffmpeg:0[encode] )
	discogs? ( >=dev-python/discogs-client-2[${PYTHON_USEDEP}] )
	echonest? ( dev-python/pyechonest[${PYTHON_USEDEP}] )
	echonest_tempo? ( dev-python/pyechonest[${PYTHON_USEDEP}] )
	fetchart? ( dev-python/requests[${PYTHON_USEDEP}] )
	mpdstats? ( dev-python/python-mpd[${PYTHON_USEDEP}] )
	lastgenre? ( dev-python/pylast[${PYTHON_USEDEP}] )
	replaygain? ( || ( ( dev-python/gst-python:1.0 media-libs/gst-plugins-good:1.0 ) media-sound/mp3gain media-sound/aacgain ) )
	web? ( dev-python/flask[${PYTHON_USEDEP}] )
"

# The bucket plugin depends on nose
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-python/nose[${PYTHON_USEDEP}] dev-python/responses[${PYTHON_USEDEP}] )"

S=${WORKDIR}/${MY_P}

PATCHES=( ) #"${FILESDIR}"/${P}-fix-mpdstats-plugin.patch )

src_prepare() {
	distutils-r1_python_prepare_all
	
	# remove plugins that do not have appropriate dependencies installed
	for flag in $IUSE_PLUGINS ; do 
		if ! use $flag ; then
			rm -r beetsplug/${flag}.py 2>/dev/null || \
			rm -r beetsplug/${flag}/ ||
				die "Unable to remove $flag plugin"
			[[ -e test/test_${flag}.py ]] && rm test/test_${flag}.py
		elif [[ ! -e "beetsplug/${flag}" && ! -e "beetsplug/${flag}.py" ]]; then
			ewarn "Plugin \"${flag}\" wasn't found in the $PN source. This is a bug, please report it."
		fi
	done

	for flag in bpd lastgenre web ; do
		if ! use $flag ; then
			sed -i "s:'beetsplug.$flag',::" setup.py || \
				die "Unable to disable $flag plugin"
		fi
	done

	use bpd || rm -f test/test_player.py
	use fetchart || rm -f test/test_art.py
}

python_compile_all() {
	use doc && emake -C docs html
}

python_test() {
	cd test
	"${PYTHON}" testall.py || die "Testsuite failed"
}

python_install_all() {
	doman man/beet.1 man/beetsconfig.5

	use doc && dohtml -r docs/_build/html/
}
