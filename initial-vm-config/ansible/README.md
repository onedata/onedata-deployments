# Ansible playbook for setting up VM before deploying Onedata services

This playbook is used to initially prepare the the VMs (or physical
hosts) where Onezone or Oneprovider is going to be deployed. The
script requires that an epmty block device is avalable. A logical
volume will be created on this block device. It is intended to store
the persistant data of Onedata services. Using of LVM volume allows
for better managing of the deployment especially when doing
snapshot-based live backups.

## Prerequisites
- ssh access from the VM where ansible playbook is run to other nodes
- python3 on all nodes

### ansible-vm

The following packages are needed:
- python3
- ansible >=2.8.4  
- jinja2 <3.10
- jmespath  

The requirements can be installed like the following:
```
sudo apt install -y python3 python3-pip
sudo python3 -m pip install ansible "Jinja2>=2.10,<3.1" jmespath
```

Note: In case of a single node installation all steps can be done on the same VM intended for the given deployment

## Configuring

### Preparing hosts (Ansible inventory file)
Place your node names and IP addresses into `hosts`. See the comments for example lines. 

### Configuring variables
Edit `group_vars/all.yml`. 
The semantics of variables is explained in the comments.

### Configuring SSH connections
Make sure all nodes are reachable with SSH from the ansible host and
the public key (of the user running the ansible) is added.

When running for a `localhost` node, one of the ways is to do this:
```console
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""  # if not generated yet
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

or to use `ssh-agent`.
 

## Running the playbook

```
ansible-playbook -i hosts site.yml
```
