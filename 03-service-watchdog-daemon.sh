#!/bin/bash
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "It continuously monitors the specified services and restarts them if they crash."
    echo "Usage: sudo $0 [service1] [service2] ... [servicex]"
    exit 0
fi

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must run with root permissions (sudo)."
    echo "Please try again: sudo $0"
    exit 1
fi

SERVICES=("$@")
if [[ ${#SERVICES[@]} -eq 0 ]]; then
    echo "ERROR: No services specified."
    echo "Usage: sudo $0  [service1] [service2] ... [servicex]"
    exit 1
fi
while true
    do
    for service in ${SERVICES[@]}
        do
        if !(systemctl is-active --quiet $service); then
            time=$(date "+%Y-%m-%d %H:%M:%S")
            if systemctl restart  $service; then
                echo "[$time] [$service] CRASHED and RESTARTED successfully." >> watchdog.log
            else
                echo "[$time] [$service] CRASHED and FAILED to restart" >> watchdog.log
            fi
        fi
    done
    sleep 2
done
