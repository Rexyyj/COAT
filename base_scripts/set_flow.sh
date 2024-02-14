source_port=$1
destination_port=$2
client_ns=$3

sudo ovs-ofctl del-flows ovsbr0
sudo ovs-ofctl add-flow ovsbr0 in_port=$source_port,actions=output:$destination_port
sudo ovs-ofctl add-flow ovsbr0 in_port=$destination_port,actions=output:$source_port
# ip netns exec $client_ns ip -s -s neigh flush all
sudo ip netns exec $client_ns arp -d 172.16.0.10
#sudo ip netns exec $client_ns ping -q -c 1 172.16.0.10
