# ESPHome

ESPHome is an excellent framework for building ESP8266/ESP32 based IoT devices;  https://esphome.io/

It runs nicely as a docker container using the offical image; https://hub.docker.com/r/esphome/esphome

For my own deployment I opted for a [macvlan](https://github.com/Fraddles/Home-Automation/tree/main/macvlan) network to give the container it's own IP and DNS, and to run the container as a non-root user.  The latter may have implications if you want to try and pass serial devices into the container.

The environment variables are required to allow the container to run as a non-root user, and to re-apply some settings that are reset to defaults as a result of the changed `platform.io` folder locations.

If you are using Home-Assistant with a standalone docker container like this you can get a sidebar item in HA for your ESPHome dashboard with the following added to your HA `configuration.yaml`;
```
# iframe panels
panel_iframe:
  router:
    title: "ESPHome"
    url: "http://<ESPHOME HOST>:6052"
    icon: mdi:chip
```
