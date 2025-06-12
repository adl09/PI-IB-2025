#!/bin/bash

# Define source and destination directories
SOURCE_DIR="/home/alberto/Documentos/PI-IB-2025/camkes-vm-examples-manifest/build_zmq/images"
CWD=$(pwd)
DEST_DIR="$CWD/isozmq"

# Check if destination directory exists and erase it
if [ -d "$DEST_DIR" ]; then
    echo "Destination directory exists, removing: $DEST_DIR"
    rm -rf "$DEST_DIR"
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

    # Add grub/grub.cfg in the destination directory
    mkdir -p "$DEST_DIR/boot/grub"
    echo "set default=0
set timeout=60
serial --unit=1 --speed=115200 --word=8 --parity=no --stop=1    
menuentry "seL4" {
    multiboot /boot/kernel-x86_64-pc99 console_port=0x2f8 debug_port=0x2f8
    module /boot/capdl-loader-image-x86_64-pc99
}" > "$DEST_DIR/boot/grub/grub.cfg"


# Copy files from source to destination
cp -r "$SOURCE_DIR"/* "$DEST_DIR/boot"

echo "Files copied from $SOURCE_DIR to $DEST_DIR successfully."

grub-mkrescue -o "$CWD/isozmq/image.iso" "$CWD/isozmq"