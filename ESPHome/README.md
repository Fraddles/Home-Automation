# ESPHome

ESPHome is an excellent framework for building ESP8266/ESP32 based IoT devices;  https://esphome.io/

It runs nicely as a docker container using the offical image; https://hub.docker.com/r/esphome/esphome

For my own deployment I opted for a [macvlan](https://github.com/Fraddles/Home-Automation/tree/main/macvlan) network to give the container it's own IP and DNS, and to run the container as a non-root user.  The latter may have implications if you want to try and pass serial devices into the container.
