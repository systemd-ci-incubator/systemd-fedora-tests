#!/bin/bash

set -ex
set -o pipefail

# Ensure we have the necessary tooling
rpm -q dnf rpm-build

# Ensure SELinux is enabled and switch it to the permissive mode, so we can
# collect all issues at once
if ! selinuxenabled || ! setenforce 0; then
    echo >&2 "This test requires enabled SELinux, can't continue..."
    exit 1
fi

# Prepare a temporary working directory outside of /tmp (tmpfs), as we're going
# to store a significant chunk of data there
WORKDIR="$(mktemp -d /var/tmp/systemd-integration-tetsuite-XXX)"
# Ensure cleanup of the workdir on script exit
trap "cd / && rm -fr $WORKDIR" EXIT PIPE INT

pushd "$WORKDIR"

# Install systemd build dependencies
dnf builddep -y systemd
# Download systemd SRPM
dnf download --source systemd
# Make the CWD our rpmbuild root and unpack the SRPM there
rpm --define "_topdir $PWD" -i systemd-*.src.rpm
# Unpack the source tarball and apply all patches (if any)
rpmbuild -bp SPECS/systemd.spec

# TBD
