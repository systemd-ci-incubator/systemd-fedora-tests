#!/bin/bash

. /usr/share/beakerlib/beakerlib.sh || exit 1

set -o pipefail

TEST="/systemd/selinux/after-boot"
PACKAGE="systemd"

rlJournalStart

if [[ $REBOOTCOUNT -eq 0 ]]; then
    # First boot, do an initial setup
    rlPhaseStartSetup
        for package in systemd dnf rpm-build grubby; do
            rlAssertRpm $package
        done

        rlGetPhaseState || rlDie "Missing test dependencies"

        rlLogInfo "Make sure SELinux is enabled on the next boot in permissive mode"
        rlRun "grubby --args 'selinux=1 enforcing=0' --update-kernel=ALL"
        rlRun "grep -r 'selinux=1 enforcing=0' /boot"

        if ! rlGetPhaseState; then
            rlDie "Setup failed, can't continue"
        fi
    rlPhaseEnd

    rhts-reboot

elif [[ $REBOOTCOUNT -eq 1 ]]; then
    # Second boot, check the SELinux configuration and check for systemd-related AVCs
    rlPhaseStartTest "Check SELinux configuration"
        rlRun "selinuxenabled" 0 "SELinux must be enabled"
        rlRun "getenforce | grep -i permissive" 0 "SELinux should be in the permissive mode"
        rlRun "sestatus"
    rlPhaseEnd

    rlPhaseStartTest "Check for PID 1 AVCs since boot"
        rlRun -s "ausearch -m avc -ts boot -p 1"
        rlRun "test ! -s $rlRun_LOG" 0 "The ausearch query should return no results"
    rlPhaseEnd

    rlPhaseStartCleanup
        # TODO: possibly revert the grubby change & reboot
        true
    rlPhaseEnd

    rlJournalPrintText
fi

rlJournalEnd
