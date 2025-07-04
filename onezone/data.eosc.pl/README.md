# Scripts for deploying Onezone @ data.eosc.pl

## Prerequisites

Prepare a host with the following:
* git
* docker
* docker-compose
* python + pyyaml
* hostname set to data.eosc.pl
* static DNS NS records pointing at the host IP for subdomain data.eosc.pl, e.g.:
  ```
  data.eosc.pl. IN NS ns1.data.eosc.pl
  data.eosc.pl. IN NS ns2.data.eosc.pl
  ns1.data.eosc.pl. IN A 149.156.10.134
  ns2.data.eosc.pl. IN A 149.156.10.134
  ```
  Onezone will handle the requests for the domain using the build-in DNS server,
  which enables subdomain delegation for subject Oneproviders (you can find out
  more [here][Subdomain delegation]).


## First deployment

1. Place your auth.config in `data/secret/auth.config` - see [OpenID & SAML] for more
2. Run `./onezone.sh start` (see [onezone.sh]) 
3. The installation should happen automatically (batch mode) and might take a while 
   (consult container logs for indication whether the installation was finished)
4. Visit https://data.eosc.pl and log in using the credentials 
`admin:EMERGENCY_PASSPHRASE` (can be found in `data/secret/emergency-passphrase.txt`)


## Maintaining the deployment

The Onezone docker is configured to restart automatically. 

You can use the `onezone.sh` script to easily start / stop the deployment and
for some convenient commands allowing to exec to the container or view the logs.

Regularly back-up the persistence directory: `data/persistence`. The script `odbackup.sh`
can be used to backup the service. See the top-level `../../README.md` for 
usage instructions.

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
