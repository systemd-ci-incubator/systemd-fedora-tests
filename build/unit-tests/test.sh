#!/bin/bash

set -eux
set -o pipefail

TEMPDIR="$(mktemp -d)"
pushd "$TEMPDIR"

trap "rm -fr '$TEMPDIR'" EXIT

dnf download --source "$(rpm -q systemd)"
dnf -y builddep systemd*.src.rpm
dnf -y install gnu-efi-devel
rpmbuild --clean --recompile systemd*.src.rpm
