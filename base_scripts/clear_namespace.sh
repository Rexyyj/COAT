namespace=$1

ip link del dev $namespace-pod-ovs
ovs-vsctl del-port $namespace-pod-ovs
ip netns del $namespace
