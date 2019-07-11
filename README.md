# Production Onedata Deployments

This repository contains configs and docker-compose files for deploying and
maintaining production Onedata deployments. You can also find some examples 
(templates) to adjust to your needs and deploy your own instances.


## Structure

* **homepage** - configs for deploying the homepage (onedata.org), 
                 which includes general info about Onedata, documentation and 
                 API reference
* **onezone** - configs used in production Onezone instances (per domain), 
                and some example templates from which the production configs 
                were derived
* **oneprovider** - configs used in production Oneprovider instances 
                    (per domain) and examples mostly intended for people who
                    do not want to use the [Onedatify wizard][]
* **bin** - useful scripts 
                    
                    
                    
## Useful scripts

Can be found in the `bin` directory.

### onezone.sh 

The `onezone.sh` is merely a wrapper for the docker-compose command that simplifies
emergency passphrase management. The passphrase is expected in  
`data/secret/emergency-passphrase.txt` (relative to given deployment). Before
deploying, you can put there an emergency passphrase of your choice. Otherwise, 
it will be generated. If installing using the graphical wizard, provide the same
passphrase as in the file.

If you wish, you can simply use `docker-compose up -d`, but be aware of the following:
* If you are installing using the graphical wizard, the emergency passphrase is not needed
  to be specified beforehand - you will be asked to set up one during installation
* If you are installing using the batch mode, you must provide an emergency 
  passphrase in the EMERGENCY_PASSPHRASE env variable (which is referenced in 
  `docker-compose.yaml`)
* If you are restarting the deployment, EMERGENCY_PASSPHRASE is not obligatory, 
  but it will allow you to see more output from the service startup.
                    
[Onedatify wizard]: https://onedata.org/#/home/documentation/doc/administering_onedata/oneprovider_tutorial[onedatify-based-setup].html