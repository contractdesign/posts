
# Network Namespaces

Network namespaces have their own network protocol stacks distinct
from those of the hosts.  This means that a namespace can have its own
internal routing rules, independent of those of the host.


To play with this, let's create a pair of network namespaces, connect
them with veth pairs and experiment with pinging between them.  I
borrowed this
[script](https://unix.stackexchange.com/questions/405805/connecting-two-network-namespaces-via-a-veth-interface-pair-where-each-endpoint)
that I found on stackoverflow to create this situation.

```bash
#!/bin/bash

# Create two network namespaces
sudo ip netns add 'test-1'
sudo ip netns add 'test-2'

# Create a veth virtual-interface pair
sudo ip link add 'myns-1-eth0' type veth peer name 'myns-2-eth0'

# Assign the interfaces to the namespaces
sudo ip link set 'myns-1-eth0' netns 'test-1'
sudo ip link set 'myns-2-eth0' netns 'test-2'

# Change the names of the interfaces (I prefer to use standard interface names)
sudo ip netns exec 'test-1' ip link set 'myns-1-eth0' name 'eth0'
sudo ip netns exec 'test-2' ip link set 'myns-2-eth0' name 'eth0'

# Assign an address to each interface
sudo ip netns exec 'test-1' ip addr add 192.168.1.1/24 dev eth0
sudo ip netns exec 'test-2' ip addr add 192.168.2.1/24 dev eth0

# Bring up the interfaces (the veth interfaces and the loopback interfaces)
sudo ip netns exec 'test-1' ip link set 'lo' up
sudo ip netns exec 'test-1' ip link set 'eth0' up
sudo ip netns exec 'test-2' ip link set 'lo' up
sudo ip netns exec 'test-2' ip link set 'eth0' up

# Configure routes
sudo ip netns exec 'test-1' ip route add default via 192.168.1.1 dev eth0
sudo ip netns exec 'test-2' ip route add default via 192.168.2.1 dev eth0
```

Now that the two namespaces, `test-1` and `test-2`, have been created,
use `sudo ip netns exec test-1 /bin/bash` to open a shell to `test-1`
and similarly open a shell to `test-2`.  In `test-1`, ping the other
container at address 192.168.2.1 while watching the packet counts for
the various rules using:

```bash
$ watch -d iptables -vnL
```

Try disabling the ping response from `test-2` to observe only the
INPUT chain counters incrementing.

```bash
    echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all
```

Experiment with adding chains and rules to the chains and seeing the
effect on the rule counters.

```bash
$ iptables -N COUNT
$ iptables -A INPUT -j COUNT
$ iptables -A COUNT -d 192.168.2.1 -j RETURN
```

To restore the original table,
```bash
$ iptables -F
$ iptables -X COUNT
```

Alternatively, delete the namespace itself in a shell on the *host*, 

```bash
$ ip netns rm test-1
```
