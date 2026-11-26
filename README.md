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
echo 'app-misc/melodious ~amd64' >> /etc/portage/package.accept_keywords/melodious
```

The MCP servers and their dependencies (see [MCP servers](#mcp-servers) below)
are `~amd64` too; the dependencies keyworded here are `dev-python/mcp`,
`mcp-types`, `sse-starlette`, `aioharmony`, `androidtvremote2`, `aiomqtt`,
`aiowebostv` and `adb-shell`, plus the `acct-user`/`acct-group` pairs:

```
cat >> /etc/portage/package.accept_keywords/mcp <<'EOF'
app-misc/mcp-server-* ~amd64
dev-python/mcp ~amd64
dev-python/mcp-types ~amd64
dev-python/sse-starlette ~amd64
dev-python/aioharmony ~amd64
dev-python/androidtvremote2 ~amd64
dev-python/aiomqtt ~amd64
dev-python/aiowebostv ~amd64
dev-python/adb-shell ~amd64
EOF
```

A few `::gentoo` dependencies are `~amd64` only too (`dev-python/pydantic`,
`zeroconf`, `paho-mqtt` at the time of writing); on a stable system, emerge
lists what else to accept.

## Packages

| Package | Notes |
|---|---|
| `media-video/xrdome` | Live ebuild for [SDNick484/xrdome](https://github.com/SDNick484/xrdome). Same file as `packaging/gentoo/` upstream. |
| `sys-auth/howdy` | 3.0.0, pinned to an upstream commit. Needs the two packages below. The global `gtk` flag adds the `howdy-gtk` GUI. |
| `sys-auth/howdy-models` | The three dlib face models howdy loads. |
| `dev-python/elevate` | `howdy-gtk` dependency. |
| `app-misc/mcp-server-*` | Nine [MCP servers](#mcp-servers): onkyo, shieldtv, harmony, sofabaton, webos, batocera, pixelcade, misterfpga, steam-backlog. |
| `dev-python/mcp`, `dev-python/mcp-types` | The MCP Python SDK 2.x (GURU has only 1.x). |
| `dev-python/sse-starlette`, `aioharmony`, `androidtvremote2`, `aiomqtt`, `aiowebostv`, `adb-shell` | MCP server dependencies missing from `::gentoo`. |
| `app-misc/go-hass-agent` | [Go Hass Agent](https://github.com/joshuar/go-hass-agent), the Home Assistant desktop agent, with an OpenRC user service instead of upstream's systemd unit. |
| `app-misc/melodious` | [Melodious](https://github.com/schlambos/harmony-hub-control) 2.5.0, local setup and control of Logitech Harmony Hubs: the desktop app on a prebuilt Electron (`gui`), the hub installer (`melodious-install`) and the root tool (`melodious-hub-root`). Part of it is `all-rights-reserved`, so it needs that licence accepted and is `bindist`-restricted. Same files as `packaging/gentoo/` upstream. |

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

## MCP servers

One package per `SDNick484/mcp-server-*` repository (`mcp-server-shared` is not
a package: each server carries a synced copy of it). Each has the tagged
release and a `-9999` live ebuild; `steam-backlog` has no tag yet, so it is
live only and needs `**`. The common code is in `eclass/mcp-server.eclass`.

| Package | Service user | Init scripts |
|---|---|---|
| `app-misc/mcp-server-onkyo` | `mcp-onkyo` | `mcp-server-onkyo` |
| `app-misc/mcp-server-shieldtv` | `mcp-shieldtv` | `mcp-server-shieldtv` |
| `app-misc/mcp-server-harmony` | `mcp-harmony` | `mcp-server-harmony` |
| `app-misc/mcp-server-sofabaton` | `mcp-sofabaton` | `mcp-server-sofabaton` |
| `app-misc/mcp-server-webos` | `mcp-webos` | `mcp-server-webos` |
| `app-misc/mcp-server-batocera` | `mcp-batocera` | `mcp-server-batocera` |
| `app-misc/mcp-server-pixelcade` | `mcp-pixelcade` | `mcp-server-pixelcade` |
| `app-misc/mcp-server-misterfpga` | `mcp-mister` | `mcp-server-misterfpga`, `mcp-server-misterfpga-track` |
| `app-misc/mcp-server-steam-backlog` | `mcp-steam-backlog` | `mcp-server-steam-backlog` |

For an MCP client on the same machine (Claude Code, Claude Desktop), nothing
else is needed: point the client at `mcp-server-<name> serve` (stdio).

As a service, each package installs the upstream Alpine deployment with its
paths moved from the `/opt` virtualenv to `/usr`:

- `/etc/init.d/mcp-server-<name>`: the upstream OpenRC script
  (`supervise-daemon`, `retry="SIGTERM/15/SIGKILL/5"`), run as the service user.
- `/usr/libexec/mcp-server-<name>/run.sh`: loads the env file and execs
  `mcp-server-<name> serve --http`.
- `/etc/mcp-server-<name>/env` (`root:<user>`, 0640, config-protected): bind
  address, port, path and Cloudflare Access, from upstream's `env.example`.
- State in `/var/lib/mcp-server-<name>`, logs in `/var/log/mcp-server-<name>`.
- `/usr/share/mcp-server-<name>/COMMIT`: the installed commit and repository,
  which `/healthz` reports on servers that have the feature (every `main`, so
  the `-9999` ebuilds, and releases tagged from it; the current tags predate
  it and ignore the file). `run.sh` points `MCP_COMMIT_FILE` at it unless the env file
  sets it. Live ebuilds stamp the commit they built; releases stamp the commit
  recorded in the tag tarball's header, so there is nothing to update per
  release.

```
vim /etc/mcp-server-onkyo/env
rc-update add mcp-server-onkyo default
rc-service mcp-server-onkyo start
```

`mcp-server-batocera` also installs the cabinet's play tracker in
`/usr/share/mcp-server-batocera/playtracker`, to copy to the Batocera machine.

The users and groups get dynamic IDs (`ACCT_USER_ID=-1`). To pin one, set e.g.
`ACCT_USER_MCP_ONKYO_ID=…` in `make.conf`.

Release tarballs are GitHub tag archives. To add a release after tagging
`vX.Y.Z` upstream, copy the previous ebuild to the new version and run
`ebuild <file> manifest`. If GURU is also enabled, its `dev-python/mcp` (1.x)
and `dev-python/adb-shell` overlap with this overlay's; the servers need
`>=dev-python/mcp-2.3`.
