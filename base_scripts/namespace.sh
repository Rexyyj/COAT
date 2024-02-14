namespace=$1
ip=$2

ip link add dev $namespace-pod-ovs type veth peer name $namespace-pod-netns
ovs-vsctl add-port ovsbr0 $namespace-pod-ovs

# Create new network namespace
ip netns add $namespace
ip link set netns $namespace $namespace-pod-netns
ip -n $namespace addr add $ip dev $namespace-pod-netns

# Bring up the connection
ip -n $namespace link set $namespace-pod-netns up
ip link set $namespace-pod-ovs up
