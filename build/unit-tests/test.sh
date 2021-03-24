#!/bin/sh

set -eu
set -o pipefail

if ! rpm -q systemd-tests; then
    echo >&2 "Package 'systemd-tests' is not installed"
    exit 1
fi

/usr/lib/systemd/tests/run-unit-tests.py -u
