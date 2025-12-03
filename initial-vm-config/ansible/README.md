# Ansible playbook for setting up VM before deploying Onedata services

## Prerequisites
- ssh access from the VM where ansible playbook is run to other nodes
- python3 on all nodes

### ansible-vm
- python3
- ansible >=2.8.4  
- jinja2 <3.10
- jmespath  

The recommened way is to use Python virtual environment, like below:

#### Ubuntu
```
sudo apt update
sudo apt install python3 python3-venv
python3 -m venv ~/.vm-prep
source ~/.vm-prep/bin/activate
python3 -m pip install ansible "Jinja2>=2.10,<3.1" jmespath
```

#### Centos, Rocky
```
python3 -m venv ~/.vm-prep
source ~/.vm-prep/bin/activate
python3 -m pip install ansible "Jinja2>=2.10,<3.1" jmespath
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
source ~/.vm-prep/bin/activate   # make sure the python venv is activated
ansible-playbook -i hosts site.yml
```
