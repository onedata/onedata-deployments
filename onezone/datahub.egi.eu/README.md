# Scripts for deploying Onezone @ datahub.egi.eu

## Cluster setup

There are 4 cluster nodes, 2 used for oz-worker and 2 for couchbase:
* onedata00.cloud.plgrid.pl
* onedata01.cloud.plgrid.pl
* zonedb01.cloud.plgrid.pl
* zonedb02.cloud.plgrid.pl

Use `./attach-to-all-nodes.sh` to open tmux session with ssh to each.


## Prerequisites

Prepare 4 hosts with the following:
* git
* docker
* docker-compose
* python + pyyaml
* properly configured hostnames (as in cluster setup above)
* static DNS NS records pointing at the host IP for subdomain datahub.egi.eu, e.g.:
  ```
  datahub.egi.eu.      120  IN  NS  ns1.datahub.egi.eu
  datahub.egi.eu.      120  IN  NS  ns2.datahub.egi.eu
  ns1.datahub.egi.eu.  120  IN  A   149.156.182.4
  ns2.datahub.egi.eu.  120  IN  A   149.156.182.24
  ```
  Onezone will handle the requests for the domain using the build-in DNS server,
  which enables subdomain delegation for subject Oneproviders (you can find out
  more [here][Subdomain delegation]).


## First deployment

1. SSH to the master node (`ubuntu@onedata00.cloud.plgrid.pl`)
2. Navigate to the path `.../onedata-deployments/onezone/datahub.egi.eu`
3. Run `./pull-changes-on-all-nodes.sh` to checkout the latest commit on all nodes
4. Place your auth.config in `./data/secret/auth.config` - see [OpenID & SAML] for more
5. Place your emergency password in `./data/secret/emergency-password.txt`
6. Place your mailer.config in `./data/secret/mailer.config` - see [app.config], section "Mailer configuration" for more
7. Run `./distribute-secret-config.sh` to distribute the secret files 
8. Verify that `data/configs/overlay.config` includes desired and up-to-date config
9. Run `./onezone.sh start` **on all nodes** (see [onezone.sh]) 
10. Visit `https://$HOST_IP:9443` and step through the installation wizard
11. When prompted for emergency passphrase (1st step), provide the one from `data/secret/emergency-passphrase.txt`


## Maintaining the deployment

The Onezone dockers (on each host) are configured to restart automatically. 

You can use the `onezone.sh` script to easily start / stop the deployment and
for some convenient commands allowing to exec to the container or view the logs.

Regularly back-up the persistence directory: `./data/persistence`. The script `odbackup.sh`
can be used to backup the service. See the top-level `../../README.md` for 
usage instructions. The backup for the datahub onezone service is configured with 
the following env vars:
`S3_CONF_PATH=~/.s3cfg-prod-test`
`S3_BUCKET=s3://datahub-backups`

Currently, the backup script is called each day at about 1am. See `/etc/crontab` and 
`/etc/cron.d/daily/datahub-backup` for details. 

### Upgrading / modifying the deployment

1. Make desired changes (e.g. bump the Onezone image)
2. Commit the changes to this repository
3. SSH to the master node (`ubuntu@onedata00.cloud.plgrid.pl`)
4. Run `./pull-changes-on-all-nodes.sh` to checkout the latest commit on all nodes
5. Pull the new Onezone docker on all nodes
6. If auth.config or mailer.config needs change, from the master node:
    * overwrite the desired files in `./data/secret/`
    * run `./distribute-secret-config.sh` to distribute it
7. While the system is running, create a backup **on all nodes**, e.g.
    * `sudo rsync -avzs ./data/persistence ~/backup-20191115-18.02.2` 
8. Run `./onezone.sh stop` **on all nodes** (see [onezone.sh]) 
9. Repeat the backup **on all nodes** again to include changes from these couple of seconds
    * `sudo rsync -avzs ./data/persistence ~/backup-20191115-18.02.2` 
10. Run `./onezone.sh start` **on all nodes** (see [onezone.sh]) 


## More

Please refer to the [documentation][onezone docs].


[Subdomain delegation]: https://onedata.org/#/home/documentation/doc/administering_onedata/onezone_tutorial[dns-records-setup-for-subdomain-delegation].html
[onezone.sh]: ../../README.md#onezone.sh
[OpenID & SAML]: https://onedata.org/#/home/documentation/doc/administering_onedata/openid_saml_configuration/openid_saml_configuration_19_02.html
[onezone docs]: https://onedata.org/#/home/documentation/doc/administering_onedata/onezone_tutorial.html
[app.config]: https://github.com/onedata/oz-worker/blob/develop/rel/files/app.config