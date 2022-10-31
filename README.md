# Home-Automation
Rambling bits and pieces about my Home-Assistant and ESPHome setup.

The core of the system is Home-Assistant being fed data from a number of ESPHome devices scattered around the house, plus a couple of other applications for particular services, all running in Docker containers.

The user facing services are;
* Home Assistant
* ESPHome
* Portainer
* NextCloud + Nginx
* Grafana
* [UniFi Controller] (https://github.com/Fraddles/Home-Automation/tree/main/UniFi%20Controller)
* MiniDLNA

And a number of backend services;
* Mosquitto 
* PostgreSQL + Adminer
* InfluxDB + Chronograf
* Telegraf
* LOKI + Promtail

All of the containers are launched using Docker Compose and run as a non-root user wherever possible.

Originally this all ran on a single Pi4-4GB with 120GB SSD until the InfluxDB outgrew the contraints of the original 32bit Raspbian installation, then I had to migrate InfluxDB to another Pi4.  A couple of years later and it is time for some significant updates and upgrades.  And Documentation!

The original setup exposed services to the network using either regular Docker published ports, or `host` networking where required.  This worked well, but made moving services from one host to another a bit of a hassle, as not only did the data for the service need to be moved, but everything that talked to it had to be reconfigured.  Not a big deal for some things, but a real pain for others like MQTT that has a lot of clients to be reconfigred.  I wanted something more dynamic.

I would have liked the option to use my network DHCP server to assign dynamic IPs to the containers.  Docker will not do this, but Podman will, however only in a later version than is currently available for the Pi4, so I needed a solution that would work for Docker.

After much searching and reading the solution I settled on was using a Docker [macvlan] (https://github.com/Fraddles/Home-Automation/tree/main/macvlan) network and assigning each service that needed it a static IP.  This results in the container having a fixed IP that will follow it to whichever host it is run up on.  It also allows each service to have it's own DNS entry (router dependant) so you do not need to remember all those IPs!.  It is not truly dynamic, but it does allow for moving services from one host to another easily.

Currently I am in the process of migrating everything off the two Pi4s onto an old laptop so that the Pi4s can be rebuilt and reconfigued with minimal downtime.  I will try to document here the process of setting up, upgrading and migrating all of these parts...
