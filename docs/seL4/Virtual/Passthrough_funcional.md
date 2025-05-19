# Passthrough
vm0.iospace_domain = 0x0f;
        vm0.pci_devices_iospace = 1;

        vm0.vm_ioports = [
            {"start":0xc000, "end":0xc03f, "pci_device":2, "name":"eth"}
        ];
    
        vm0.pci_devices = [
            {
                "name":"eth",
                "bus":0,
                "dev":0x2,
                "fun":0,
                "irq":"eth",
                "memory":[
                    {"paddr":0xfeb80000, "size":0x20000, "page_bits":12}
                ]
            }
        ];
    
        vm0.vm_irqs = [
            {"name":"eth", "ioapic":0, "source":0xb, "level_trig":1, "active_low":1, "dest":10}
        ];

# ===================================


ACPI: IOMMU host address width: 39
ACPI: 1 IOMMUs detected
ACPI: MADT_IOAPIC ioapic_id=0 ioapic_addr=0xfec00000 gsib=0
IOMMU: Create VTD context table for PCI bus 0xc0 (pptr=0xffffff807e0f0000)


# Pruebas 13/05:

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
    -device e1000e,mac=00:00:00:41:7f:01,id=network0.0,netdev=network0,addr=0x3 \
    -netdev tap,ifname=tapA1,id=network0,script=no,downscript=no \
    -device e1000e,mac=00:00:00:41:7f:02,id=network1.0,netdev=network1,addr=0x4 \
    -netdev tap,ifname=tapA2,id=network1,script=no,downscript=no

sudo ip link add name br0 type bridge
sudo ip link set br0 up
sudo ip tuntap add dev tapA1 mode tap
sudo ip tuntap add dev tapA2 mode tap
sudo ip link set tapA1 up
sudo ip link set tapA2 up
sudo ip link set tapA1 master br0
sudo ip link set tapA2 master br0