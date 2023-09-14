# Openfaas automation for Oneprovider

The ansible scripts in this directory set up the OpenFaaS automation
engine for Oneprovider.  They deploy a one-node k8s cluster, OpenFaaS,
the necessary companions, and configures the Oneprovider.

> NOTE: During the process, the Oneprovider will be restarted by the scripts.

> NOTE: The ansible scripts are responsible for the first deployment
> of the OpenFaaS service and do not cover the continuous maintenance
> of the services.

It is assumed that OpenFaaS is installed on a dedicated VM (openfaas-vm). 
The scripts can be started on the same or different VM (ansible-vm). 

## Prerequisites
- ssh access from ansible-vm to openfaas-vm and Oneprovider
- python3 on all nodes

### ansible-vm
- ansible 2.15
- python3.9

## Configuring variables
Edit `group_vars/all.yml`.

## Preparing hosts
Edit `hosts` and place the appropriate IP addresses.

## Running ansible
```
ansible-playbook -i hosts site.yml
```

## Installing another instance of openfaas in the same kind cluster

It is possible to instantiate more than one OpenFaaS service on the same kind cluster,
for use by different Oneproviders (they cannot share the same instance).

**WARNING**: To achieve that, enough ports must be reserved in the kind cluster 
**in advance**, i.e. when running the first deployment.
This cannot be done later with those ansible scripts.

The procedure is generally the same as installing the first instance
but some variables in `group_vars/all.yml` need to be modified.


### Modifying `group_vars/all.yml`
Modify the following variables according to the infile comments:
- oneprovider_hostname
- openfaas_port
- openfaas_node_port
- openfaas_function_namespace
- pod_status_monitor_namespace
- first_openfaas_instance_on_this_cluster

### Modifying ansible inventory file `hosts`
Modify the provider IP address in the `oneprovider` group.

### Running ansible
The same command as for the first instance should be used:
```
ansible-playbook -i hosts site.yml
```

