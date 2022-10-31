#!/bin/sh
#
# Let the Docker host and containers on the macvlan network talk to 
# each other using a macvlan shim.
# Put this script in /usr/local/bin and make it executable.
# Need to adjust the interface name and IPs as required.

HOSTIF=eth0
HOSTIP=192.168.0.16
MACSUB=192.168.0.16/28

# Test if the macvlan interface already exists
if ip link show | grep "dockmac-shim" > /dev/null; then
  echo "*ERROR: dockmac-shim bridge interface already exists."; exit
fi

# Create the bridge and assign IP address
echo "*INFO: Setting up macvlan bridge interface on $HOSTIF"
ip link add dockmac-shim link $HOSTIF type macvlan mode bridge
ip addr add $HOSTIP/32 dev dockmac-shim
ip link set dockmac-shim up

# Add a route to the macvlan IP range
echo "*INFO: Setting up route for $MACVLAN subnet"
ip route add $MACSUB dev dockmac-shim
