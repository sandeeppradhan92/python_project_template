## Start azure cli container [Optional]
```bash
docker run -it mcr.microsoft.com/azure-cli
```

## Inside the container login to the 
```bash
az login
```

## install kubectl cli [CLI version should be same as server version]
```bash
az aks install-cli  --client-version=v1.20.9
```

## Export creds from aks to authenticate kubectl cli
```bash
az aks get-credentials --resource-group Danone_POC --name danoneaksmmmb28049090a --file kubeconfig-ss
export KUBECONFIG=/kubeconfig-ss
```

## Create namespace
```bash
kubectl apply -f manifests/namespace.yaml
```

## Create secret to authenticate aks with acr
```bash
export secret_name=danonesimultorcred
export namespace=simulator-app-dev
export acrurl=7f2caeaa043040bcbe6e93cc7d5ab64d.azurecr.io
export acrusername=7f2caeaa043040bcbe6e93cc7d5ab64d
export acrpassword=fmx40cW=uGf4ut1xusC9KDkfyuLBwt7f
kubectl create secret docker-registry $secret_name  --namespace $namespace --docker-server=$acrurl --docker-username=$acrusername --docker-password=$acrpassword
```

## Deploy application
```bash
kubectl apply -f manifests/deployment.yaml
```

## Get load balancer service URL
```bash
export endpointurl=$(kubectl get service simulator-backend-service -n simulator-app-dev --output="jsonpath={.status.loadBalancer.ingress[0].ip}"):$(kubectl get service simulator-backend-service -n simulator-app-dev --output="jsonpath={.spec.ports[0].port}")
echo $endpointurl
```

## Test the deployed endpoint
- Test for basic access
    ```bash 
    curl --location --request GET $endpointurl'/ping'
    ```
- Test for simulator endpoint
    ```bash
    curl --location --request GET $endpointurl'/get_values' \
    --header 'Content-Type: application/json' \
    --data-raw '[{"_sim_agg_level":"House","_sim_time_scaling":"Yearly"}]'
    ```