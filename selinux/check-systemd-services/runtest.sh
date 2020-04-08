#!/bin/bash

. /usr/share/beakerlib/beakerlib.sh || exit 1

set -o pipefail

TEST="/systemd/selinux/check-systemd-services"
PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlLogInfo "Make sure SELinux is enabled and in permissive mode"
        rlRun "selinuxenabled" 0 "SELinux must be enabled"
        rlRun "setenforce 0" 0 "Switch SELinux to permissive mode"
        rlRun "getenforce | grep -i permissive" 0 "SELinux should be in the permissive mode"
        rlRun "sestatus"

        if ! rlGetPhaseState; then
            rlDie "Setup failed, can't continue"
        fi
    rlPhaseEnd

    SERVICES=(
        systemd-homed
        systemd-hostnamed
        systemd-journald
        systemd-logind
        systemd-machined
        systemd-random-seed
        systemd-sysctl
        systemd-timesyncd
        systemd-userdbd
    )

    for svc in "${SERVICES[@]}"; do
        rlPhaseStartTest "Check $svc.service for AVCs"
            TIMESTAMP="$(date +"%x %T")"
            # The timestamp is unquoted intentionally, as the -ts parameter expects
            # the argument in two parts (-ts <date> <time>)
            rlRun "systemctl restart $svc.service"
            rlRun "sleep 5"
            rlRun "systemctl --no-pager status $svc.service"
            # ausearch returns 1 when no matches were found
            rlRun -s "ausearch -m avc -ts $TIMESTAMP" 1
            rlRun "rm -f $rlRun_LOG"
        rlPhaseEnd
    done

    rlJournalPrintText
rlJournalEnd
