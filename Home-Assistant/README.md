# Home-Assistant in Docker

Home-Assistant running in Docker using Compose with Lets Encrypt wildcard SSL certificate plus Whisper and Piper add-ons for voice services.

The HASS compose stack consists of three containers;
* Home-Assistant
* wyoming-whisper
* wyoming-piper

Home-Assistant configuration and files lives in a subfolder called 'config', Whisper and Piper likewise have their files in subfolders named 'whisper' and 'piper' respectively.

All containers run as an unprivileged user that needs to exist on the host before hand, and folder permissions need to allow full access to the subfolders for this user.

The HA container is exposed to the network using a [macvlan](https://github.com/Fraddles/Home-Automation/tree/main/macvlan) connection so that it has a real IP on the main LAN.  The Whisper and Piper containers are not exposed to the LAN and communicate with HA using an internal docker network.  One point of note with this is that HA did not seem to pick up the Whisper and Piper containers automatically, but they were easily added manually using the container name as the address and the appropriate port (10200 for Piper and 10300 for Whisper).

The Lets Encrypt certificate is generated using certbot in a separate process and then mapped into the HA container.  The certbot process will be covered in a separate topic.  Due to the way that cetbot handles 'live' and 'archived' certificates using symlinks it is neccessary to map two folders into the container for the certificates to be accessible to Home-Assistant (see here for a concise exlanation; https://superuser.com/questions/1357862/how-to-mount-certificates-from-certbot-to-use-inside-docker-container).

The following needs to be added to the HA `configuration.yaml` to use the mapped certificates for HTTPS;
```
http:
  ssl_certificate: /ssl/live/<certificate_name>/fullchain.pem
  ssl_key: /ssl/live/<certificate_name>/privkey.pem
```
