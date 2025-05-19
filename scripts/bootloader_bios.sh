#!/bin/sh
# Script to create a bootable USB for BIOS mode with GRUB
# This script assumes the USB device is /dev/sdb and the first partition is /dev/sdb1
# WARNING: This script will erase all data on the specified USB device.

set -e  # Exit on error

USB_DEV="/dev/sdb"
USB_PART="${USB_DEV}1"
MOUNT_POINT="/mnt/usb"

# Confirm device exists
if [ ! -b "$USB_DEV" ]; then
  echo "Device $USB_DEV does not exist."
  exit 1
fi

# Unmount if mounted
sudo umount "$USB_PART" || true

# Recreate partition table and format as FAT32 for BIOS compatibility
sudo parted "$USB_DEV" --script mklabel msdos
sudo parted "$USB_DEV" --script mkpart primary fat32 1MiB 100%
sudo mkfs.vfat -F 32 "$USB_PART"

# Mount USB
sudo mkdir -p "$MOUNT_POINT"
sudo mount "$USB_PART" "$MOUNT_POINT"

# Install GRUB in BIOS mode (i386-pc is the right target for legacy BIOS)
sudo grub-install --target=i386-pc --boot-directory="$MOUNT_POINT/boot" "$USB_DEV"

# Copy kernel and loader images
# sudo cp ./camkes-vm-examples/build_zmq/images/kernel-x86_64-pc99 "$MOUNT_POINT/boot/kernelsel4"
# sudo cp ./camkes-vm-examples/build_zmq/images/capdl-loader-image-x86_64-pc99 "$MOUNT_POINT/boot/capdl"

sudo cp ./camkes-vm-examples/build/images/kernel-ia32-pc99 /mnt/usb/boot/kernelsel4
sudo cp ./camkes-vm-examples/build/images/capdl-loader-image-ia32-pc99 /mnt/usb/boot/capdl


sudo cp ./linuxkernel_4.9/linux-stable/arch/x86/boot/bzImage "$MOUNT_POINT/boot/kernel"
sudo cp ./linuxkernel_4.9/buildroot-2023.11/output/images/rootfs.cpio "$MOUNT_POINT/boot/rootfs"

# Write GRUB config
sudo mkdir -p "$MOUNT_POINT/boot/grub"
sudo tee "$MOUNT_POINT/boot/grub/grub.cfg" > /dev/null <<EOF
set timeout=5
set default=0

menuentry 'seL4 VM' {
    multiboot2 /boot/kernelsel4 console=tty0 console=ttyS0,115200n8
    module2 /boot/capdl
}

menuentry 'Linux VM' {
    linux /boot/kernel console=tty0 console=ttyS0,115200n8
    initrd /boot/rootfs
}
EOF

# Unmount USB
sudo umount "$MOUNT_POINT"

echo "Bootable USB created successfully with GRUB (BIOS mode)."
