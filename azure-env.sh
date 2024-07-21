set -e
set -u

source ./setup.sh
source ./azure-env-functions.sh

export AE_DEBUG=1

show_initial_vars

ensure_resource_group

ensure_appconfig_service
set_appconfig_endoint
set_appconfig_connection_string
expose_appconfig_service_id
insert_keys_to_config

ensure_keyvault

ensure_container_registry
login_to_registry

ensure_aks_cluster
ensure_k8s_app_namespace

build_and_push_envprint

install_kubernestes_provider

ensure_k8s_secret

ensure_config_configmap

create_and_start_service

check_service_settings
