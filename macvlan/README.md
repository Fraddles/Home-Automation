# Docker macvlan setup

The required setup and caveats for setting up docker macvlan networking to give individual containers static IP addresses.

A Docker macvlan network gives each container a unique MAC address on a separate virtual interface on the host.  This allows it to have a separate IP address that is native to the host network.  Any other devices on the network will see the container, and be able to communicate with it, as if it were any other device on the network.

HOWEVER, out of the box the HOST running the container will be unable to communicate with it and vice-versa.  This is due to restrictions in the Linux kernel that block the macvlan network and the host network from communicating.  A little bit of network trickery on the host allows bypassing this restriction.

As with most things Linux there is many ways to do this and there is many sources of information available on the Internet, from the official documentation to random blurbs like this one.  I will not go into the full details of macvlan networks, just some of my own setup.  Your search engine of choice would probably unearth many of the same pages I looked at, but I will include a couple at the bottom of this page.

Note; These instructions tested on Regular and Raspberry Debian 10/11 but should work as-is on most Linux distributions with only changes to interface names and IPs as appropriate.  No idea for MacOS or Windows sorry.

Assuming you have your host OS of choice and Docker installed and ready to go...

#### Create the macvlan network;

```shell
docker network create -d macvlan -o parent=eth0 \
 --subnet=192.168.0.0/24 \
 --gateway=192.168.0.1 \
 --ip-range=192.168.0.16/28 \
 --aux-address 'host1=192.168.0.16' \
--aux-address 'host2=192.168.0.17' \
--aux-address 'host3=192.168.0.18' \
 dockermacvlan
```

Notes;
* I used the same IP range on all of my hosts.  This is OK as long as you statically assign an IP to each container.  If you do not assign a static IP to a container, Docker will hand them out on a first-come first served basis with no coordination between hosts, potentially resulting in IP conflicts.
* The IP range I used for the macvlan network is excluded from DHCP in my router to prevent it handing out those addresses.
* As it turns out the `aux-address` entries are not really necessary due to the fact that I am manually assigning IP addresses to the containers.  You could add an `aux-address` entry for each IP that is manually allocated but then the network needs to be deleted and recreated each time you make a change…

Once the macvlan network is setup you can enable the host to talk to containers on the macvlan network with a bridge on the host.

#### Add a bridge interface;
```
ip link add dockmac-shim link eth0 type macvlan mode bridge
```
#### Give your bridge an IP;
```
ip addr add 192.168.0.16/32 dev dockmac-shim
```
#### Start the interface;
```
ip link set dockmac-shim up
```
#### Create a route to the macvlan network
```
ip route add 192.168.0.16/28 dev dockmac-shim
```

And hey presto, your host can now communicate with containers on the macvlan network that it hosts.

Notes;
* I initially got creative and assigned the same macvlan IP to all of my hosts thinking traffic on this interface would never leave the host.  BZZT WRONG.  Amongst other things traffic destined for containers in other hosts macvlan networks uses this interface.  Oddly enough, with them all using the same IP everything still worked, but there were some odd delays…
* Depending on the DHCP service your host (applicable to Raspberry flavoured Debian 11, not stock Debian 11) uses you may need/want to disable DHCP for your macvlan bridge interface.  On a Pi add `denyinterfaces dockmac-shim` to `/etc/dhcpcd.conf` and reboot or restart the DHCP service.
* The docker network is persistent across reboots, however the host bridge setup is NOT.  To make this configuration persistent I created a simple systemd service to run a script to start the bridge at boot.  If you have made it this far down the Docker rabbit hole you can probably manage a simple system service, but the attached files are what I use.  I probably should update it so it handles start-up AND shutdown :P

Once everything is in place you can use the macvlan network for your containers with the following additions to your docker-compose.yaml
```yaml
services:
  xxxxxx:
    ...
    networks:
      dockermacvlan:
        ipv4_address: 192.168.0.###

networks:
  dockermacvlan:
    external: true
```
