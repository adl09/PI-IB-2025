#!/bin/bash

sudo qemu-system-x86_64 \
    -machine q35,accel=kvm,kernel-irqchip=split \
    -cpu host,+vmx \
    -m 2G \
    -kernel camkes-vm-examples-manifest/build_zmq/images/kernel-x86_64-pc99 \
    -initrd camkes-vm-examples-manifest/build_zmq/images/capdl-loader-image-x86_64-pc99 \
    -append "pci=nomsi" \
    -nographic \
    -serial mon:stdio \
    -device intel-iommu,intremap=off \
    -device e1000e,mac=00:00:00:00:00:03,id=network0.0,netdev=network0,addr=0x3 \
    -netdev tap,ifname=tap_inB,id=network0,script=no,downscript=no \
    -device e1000e,mac=00:00:00:00:00:04,id=network1.0,netdev=network1,addr=0x4 \
    -netdev tap,ifname=tap_outB,id=network1,script=no,downscript=no