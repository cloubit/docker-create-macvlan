#!/bin/sh

# Define network variables:
SUBNET=10.10.10.0/24
IPRANGE=10.10.10.128/28
GATEWAY=10.10.10.1
ADAPTER=my-lan-adapter
NETWORKNAME=my-macvlan-name

# Define Docker variables:
DOCKERPATH=/usr/bin/docker

# check docker status.
while ! $DOCKERPATH info > /dev/null 2>&1;
do
    echo "$(date '+%Y-%m-%d %H:%M:%S') Docker is inactiv." >> $NETWORKNAME.service.log
    sleep 5
done
echo "$(date '+%Y-%m-%d %H:%M:%S') Docker is activ." >> $NETWORKNAME.service.log

# Check if Docker MacVlan available.
if docker network inspect $NETWORKNAME | grep -i "$NETWORKNAME" 
    then
    echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME is activ." >> $NETWORKNAME.service.log
else
    # Create docker MacVlan.
    docker network create --driver macvlan --subnet $SUBNET --gateway $GATEWAY --ip-range=$IPRANGE --opt parent=$ADAPTER $NETWORKNAME
    sleep 3
    # Check if Docker macvlan was created.
    if docker network inspect $NETWORKNAME | grep -i "$NETWORKNAME" 
        then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME was created." >> $NETWORKNAME.service.log
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME was not created." >> $NETWORKNAME.service.log
    fi
fi

# Check is promiscuous mode active.
if ip a | grep -i "$ADAPTER.*PROMISC"
    then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Promiscuous mode on adapter $ADAPTER is active." >> $NETWORKNAME.service.log
else
    ip link set $ADAPTER promisc on
    if ip a | grep -i "$ADAPTER.*PROMISC"
        then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Promiscuous mode on adapter $ADAPTER is active." >> $NETWORKNAME.service.log
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') Promiscuous mode on adapter $ADAPTER is not active" >> $NETWORKNAME.service.log
    fi
fi
echo "$(date '+%Y-%m-%d %H:%M:%S') Script has run. Check output before." >> $NETWORKNAME.service.log
