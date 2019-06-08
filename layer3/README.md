# Description

The native Docker networking capability is built around Linux bridges, which
makes it a layer 2 solution.  `layer3.csh` is an experiment to see whether I
could use layer 3 routing between two Docker networks.  This script creates two
containers, each in a separate network, and attaches a third container to both
networks on separate interfaces.

Once the network and containers are running, the user can verify functionality
by `docker exec` with a shell and pinging from one to another.
Please see the comments for more information.
