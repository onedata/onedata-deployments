# Openfaas automation for oneprovider
The ansible scripts in this directory helps with settin up automation for oneprovider.
It deploys one-node k8s cluster, openfaas, the neccessary companions and configures the oneprivider.
Keep in mind that during the process the oneprovider will be restarted by the scripts.

It is assumed that openfaas is installed on a dedicated VM (openfaas-vm). The scripts can be started on 
the same or different VM (ansible-vm). 
## Prerequisites
- ssh access from ansible-vm to openfaas-vm and oneprovider
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
