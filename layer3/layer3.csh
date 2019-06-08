#!/bin/bash

#
# script to bring up two containers in separate docker (bridge) networks
# and use a third container to route between them
#

export IMAGE=alpine


#
# create networks: red and blue
#
docker network rm red blue

docker network create \
--driver=bridge \
--subnet=172.20.0.0/16 \
blue

docker network create \
--driver=bridge \
--subnet=172.21.0.0/16 \
red

#
# create router and connect it to both red and blue networks
#


# both capabilities needed to modify iptables
docker run --cap-add NET_ADMIN --cap-add NET_RAW --name router --network blue \
--ip=172.20.0.3 \
-itd --rm ${IMAGE}

docker network connect --ip=172.21.0.3 red router

# add iptables to the base build to monitor counters in the chains
#
docker exec -it router apk update
docker exec -it router apk add iptables

# 
# bring up containers in each of the networks
#
docker run --cap-add NET_ADMIN --name blue --network blue \
--ip=172.20.0.2 \
-itd \
--rm ${IMAGE}

docker run --cap-add NET_ADMIN --name red --network red \
--ip=172.21.0.2 \
-itd \
--rm ${IMAGE}



#
# attach a shell to these containers (docker exec -it red ash), delete the
# default route, and change the default route to the .3 address of the 3rd
# container
# ip route del default
# ip route add default via 172.20.0.3

# since ip forwarding is enabled by default, pings from 172.20.0.2 to
# 172.21.0.2 should flow right through the 3rd container
#
# the counters visible in the 3rd container using watch -d iptables -nvL
# should be incrementing for the FORWARD chain


