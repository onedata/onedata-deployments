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


## Preview the homepage locally

Run `./test-preview.sh`, the homepage should show up automatically in your 
browser on `http://localhost:8000` (if not, visit the page manually) - 
this runs the homepage static docker with a web server inside.


## First deployment

1. Run `./update-homepage.py --deploy` to deploy static homepage files according to `homepage-docker-image.cfg`
2. Run `./init-letsencrypt.sh`, you might want to enable staging mode before (see the beginning of the script)
3. Verify if the certificates are OK and homepage is served on onedata.org
4. Run `docker-compose up -d`


## Maintaining the deployment

The maintenance is quite easy - dockers are configured to restart automatically, 
there is a certbot container running that tries to renew the certificates every
12 hours, plus a periodic task that reloads the nginx server to pick up the new certs. 

In case the dockers are killed somehow, just do `docker-compose up -d`.


## Updating the homepage

The static files of homepage can be updated without stopping the containers - 
they use a mount point from host. Use the `./update-homepage.py` script 
(consult the code or use --help for more). General procedure looks like the following:

1. Run `./update-homepage.py --image docker.onedata.org/homepage:ID-67e61b7749`
in the repository (replace with desired ID), this will change the image 
in `homepage-docker-image.cfg`.

2. Commit and push the changes

3. Pull the changes on the onedata.org host

4. Run `./update-homepage.py --deploy` on the onedata.org host

5. Done, the nginx will be serving the new homepage from now on.