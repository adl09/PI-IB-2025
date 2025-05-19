# DEMO 2 QEMU WIREGUARD

# HOST:
sudo ip link add name brPC1 type bridge
sudo ip link add name brAB type bridge
sudo ip link add name brPC2 type bridge

sudo ip tuntap add dev tap_inA mode tap
sudo ip tuntap add dev tap_inB mode tap
sudo ip tuntap add dev tap_outA mode tap
sudo ip tuntap add dev tap_outB mode tap
sudo ip tuntap add dev tap_PC1 mode tap
sudo ip tuntap add dev tap_PC2 mode tap

sudo ip link set tap_PC1 master brPC1
sudo ip link set tap_inA master brPC1
sudo ip link set tap_outA master brAB
sudo ip link set tap_outB master brAB
sudo ip link set tap_inB master brPC2
sudo ip link set tap_PC2 master brPC2

sudo ip link set brPC1 up
sudo ip link set brPC2 up
sudo ip link set brAB up
sudo ip link set tap_inA up  
sudo ip link set tap_inB up  
sudo ip link set tap_outA up  
sudo ip link set tap_outB up  
sudo ip link set tap_PC1 up  
sudo ip link set tap_PC2 up

sudo ip addr add 100.64.0.1/24 dev brAB
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 100.64.0.0/24 -o wlp0s20f3 -j MASQUERADE

# A:
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
    -device e1000e,mac=00:00:00:00:00:01,id=network0.0,netdev=network0,addr=0x3 \
    -netdev tap,ifname=tap_inA,id=network0,script=no,downscript=no \
    -device e1000e,mac=00:00:00:00:00:02,id=network1.0,netdev=network1,addr=0x4 \
    -netdev tap,ifname=tap_outA,id=network1,script=no,downscript=no

VM0 (tap_inA)
    export PS1="(VM0_in) # "
    ifconfig eth1 up
    ip addr add 10.0.1.254/24 dev eth1
    ip route add default via 192.168.1.3 dev eth0
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    ip route add 10.0.2.0/24 via 192.168.1.2
    ip route add 10.0.0.0/24 via 192.168.1.2 dev eth0

VM1 (wireguard)
    export PS1="(VM1_wg) # "
    
    ip link add dev wg0 type wireguard
    ip address add 10.0.0.1/24 dev wg0
    wg set wg0 private-key <(echo "6NuHbDnd8VzX2WQU28RC7pL+R1o58GbNHdJy04wq1Fk=") listen-port 51820
    wg set wg0 peer DAAC2qlKupMuyQsETEBKFM4QJN4Nq4kPh7OQEUcYfyQ= endpoint 100.64.0.3:51820 allowed-ips 0.0.0.0/0
    ip link set wg0 up
    ip route add 10.0.2.0/24 dev wg0
    ip route add 10.0.1.0/24 via 192.168.1.1 dev eth0
    
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    ip route add default via 192.168.1.3 dev eth0


VM2 (tap_outA)
    export PS1="(VM2_out) # "
    ifconfig eth1 up
    ip addr add 100.64.0.2/24 dev eth1
    ip route add default via 100.64.0.1 dev eth1
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
    
    iptables -t nat -A PREROUTING -i eth1 -p udp --dport 51820 -j DNAT --to-destination 192.168.1.2:51820
    iptables -A FORWARD -i eth1 -o eth0 -p udp --dport 51820 -d 192.168.1.2 -j ACCEPT
    
    iptables -t nat -A POSTROUTING -o eth0 -s 192.168.1.2 -j MASQUERADE

# B:
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


VM0 (tap_inB)
    export PS1="(VM0_in) # "

    ifconfig eth1 up
    ip addr add 10.0.2.254/24 dev eth1
    ip route add default via 192.168.1.3 dev eth0
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    ip route add 10.0.1.0/24 via 192.168.1.2
    ip route add 10.0.0.0/24 via 192.168.1.2 dev eth0


VM1 (wireguard)
    export PS1="(VM1_wg) # "
    
    ip link add dev wg0 type wireguard
    ip address add 10.0.0.2/24 dev wg0
    wg set wg0 private-key <(echo "QOIxVbllzPknt1k5yaTJcxTUSiSovCzXSHWtyuz2UUo=") listen-port 51820
    wg set wg0 peer luu9nHDcG1hKxulslt3cLvrSKE3fXXEe8jplrTrHnlQ= endpoint 100.64.0.2:51820 allowed-ips 0.0.0.0/0
    ip link set wg0 up

    ip route add 10.0.1.0/24 dev wg0
    ip route add 10.0.2.0/24 via 192.168.1.1 dev eth0

    
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
    ip route add default via 192.168.1.3 dev eth0


VM2 (tap_outB)
    export PS1="(VM2_out) # "

    ifconfig eth1 up
    ip addr add 100.64.0.3/24 dev eth1
    ip route add default via 100.64.0.1 dev eth1
    echo 1 > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
    
    iptables -t nat -A PREROUTING -p udp --dport 51820 -j DNAT --to-destination 192.168.1.2:51820
    iptables -A FORWARD -p udp -d 192.168.1.2 --dport 51820 -j ACCEPT


# PC1:
sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -m 128 \
    -append "console=ttyS0" \
    -nographic \
    -kernel custom-vm-kernel/linux-stable/arch/x86/boot/bzImage \
    -initrd custom-vm-kernel/buildroot-2023.11/output/images/rootfs.cpio \
    -device e1000e,mac=00:00:00:00:00:10,id=network0.0,netdev=network0,addr=0x3 \
    -netdev tap,ifname=tap_PC1,id=network0,script=no,downscript=no

ifconfig eth0 up
ip addr add 10.0.1.1/24 dev eth0
ip route add default via 10.0.1.254

# PC2:
sudo qemu-system-x86_64 \
    -accel kvm \
    -cpu host \
    -m 128 \
    -append "console=ttyS0" \
    -nographic \
    -kernel custom-vm-kernel/linux-stable/arch/x86/boot/bzImage \
    -initrd custom-vm-kernel/buildroot-2023.11/output/images/rootfs.cpio \
    -device e1000e,mac=00:00:00:00:00:11,id=network0.0,netdev=network0,addr=0x3 \
    -netdev tap,ifname=tap_PC2,id=network0,script=no,downscript=no

ifconfig eth0 up
ip addr add 10.0.2.2/24 dev eth0
ip route add default via 10.0.2.254



=======================================
# GNS3: ENCR

VM2A:
sudo -i
ip link set ens5 up
dhclient ens5

ip addr del 192.168.1.100/24 dev ens4
ip addr add 192.168.1.3/24 dev ens4
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE


VM1A (WG):
sudo -i
ip link set ens4 up
ip addr del 192.168.1.100/24 dev ens4
ip addr add 192.168.1.2/24 dev ens4
ip route add default via 192.168.1.3 dev ens4

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE

ip route add 192.168.4.0/24 dev wg0
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE

VM0A:

ip link set ens5 up
ip addr add 10.0.1.254/24 dev ens5
iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE

ip link set ens4 up
echo 1 > /proc/sys/net/ipv4/ip_forward
ip addr del 192.168.1.100/24 dev ens4
ip addr add 192.168.1.1/24 dev ens4

ip route add default via 192.168.1.3 dev ens4
iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
ip route add 192.168.4.0/24 via 192.168.1.2 dev ens4
