# Installing openfaas-sidecars
## Generate certs

  ```
  openssl genrsa -out ca.key 2048
  export COMMON_NAME=sidecarinjector.openfaas-fn.svc
  openssl  req -x509 -new -nodes -key ca.key -subj "/CN=${COMMON_NAME}" \
      -addext "subjectAltName = DNS:${COMMON_NAME}" -days 3650 -reqexts v3_req \
      -extensions v3_ca -out ca-ns-sidecarinjector.crt
  cat ca-ns-sidecarinjector.crt | base64 -w 0 > caBundle
  ```
## prepare values.yaml files
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
## Preparing function namespaces
```
kubectl label ns openfaas-fn sidecar-injection=enabled --overwrite
```
## Deploying charts
```
helm upgrade -i -n openfaas-fn -f values.yaml sidecarinjector onedata/sidecarinjector
cd ..
```

