#!/bin/bash
echo "[*] Starting..."
mkdir /sys/fs/cgroup/{cpu,memory,pids}/NSJAIL
chown ctf /sys/fs/cgroup/{cpu,memory,pids}/NSJAIL

iptables -S FORWARD | grep $1 | grep NEW | cut -d " " -f 2- | xargs -rL1 iptables -D
iptables -A FORWARD -i $DEFAULT_IFACE -s $2 -o veth0 -p tcp -d $1 --dport 9999 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
exec nsjail --config /jail.cfg --macvlan_vs_ip $1
