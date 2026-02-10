#!/bin/bash

PASSWD_FILE="/etc/passwd"
SHADOW_FILE="/etc/shadow"
REPORT_FILE="audit_report"
ERROR_FILE="audit_error"

if [[ "$1" == '--help']]; then

	echo "This script performs a basic security audit by checking."
   echo "Total number of regular users (UID >= 1000)."
   echo "Critical file permissions (/etc/shadow and /etc/passwd)"
   echo "Potential security risks (Fake root accounts & empty passwords)"
	echo "Usage:sudo $0"
	exit 0;
fi

if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must run with root permissions (sudo)." 
   echo "Please try again: sudo $0"
   exit 1
fi

echo "=== SYSTEM SECURITY AUDIT REPORT ===" > "$REPORT_FILE"
date '+%Y-%m-%d %H:%M:%S' >> "$REPORT_FILE"
echo "-------------------------------------" >> "$REPORT_FILE"
if [ -f "$ERROR_FILE" ]; then rm "$ERROR_FILE"; fi

count=$(awk -F: '$3 >= 1000 && $3 < 60000' "$PASSWD_FILE" | wc -l)
echo "Info: There are $count regular users in the system." | tee -a "$REPORT_FILE"
echo "-------------------------------------" >> "$REPORT_FILE"

shadow_octal=$(stat -c %a "$SHADOW_FILE" 2>>"$ERROR_FILE")

if [[ "$shadow_octal" =~ ^(640|600|400|000)$ ]]; then
    echo "SUCCESS: Shadow Permission Safe ($shadow_octal)" | tee -a "$REPORT_FILE"
else
    shadow_human=$(stat -c %A "$SHADOW_FILE" 2>>"$ERROR_FILE")
    echo "WARNING: Shadow Permission RISKY! (Found: $shadow_octal, Human: $shadow_human)" | tee -a "$REPORT_FILE"
fi

passwd_octal=$(stat -c %a "$PASSWD_FILE" 2>>"$ERROR_FILE")

if [[ "$passwd_octal" == "644" ]]; then
    echo "SUCCESS: Passwd Permission Safe ($passwd_octal)" | tee -a "$REPORT_FILE"
else
    passwd_human=$(stat -c %A "$PASSWD_FILE" 2>>"$ERROR_FILE")
    echo "WARNING: Passwd Permission WRONG! (Found: $passwd_octal, Expected: 644)" | tee -a "$REPORT_FILE"
fi

echo "-------------------------------------" >> "$REPORT_FILE"

fake_roots=$(awk -F: '$3 == 0 && $1 != "root" {print $1}' "$PASSWD_FILE" 2>>"$ERROR_FILE")

if [ -z "$fake_roots" ]; then
    echo "SUCCESS: Fake Root Check: CLEAN." | tee -a "$REPORT_FILE"
else
    echo "CRITICAL: Fake Root Detected! Users: $fake_roots" | tee -a "$REPORT_FILE"
fi

empty_pass=$(awk -F: 'length($2) == 0 {print $1}' "$SHADOW_FILE" 2>>"$ERROR_FILE")

if [ -z "$empty_pass" ]; then
    echo "SUCCESS: Password Check: CLEAN." | tee -a "$REPORT_FILE"
else
    echo "CRITICAL: Empty Password Accounts Found! Users: $empty_pass" | tee -a "$REPORT_FILE"
fi

echo "-------------------------------------" >> "$REPORT_FILE"

if [ -s "$ERROR_FILE" ]; then
    echo "WARNING: Errors occurred during audit:"
    cat "$ERROR_FILE"
    echo "Check $REPORT_FILE for details."

    exit 1
else
    echo "SUCCESS: Audit completed successfully."
    rm -f "$ERROR_FILE"
    exit 0
fi
