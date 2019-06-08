# Description

The native Docker networking capability is built around Linux bridges, which
makes it a layer 2 solution.  `layer3.csh` is an experiment to see whether I
could use layer 3 routing between two Docker networks.  This script creates two
containers in separate networks and attaches a third container between them.
The user can them `docker exec` to the shells and attempt to ping through the
3rd containers.  Please see the comments for more information.
