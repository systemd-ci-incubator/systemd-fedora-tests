#!/bin/bash

set -eux
set -o pipefail

TEMPDIR="$(mktemp -d)"
pushd "$TEMPDIR"

trap "rm -fr '$TEMPDIR'" EXIT

dnf download --source systemd
dnf -y builddep systemd*.src.rpm
rpmbuild --build-in-place --clean --recompile systemd*.src.rpm
