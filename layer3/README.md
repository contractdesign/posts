# Description

The native Docker networking capability is built around Linux bridges, which
makes it a layer 2 solution.  `layer3.csh` is an experiment to see whether I
could use layer 3 routing between two Docker networks.  This script creates two
containers in separate networks and attaches a third container between them.
The user can `docker exec` with a shell and attempt to ping from one to another
through the 3rd container.  Please see the comments for more information.
