# gentoo-nick

Nick Andrade's personal Gentoo overlay (repo name `nick`).

## Use it

```
eselect repository add nick git https://github.com/SDNick484/gentoo-nick.git
emaint sync -r nick
```

Everything here is `~arch` or live. Accept keywords as needed, for example:

```
echo 'media-video/xrdome **' >> /etc/portage/package.accept_keywords/xrdome
echo 'sys-auth/howdy ~amd64' >> /etc/portage/package.accept_keywords/howdy
```

## Packages

| Package | Notes |
|---|---|
| `media-video/xrdome` | Live ebuild for [SDNick484/xrdome](https://github.com/SDNick484/xrdome). Same file as `packaging/gentoo/` upstream. |
| `sys-auth/howdy` | 3.0.0, pinned to an upstream commit. Needs the two packages below. |
| `sys-auth/howdy-models` | dlib face models for howdy. |
| `dev-python/elevate` | howdy dependency. |

`sys-auth/howdy`, `sys-auth/howdy-models` and `dev-python/elevate` come from
[kcning/gentoo-overlay](https://github.com/kcning/gentoo-overlay), copied unchanged
(original copyright headers kept). `howdy` also needs `>=sci-libs/dlib-19.24.3[python]`, which is in `::gentoo`.
