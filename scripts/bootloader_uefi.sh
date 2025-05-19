#!/bin/sh
# Script to create a bootable USB for UEFI mode with GRUB
# This script assumes the USB device is /dev/sdb and the first partition is /dev/sdb1
# WARNING: This script will erase all data on the specified USB device.

set -e  # Exit on error

# Recreate the USB partition and filesystem
sudo umount /dev/sdb1 || true
sudo parted /dev/sdb -- mklabel gpt
sudo parted -a optimal /dev/sdb -- mkpart ESP fat32 1MiB 100%
sudo parted /dev/sdb -- set 1 esp on
sudo mkfs.fat -F32 /dev/sdb1


# Mount and install GRUB
sudo mount /dev/sdb1 /mnt/usb
sudo mkdir -p /mnt/usb/EFI/BOOT

sudo grub-install --target=x86_64-efi \
                  --efi-directory=/mnt/usb \
                  --boot-directory=/mnt/usb/boot \
                  --removable \
                  --no-nvram


# Copy kernel and loader
#sudo cp ./camkes-vm-examples/build_zmq/images/kernel-x86_64-pc99 /mnt/usb/boot/kernelsel4
#sudo cp ./camkes-vm-examples/build_zmq/images/capdl-loader-image-x86_64-pc99 /mnt/usb/boot/capdl

sudo cp ./camkes-vm-examples/build/images/kernel-ia32-pc99 /mnt/usb/boot/kernelsel4
sudo cp ./camkes-vm-examples/build/images/capdl-loader-image-ia32-pc99 /mnt/usb/boot/capdl

sudo cp ./linuxkernel_4.9/linux-stable/arch/x86/boot/bzImage /mnt/usb/boot/kernel
sudo cp ./linuxkernel_4.9/buildroot-2023.11/output/images/rootfs.cpio /mnt/usb/boot/rootfs


# Write GRUB config
sudo mkdir -p /mnt/usb/boot/grub
sudo tee /mnt/usb/boot/grub/grub.cfg > /dev/null <<EOF
menuentry 'seL4 VM' {
    multiboot /boot/kernelsel4 console=ttyS0
    module /boot/capdl
}
menuentry 'Linux VM' {
    linux /boot/kernel console=ttyS0
    initrd /boot/rootfs
}
EOF

# Cleanup
sudo umount /mnt/usb