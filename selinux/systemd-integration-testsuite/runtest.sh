#!/bin/bash

. /usr/share/beakerlib/beakerlib.sh || exit 1

set -o pipefail

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm systemd dnf rpm-build
        rlRun "selinuxenabled" 0 "SELinux must be enabled"
        rlRun "setenforce 0" 0 "We need to run SELinux in the permissive mode"
        # Prepare a temporary working directory outside of /tmp (tmpfs), as we're going
        # to store a significant chunk of data there
        WORKDIR="$(mktemp -d /var/tmp/systemd-integration-tetsuite-XXX)"

        rlRun "pushd $WORKDIR"

        if ! rlGetPhaseState; then
            rlDie "Setup failed, can't continue"
        fi
    rlPhaseEnd

    rlPhaseStart "Example test 1"
        rlRun "systemd-run -r --unit hello.service -p Environment='HELLO=world' /bin/bash -c 'env | grep HELLO'"
        rlRun "sleep 1"
        rlRun "systemctl status hello.service"
        rlRun "journalctl -u hello.service"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
