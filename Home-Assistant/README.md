# Home-Assistant in Docker

Home-Assistant running in Docker using Compose with Lets Encrypt wildcard SSL certificate plus Whisper, Piper and OpenWakeWord add-ons for voice services.

My HASS compose stack consists of four containers;
* Home-Assistant core
* wyoming-whisper
* wyoming-piper
* wyoming-openwakeword

Home-Assistant configuration and files live in a subfolder called 'config', Whisper, Piper and OpenWakeWord have their files in subfolders named 'whisper', 'piper', and 'wakeword' respectively.

All containers in the stack run as an unprivileged user (1001) that needs to exist on the host before-hand.  Folder permissions need to allow full access to all subfolders for this user.

### Network
The HA container is exposed to the network using a [macvlan](https://github.com/Fraddles/Home-Automation/tree/main/macvlan) connection so that it has a real IP on the main LAN.  The other containers are not exposed to the LAN and communicate with HA using an internal docker network.  One point of note with this is that HA did not seem to pick up the extra containers automatically, but they were easily added manually using the container name as the address and the appropriate port (10200 for Piper, 10300 for Whisper, and 10400 for OpenWakeWord).

### Lets Encrypt
The Lets Encrypt certificate is generated using certbot in a separate process (see [Lets Encrypt](https://github.com/Fraddles/Home-Automation/tree/main/Lets%20Encrypt)) and then mapped into the HA container using bind mounts.

The following needs to be added to the HA `configuration.yaml` to use the certificates for HTTPS;
```
http:
  ssl_certificate: /ssl/fullchain.pem
  ssl_key: /ssl/privkey.pem
```
This will still serve up HA on port 8123, but using HTTPS instead of HTTP, unless you specify otherwise by also setting `server_port` in your http config.
