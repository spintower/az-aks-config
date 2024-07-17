

function show_initial_vars() {
    echo MY_APP_NAME=$MY_APP_NAME
    echo MY_APP_NAME_NODASH=$MY_APP_NAME_NODASH
    echo UNIQUE_SUFFIX=$UNIQUE_SUFFIX
    echo AZURE_LOCATION=$AZURE_LOCATION
    echo myResourceGroup=${myResourceGroup}
    echo myAKSCluster=${myAKSCluster}
    echo appConfigServiceName=${appConfigServiceName}
    echo myKeyVault=${myKeyVault}
    echo APPCONFIG_ENDPOINT=${APPCONFIG_ENDPOINT}
    echo APPCONFIG_CONNECTION_STRING=${APPCONFIG_CONNECTION_STRING}
    echo APPCONFIG_CONNECTION_STRING_RO=${APPCONFIG_CONNECTION_STRING_RO}
    echo APPCONFIG_SERVICE_ID=${APPCONFIG_SERVICE_ID}
    echo AKS_CLUSTER_PRINCIPAL=${AKS_CLUSTER_PRINCIPAL}
    echo K8S_SECRET_FOR_CONFIG=${K8S_SECRET_FOR_CONFIG}
    echo CONFIGMAP_FROM_CONFIG_PROVIDER=${CONFIGMAP_FROM_CONFIG_PROVIDER}
}

function resource_group_exists() {
    echo Checking resource group $myResourceGroup
    local cmd="az group show --name $myResourceGroup"
    echo $cmd
    local EXIT_CODE
    EXIT_CODE=0
    $cmd || EXIT_CODE=$?
    if [ $AE_DEBUG ] ; then echo $EXIT_CODE; fi
    return $EXIT_CODE
}

function create_resource_group() {
    echo Creating resource group $myResourceGroup
    local cmd="az group create --name $myResourceGroup --location $AZURE_LOCATION"
    echo $cmd
    $cmd
}

function ensure_resource_group() {
    if resource_group_exists ; then
        echo resource group $myResourceGroup already exists, good.
    else
        echo resource group $myResourceGroup does not exist, creating
        create_resource_group
    fi
}

function appconfig_service_exists() {
    echo Checking appconfig service $appConfigServiceName
    local cmd="az appconfig show --name $appConfigServiceName"
    echo $cmd
    local EXIT_CODE
    EXIT_CODE=0
    $cmd || EXIT_CODE=$?
    if [ $AE_DEBUG ] ; then echo $EXIT_CODE; fi
    return $EXIT_CODE
}

function create_appconfig_service() {
    echo Creating appconfig service $appConfigServiceName
    local cmd="az appconfig create \
        --name $appConfigServiceName \
        --location $AZURE_LOCATION \
        --resource-group $myResourceGroup \
        --sku free"
    echo $cmd
    $cmd
}

function ensure_appconfig_service() {
    if appconfig_service_exists ; then
        echo app configuration service $appConfigServiceName already exists, good.
    else
        echo app configuration service $appConfigServiceName does not exist, creating
        create_appconfig_service
    fi
}

function set_appconfig_endoint() {
    local endpoint
    endpoint=$(az appconfig show --name $appConfigServiceName --query endpoint -o tsv)
    echo Setting APPCONFIG_ENDPOINT to "$endpoint"
    export APPCONFIG_ENDPOINT="$endpoint"
}

function set_appconfig_connection_string() {
    local connection_string
    connection_string=$(az appconfig credential list \
        --resource-group $myResourceGroup \
        --name $appConfigServiceName \
        --query "[?name=='Primary'] .connectionString" -o tsv)
    echo Setting APPCONFIG_CONNECTION_STRING to "$connection_string"
    export APPCONFIG_CONNECTION_STRING="$connection_string"
    echo Setting AZURE_APPCONFIG_CONNECTION_STRING to "$connection_string"
    export AZURE_APPCONFIG_CONNECTION_STRING="$connection_string"
}

function set_appconfig_connection_string_ro() {
    local connection_string
    connection_string=$(az appconfig credential list \
        --name $appConfigServiceName \
        --resource-group "$myResourceGroup" \
        --query "[?name=='Primary Read Only'] .connectionString" -o tsv)
    echo Setting APPCONFIG_CONNECTION_STRING_RO to "$connection_string"
    export APPCONFIG_CONNECTION_STRING_RO="$connection_string"
}

function expose_appconfig_service_id() {
    local appconfig_service_id
    appconfig_service_id=$(az appconfig show \
        --resource-group $myResourceGroup \
        --name $appConfigServiceName \
        --query "id" -o tsv)
    echo Setting APPCONFIG_SERVICE_ID to "$appconfig_service_id"
    export APPCONFIG_SERVICE_ID="$appconfig_service_id"
}

function insert_key_to_config() {
    local key=$1
    local value=$2
    echo inserting into config: $key -- $value
    az appconfig kv set \
        --yes \
        --key "$key" \
        --value "$value"
}

function insert_keys_to_config() {
    insert_key_to_config mssql.tvs_blob.host sqlag-ecom-tvs-general.ag1.taservs.net
    insert_key_to_config mssql.tvs_blob.port 1433
}

# ================= key vault ================
function keyvault_exists() {
    echo Checking keyvault $myKeyVault
    local cmd="az keyvault show --name $myKeyVault"
    echo $cmd
    local EXIT_CODE
    EXIT_CODE=0
    $cmd || EXIT_CODE=$?
    if [ $AE_DEBUG ] ; then echo $EXIT_CODE; fi
    return $EXIT_CODE
}

function create_keyvault() {
    echo Creating keyvault $myKeyVault
    local cmd="az keyvault create \
        --name "$myKeyVault" \
        --resource-group "$myResourceGroup" \
        --enable-rbac-authorization"
    echo $cmd
    $cmd
}

function ensure_keyvault() {
    if keyvault_exists ; then
        echo keyvault $myKeyVault already exists, good.
    else
        echo keyvault $myKeyVault does not exist, creating
        create_keyvault
    fi
}

# ================= container registry ================
function container_registry_exists() {
    echo Checking container registry $myContainerRegistry
    local cmd="az acr show --name $myContainerRegistry"
    echo $cmd
    local EXIT_CODE
    EXIT_CODE=0
    $cmd || EXIT_CODE=$?
    if [ $AE_DEBUG ] ; then echo $EXIT_CODE; fi
    return $EXIT_CODE
}

function create_container_registry() {
    echo Creating container registry $myContainerRegistry
    local cmd="az acr create \
        --name "$myContainerRegistry" \
        --resource-group "$myResourceGroup" \
        --sku Basic"
    echo $cmd
    $cmd
}

function ensure_container_registry() {
    if container_registry_exists ; then
        echo container registry $myContainerRegistry already exists, good.
    else
        echo container registry $myContainerRegistry does not exist, creating
        create_container_registry
    fi
}

function login_to_registry() {
    echo logging in to registry
    echo az acr login --name $myContainerRegistry
    az acr login --name $myContainerRegistry
}

# ================= aks cluster ================
function aks_cluster_exists() {
    echo Checking aks cluster $myAKSCluster
    local cmd="az aks show --name $myAKSCluster --resource-group $myResourceGroup"
    echo $cmd
    local EXIT_CODE
    EXIT_CODE=0
    $cmd || EXIT_CODE=$?
    if [ $AE_DEBUG ] ; then echo $EXIT_CODE; fi
    return $EXIT_CODE
}

function create_aks_cluster() {
    echo Creating aks cluster $myAKSCluster
    local cmd="az aks create \
        --resource-group "$myResourceGroup" \
        --name "$myAKSCluster" \
        --node-count 2 \
        --tier Free \
        --generate-ssh-keys \
        --enable-managed-identity \
        --attach-acr $myContainerRegistry"
    echo $cmd
    $cmd
}

function ensure_aks_cluster() {
    if aks_cluster_exists ; then
        echo aks cluster $myAKSCluster already exists, good.
    else
        echo aks cluster $myAKSCluster does not exist, creating
        create_aks_cluster
    fi
}

function set_ask_cluster_credentials() {
    echo Setting AKS cluster credentials
    echo az aks get-credentials --resource-group "$myResourceGroup" -n "$myAKSCluster"
    az aks get-credentials --resource-group "$myResourceGroup" -n "$myAKSCluster"
}

# ================= push docker container ================
function build_and_push_envprint() {
    pushd .
    cd nginx-envprint
    docker build -t nginx-envprint .
    docker tag nginx-envprint ${myContainerRegistry}.azurecr.io/nginx-envprint
    docker push ${myContainerRegistry}.azurecr.io/nginx-envprint
    popd
}

# ================= install kubernetes provider ================
function install_kubernestes_provider() {
    local cmd
    cmd="helm install azureappconfiguration.kubernetesprovider \
    oci://mcr.microsoft.com/azure-app-configuration/helmchart/kubernetes-provider \
    --namespace azappconfig-system \
    --create-namespace"
    echo $cmd
    $cmd
}

# ================= link cluster to config service ================
function expose_aks_cluster_principal() {
    local principal
    principal=$(az aks show \
    --name $myAKSCluster \
    --resource-group $myResourceGroup \
    --query identity.principalId \
    --output tsv)
    echo Setting AKS_CLUSTER_PRINCIPAL to "$principal"
    export AKS_CLUSTER_PRINCIPAL="$principal"
}

function assign_aks_to_config_role() {
    local cmd
    cmd="az role assignment create \
    --assignee $AKS_CLUSTER_PRINCIPAL \
    --role \"App Configuration Data Reader\" \
    --scope $APPCONFIG_SERVICE_ID"
    echo $cmd
    $cmd
}

# ================= secret in k8s ================
function k8s_secret_exists() {
    echo Checking k8s secret $K8S_SECRET_FOR_CONFIG
    local cmd="kubectl get secret $K8S_SECRET_FOR_CONFIG"
    echo $cmd
    local EXIT_CODE
    EXIT_CODE=0
    $cmd || EXIT_CODE=$?
    if [ $AE_DEBUG ] ; then echo $EXIT_CODE; fi
    return $EXIT_CODE
}

function create_k8s_secret() {
    echo Creating k8s secret $K8S_SECRET_FOR_CONFIG
    # local cmd="kubectl create secret generic \
    #     config-service-secret \
    #     --from-literal=azure_app_configuration_connection_string=$APPCONFIG_CONNECTION_STRING'"
    # echo $cmd
    # $cmd
    kubectl create secret generic \
        config-service-secret \
        --from-literal="azure_app_configuration_connection_string=$APPCONFIG_CONNECTION_STRING"
}

function ensure_k8s_secret() {
    if k8s_secret_exists ; then
        echo k8s_secret $K8S_SECRET_FOR_CONFIG already exists, good.
    else
        echo k8s_secret $K8S_SECRET_FOR_CONFIG does not exist, creating
        create_k8s_secret
    fi
}

# ================= config_configmap ================
function config_configmap_exists() {
    echo Checking config configmap $CONFIGMAP_FROM_CONFIG_PROVIDER
    local cmd="kubectl get configmap $CONFIGMAP_FROM_CONFIG_PROVIDER"
    echo $cmd
    local EXIT_CODE
    EXIT_CODE=0
    $cmd || EXIT_CODE=$?
    if [ $AE_DEBUG ] ; then echo $EXIT_CODE; fi
    return $EXIT_CODE
}

function create_config_configmap() {
    echo Creating config configmap $CONFIGMAP_FROM_CONFIG_PROVIDER
    local cmd="cat nginx/csSecret.yaml | envsubst | kubectl apply -f -"
    echo $cmd
    eval "$cmd"
}

function ensure_config_configmap() {
    if config_configmap_exists ; then
        echo config configmap $CONFIGMAP_FROM_CONFIG_PROVIDER already exists, good.
    else
        echo config configmap $CONFIGMAP_FROM_CONFIG_PROVIDER does not exist, creating
        create_config_configmap
    fi
}

# ================= config_configmap ================
function create_and_start_service() {
    cat nginx/deployment.yaml | envsubst | kubectl apply -f -
    cat nginx/service.yaml | envsubst | kubectl apply -f -
    kubectl get service my-app-demo-service -o json | jq .status.loadBalancer.ingress[0].ip
}
