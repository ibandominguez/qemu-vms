#!/usr/bin/env bash

# Change working directory
cd "$(dirname "$0")"

# Parameters.
version=18.04
id=ubuntu-18.04.6-desktop-amd64
disk_img="${id}.img.qcow2"
disk_img_snapshot="${id}.snapshot.qcow2"
iso="${id}.iso"

# Get image.
if [ ! -f "$iso" ]; then
  wget "http://releases.ubuntu.com/${version}/${iso}"
fi

# Go through installer manually.
if [ ! -f "$disk_img" ]; then
  qemu-img create -f qcow2 "$disk_img" 8G
  qemu-system-x86_64 \
    -cdrom "$iso" \
    -drive "file=${disk_img},format=qcow2" \
    -m 4G \
    -accel hvf \
    -smp 2 \
  ;
fi

# Create an image based on the original post-installation image
# so as to keep a pristine post-install image.
if [ ! -f "$disk_img_snapshot" ]; then
  qemu-img \
    create \
    -f qcow2 \
    -F qcow2 \
    -b "$disk_img" \
    "$disk_img_snapshot" \
  ;
fi

# Run the copy of the installed image.
qemu-system-x86_64 \
  -drive "file=${disk_img_snapshot},format=qcow2" \
  -m 4G \
  -smp 2 \
  -soundhw hda \
  -vga virtio \
  -accel hvf \
  -vnc 192.168.189.138:0 \
  "$@" \
;