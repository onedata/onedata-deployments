# Openfaas automation for Oneprovider

The ansible scripts in this directory set up the OpenFaaS automation
engine for Oneprovider. They deploy a one-node k8s cluster, OpenFaaS,
the necessary companions, and configures the Oneprovider.

> NOTE: During the process, the Oneprovider will be restarted by the scripts.

> NOTE: The ansible scripts are responsible for the first deployment
> of the OpenFaaS service and do not cover the continuous maintenance
> of the services.

OpenFaaS will be installed on a dedicated VM (openfaas-vm). 
The scripts can be started on the same or different VM (ansible-vm).
The Oneprovider service is expected to be running on the same or different VM (oneprovider-vm).

In a specific case, all the three vms can be 'localhost'.


## Prerequisites
- ssh access from ansible-vm to openfaas-vm and oneprovider-vm
- python3 on all nodes
- oneprovider version >= 21.02.5

### ansible-vm
- Ubuntu 20.04 or higher
- python3
- ansible >=2.8.4
- jinja2 <3.10
- jmespath

The requirements can be installed like the following:
```
sudo apt update
sudo apt install python3 pipx python3-pip python3-venv
pipx ensurepath
. ~/.bashrc
pipx install --include-deps ansible
ansible-galaxy collection install kubernetes.core
```

> NOTE: The scripts has been tested with ansible 6.7.0 and ansible-core 2.13.13.
> In case of problems with future ansible versions try installing these specific versions.

## Configuring

### Preparing hosts (Ansible inventory file)
Edit `hosts` and place the appropriate IP addresses. See the comments for explanation.

### Configuring variables
Edit `group_vars/all.yml`. At least following variables must be overwritten:
- `oneprovider_hostname`
- `openfaas_host`
- `openfaas_admin_password`
- `openfaas_activity_feed_secret`

The rest can be left as defaults.

### Configuring SSH connections
Make sure all nodes are reachable with SSH from the ansible host and
the public key (of the user running the ansible) is added.

When running for a `localhost` node, one of the ways is to do this:
```console
[ ! -f ~/.ssh/id_rsa ] && ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""  # will be done if not generated yet
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

or to use `ssh-agent`.


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

