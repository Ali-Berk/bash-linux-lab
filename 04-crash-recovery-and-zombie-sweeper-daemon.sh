#!/bin/bash
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "It continuously monitors processes and report zombie proccess if they are above 1000 try to kill processes and if services crash restart they"
    echo "Usage: sudo $0"
    exit 0
fi

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must run with root permissions (sudo)."
    echo "Please try again: sudo $0"
    exit 1
fi

if ! dpkg -s lsof > /dev/null 2>&1; then
    echo "ERROR: lsof package must have to run this script."
    echo "Before execute please try: sudo apt install lsof"
    exit 1
fi

touch /var/log/system_recovery.log
chmod 600 /var/log/system_recovery.log

while true; do
ps -eo ppid,stat | awk '$2 ~ /^Z/ {count++} END {if (count >= 1000) system("systemctl reboot"); else if (count > 0) print "WARNING: System has " count " zombie processes!"}' >> /var/log/system_recovery.log

systemctl list-units --state=failed | grep "\.service" | awk '{print $2}' | tee -a /var/log/system_recovery.log | xargs -r -I {} systemctl restart {} 2>>/var/log/system_recovery.log


sleep 10
done
