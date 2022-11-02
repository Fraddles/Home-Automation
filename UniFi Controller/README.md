# UniFi Controller in Docker with macvlan static IP

Docker Compose YAML file to run the UniFi controller container on a macvlan network with a statically assigned IP on the host network.

This is what started my macvlan journey when the UniFi controller kept on 'stealing' the hosts IP address...

If you have a USG, are using dnsmasq for DHCP/DNS, and have your host machine using DHCP...  It seems that the controller overrides the IP of the host it is running on with the hostname 'unifi' in local DNS (within a minute or so of the host getting a new lease), causing the host to be refused that IP again at its next DHCP renewal, resulting in the host constantly changing IP address.  The macvlan network resolves this issue by giving the controller its own IP address.

The controller runs as unprivileged user '1001:1001' which needs to already exist on the host or you can use a different user.  Watch out for permissions issues on the mapped volumes!

The macvlan network needs to be setup beforehand, see https://github.com/Fraddles/Home-Automation/tree/main/macvlan

The (excellent) container image used is this one; https://github.com/jacobalberty/unifi-docker
