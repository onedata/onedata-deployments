# Openfaas automation for Oneprovider

The ansible scripts in this directory set up the OpenFaaS automation engine for Oneprovider.
They deploy a one-node k8s cluster, OpenFaaS, the necessary companions, and configures the Oneprovider.

NOTE: During the process, the Oneprovider will be restarted by the scripts.

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
