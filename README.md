# gentoo-nick

Nick Andrade's personal Gentoo overlay (repo name `nick`).

## Use it

As root, with `app-eselect/eselect-repository` installed:

```
eselect repository add nick git https://github.com/SDNick484/gentoo-nick.git
emaint sync -r nick
```

Everything here is `~arch` or live. Accept keywords as needed (as root, with
`/etc/portage/package.accept_keywords` as a directory). `xrdome` is a live
ebuild with no keywords, so it needs `**`; `~amd64` is not enough. `howdy`
pulls in `howdy-models` and `elevate`, which are `~amd64` too:

```
echo 'media-video/xrdome **' >> /etc/portage/package.accept_keywords/xrdome
echo 'sys-auth/howdy ~amd64' >> /etc/portage/package.accept_keywords/howdy
echo 'sys-auth/howdy-models ~amd64' >> /etc/portage/package.accept_keywords/howdy
echo 'dev-python/elevate ~amd64' >> /etc/portage/package.accept_keywords/howdy
echo 'app-misc/go-hass-agent ~amd64' >> /etc/portage/package.accept_keywords/go-hass-agent
```

## Packages

| Package | Notes |
|---|---|
| `media-video/xrdome` | Live ebuild for [SDNick484/xrdome](https://github.com/SDNick484/xrdome). Same file as `packaging/gentoo/` upstream. |
| `sys-auth/howdy` | 3.0.0, pinned to an upstream commit. Needs the two packages below. The global `gtk` flag adds the `howdy-gtk` GUI. |
| `sys-auth/howdy-models` | The three dlib face models howdy loads. |
| `dev-python/elevate` | `howdy-gtk` dependency. |
| `app-misc/go-hass-agent` | [Go Hass Agent](https://github.com/joshuar/go-hass-agent), the Home Assistant desktop agent, with an OpenRC user service instead of upstream's systemd unit. |

`sys-auth/howdy`, `sys-auth/howdy-models` and `dev-python/elevate` started from
[kcning/gentoo-overlay](https://github.com/kcning/gentoo-overlay); the original
copyright headers are kept, but all three have been changed here:

- `howdy` is `3.0.0-r1`: it installs the PAM module to `/$(get_libdir)/security`,
  always installs `config.ini`, declares the PAM module's build deps, uses
  `python-single-r1`, and uses the global `gtk` flag instead of `gtk3`/`qt6`
  (opencv may have either highgui backend). With `gtk` it also installs the polkit
  action `howdy-gtk` needs to open its window through `pkexec`.
- `howdy-models` downloads only the three models howdy uses (~28 MB) instead of
  the whole `dlib-models` tag (~200 MB). The installed files are the same.
- `elevate` adds Python 3.15.

`howdy` also needs `>=sci-libs/dlib-19.24.3[python]`, which is in `::gentoo`.

The howdy ebuild does not touch `/etc/pam.d`; enabling it for login is up to you.

howdy opens the camera with `cv2.VideoCapture`, and `media-libs/opencv` only
builds that (its `videoio` module) with `USE=ffmpeg` or `USE=gstreamer`; `v4l`
alone is not enough. `opencv-4.14.0` caps `media-video/ffmpeg` below 9 when
`USE=ffmpeg` (Gentoo bug 980612), so with ffmpeg 9 installed use gstreamer:

```
echo 'media-libs/opencv python gstreamer -ffmpeg' >> /etc/portage/package.use/howdy
```

## go-hass-agent

Go ebuilds can't download modules at build time, and upstream builds its web UI
with npm. Both are bundled into `go-hass-agent-<ver>-deps.tar.xz`, a release
asset on this repo. To build it for a new version (needs network, Go, and npm):

```
scripts/make-go-hass-agent-deps.sh 14.19.0
gh release create go-hass-agent-14.19.0 go-hass-agent-14.19.0-deps.tar.xz
ebuild app-misc/go-hass-agent/go-hass-agent-14.19.0.ebuild manifest
```

The script also prints the dependency licenses (with `dev-go/go-licenses`
installed) for the ebuild's `LICENSE` line.

Start the agent with `rc-update --user add go-hass-agent default` (OpenRC 0.60+
user services), or copy `start-go-hass-agent.desktop` into `~/.config/autostart`
if your session bus isn't the dbus user service. Upstream's file capabilities are
not applied; the post-install message has the `setcap` line if you want them.
