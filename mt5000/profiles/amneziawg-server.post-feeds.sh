#!/bin/sh
# Ship the first-boot script that creates the server. The packages come from
# the amneziawg profile's feed, so that profile must be listed too.
set -eu
test -d feeds/amneziawg || {
	echo "::error::amneziawg-server needs the amneziawg profile"; exit 1; }
install -D -m 0755 "$(dirname "$0")/amneziawg-server.uci-defaults" \
	files/etc/uci-defaults/90-amneziawg-server
