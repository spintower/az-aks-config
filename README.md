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

alex@ :~/work/aks/azure/az-aks-config$ az role assignment create --role "Key Vault Secrets Officer" --assignee 3ddff80c-4004-447a-881c-719d3c015be9 --scope $keyVaultId 
{
  "condition": null,
  "conditionVersion": null,
  "createdBy": null,
  "createdOn": "2024-07-30T05:37:44.858024+00:00",
  "delegatedManagedIdentityResourceId": null,
  "description": null,
  "id": "/subscriptions/6ef47e6b-b3c5-4454-bb03-f60429ecb467/resourceGroups/configed-app-rg/providers/Microsoft.KeyVault/vaults/configed-app-kv-clover/providers/Microsoft.Authorization/roleAssignments/8f618284-e826-4838-9815-8c8a711a3782",
  "name": "8f618284-e826-4838-9815-8c8a711a3782",
  "principalId": "3ddff80c-4004-447a-881c-719d3c015be9",
  "principalType": "User",
  "resourceGroup": "configed-app-rg",
  "roleDefinitionId": "/subscriptions/6ef47e6b-b3c5-4454-bb03-f60429ecb467/providers/Microsoft.Authorization/roleDefinitions/b86a8fe4-44ce-4948-aee5-eccb2c155cd7",
  "scope": "/subscriptions/6ef47e6b-b3c5-4454-bb03-f60429ecb467/resourceGroups/configed-app-rg/providers/Microsoft.KeyVault/vaults/configed-app-kv-clover",
  "type": "Microsoft.Authorization/roleAssignments",
  "updatedBy": "3ddff80c-4004-447a-881c-719d3c015be9",
  "updatedOn": "2024-07-30T05:37:45.375350+00:00"
}
