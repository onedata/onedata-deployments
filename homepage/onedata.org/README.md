# Scripts for deploying onedata.org homepage

This directory contains scripts and docker configs for deploying onedata.org 
homepage. It is based on the nginx-certbot boilerplate by Philipp Schmieder:
https://github.com/wmnnd/nginx-certbot


## Prerequisites

Prepare a host with the following:
* git
* docker
* docker-compose
* python + pyyaml
* hostname set to onedata.org
* static DNS A records pointing to the host's IP for domains onedata.org and www.onedata.org


## Preview the docs locally

1. Run `./update-homepage.py --deploy` to deploy static GUI / docs files according to `homepage-config.yaml`
2. Run `./test-preview.sh`, the docs page should show up automatically in your browser on `http://localhost:8080` (if not, visit the page manually) - this starts a simple docker with nginx


## First deployment

1. Run `./update-homepage.py --deploy` to deploy static GUI / docs files according to `homepage-config.yaml`
2. Run `./init-letsencrypt.sh`, you might want to enable staging mode before (see the beginning of the script)
3. Verify if the certificates are OK and homepage is served on onedata.org
4. Run `docker-compose up -d`


## Maintaining the deployment

The maintenance is quite easy - dockers are configured to restart automatically, 
there is a certbot container running that tries to renew the certificates every
12 hours, plus a periodic task that reloads the nginx server to pick up the new certs. 

In case the dockers are killed somehow, just do `docker-compose up -d`.


## Updating homepage GUI or docs

The static files of GUI or docs can be updated without stopping the containers - 
they use a mount point from host. To update the homepage or docs, use the 
`./update-homepage.py` script (consult the code or use --help for more).

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
