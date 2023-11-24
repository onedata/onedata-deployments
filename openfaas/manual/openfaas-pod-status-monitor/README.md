This directory contains the openfaas-pod-status-monitor charts.
Before deploying edit `openfaas-pod-status-monitor/values.yaml`. Replace serverURL and secret. 
In order to deploy it run:

```
cd ..
kubectl create namespace openfaas-fn
helm install openfaas-pod-status-monitor openfaas-pod-status-monitor -n openfaas-fn
```
