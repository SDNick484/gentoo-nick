# Copyright 2026 Nick Andrade
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop go-module optfeature xdg

DESCRIPTION="Home Assistant native app for desktop/laptop devices"
HOMEPAGE="https://github.com/joshuar/go-hass-agent"
SRC_URI="
	https://github.com/joshuar/go-hass-agent/archive/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/SDNick484/gentoo-nick/releases/download/${P}/${P}-deps.tar.xz
"

LICENSE="MIT"
# Dependent licenses: regenerate with dev-go/go-licenses when bumping
# (see scripts/make-go-hass-agent-deps.sh in this overlay).
LICENSE+=" Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="sys-apps/dbus"
BDEPEND=">=dev-lang/go-1.27.3:="

DOCS=( README.md CHANGELOG.md BREAKING_CHANGES.md )

src_prepare() {
	default

	# The web UI's bundled JS/CSS are built upstream with npm (esbuild +
	# tailwindcss). They are pre-built into the deps tarball so the build
	# needs no network access. Templ output (*_templ.go) is committed upstream.
	cp "${WORKDIR}"/web-assets/* web/content/ || die "missing pre-built web assets"
}

src_compile() {
	ego build \
		-ldflags "-X github.com/joshuar/go-hass-agent/config.AppVersion=v${PV}" \
		-o go-hass-agent .
}

src_test() {
	# Many tests probe D-Bus, /sys and the running session; keep to the
	# packages that are hermetic.
	ego test ./config/... ./models/... ./validation/...
}

src_install() {
	dobin go-hass-agent
	einstalldocs

	doicon web/content/go-hass-agent.png
	domenu assets/start-go-hass-agent.desktop
	insinto /usr/share/metainfo
	doins assets/dev.pages.joshuarich.go-hass-agent.metainfo.xml

	# OpenRC user service (OpenRC >= 0.60). Replaces upstream's systemd
	# user unit, which is deliberately not installed.
	exeinto /etc/user/init.d
	newexe "${FILESDIR}"/go-hass-agent.user.initd go-hass-agent
	insinto /etc/user/conf.d
	newins "${FILESDIR}"/go-hass-agent.user.confd go-hass-agent
}

pkg_postinst() {
	xdg_pkg_postinst

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Register the agent once, as your own user:"
		elog "  go-hass-agent register --server https://<your-ha-url> --token <long-lived-token>"
		elog "(or start it and use the web UI at http://localhost:8223)."
		elog
		elog "Start it with your desktop session, either:"
		elog "  * OpenRC user service:  rc-update --user add go-hass-agent default"
		elog "    (needs your session D-Bus at \$XDG_RUNTIME_DIR/bus, e.g. the"
		elog "    dbus user service; override DBUS_SESSION_BUS_ADDRESS in"
		elog "    ~/.config/rc/conf.d/go-hass-agent otherwise), or"
		elog "  * XDG autostart:  cp /usr/share/applications/start-go-hass-agent.desktop \\"
		elog "      ~/.config/autostart/   (inherits the session's D-Bus; simplest on MATE/Xorg)"
		elog
		elog "Upstream's postinstall grants file capabilities for user-activity and"
		elog "SMART sensors. They are NOT applied here: cap_sys_admin and"
		elog "cap_dac_override on a user-run, network-facing binary are root-equivalent."
		elog "Opt in yourself only if you need those sensors:"
		elog "  setcap 'cap_setgid,cap_setuid,cap_sys_rawio,cap_sys_admin,cap_mknod,cap_dac_override=+ep' /usr/bin/go-hass-agent"
	fi

	optfeature "session, screen lock and power sensors/controls" sys-auth/elogind sys-apps/systemd
	optfeature "battery sensors" sys-power/upower
	optfeature "location sensor" app-misc/geoclue
	optfeature "firmware security sensor" sys-apps/fwupd
	optfeature "running apps and desktop settings sensors" sys-apps/xdg-desktop-portal
	optfeature "audio volume, mute and microphone sensors" media-video/pipewire
	optfeature "external monitor brightness control" app-misc/ddcutil
	optfeature "webcam control" media-video/ffmpeg
	optfeature "chrony time sync sensors" net-misc/chrony
	optfeature "NVIDIA GPU sensors" x11-drivers/nvidia-drivers
	optfeature "setting file capabilities manually" sys-libs/libcap
}
