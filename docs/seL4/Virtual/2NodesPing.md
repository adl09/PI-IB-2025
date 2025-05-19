# Idea:
- Nodos A,B.
    - VM0_x: red interna (passthrough).
    - VM1_x: Wireguard.
    - VM2_x: red externa (passthrough).

PC1 -- eth1.VM0_A.eth0 -- eth0.VM1_A.eth0 -- eth0.VM2_A.eth2 <-internet-> eth2.VM2_B.eth0 -- eth0.VM1_A.eth0 -- eth0.VM0_B.eth1 -- PC2

Para esto necesitamos 3 bridges en el host:

sudo ip link add br0 type bridge
sudo ip link add br1 type bridge
sudo ip link add br2 type bridge
sudo ip link set br0 up
sudo ip link set br1 up
sudo ip link set br2 up

br0: PC1 ↔ QEMU_A.eth1
br1: QEMU_A.eth2 ↔ QEMU_B.eth2
br2: QEMU_B.eth1 ↔ PC2


####################33



sudo ip link add name brPC1 type bridge
sudo ip link add name brAB type bridge
sudo ip link add name brPC2 type bridge

sudo ip tuntap add dev tapA1 mode tap
sudo ip tuntap add dev tapA2 mode tap
sudo ip tuntap add dev tapA3 mode tap
sudo ip tuntap add dev tapA4 mode tap

sudo ip link set br0 up
sudo ip link set brAB up
sudo ip link set br1 up
sudo ip link set veth0 up
sudo ip link set veth1 up
sudo ip link set veth2 up
sudo ip link set veth3 up
sudo ip link set tapA1 up
sudo ip link set tapA2 up
sudo ip link set tapA3 up
sudo ip link set tapA4 up

sudo ip link set tapA2 master br0
sudo ip link set veth1 master br0
sudo ip link set tapA1 master brAB
sudo ip link set tapA4 master brAB
sudo ip link set tapA3 master br1
sudo ip link set veth2 master br1

sudo ip addr add 10.0.10.1/24 dev veth0
sudo ip addr add 10.0.20.1/24 dev veth3

# pruebita
sudo ip link add name br0 type bridge
sudo ip link set br0 up
sudo ip tuntap add dev tapA1 mode tap
sudo ip tuntap add dev tapA3 mode tap
sudo ip link set tapA1 up
sudo ip link set tapA3 up
sudo ip link set tapA1 master br0
sudo ip link set tapA3 master br0

sudo ip link add name br1 type bridge
sudo ip link set br1 up
sudo ip tuntap add dev tapA2 mode tap
sudo ip tuntap add dev tapA4 mode tap
sudo ip link set tapA2 up
sudo ip link set tapA4 up
sudo ip link set tapA2 master br1
sudo ip link set tapA4 master br1


VM0_A
ifconfig eth1 up
ip addr add 10.0.10.1/24 dev eth1

VM0_B
ifconfig eth1 up
ip addr add 10.0.10.2/24 dev eth1

VM2_A
ifconfig eth1 up
ip addr add 10.0.20.1/24 dev eth1

VM2_B
ifconfig eth1 up
ip addr add 10.0.20.2/24 dev eth1

A:
sudo qemu-system-x86_64 \
    -machine q35,accel=kvm,kernel-irqchip=split \
    -cpu host,+vmx \
    -m 2G \
    -kernel camkes-vm-examples/build_zmq/images/kernel-x86_64-pc99 \
    -initrd camkes-vm-examples/build_zmq/images/capdl-loader-image-x86_64-pc99 \
    -append "pci=nomsi" \
    -nographic \
    -serial mon:stdio \
    -device intel-iommu,intremap=off \
    -netdev tap,id=net0,ifname=tapA1,script=no,downscript=no \
    -device e1000e,netdev=net0,mac=52:54:00:00:00:01,bus=pcie.0,addr=0x2 \
    -netdev tap,id=net1,ifname=tapA2,script=no,downscript=no \
    -device e1000e,netdev=net1,mac=52:54:00:00:00:02,bus=pcie.0,addr=0x3

En VM correspondiente a mac=52:54:00:00:00:01
ip addr add 10.0.30.1/24 dev eth1
ip link set eth1 up
En VM correspondiente a mac=52:54:00:00:00:02
ip addr add 10.0.10.2/24 dev eth1
ip link set eth1 up


B:
sudo qemu-system-x86_64 \
    -machine q35,accel=kvm,kernel-irqchip=split \
    -cpu host,+vmx \
    -m 2G \
    -kernel camkes-vm-examples/build_zmq/images/kernel-x86_64-pc99 \
    -initrd camkes-vm-examples/build_zmq/images/capdl-loader-image-x86_64-pc99 \
    -append "pci=nomsi" \
    -nographic \
    -serial mon:stdio \
    -device intel-iommu,intremap=off \
    -netdev tap,id=net3,ifname=tapA3,script=no,downscript=no \
    -device e1000e,netdev=net3,mac=52:54:00:00:00:03 \
    -netdev tap,id=net4,ifname=tapA4,script=no,downscript=no \
    -device e1000e,netdev=net4,mac=52:54:00:00:00:04

En VM correspondiente a mac=52:54:00:00:00:03
ip addr add 10.0.20.2/24 dev eth1
ip link set eth1 up

En VM correspondiente a mac=52:54:00:00:00:04
ip addr add 10.0.30.2/24 dev eth1
ip link set eth1 up


# PROBLEMA

VM0(irq11 to irq10) -> ifconfig eth1 up

Luego VM2(irq11 to irq12) -> ifconfig eth1 up --> Error!

Al hacer eso seL4 se cuelga por un rato y luego tira, en VM0:
[   48.557120] irq 10: nobody cared (try booting with the "irqpoll" option)
...
...
[   59.119869] Disabling IRQ #10


Parece que las irq11 de la NIC2 se siguen traduciendo como irq10 y van a la primer VM en levantar eth1 (VM0), pero como no hay respuesta se rompe.

