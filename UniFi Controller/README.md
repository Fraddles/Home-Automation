# UniFi Controller in Docker with macvlan static IP

Docker Compose YAML file to run the UniFi controller container on a macvlan network with a statically assigned IP on the host network.

This is what started my macvlan journey when the UniFi controller kept on 'stealing' the hosts IP and causing the host to get a new IP at each DHCP renewal.

If you have a USG and are using dnsmasq for DHCP/DNS it seems that the controller overrides the IP of the host with the hostname 'unifi' in local DNS (within a minute of the host getting a new lease), causing the host to be refused that IP again at its next DHCP renewal.  On the upside this means that your devices can always(?) find the controller without manual intervention, as there is always a current DNS entry for 'unifi'.

The controller runs as unprivileged user '1001:1001' which needs to already exist on the host or you can use a different user.  Watch out for permissions issues on the mapped volumes!

The macvlan network needs to be setup beforehand, see https://github.com/Fraddles/Home-Automation/tree/main/macvlan

The (excellent) container image used is this one; https://github.com/jacobalberty/unifi-docker
