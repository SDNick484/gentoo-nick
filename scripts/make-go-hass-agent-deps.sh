#!/bin/bash
# Build the deps tarball for app-misc/go-hass-agent:
#   go-mod/       Go module cache (GOMODCACHE layout expected by go-module.eclass)
#   web-assets/   npm-built scripts.js and styles.css for web/content/
# and print the dependency licenses for the ebuild's LICENSE line.
#
# Needs network, dev-lang/go >= 1.27.3, net-libs/nodejs (npm), and
# optionally dev-go/go-licenses.
#
# Usage: make-go-hass-agent-deps.sh 14.19.0
set -euo pipefail

pv=${1:?usage: $0 <version>}
p=go-hass-agent-${pv}
work=$(mktemp -d)
trap 'rm -rf "${work}"' EXIT

curl -fsSL "https://github.com/joshuar/go-hass-agent/archive/v${pv}.tar.gz" \
	| tar -xz -C "${work}"
src=${work}/${p}

export GOMODCACHE=${work}/go-mod GOTOOLCHAIN=local GOFLAGS=-modcacherw
( cd "${src}" && go mod download )
find "${GOMODCACHE}/cache/download" -type f -name '*.zip' -delete

( cd "${src}" && npm clean-install && npm run build:js && npm run build:css )
mkdir "${work}/web-assets"
cp "${src}"/web/content/scripts.js "${src}"/web/content/styles.css "${work}/web-assets/"

XZ_OPT='-T0 -9' tar --owner 0 --group 0 --posix -C "${work}" \
	-acf "${PWD}/${p}-deps.tar.xz" go-mod web-assets
echo "Wrote ${PWD}/${p}-deps.tar.xz"

if command -v go-licenses >/dev/null; then
	echo "Dependency licenses:"
	( cd "${src}" && go-licenses report . 2>/dev/null ) | awk -F, '{print $3}' | sort -u
else
	echo "Install dev-go/go-licenses to list dependency licenses."
fi
