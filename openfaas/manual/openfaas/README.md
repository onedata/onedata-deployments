# Installing OpenFaaS
```
helm repo add onedata https://onedata.github.io/charts/
helm repo update
kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm upgrade openfaas --install onedata/openfaas -f values.yaml --namespace openfaas --set generateBasicAuth=true --version 11.1.14
kubectl apply -f openfaas-svc-public.yaml
```
Follow the instructions from the `helm upgrade` output to check that openfaas 
has been deployed with success.
