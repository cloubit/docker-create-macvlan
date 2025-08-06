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

echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME Script started successfully" >> $NETWORKNAME.log

while true;
    do
    # check docker status.
    while ! $DOCKERPATH info > /dev/null 2>&1;
        do
            echo "$(date '+%Y-%m-%d %H:%M:%S') Docker is inactiv." >> $NETWORKNAME.log
            sleep 5
    done
        echo "$(date '+%Y-%m-%d %H:%M:%S') Docker is activ." > /dev/null
    # Check if Docker MacVlan available.
    if docker network inspect $NETWORKNAME | grep -i "$NETWORKNAME" 
        then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME is activ." > /dev/null
    else
        # Create docker MacVlan.
        docker network create --driver $DRIVER --subnet $SUBNET --gateway $GATEWAY --ip-range=$IPRANGE --opt parent=$ADAPTER $NETWORKNAME
        sleep 3
        # Check if Docker macvlan was created.
        if docker network inspect $NETWORKNAME | grep -i "$NETWORKNAME" 
            then
            echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME was created." >> $NETWORKNAME.log
        else
            echo "$(date '+%Y-%m-%d %H:%M:%S') $NETWORKNAME was created." >> $NETWORKNAME.log
        fi
    fi
    # Check is promiscuous mode active.
    if ip a | grep -i "$ADAPTER.*PROMISC"
        then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Promiscuous mode on adapter $ADAPTER is active." > /dev/null
    else
        ip link set $ADAPTER promisc on
        echo "$(date '+%Y-%m-%d %H:%M:%S') Promiscuous mode on adapter $ADAPTER was configured." >> $NETWORKNAME.log
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') Script run successfully. Check output before." >> $NETWORKNAME.log
    sleep 120 
done
