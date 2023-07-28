# Installing OpenFaaS
```
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm upgrade openfaas --install openfaas/openfaas -f values.yaml --namespace openfaas --set generateBasicAuth=true --version 11.1.14
k apply -f openfaas-svc-public.yaml
```
Follow the instructions from the `helm upgrade` output to check that openfaas 
has been deployed with success.
