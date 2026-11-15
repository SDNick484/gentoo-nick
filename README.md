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
```

## Packages

| Package | Notes |
|---|---|
| `media-video/xrdome` | Live ebuild for [SDNick484/xrdome](https://github.com/SDNick484/xrdome). Same file as `packaging/gentoo/` upstream. |
| `sys-auth/howdy` | 3.0.0, pinned to an upstream commit. Needs the two packages below. The global `gtk` flag adds the `howdy-gtk` GUI. |
| `sys-auth/howdy-models` | The three dlib face models howdy loads. |
| `dev-python/elevate` | `howdy-gtk` dependency. |

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

`media-libs/opencv-4.14.0` caps `media-video/ffmpeg` below 9 when `USE=ffmpeg`
(Gentoo bug 980612). howdy reads the camera through OpenCV's V4L backend, so
`media-libs/opencv -ffmpeg` in `package.use` works around it until that is fixed.
