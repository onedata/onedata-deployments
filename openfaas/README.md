# OpenFaaS deployments

OpenFaaS and the components needed to run automation tasks in Onedata
can be easily installed with the supplied ansible playbooks - see
[ansible/README.md](ansible/README.md). If you want to do it the hard way and
deploy OpenFaaS manually, read on.

The procedure of deploying OpenFaaS includes installing/deploying of the following 
software and services:
 - docker,
 - k8s cluster - [kind](https://kind.sigs.k8s.io/) is used in this tutorial,
 - helm,
 - openfaas,
 - openfaas-pod-status-monitor,
 - openfaas-sidecar.
Proceed with the commands in the following sections to set it up.

## Installing docker
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release conntrack -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
```

## Installing kind 
```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.19.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```
## Creating k8s cluster
```
kind create cluster --config=kind-config.yaml
kubectl cluster-info --context kind-kind
```

## Configuring permissions for k8s
```
kubectl create clusterrolebinding serviceaccounts-cluster-admin   --clusterrole=cluster-admin   --group=system:serviceaccounts

```
## Installing helm
```
wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar zxvf helm-v3.6.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```
## Installing OpenFaaS
```
cd openfaas
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm upgrade openfaas --install openfaas/openfaas -f values.yaml --namespace openfaas --set generateBasicAuth=true --version 11.1.14
k apply -f openfaas-svc-public.yaml
cd ..
```
## Creating pull image secret for docker.onedata.org (optional)
In case images from a private docker registry are to be used, an image pull secret should be added:
```
docker login docker.onedata.org -u onedata-ro -p onedata-ro-password
kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json --type=kubernetes.io/dockerconfigjson
```
Then use the secret in `values.yaml` files:
```
imagePullSecrets:
name: regcred
```
Note that secrets are bound to namespaces. In order to copy the secret to another namespace use:
```
kubectl get secret regcred -o yaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=onedata -f -
```
The above command copies the secret from the `default` namespace to the namespace `onedata`. 

## Installing openfaas-pod-status-monitors

Edit `openfaas-pod-status-monitor/values.yaml`. Replace serverURL and secret. 

```
kubectl create namespace onedata
helm install openfaas-pod-status-monitor openfaas-pod-status-monitor -n onedata
```
## Installing openfaas-sidecars
### Generate certs

  ```
  cd openfaas-sidecar
  openssl genrsa -out ca.key 2048
  export COMMON_NAME=sidecarinjector.openfaas-fn.svc
  openssl  req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" \
      -addext "subjectAltName = DNS:${COMMON_NAME}" -days 3650 -reqexts v3_req \
      -extensions v3_ca -out ca-ns-sidecarinjector.crt
  cat ca-ns-sidecarinjector.crt | base64 -w 0 > caBundle
  ```
### prepare values.yaml files
  ```
  vi values.yaml # copy-paste key, cert and caBundle
  ```
The values.yaml file should look like this:
  ```
appname: sidecarinjector
namespace: openfaas-fn

caBundle:
  crt: |-
    <content of ca-ns-sidecarinjector.crt>
  key: |-
    <content of ca.key>
  caBundle: <content of caBundle>
  ```
### Preparing function namespaces
```
## TO-CHECK: This should not be necessary for the default openfaas
## function namespace - openfaas-fn
kubectl label ns openfaas-fn sidecar-injection=enabled --overwrite
```
### Deploying charts
```
helm upgrade -i -n openfaas-fn -f values.yaml sidecarinjector onedata/sidecarinjector
cd ..
```
## Obtaining openfaas creds
Make sure that the releases have been deployed and the corresponding pods are running. 
Now, the Oneprovider can be configured. First, obtain the openfaas password: 
```
echo $(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode)
```
## Configuring oneprovider
Place the obtained password and the rest of parameters in the file op-worker-overlay.config. The overlay should
look similar to this:
```
[
    {op_worker, [
        {openfaas_host, "10.0.0.2"},
        {openfaas_port, 8080},
        {openfaas_function_namespace, "openfaas-fn"},
        {openfaas_admin_username, "admin"},
        {openfaas_admin_password, "XXXXXXXXXX"},
        {openfaas_function_constraints, []},
        {openfaas_function_labels, #{}},
        {openfaas_function_limits, #{}},
        {openfaas_function_annotations, #{}},
        {openfaas_function_requests, #{}},
        {openfaas_function_env, #{
            "read_timeout" => "604800s",
            "write_timeout" => "604800s",
            "exec_timeout" => "604800s"}
        },
        {openfaas_activity_feed_secret, "YYYYYYYYYYYYY"}
    ]}
].

```

