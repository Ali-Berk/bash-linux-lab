#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must run with root permissions (sudo)."
    echo "Please try again: sudo $0"
    exit 1
fi

ALPINE_VER="3.23.3"
ROOTFS_DIR="./alpine-container"
TAR_URL="https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-minirootfs-3.23.3-x86_64.tar.gz"

if [ ! -x "$ROOTFS_DIR/bin/sh" ]; then
    mkdir -p "$ROOTFS_DIR"
    wget -qO alpine.tar.gz "$TAR_URL"
    tar -xzf alpine.tar.gz -C "$ROOTFS_DIR"
    rm -f alpine.tar.gz
fi
mount -t proc proc "$ROOTFS_DIR/proc"
mount -t sysfs sys "$ROOTFS_DIR/sys"
mount -o bind /dev "$ROOTFS_DIR/dev"

CGROUP_PATH="/sys/fs/cgroup/alpine-container"
echo "+cpu" > /sys/fs/cgroup/cgroup.subtree_control 2>/dev/null

mkdir -p "$CGROUP_PATH"
echo "52428800" > "$CGROUP_PATH/memory.max"
echo "50000 100000" > "$CGROUP_PATH/cpu.max"
echo $$ > "$CGROUP_PATH/cgroup.procs"

echo "Type 'exit' to exit."
unshare --pid --fork --mount-proc="$ROOTFS_DIR/proc" chroot "$ROOTFS_DIR" /bin/sh

umount "$ROOTFS_DIR/proc" 2>/dev/null
umount "$ROOTFS_DIR/sys" 2>/dev/null
umount "$ROOTFS_DIR/dev" 2>/dev/null

rmdir "$CGROUP_PATH" 2>/dev/null
