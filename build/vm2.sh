#!/bin/bash
set -e
sudo mount /dev/sda1 /media -o ro
cd /media
sudo rm /mnt/filesystem.squashfs || true
sudo mksquashfs . /mnt/filesystem.squashfs -e ./vmlinuz -e ./vmlinuz.old -e ./initrd.img -e ./initrd.img.old -e ./etc/fstab -e ./boot -e ./root/.bash_history -e ./root/.ssh -e ./root/.viminfo -e ./tmp/* -e /tmp/.* -e ./lost+found -comp xz
sudo cp ./vmlinuz /mnt/vmlinuz
sudo cp ./initrd.img /mnt/initrd.img
cd ..
sudo umount /media
