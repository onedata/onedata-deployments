# OpenFaaS deployments

The procedure of deploying OpenFaaS is the following:
- A kubernetess cluster is needed. In this deployment we use minikube. The following commands install docker and minikube: 

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release -y
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo cp minikube-linux-amd64 /usr/local/bin/minikube
sudo chmod +x /usr/local/bin/minikube
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
sudo minikube start --driver=docker
```
- Install helm
```
wget https://get.helm.sh/helm-v3.6.3-linux-amd64.tar.gz
tar zxvf helm-v3.6.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```
- Install OpenFaaS
```
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm upgrade openfaas --install openfaas/openfaas -f values.yaml --namespace openfaas --set generateBasicAuth=true --version 11.1.14
k apply -f openfaas-svc-public.yaml
```
- Create secret for docker.onedata.org
```
docker login docker.onedata.org -u onedata-ro -p onedata-ro-password
kubectl create secret generic regcred --from-file=.dockerconfigjson=/home/ubuntu/.docker/config.json --type=kubernetes.io/dockerconfigjson
```

- Install openfaas-pod-status-monitors
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
- Install openfaas-sidecars
  - Generate certs
  ```
  openssl genrsa -out plg-01-ca.key 2048
  openssl genrsa -out plg-02-ca.key 2048
  export COMMON_NAME=sidecarinjector-plg-01.sidecarinjector.svc
  openssl  req -x509 -new -nodes -key plg-01-ca.key -subj "/CN=${COMMON_NAME}" \
      -addext "subjectAltName = DNS:${COMMON_NAME}" -days 3650 -reqexts v3_req \
      -extensions v3_ca -out plg-01-ca-ns-sidecarinjector.crt
  cat plg-01-ca-ns-sidecarinjector.crt | base64 > plg-01-caBunle
  export COMMON_NAME=sidecarinjector-plg-02.sidecarinjector.svc
  openssl  req -x509 -new -nodes -key plg-02-ca.key -subj "/CN=${COMMON_NAME}" \
      -addext "subjectAltName = DNS:${COMMON_NAME}" -days 3650 -reqexts v3_req \
      -extensions v3_ca -out plg-02-ca-ns-sidecarinjector.crt
  cat plg-02-ca-ns-sidecarinjector.crt | base64 > plg-02-caBunle
  ```
  - prepare values.yaml files
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
  - Deploy charts
```
kubectl create namespace openfaas-fn-plg-01
kubectl create namespace openfaas-fn-plg-02
helm upgrade -i -n openfaas-fn-plg-01 -f plg-01-values.yaml sidecarinjector-plg-01 onedata/sidecarinjector
helm upgrade -i -n openfaas-fn-plg-02 -f plg-02-values.yaml sidecarinjector-plg-02 onedata/sidecarinjector
```
Make sure that the releases have been deployed and the given pods are running. 
Now we are ready to configure the provider. First we need to obtain the openfaas password. 
```
echo $(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode)
```
Place the obtained password in the file op-worker-overlay.config:
```
{openfaas_admin_password, "obtained-password"},
```
Place also the pod monitor password:
```
{openfaas_activity_feed_secret, "secret-from-pod-monitor-values"}
```
