# Onezone deployment example (wizard)

This template can be used to set up a Onezone instance using a graphical wizard
installation. After starting the instance, the Onepanel service will be running
in the docker container - you can visit `https://$HOST_IP:9443` and a wizard
will walk you through the installation.


## Prerequisites

Prepare a host with the following:
* git
* docker
* docker-compose
* python + pyyaml
* hostname set to example.com   *(substitute with desired hostname)*
* proper DNS setup of your domain, either:
    * make sure your domain is resolvable by DNS
    * or delegate the domain to Onezone's built-in DNS server ([see more][Subdomain delegation])


## First deployment

1. Place your auth.config in `data/secret/auth.config` - see [OpenID & SAML] for more
2. Run `./onezone.sh start` (see [onezone.sh]) or `docker-compose up -d`
3. Visit `https://$HOST_IP:9443` and step through the installation wizard
4. When prompted for emergency passphrase (1st step), provide the one from `data/secret/emergency-passphrase.txt`


## Maintaining the deployment

The Onezone docker is configured to restart automatically. 

You can use the `onezone.sh` script to easily start / stop the deployment and
for some convenient commands allowing to exec to the container or view the logs.


[Subdomain delegation]: https://onedata.org/#/home/documentation/doc/administering_onedata/onezone_tutorial[dns-records-setup-for-subdomain-delegation].html
[onezone.sh]: ../../README.md#onezone.sh
[OpenID & SAML]: https://onedata.org/#/home/documentation/doc/administering_onedata/openid_saml_configuration/openid_saml_configuration_19_02.html