#!/bin/sh
#
# This script is supposed to run inside the Debian Testing Docker container
# on the CI system.
#
set -e
export LANG=C.UTF-8

echo "D compiler: $DC"
set -v
$DC --version

#
# Build & Test
#
dub test -b unittest-cov
