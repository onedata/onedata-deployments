# Ansible playbook for seting up VM before deploying Onedata services

## Requirements
ansible >=2.8.4  
jinja2 >=2.10  
jmespath  

The requirements can be installed with pip:
```
sudo pip install -U Jinja2
sudo pip install jmespath
```

## Configuring
### Ansible invetory file
Place your node names and IP addresses into `hosts`. See the comments for example lines. 

### Ansible variables
Edit `group_vars/all.yml`. 
The variables semantic is explained in the comments.
 
## Running the playbook

Run:
```
ansible-playbook -i hosts site.yml
```

