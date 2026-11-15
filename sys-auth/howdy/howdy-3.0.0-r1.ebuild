# Copyright 2025-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit meson pam python-single-r1

DESCRIPTION="Windows Hello style facial authentication for Linux"
HOMEPAGE="https://github.com/boltgolt/howdy"

EGIT_COMMIT="d3ab99382f88f043d15f15c1450ab69433892a1c"
SRC_URI="https://github.com/boltgolt/howdy/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${EGIT_COMMIT}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# gtk3 and qt6 pick the opencv highgui backend used by "howdy test".
IUSE="+gtk3 qt6"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	|| ( gtk3 qt6 )
"

PATCHES=(
	"${FILESDIR}/${P}-fix-dlib-data.patch"
	# howdy-gtk ignored -Dpython_path and baked the build-time python
	# wrapper from ${T} into /usr/bin/howdy-gtk.
	"${FILESDIR}/${P}-gtk-python-path.patch"
)

# The PAM module (C++) links these.
DEPEND="
	dev-libs/inih
	dev-libs/libevdev
	sys-libs/pam
"
# NOTE: dlib version < 19.24.3 does not work with numpy 2.0
# elevate and pygobject are only used by howdy-gtk.
RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		>=dev-python/numpy-2.0.0[${PYTHON_USEDEP}]
		dev-python/python-pam[${PYTHON_USEDEP}]
		>=sci-libs/dlib-19.24.3[python,${PYTHON_USEDEP}]
		gtk3? (
			dev-python/elevate[${PYTHON_USEDEP}]
			dev-python/pygobject:3[${PYTHON_USEDEP}]
			media-libs/opencv[gtk3,png,python,v4l,${PYTHON_USEDEP}]
		)
		qt6? (
			media-libs/opencv[qt6,png,python,v4l,${PYTHON_USEDEP}]
		)
	')
	gtk3? ( x11-libs/gtk+:3[introspection] )
	sys-auth/howdy-models
"
BDEPEND="
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	default
	rm "${S}"/README.md || die

	# Upstream skips config.ini when the build host already has one, which
	# makes the image depend on the host. Always install it; CONFIG_PROTECT
	# keeps local edits.
	sed -i "s/^if not fs.exists(config_path)$/if true/" \
		"${S}"/howdy/src/meson.build || die

	if ! use gtk3; then
		sed -i "s/^subdir('howdy-gtk')/#&/" "${S}"/meson.build || die
	fi
}

src_configure() {
	local emesonargs=(
		# Upstream defaults to ${libdir}/security, which libpam does not
		# search on split-usr systems.
		-Dpam_dir="$(getpam_mod_dir)"
		-Dpython_path="${PYTHON}"
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	python_optimize "${ED}"/usr/$(get_libdir)/howdy
	if use gtk3; then
		python_optimize "${ED}"/usr/$(get_libdir)/howdy-gtk
	fi
}
