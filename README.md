cd nginx-envprint
docker build -t nginx-envprint .
docker tag nginx-envprint ${myContainerRegistry}.azurecr.io/nginx-envprint
docker push myregistry.azurecr.io/nginx-envprint

secret

kubectl create secret generic config-service-secret --from-literal=azure_app_configuration_connection_string="$APPCONFIG_CONNECTION_STRING"

