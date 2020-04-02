#!/bin/bash

. /usr/share/beakerlib/beakerlib.sh || exit 1

set -o pipefail

TEST="TESTNAME-TBD"
PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        for package in systemd dnf rpm-build; do
            rlAssertRpm $package
        done

        rlRun "selinuxenabled" 0 "SELinux must be enabled"
        rlRun "setenforce 0" 0 "We need to run SELinux in the permissive mode"
        rlRun "sestatus"
        # Prepare a temporary working directory outside of /tmp (tmpfs), as we're going
        # to store a significant chunk of data there
        WORKDIR="$(mktemp -d /var/tmp/systemd-integration-tetsuite-XXX)"

        rlRun "pushd $WORKDIR"

        if ! rlGetPhaseState; then
            rlDie "Setup failed, can't continue"
        fi
    rlPhaseEnd

    rlPhaseStartTest "Example test 1"
        rlRun "systemd-run -r --unit hello.service -p Environment='HELLO=world' /bin/bash -c 'env | grep HELLO'"
        rlRun "sleep 1"
        rlRun "systemctl status hello.service"
        rlRun "journalctl -u hello.service"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -fr $WORKDIR"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
