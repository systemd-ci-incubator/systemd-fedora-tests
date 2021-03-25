#!/bin/bash

set -eux
set -o pipefail

if ! rpm -q systemd-tests; then
    echo >&2 "Missing package 'systemd-tests'"
    exit 1
fi

/usr/lib/systemd/tests/run-unit-tests.py --unsafe

## This currently takes ages, so let's put it aside for now
#TEMPDIR="$(mktemp -d)"
#pushd "$TEMPDIR"
#
#trap "rm -fr '$TEMPDIR'" EXIT
#
#dnf download --source "$(rpm -q systemd)"
#dnf -y builddep systemd*.src.rpm
#dnf -y install gnu-efi-devel
#rpmbuild --clean --recompile systemd*.src.rpm
