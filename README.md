# AZ-AKS-config

## How to use

Edit `setup.sh` and put a random string into `UNIQUE_SUFFIX` variable to avoid collisions
with globally unique names.

```shell
$ source setup.sh
$ source azure-env-functions.sh
```

Run commands in order from `azure-env.sh` starting with `show_initial_vars`.

The last command will print the external IP address of the service, use curl to get
the environment variables from the pod:

```shell
curl http://[external-ip]/env.txt
```


## Random notes

cd nginx-envprint
docker build -t nginx-envprint .
docker tag nginx-envprint ${myContainerRegistry}.azurecr.io/nginx-envprint
docker push myregistry.azurecr.io/nginx-envprint

secret

kubectl create secret generic config-service-secret --from-literal=azure_app_configuration_connection_string="$APPCONFIG_CONNECTION_STRING"

