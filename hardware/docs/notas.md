ADMIN
AFASVYRUDY
ipmitool -I lanplus -H 192.168.1.3 -U ADMIN -P AFASVYRUDY shell

Estoy tratando de ver I/O de grub en TextConsole de IPMIView


serial_com1 es TextConsole, pero mi salida de seL4 es serial_com0

ipmitool -I lanplus -H $BMC_IP -U $USER -P $PASS sol info 1

terminal_input serial no va
terminal_input serial_com1 va con SOL

Para generar una iso:
en /iso_build/
grub-mkrescue -o image3.iso .

serial --unit=1 --speed=115200 --word=8 --parity=no --stop=1

ahora terminal_output serial va a TextConsole

ipmitool -I lanplus -H 192.168.1.3 -U ADMIN -P AFASVYRUDY sol activate
ipmi> sol activate

cp /home/alberto/Documentos/PI-IB-2025/camkes-vm-examples-manifest/build_zmq/images/capdl-loader-image-x86_64-pc99 .
cp /home/alberto/Documentos/PI-IB-2025/camkes-vm-examples-manifest/build_zmq/images/kernel-x86_64-pc99 .


QEMU info qtree:
          dev: isa-serial, id ""
            index = 0 (0x0)
            iobase = 1016 (0x3f8)
            irq = 4 (0x4)
ESO ESTÁ IGUAL QUE EN LA BIOS DEL EQUIPO

sol set privilege-level admin 1
sol set baud 115200 1
sol set force-encryption false 1
sol set force-authentication false 1
sol set non-volatile-bit-rate 115200 1
sol set volatile-bit-rate 115200 1

sel4.log lo hice con:
menuentry "seL4" {
    multiboot /boot/kernel-x86_64-pc99 console_port=0x2f8 debug_port=0x2f8 console=ttyS1,115200n8
    module /boot/capdl-loader-image-x86_64-pc99
}

# ==============================================
# Resumen linuxvm_030625.log

[    2.073376] serial8250: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    2.102092] serial8250: ttyS1 at I/O 0x2f8 (irq = 3, base_baud = 115200) is a 16550A

[    2.369286] igb 0000:17:00.0: added PHC on eth0
[    2.373804] igb 0000:17:00.0: Intel(R) Gigabit Ethernet Network Connection
[    2.380661] igb 0000:17:00.0: eth0: (PCIe:5.0Gb/s:Width x4) 7c:c2:55:6b:c4:d4
[    2.387847] igb 0000:17:00.0: eth0: PBA No: 020C00-000
[    2.392975] igb 0000:17:00.0: Using legacy interrupts. 1 rx queue(s), 1 tx queue(s)
[    2.400749] igb 0000:17:00.1: assigned PCI INT B -> IRQ 10
[    2.406224] igb 0000:17:00.1: sharing IRQ 10 with 0000:00:04.1
[    2.412038] igb 0000:17:00.1: sharing IRQ 10 with 0000:00:04.5

[    2.488306] igb 0000:17:00.1: added PHC on eth1
[    2.492828] igb 0000:17:00.1: Intel(R) Gigabit Ethernet Network Connection
[    2.499687] igb 0000:17:00.1: eth1: (PCIe:5.0Gb/s:Width x4) 7c:c2:55:6b:c4:d5
[    2.506871] igb 0000:17:00.1: eth1: PBA No: 020C00-000
[    2.512000] igb 0000:17:00.1: Using legacy interrupts. 1 rx queue(s), 1 tx queue(s)
[    2.519759] igb 0000:17:00.2: assigned PCI INT C -> IRQ 11
[    2.525239] igb 0000:17:00.2: sharing IRQ 11 with 0000:00:04.2
[    2.531054] igb 0000:17:00.2: sharing IRQ 11 with 0000:00:04.6
[    2.536884] igb 0000:17:00.2: sharing IRQ 11 with 0000:00:14.2

Tenemos eth0,eth1,eth2,eth3 con igb. Son los 4 puertos.

[    2.841820] i40e: Intel(R) Ethernet Connection XL710 Network Driver - version 1.6.16-k
[    2.849716] i40e: Copyright (c) 2013 - 2014 Intel Corporation.
[    2.855604] i40e 0000:b5:00.0: assigned PCI INT A -> IRQ 11
[    2.937981] i40e 0000:b5:00.0: sharing IRQ 11 with 0000:17:00.0

[    3.900674] i40e 0000:b5:00.1: assigned PCI INT A -> IRQ 11
[    4.006703] i40e 0000:b5:00.1: sharing IRQ 11 with 0000:b5:00.0

Estos son los otros 2 puertos 10Gb

3: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 7c:c2:55:6b:c4:d4 brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 7c:c2:55:6b:c4:d5 brd ff:ff:ff:ff:ff:ff
5: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 7c:c2:55:6b:c4:d6 brd ff:ff:ff:ff:ff:ff
6: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 7c:c2:55:6b:c4:d7 brd ff:ff:ff:ff:ff:ff
7: eth4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 3c:ec:ef:d2:88:84 brd ff:ff:ff:ff:ff:ff
8: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 3c:ec:ef:d2:88:85 brd ff:ff:ff:ff:ff:ff

# =================================================
# Resumen sel4_030625.log

Boot config: debug_port = 0x2f8
ACPI: 4 IOMMUs detected
ACPI: MADT_APIC apic_id=0x0
ACPI: MADT_APIC apic_id=0x4
ACPI: Not recording this APIC, only support 1

ACPI: MADT_IOAPIC ioapic_id=8 ioapic_addr=0xfec00000 gsib=0
ACPI: MADT_IOAPIC ioapic_id=9 ioapic_addr=0xfec01000 gsib=24
ACPI: Not recording this IOAPIC, only support 1
ACPI: MADT_IOAPIC ioapic_id=10 ioapic_addr=0xfec08000 gsib=32
ACPI: Not recording this IOAPIC, only support 1
ACPI: MADT_IOAPIC ioapic_id=11 ioapic_addr=0xfec10000 gsib=40
ACPI: Not recording this IOAPIC, only support 1
ACPI: MADT_IOAPIC ioapic_id=12 ioapic_addr=0xfec18000 gsib=48
ACPI: Not recording this IOAPIC, only support 1
