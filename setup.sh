# initial naming setup
export UNIQUE_SUFFIX=cafefe # put a random string here, some names must be globally unique

# base name, 14 chars or less
export MY_APP_NAME=configed-app
export MY_APP_NAME_NODASH=$(echo ${MY_APP_NAME} | tr -d "-")
export AZURE_LOCATION=eastus
export myResourceGroup=${MY_APP_NAME}-rg
export myAKSCluster=${MY_APP_NAME}-aks-cluster
# appConfigName: must be globally unique
export appConfigServiceName=${MY_APP_NAME}-configservice-${UNIQUE_SUFFIX}
# key vault name: must be globally unique under 24 chars
export myKeyVault=${MY_APP_NAME}-kv-${UNIQUE_SUFFIX}
export APPCONFIG_ENDPOINT="not-yet-set"
export APPCONFIG_CONNECTION_STRING="not-yet-set"
export APPCONFIG_CONNECTION_STRING_RO="not-yet-set"
export APPCONFIG_SERVICE_ID="not-yet-set"
# container registry, alphanumeric only, globally unique
export myContainerRegistry=${MY_APP_NAME_NODASH}${UNIQUE_SUFFIX}
# AKS cluster principal
export AKS_CLUSTER_PRINCIPAL="not yet set"
# k8s secret for config service
export K8S_SECRET_FOR_CONFIG=config-service-secret
# configmap from configprovider
export CONFIGMAP_FROM_CONFIG_PROVIDER=configmap-created-by-appconfig-provider
# k8s namespace for service and secrets
export K8S_APP_NAMESPACE=blob-management
