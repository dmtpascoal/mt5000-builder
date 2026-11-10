#!/bin/sh
# Build the latest AmneziaWG releases: move each package to its repository's
# newest release tag, pinned to the commit behind that tag so a moved tag
# cannot change what gets built.
set -eu
latest() { # makefile repo-url
	tag=$(git ls-remote --tags --refs "$2" 'v*' |
		sed 's|.*refs/tags/||' | sort -V | tail -1)
	test -n "$tag"
	commit=$(git ls-remote "$2" "refs/tags/$tag^{}" | cut -f1)
	[ -n "$commit" ] || commit=$(git ls-remote "$2" "refs/tags/$tag" | cut -f1)
	sed -e "s|^PKG_VERSION:=.*|PKG_VERSION:=${tag#v}|" \
		-e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=$commit|" "$1" > "$1.new"
	mv "$1.new" "$1"
	grep -qx "PKG_SOURCE_VERSION:=$commit" "$1"
	echo "$(basename "$(dirname "$1")"): $tag ($commit)"
}
latest feeds/amneziawg/kmod-amneziawg/Makefile \
	https://github.com/amnezia-vpn/amneziawg-linux-kernel-module.git
latest feeds/amneziawg/amneziawg-tools/Makefile \
	https://github.com/amnezia-vpn/amneziawg-tools.git
