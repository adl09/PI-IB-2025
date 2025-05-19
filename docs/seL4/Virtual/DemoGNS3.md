
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
