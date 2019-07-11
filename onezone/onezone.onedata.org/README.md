# Scripts for deploying Onezone @ onezone.onedata.org

## Prerequisites

Prepare a host with the following:
* git
* docker
* docker-compose
* python + pyyaml
* hostname set to onezone.onedata.org
* static DNS NS records pointing at the host IP for subdomain onezone.onedata.org, e.g.:
  ```
  onezone.onedata.org.      120  IN  NS  ns1.onezone.onedata.org
  ns1.onezone.onedata.org.  120  IN  A   149.156.182.35
  ```
  Onezone will handle the requests for the domain using the build-in DNS server,
  which enables subdomain delegation for subject Oneproviders.


## First deployment

1. Place your auth.config in `data/secret/auth.config` - see [OpenID & SAML] for more
2. Run `./onezone.sh start` (see [onezone.sh]) or `docker-compose up -d`
3. Visit https://$HOST_IP:9443 and step through the installation wizard
4. When prompted for emergency passphrase (1st step), provide the one from `data/secret/emergency-passphrase.txt`


## Maintaining the deployment

The Onezone docker is configured to restart automatically. 

You can use the `onezone.sh` script to easily start / stop the deployment and
for some convenient commands allowing to exec to the container or view the logs.


## Updating homepage GUI or docs

The static files of GUI or docs can be updated without stopping the containers - 
they use a mount point from host. To update the homepage or docs, use the 
"./update-homepage.py" script (consult the code or use --help for more).

Update GUI files:
```
./update-homepage.py --gui docker.onedata.org/homepage:ID-67e61b7749
<commit the changes, pull them on the host>
./update-homepage.py --deploy   # run on the host
```

Update docs:
```
./update-homepage.py --docs docker.onedata.org/onedata-documentation:ID-926790c237
<commit the changes, pull them on the host>
./update-homepage.py --deploy   # run on the host
```



[onezone.sh]: ../../README.md#onezone.sh
[OpenID & SAML]: https://onedata.org/#/home/documentation/doc/administering_onedata/openid_saml_configuration/openid_saml_configuration_19_02.html