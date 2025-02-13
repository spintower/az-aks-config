resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  location  = azurerm_resource_group.sqlresourcegroup.location
  parent_id = azurerm_resource_group.sqlresourcegroup.id
}

# normally not needed, we'll stash it into a file in locafiles/
#output "key_public" {
#  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
#}

output "key_private" {
  value = azapi_resource_action.ssh_public_key_gen.output.privateKey
}