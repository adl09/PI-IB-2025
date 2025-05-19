# seL4_Laboratorio
# camkes-vm-examples:

PING QEMU-QEMU
Propósito: Comunicar dos instancias de QEMU, en principio usando VM-Linux y luego seL4-VMLinux

Dentro de seL4_Laboratorio ejecutamos:

# 2 QEMU VM WIREGUARD PING:
HOST
sudo ip link add name br0 type bridge
sudo ip link set br0 up
sudo ip tuntap add dev tap0 mode tap
sudo ip tuntap add dev tap1 mode tap
sudo ip link set tap0 up
sudo ip link set tap1 up
sudo ip link set tap0 master br0
sudo ip link set tap1 master br0

VM1
qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -kernel linuxkernel_4.9/linux-stable/arch/x86/boot/bzImage \
    -initrd linuxkernel_4.9/buildroot-2023.11/output/images/rootfs.cpio \
    -append "console=ttyS0" \
    -nographic \
    -device e1000,netdev=net0,mac=52:54:00:00:00:03 \
    -netdev user,id=net0 \
    -m 512

ip addr add 192.168.100.1/24 dev eth0
ip link set eth0 up
ping 192.168.100.2


VM2
sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -kernel linuxkernel_4.9/linux-stable/arch/x86/boot/bzImage \
    -initrd linuxkernel_4.9/buildroot-2023.11/output/images/rootfs.cpio \
    -append "console=ttyS0 noapic" \
    -nographic \
    -device e1000,netdev=net0,mac=52:54:00:00:00:04 \
    -netdev user,id=net0 \
    -m 512

ip addr add 192.168.100.2/24 dev eth0
ip link set eth0 up

Wireguard:
wg genkey | tee privatekey | wg pubkey > publickey
ip link add dev wg0 type wireguard
ip addr add 10.0.0.1/24 dev wg0 #ON A
wg set wg0 listen-port 51820 private-key ./privatekey peer <Bpublickey> allowed-ips 10.0.0.2/32 endpoint 192.168.100.2:51820 #ON A
ip link set wg0 up

wg genkey | tee privatekey | wg pubkey > publickey
ip link add dev wg0 type wireguard
ip addr add 10.0.0.2/24 dev wg0 #ON B
wg set wg0 listen-port 51820 private-key ./privatekey peer <Apublickey> allowed-ips 10.0.0.1/32 #ON B
ip link set wg0 up

-------------------------------------------------------------
build: build de minimal (x86_32)
../init-build.sh -DCAMKES_VM_APP=minimal
ninja

Para ejecutar seL4-VM

sudo qemu-system-i386 \
    -accel kvm \
    -cpu host \
    -kernel images/kernel-ia32-pc99 \
    -initrd images/capdl-loader-image-ia32-pc99 \
    -m 512 \
    -append 'console=ttyS0' \
    -nographic

-------------------------------------------------------------
# 3 VM AMPLIAR LUEGO
build_zmq: 3VM
../init-build.sh -DCAMKES_VM_APP=zmq_samples -DSIMULATION=ON

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
    -netdev tap,id=net0,ifname=tap1,script=no,downscript=no \
    -device e1000e,netdev=net0,mac=52:54:00:00:00:02

VM0:
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
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device e1000e,netdev=net0,mac=52:54:00:00:00:01

ifconfig eth1 up
ip addr add 192.168.100.1/24 dev eth1
ip link set eth1 up

VM1:
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
    -netdev tap,id=net0,ifname=tap1,script=no,downscript=no \
    -device e1000,netdev=net0,mac=52:54:00:00:00:02

ifconfig eth1 up
ip addr add 192.168.100.2/24 dev eth1
ip link set eth1 up

iperf3 benchmark:
Tenemos muchos mensajes así:
    camkes_virtqueue_buffer_alloc@virtqueue.c:32 Error: ran out of memory
    camkes_virtqueue_driver_scatter_send_buffer@virtqueue.c:193 Error: could not allocate virtqueue buffer
    emul_raw_tx@virtio_net_vswitch.c:137 Unknown error while enqueuing available buffer for dest 2:0:0:0:aa:3.

iperf3 -c 192.168.1.3

Connecting to host 192.168.1.3, port 5201
[  5] local 192.168.1.2 port 46384 connected to 192.168.1.3 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  2.84 MBytes  23.8 Mbits/sec   35   17.0 KBytes       
[  5]   1.00-2.02   sec  2.92 MBytes  24.0 Mbits/sec   28   18.4 KBytes       
[  5]   2.02-3.03   sec  2.87 MBytes  23.8 Mbits/sec   26   19.8 KBytes       
[  5]   3.03-4.00   sec  2.85 MBytes  24.7 Mbits/sec   26   19.8 KBytes       
[  5]   4.00-5.01   sec  3.05 MBytes  25.4 Mbits/sec   18   15.6 KBytes       
[  5]   5.01-6.01   sec  2.79 MBytes  23.4 Mbits/sec   30   18.4 KBytes       
[  5]   6.01-7.00   sec  2.79 MBytes  23.6 Mbits/sec   30   18.4 KBytes       
[  5]   7.00-8.00   sec  2.91 MBytes  24.4 Mbits/sec   28   18.4 KBytes       
[  5]   8.00-9.01   sec  2.86 MBytes  23.8 Mbits/sec   31   15.6 KBytes       
[  5]   9.01-10.01  sec  3.02 MBytes  25.4 Mbits/sec   25   17.0 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.01  sec  28.9 MBytes  24.2 Mbits/sec  277             sender
[  5]   0.00-9.72   sec  28.8 MBytes  24.8 Mbits/sec                  receiver

iperf3 -c 192.168.1.3 -u -b 100M

Connecting to host 192.168.1.3, port 5201
[  5] local 192.168.1.2 port 41800 connected to 192.168.1.3 port 5201
[ ID] Interval           Transfer     Bitrate         Total Datagrams
[  5]   0.00-1.00   sec  1.03 MBytes  8.63 Mbits/sec  745  
[  5]   1.00-2.00   sec  1.02 MBytes  8.55 Mbits/sec  738  
[  5]   2.00-3.00   sec  1.14 MBytes  9.53 Mbits/sec  823  
[  5]   3.00-4.01   sec  1.14 MBytes  9.53 Mbits/sec  828  
[  5]   4.01-5.00   sec  1.03 MBytes  8.66 Mbits/sec  743  
[  5]   5.00-6.00   sec  1.11 MBytes  9.26 Mbits/sec  801  
[  5]   6.00-7.01   sec  1.11 MBytes  9.28 Mbits/sec  804  
[  5]   7.01-8.00   sec  1.20 MBytes  10.1 Mbits/sec  872  
[  5]   8.00-9.00   sec  1020 KBytes  8.37 Mbits/sec  721  
[  5]   9.00-10.01  sec  1.20 MBytes  9.98 Mbits/sec  868  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-10.01  sec  11.0 MBytes  9.19 Mbits/sec  0.000 ms  34114925232128/0 (-1.9e-41%)  �!�
[  5]   0.00-9.17   sec  10.2 MBytes  9.30 Mbits/sec  1.491 ms  566/7930 (7.1%)  receiver


Probé de modificar /home/alberto/Documentos/ADL/seL4_Laboratorio/camkes-vm-examples/projects/camkes-tool/libsel4camkes/src/virtqueue.c
BLOCK_SIZE de 128 hasta 4096 pero esto solo lo empeora. 

CAMBIANDO COSAS:
Ya no hay errores.
Se modificó #define BLOCK_SIZE 2048 //before 128
En connections.h
#define VM_CONNECTION_CONFIG(to_end, topology) \
    topology(__CONFIG_EXPAND_PERVM) \
    to_end##_topology = [topology(__CONFIG_EXPAND_TOPOLOGY)]; \
    topology##_conn.queue_length = 256 * 32; // added

vm##base_id.ether_##target_id##_send_shmem_size = 32768*16; \ agregué el x16
vm##base_id.ether_##target_id##_recv_shmem_size = 32768*16; \


En vm.h
//vm##num.fs_shmem_size = 0x10000; //before 0x1000
// vm##num.serial_getchar_shmem_size = 0x10000; // before 0x1000

# iperf3 -c 192.168.1.1 -b 100M > a
Accepted connection from 192.168.1.2, port 56582
[  103.620188] random: iperf3: uninitialized urandom read (131072 bytes read)
[  5] local 192.168.1.1 port 5201 connected to 192.168.1.2 port 56588
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec  4.05 MBytes  33.8 Mbits/sec                  
[  5]   1.00-2.01   sec  5.52 MBytes  46.1 Mbits/sec                  
[  5]   2.01-3.01   sec  4.01 MBytes  33.6 Mbits/sec                  
[  5]   3.01-4.01   sec  4.64 MBytes  38.9 Mbits/sec                  
[  5]   4.01-5.01   sec  4.13 MBytes  34.5 Mbits/sec                  
[  5]   5.01-6.00   sec  5.56 MBytes  47.0 Mbits/sec                  
[  5]   6.00-7.01   sec  5.46 MBytes  45.4 Mbits/sec                  
[  5]   7.01-7.78   sec  2.64 MBytes  28.7 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-7.78   sec  36.0 MBytes  38.8 Mbits/sec

Seguimos teniendo problemas:
UDP anda patrass

# iperf3 -c 192.168.1.1 -b 100M -u > a
Accepted connection from 192.168.1.2, port 56612
[  5] local 192.168.1.1 port 5201 connected to 192.168.1.2 port 35669
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datags
[  5]   0.00-1.00   sec  2.05 MBytes  17.2 Mbits/sec  1.278 ms  0/1482 (0%)  
[  5]   1.00-2.01   sec  1.34 MBytes  11.1 Mbits/sec  1.479 ms  0/968 (0%)  
[  5]   2.01-3.00   sec  1.31 MBytes  11.1 Mbits/sec  1.438 ms  0/949 (0%)  
[  5]   3.00-4.02   sec  1.37 MBytes  11.3 Mbits/sec  1.358 ms  0/990 (0%)  
[  5]   4.02-5.01   sec  1.36 MBytes  11.5 Mbits/sec  1.565 ms  0/988 (0%)  
[  5]   5.01-6.00   sec  1.34 MBytes  11.3 Mbits/sec  1.193 ms  0/970 (0%)  
[  5]   6.00-7.00   sec  1.29 MBytes  10.8 Mbits/sec  1.444 ms  0/933 (0%)  
[  5]   7.00-8.00   sec  1.35 MBytes  11.4 Mbits/sec  0.912 ms  0/981 (0%)  
[  5]   8.00-9.00   sec  1.36 MBytes  11.4 Mbits/sec  0.828 ms  0/987 (0%)  
[  5]   9.00-9.59   sec   795 KBytes  11.0 Mbits/sec  0.742 ms  0/562 (0%)  



-------------------------------------------------------------
# Custom-linux

En build hay un set up funcionando con seL4 + 4.9 linux kernel + Wireguard
Se modificó el CMakeLists.txt para que tome el kernel linux y rootfs de otro directorio:
    Kernel: set(kernel_file "/host/linuxkernel_4.9/linux-stable/arch/x86/boot/bzImage")
    Build usando .config default (4.8.16) con algunos argumentos cambiados para poder ejecutar wireguard.
    El kernel se buildea después de rootfs, porque se lo utiliza.

    rootfs: set(rootfs_file "/host/linuxkernel_4.9/buildroot-2023.11/output/images/rootfs.cpio").
    Se agregó wireguard, se buildea sin kernel.

-------------------------------------------------------------
# More-ram

Se modifican los argumentos de minimal.camkes:

    vm0.simple_untyped23_pool = 40; // 40*2**23 = 335MiB debe ser mayor que guest_ram_mb
    vm0.heap_size = 0x2000000; // Si no funca se aumenta esto.
    vm0.guest_ram_mb = 256;

-------------------------------------------------------------


-------------------------------------------------------------
# PRUEBAS
En seL4_Laboratorio:

sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -kernel camkes-vm-examples/build/images/kernel-ia32-pc99 \
    -initrd camkes-vm-examples/build/images/capdl-loader-image-ia32-pc99 \
    -serial mon:stdio \
    -nographic \
    -device ioapic,id=ioapic0 \
    -append "acpi=off pci=nomsi" \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device e1000e,netdev=net0,mac=52:54:00:00:00:01 \
    -m 1G

sudo ./simulate --machine q35,accel=kvm,kernel-irqchip=split --mem-size 2G --extra-cpu-opts "+vmx" --extra-qemu-args="-enable-kvm -device intel-iommu,intremap=off -net nic,model=e1000e -net tap,script=no,ifname=tap0 -device ioapic,id=ioapic0"

Solo VM Linux:

sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -kernel linuxkernel_4.9/linux-stable/arch/x86/boot/bzImage \
    -initrd linuxkernel_4.9/buildroot-2023.11/output/images/rootfs.cpio \
    -append "console=ttyS0 acpi=off pci=nomsi" \
    -nographic \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device e1000,netdev=net0,mac=52:54:00:00:00:02 \
    -m 512

sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -kernel default_linux/kernel/32/default_bzimage_4.8.16 \
    -initrd default_linux/rootfs/32/default_buildroot_rootfs-bare.cpio \
    -append "console=ttyS0 acpi=off pci=nomsi" \
    -nographic \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device e1000e,netdev=net0,mac=52:54:00:00:00:02 \
    -m 512


-------------------------------------------------------------

# RUNNING BARE-METAL
Tengo dos scripts:
./bootloader_legacy.sh: crea un pendrive booteable con seL4 y VM sola. MBR
sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host,+fsgsbase \
    -m 1G \
    -drive file=/dev/sdb,format=raw \
    -bios /usr/share/ovmf/OVMF.fd

./bootloader.sh: idem para UEFI.
sudo qemu-system-x86_64 \
  -accel kvm \
  -cpu host \
  -m 1G \
  -drive file=/dev/sdb,format=raw

-------------------------------------------------------------
# Passthrough SATA:

sudo qemu-system-x86_64 \
    -cpu host \
    -accel kvm \
    -append 'noapic pci=nomsi console=ttyS0' \
    -kernel camkes-vm-examples/build/images/kernel-ia32-pc99 \
    -initrd camkes-vm-examples/build/images/capdl-loader-image-ia32-pc99 \
    -m 1G \
    -net none \
    -netdev tap,id=net0,ifname=tap1,script=no,downscript=no \
    -device e1000,netdev=net0 \
    -serial mon:stdio \
    -device ahci,id=ahci0 \
    -drive id=disk1,file=data.img,format=raw,if=none \
    -device ide-hd,drive=disk1,bus=ahci0.0 \
    -nographic


# MINIMAL_64
sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -kernel camkes-vm-examples/build64/images/kernel-x86_64-pc99 \
    -initrd camkes-vm-examples/build64/images/capdl-loader-image-x86_64-pc99 \
    -serial mon:stdio \
    -nographic \
    -append "acpi=off pci=nomsi" \
    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \
    -device e1000e,netdev=net0,mac=52:54:00:00:00:01 \
    -m 1G