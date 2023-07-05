This directory contains the openfaas-pod-status-monitor charts
In order to deploy it run:

```
cd ..
kubectl create namespace onedata
helm install openfaas-pod-status-monitor openfaas-pod-status-monitor -n onedata
```
