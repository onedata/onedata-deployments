# Onezone deployment example (wizard)

This template can be used to set up a Onezone instance using batch mode
installation (determined by the `ONEPANEL_BATCH_MODE=false` variable in 
`docker-compose.yaml`). After starting the instance, the Onepanel service will 
be running in the docker container - you can visit `https://$HOST_IP:9443` and a 
wizard will walk you through the installation.


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
2. Run `./onezone.sh start` (see [onezone.sh]) 
3. Visit `https://$HOST_IP:9443` and step through the installation wizard
4. When prompted for emergency passphrase (1st step), provide the one from `data/secret/emergency-passphrase.txt`


## Maintaining the deployment

The Onezone docker is configured to restart automatically. 

You can use the `onezone.sh` script to easily start / stop the deployment and
for some convenient commands allowing to exec to the container or view the logs.

Regularly back-up the persistence directory: `data/persistence`.

To upgrade, stop the deployment (`./onezone.sh stop`), bump the onezone image 
version in `docker-compose.yaml` and start the deployment (`./onezone.sh start`).
Make sure to back-up the persistence directory beforehand.

If you modify anything (e.g. onezone image), please commit the changes rather
than make them only locally on the host.


## More

Please refer to the [documentation][onezone docs].


[Subdomain delegation]: https://onedata.org/#/home/documentation/doc/administering_onedata/onezone_tutorial[dns-records-setup-for-subdomain-delegation].html
[onezone.sh]: ../../README.md#onezone.sh
[OpenID & SAML]: https://onedata.org/#/home/documentation/doc/administering_onedata/openid_saml_configuration/openid_saml_configuration_19_02.html
[onezone docs]: https://onedata.org/#/home/documentation/doc/administering_onedata/onezone_tutorial.html
