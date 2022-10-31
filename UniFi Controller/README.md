# UniFi Controller in Docker with macvlan static IP

Docker Compose YAML file to run the UniFi controller container on a macvlan network with a statically assigned IP on the host network.

The macvlan network needs to be setup beforehand, see https://github.com/Fraddles/Home-Automation/tree/main/macvlan

This is what started my macvlan journey when the UniFi controller kept on 'stealing' the hosts IP and causing the host to get a new IP at each DHCP renewal.

The (excellent) container image used is this one; https://github.com/jacobalberty/unifi-docker
