# Production Onedata Deployments

This repository contains configs and docker-compose files for deploying and
maintaining production Onedata deployments. You can also find some examples 
(templates) to adjust to your needs and deploy your own instances.


# Structure

* **homepage** - configs for deploying the homepage (onedata.org), 
                 which includes general info about Onedata, documentation and 
                 API reference
* **onezone** - configs used in production Onezone instances (per domain), 
                and some example templates from which the production configs 
                were derived
* **oneprovider** - configs used in production Oneprovider instances 
                    (per domain) and examples mostly intended for people who
                    do not want to use the [Onedatify wizard][].
                    
                    
[Onedatify wizard]: https://onedata.org/#/home/documentation/doc/administering_onedata/oneprovider_tutorial[onedatify-based-setup].html