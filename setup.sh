#!/bin/bash

# cgroupv2 shit
mkdir /sys/fs/cgroup/INSTANCER
echo "0" > /sys/fs/cgroup/INSTANCER/cgroup.procs
echo "+pids +memory +cpu" > /sys/fs/cgroup/cgroup.subtree_control

ip link del veth0
ip link add veth0 type veth peer veth1
ip addr add 10.0.4.1/24 dev veth0
ip link set up veth0
ip link set up veth1
echo 1 > /proc/sys/net/ipv4/ip_forward

export DEFAULT_IFACE=$(ip route | grep default | awk '{print $5}')

NUM_SERVERS="${CHALL_NUM_SERVERS:-5}"
PORT_BASE="${CHALL_PORT_BASE:-7000}"
for i in $(seq 1 $NUM_SERVERS); do
  NUM=$((i + 1))
  PORT=$((NUM + PORT_BASE))
  iptables -A FORWARD -o $DEFAULT_IFACE -i veth0 -p tcp -s 10.0.4.$NUM -m state --state ESTABLISHED,RELATED -j ACCEPT
  iptables -A POSTROUTING -t nat -o $DEFAULT_IFACE -j MASQUERADE
  iptables -A PREROUTING -t nat -p tcp -i $DEFAULT_IFACE --dport $PORT -j DNAT --to-destination 10.0.4.$NUM:9999

done
source /venv/bin/activate
python3 /server.py
