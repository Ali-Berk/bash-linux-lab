#!/bin/bash

if [[ "$1" == '--help' || "$1" == '-h' || "$1" == '' || ! "$1" =~ ^[0-9]+$ ]]; then

   echo "This script compare a disk usage with threshold you pick."
   echo "Usage: $0 int:threshold"
	exit 0;
fi

df -P | awk -v threshold="$1"  '/^\/dev\// {if (int($5) >= threshold) print strftime("[%Y-%m %H:%M:%S]"), "WARNING: Filesystem " $1 " mounted on " $6 " has reached critical usage: " $5 " threshold: " threshold}' >>disk-space.log

