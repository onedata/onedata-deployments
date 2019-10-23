# Production Onedata Deployments

This repository contains configs and docker-compose files for deploying and
maintaining production Onedata deployments. You can also find some examples 
(templates) to adjust to your needs and deploy your own instances.


## Structure

* **homepage** - configs for deploying the homepage, which includes general info 
                 about Onedata, documentation and API reference
                 
    * *onedata.org* ([README](homepage/onedata.org/README.md)) - 
                    currently the only one homepage deployment
                      
                    
    
* **onezone** - configs used in production Onezone instances (per domain), 
                and some example templates from which the production configs 
                were derived
                
    * *onezone.onedata.org* - ([README](onezone/onezone.onedata.org/README.md)) 
                              stable Onezone deployment used as a showcase for the
                              Onedata system (referenced on the homepage)                            
                
    * *demo.onedata.org* - ([README](onezone/demo.onedata.org/README.md))
                           Onezone deployment used for demo purposes and testing
                           of bleeding edge releases                
                
    * *datahub.egi.eu* - ([README](onezone/datahub.egi.eu/README.md))
                           Onezone deployment for EGI DataHub         
                
    * *onedata.plgrid.pl* - ([README](onezone/onedata.plgrid.pl/README.md))
                           Onezone deployment for PLGrid
                           
    * *examples* - ready to use templates to set up you own instances, using the 
                   [graphical wizard](onezone/examples/graphical-wizard/README.md)
                   or [batch mode](onezone/examples/batch-mode/README.md)
                           
                
                
* **oneprovider** - configs used in production Oneprovider instances 
                    (per domain) and examples mostly intended for people who
                    do not want to use the [Onedatify wizard][]
                    
                    
* **bin** - useful scripts (see below)
                    
                    
                    
## Useful scripts

Can be found in the `bin` directory.

### onezone.sh 

The `onezone.sh` is merely a wrapper for the docker-compose command that simplifies
onepanel emergency passphrase management. The passphrase is stored in  
`data/secret/emergency-passphrase.txt` (relative to given deployment). Before
deploying, you can put there an emergency passphrase of your choice. Otherwise, 
it will be generated automatically. If installing using the graphical wizard, 
you will be prompted for the passphrase - provide the same as in the file.

If you wish, you can simply use `docker-compose up -d`, but be aware of the following:
* If you are installing using the graphical wizard, the emergency passphrase is not needed
  to be specified beforehand - you will be asked to set up one during installation
* If you are installing using the batch mode, you must provide an emergency 
  passphrase in the `EMERGENCY_PASSPHRASE` env variable (which is referenced in 
  `docker-compose.yaml`)
* If you are restarting the deployment, `EMERGENCY_PASSPHRASE` is not obligatory, 
  but it will allow you to see more output from the service startup.
                 
                 
                    
[Onedatify wizard]: https://onedata.org/#/home/documentation/doc/administering_onedata/oneprovider_tutorial[onedatify-based-setup].html
