# Lets Encrypt wildcard certificate using Cloudflare and Docker

With the introduction of additional voice features in Home-Assistant the lack of HTTPS on my home network to access it was becoming problematic.  Unfortunately it is not possible (AFAIK) to get a globally trusted certificate for a `.home` domain, and using self-signed certificates has numerous drawbacks so I decided to bite the bullet and setup Lets Encrypt.

Lets Encrypt (or any Cert authority really) requires that you have a publicly registered domain name for certificate verification.  There are some free options for this, but since I already have a domain name I decided to use it.  For a single server certificate you can use HTTP (which requires opening port 80 to the world!) or DNS verification.  I wanted a wildcard certificate, so DNS verification is the only option.

DNS verification requires creation of a specific DNS TXT record in your domain.  Lets Encrypt will query this TXT record to validate that you own the domain.  You can create this record manually, but that would be a chore to do every 90 days, so automation is needed.  The tool used for requesting and lifecycling LE certificates is [certbot](https://certbot.eff.org/) and it has [plugins](https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins) to automate the creation and removal of the required TXT records with a number of DNS providers.

My existing DDNS provider is not supported, so I opted to change to a Cloudflare free account.  The full detail on this part is beyond the scope of this page right now, but the TL:DR version;
* Sign up for a Cloudflare account, selecting the Free tier.
* Add your domain to Cloudflare's DNS... It should give you details of your new nameservers.
* Login to your domain registrar and update the nameservers (NS records) for your domain.  NOTE: This will redirect ALL DNS queries for your domain to Cloudflare!
* Wait (up to 24 hours... but usually nowhere near that long)
* While you wait, generate a suitable Cloudflare API key... I followed [this great writeup](https://alandoyle.dev/blog/certbot-using-cloudflare-dns-in-docker/).

Once global DNS has updated, and you have your Cloudflare API key you can move onto the next steps. [More or less taken from here](https://thegermancoder.com/2021/08/09/how-to-use-lets-encrypt-with-docker-and-cloudflare/)

Create a `<FOLDER>` to store your certbot files and in it create a file called `cloudflare.ini` (really, it can be called whatever you like...) with the following contents;
```
dns_cloudflare_api_token = abcde12345
```
Where abcde12345 is replaced by your Cloudflare API token.  This file should have it's permissions locked down to keep your API key secure!

Run the following to pull down the certbot container and generate a wildcard SSL certificate;
```
sudo docker run -it --rm --name certbot -v "<FOLDER>:/etc/letsencrypt" -v "<FOLDER>/cloudflare.ini:/cloudflare.ini" certbot/dns-cloudflare certonly --dns-cloudflare --dns-cloudflare-credentials /cloudflare.ini -m <YOUR_EMAIL> --agree-tos --no-eff-email --dns-cloudflare-propagation-seconds 20 --cert-name <YOUR_DOMAIN> -d <YOUR_DOMAIN> -d *.<YOUR_DOMAIN>
```
`certbot` should then;
* Request a verification token from Lets Encrypt
* Add a TXT record in Cloudflare DNS with the verification token
* <MAGIC_HAPPENS>... Certificate is issued by Lets Encrypt
* Remove TXT record from Cloudflare DNS

The process takes a couple of minutes, and then you should have your new SSL certificate and key stored in `<FOLDER>/live/<YOUR_DOMAIN>`.  However these are actually only symlinks to the latest files stored in `<FOLDER>/archive/<YOUR_DOMAIN>` ...  an important distinction when using docker as I doscovered!

When renewal time comes (have not had to renew mine as at time of writing this) it should be a simple case of going to you initial base `<FOLDER>` and running;
```
sudo docker run -it --rm --name certbot -v "<FOLDER>:/etc/letsencrypt" -v "<FOLDER>/cloudflare.ini:/cloudflare.ini" certbot/dns-cloudflare renew --dns-cloudflare --dns-cloudflare-credentials /cloudflare.ini
```
A `cron` job set to run this command every (weekly? monthly?) should ensure that the certificates are kept up to date.  Some sort of automation to restart any services using the certificate might be good too.

When running containers that use these certificates as a non-root user, there is a couple of permissions updates that are required to alow the files to be accessed.  [From here](https://eff-certbot.readthedocs.io/en/stable/using.html#where-are-my-certificates).  You can create a new group for this, or use whatever group your containers run as;
```
sudo chmod 0755 <FOLDER>/{live,archive}
sudo chgrp <USER_GROUP> <FOLDER>/live/<YOUR_DOMAIN>/privkey.pem
sudo chmod 0640 <FOLDER>/live/<YOUR_DOMAIN>/privkey.pem
```
