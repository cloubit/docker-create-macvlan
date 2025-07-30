#!/bin/sh

# Define Docker variables:
DOCKERPATH=/usr/bin/docker

# Define network variables:
DRIVER=macvlan
SUBNET=10.10.10.0/24
IPRANGE=10.10.10.128/28
GATEWAY=10.10.10.1
ADAPTER=my-lan-adapter
NETWORKNAME=my-macvlan-name
macvlan_mode=bridge

# Define host addresses:
HOST1="10.10.10.129"
HOST2="10.10.10.130"


echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME Script started successfully" >> $NETWORKNAME.log

while true;
    do
    # check docker status.
    while ! $DOCKERPATH info > /dev/null 2>&1;
        do
            echo "$(date '+%Y-%m-%d %H:%M:%S') Docker is inactiv." >> $NETWORKNAME.log
            sleep 5
    done
        echo "$(date '+%Y-%m-%d %H:%M:%S') Docker is activ." >> $NETWORKNAME.log
        # Check if Docker MacVlan available.
        docker network inspect $NETWORKNAME | grep -i "$NETWORKNAME" 
    if [ $? -eq 0 ]; 
        then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME is activ." > /dev/null
    else
        # Create docker MacVlan.
        docker network create --driver $DRIVER --subnet $SUBNET --gateway $GATEWAY --ip-range=$IPRANGE --opt parent=$ADAPTER $NETWORKNAME
        sleep 3
        # Check if Docker macvlan was created.
        docker network inspect $NETWORKNAME | grep -i "$NETWORKNAME" 
        if [ $? -eq 0 ]; 
        then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME was created." >> $NETWORKNAME.log
        else
        echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME was created." >> $NETWORKNAME.log
        fi
    fi
    # Check is Host reachable.
    if ping -c 1 -W 1 $HOST1 > /dev/null 2>&1; 
        then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Host $HOST1 reachable." > /dev/null
    else
        # Configure Docker MacVlan.
        ip link add $NETWORKNAME link $ADAPTER type $DRIVER mode bridge
        ip addr add $HOST1/32 dev $NETWORKNAME
        ip addr add $HOST2/32 dev $NETWORKNAME
        ip link set $NETWORKNAME up
        ip route add $IPRANGE dev $NETWORKNAME
        echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME was configured with Host $HOST1, $HOST2." >> $NETWORKNAME.log
        sleep 5
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') Script run successfully. Check output before." >> $NETWORKNAME.log
    sleep 30 
done
