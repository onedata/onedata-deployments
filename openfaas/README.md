# OpenFaaS deployments

The procedure of deploying OpenFaaS is the following:
- A kubernetess cluster is needed. In this deployment we use minikube. The following commands install docker and minikube: 
## Installing docker
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release conntrack -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
```
## Installing minikube
```
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo cp minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod +x /usr/local/bin/minikube
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

## Using minikube with driver none
We need to install some additional software.

### Installing go
```
wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```
### Installing cri-dockerd (from https://github.com/Mirantis/cri-dockerd)
```
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket
```
### Installing cri-tools
```
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.27.0/crictl-v1.27.0-linux-amd64.tar.gz
sudo tar zxvf crictl-v1.27.0-linux-amd64.tar.gz -C /usr/local/bin
```
### Building network plugins
```
git clone https://github.com/containernetworking/plugins.git
cd plugins
./build_linux.sh
sudo mkdir -p /opt/cni/bin
sudo cp bin/* /opt/cni/bin
```

### Starting minikube (--driver=none)
```
sudo minikube start --driver=none --cni=bridge
kubectl taint node datahub-faas node.kubernetes.io/not-ready:NoSchedule-
```

## Using minikube with driver docker
```
sudo minikube start --driver=docker
kubectl taint node datahub-faas node.kubernetes.io/not-ready:NoSchedule-
```

## Installing kind
```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.19.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind create cluster
kubectl cluster-info --context kind-kind
```

## Configuring permisions for k8s
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
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm upgrade openfaas --install openfaas/openfaas -f values.yaml --namespace openfaas --set generateBasicAuth=true --version 11.1.14
k apply -f openfaas-svc-public.yaml
```
## Creating pull image secret for docker.onedata.org
```
docker login docker.onedata.org -u onedata-ro -p onedata-ro-password
kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json --type=kubernetes.io/dockerconfigjson
```

## Installing openfaas-pod-status-monitors
  - Edit `~/openfaas-pod-status-monitor-plg-01/values.yaml`. Replace serverURL and secret. Add image pull secret.
  ```
  imagePullSecrets:
    name: regcred
  ```
  - Repeat for `~/openfaas-pod-status-monitor-plg-02/values.yaml`.
```
kubectl create namespace onedata
kubectl get secret regcred -oyaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=onedata -f -
helm install openfaas-pod-status-monitor-plg-01 openfaas-pod-status-monitor-plg-01 -n onedata
helm install openfaas-pod-status-monitor-plg-02 openfaas-pod-status-monitor-plg-02 -n onedata
```
## Installing openfaas-sidecars
### Generate certs
  ```
  openssl genrsa -out plg-01-ca.key 2048
  openssl genrsa -out plg-02-ca.key 2048
  export COMMON_NAME=sidecarinjector-plg-01.openfaas-fn-plg-01.svc
  openssl  req -x509 -new -nodes -key plg-01-ca.key -subj "/CN=${COMMON_NAME}" \
      -addext "subjectAltName = DNS:${COMMON_NAME}" -days 3650 -reqexts v3_req \
      -extensions v3_ca -out plg-01-ca-ns-sidecarinjector.crt
  cat plg-01-ca-ns-sidecarinjector.crt | base64 -w 0 > plg-01-caBundle
  export COMMON_NAME=sidecarinjector-plg-02.openfaas-fn-plg-02.svc
  openssl  req -x509 -new -nodes -key plg-02-ca.key -subj "/CN=${COMMON_NAME}" \
      -addext "subjectAltName = DNS:${COMMON_NAME}" -days 3650 -reqexts v3_req \
      -extensions v3_ca -out plg-02-ca-ns-sidecarinjector.crt
  cat plg-02-ca-ns-sidecarinjector.crt | base64 -w 0 > plg-02-caBundle
  ```
### prepare values.yaml files
  ```
  vi plg-01-values.yaml # copy-paste key, cert and caBundle
  vi plg-02-values.yaml # copy-paste key, cert and caBundle
  ```
The plg-01-values.yaml file should look like this:
  ```
appname: sidecarinjector-plg-01
namespace: openfaas-fn-plg-01

caBundle:
  crt: |-
    <content of plg-01-ca-ns-sidecarinjector.crt>
  key: |-
    <content of plg-01-ca.key>
  caBundle: <content of plg-01-caBundle>
  ```
### Preparing function namespaces
```
kubectl create namespace openfaas-fn-plg-01
kubectl create namespace openfaas-fn-plg-02
kubectl label ns openfaas-fn-plg-01 sidecar-injection=enabled --overwrite
kubectl label ns openfaas-fn-plg-02 sidecar-injection=enabled --overwrite
```
### Deploying charts
```
cd ~/openfaas-sidecar
helm upgrade -i -n openfaas-fn-plg-01 -f plg-01-values.yaml sidecarinjector-plg-01 onedata/sidecarinjector
helm upgrade -i -n openfaas-fn-plg-02 -f plg-02-values.yaml sidecarinjector-plg-02 onedata/sidecarinjector
```
## Obtaining openfaas creds
Make sure that the releases have been deployed and the given pods are running. 
Now we are ready to configure the provider. First we need to obtain the openfaas password. 
```
echo $(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode)
```
## Patching queue-worker
Edit openfaas/values.yaml and replace queueWorker specs with: 
```
queueWorker:
  image: docker.onedata.org/openfaas-queue-worker:dev
  replicas: 1
  maxInflight: 20
  gatewayInvoke: true
  queueGroup: "faas"
  ackWait: "6000000000s"
  resources:
    requests:
      memory: "120Mi"
      cpu: "50m"
  maxRetryAttempts: "10"
  maxRetryWait: "120s"
  initialRetryWait: "10s"
  httpRetryCodes: "429,502,500,504,408"
```
### Adding imagePullSecrets for openfaas
```
kubectl get secret regcred -oyaml | grep -v '^\s*namespace:\s' | kubectl apply --namespace=openfaas -f -
kubectl patch serviceaccount default -n openfaas -p '{"imagePullSecrets": [{"name": "regcred"}]}'
```
### Upgrading openfaas
```
cd ~/openfaas
helm upgrade openfaas --install openfaas/openfaas -f values.yaml --namespace openfaas --set generateBasicAuth=true --version 11.1.14
```
## Configuring oneprovider
Place the obtained password and the rest of parameters in the file op-worker-overlay.config. The overlay should
look similar to this:
```
[
    {op_worker, [
        {openfaas_host, "10.0.0.2"},
        {openfaas_port, 8080},
        {openfaas_function_namespace, "openfaas-fn-plg-02"},
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

