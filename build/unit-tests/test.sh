#!/bin/bash

set -eux
set -o pipefail

TEMPDIR="$(mktemp -d)"
pushd "$TEMPDIR"

trap "rm -fr '$TEMPDIR'" EXIT

dnf download --source systemd
rpmbuild --build-in-place --clean --recompile systemd*.src.rpm
