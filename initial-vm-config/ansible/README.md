# Ansible playbook for setting up VM before deploying Onedata services

## Prerequisites
- ssh access from the VM where ansible playbook is run to other nodes
- python3 on all nodes

### ansible-vm
- python3
- ansible >=2.8.4  
- jinja2 <3.10
- jmespath  

The requirements can be installed like the following:
```
sudo apt install -y python3 python3-pip
sudo python3 -m pip install ansible "Jinja2>=2.10,<3.1" jmespath
```

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
