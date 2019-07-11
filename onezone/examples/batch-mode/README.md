# Onezone deployment example (wizard)

This template can be used to set up a Onezone instance using graphical wizard
installation (determined by the `ONEPANEL_BATCH_MODE=true` variable in 
`docker-compose.yaml`). The service will be installed automatically according
to the config in BATCH_CONFIG section of `docker-compose.yaml`. 


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
3. The installation should happen automatically (batch mode) and might take a while 
   (consult container logs for indication whether the installation was finished)
4. Visit https://demo.onedata.org and log in using the credentials 
`admin:EMERGENCY_PASSPHRASE` (can be found in `data/secret/emergency-passphrase.txt`)


## Maintaining the deployment

The Onezone docker is configured to restart automatically. 

You can use the `onezone.sh` script to easily start / stop the deployment and
for some convenient commands allowing to exec to the container or view the logs.

Regularly back-up the persistence directory: `data/persistence`.

To upgrade, stop the deployment (`./onezone.sh stop`), bump the onezone image 
version in `docker-compose.yaml` and start the deployment (`./onezone.sh start`).
Make sure to back-up the persistence directory beforehand.


## More

Please refer to the [documentation][onezone docs].


[Subdomain delegation]: https://onedata.org/#/home/documentation/doc/administering_onedata/onezone_tutorial[dns-records-setup-for-subdomain-delegation].html
[onezone.sh]: ../../README.md#onezone.sh
[OpenID & SAML]: https://onedata.org/#/home/documentation/doc/administering_onedata/openid_saml_configuration/openid_saml_configuration_19_02.html
[onezone docs]: https://onedata.org/#/home/documentation/doc/administering_onedata/onezone_tutorial.html
