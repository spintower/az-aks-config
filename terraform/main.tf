# TODO set the variables below either enter them in plain text after = sign, or change them in variables.tf
#  (var.xyz will take the default value from variables.tf if you don't change it)

# Create resource group
resource "azurerm_resource_group" "sqlresourcegroup" {
  name     = "${random_pet.prefix.id}-rg"
  location = var.location
}

resource "azurerm_mssql_server" "mssql_server" {
  name                         = "${random_pet.prefix.id}-mssql-server"
  resource_group_name          = azurerm_resource_group.sqlresourcegroup.name
  location                     = azurerm_resource_group.sqlresourcegroup.location
  administrator_login          = "${replace(random_pet.prefix.id, "-", "")}admin"
  administrator_login_password = random_password.sqlpassword.result
  version                      = "12.0"
  
  azuread_administrator {
    login_username = azuread_user.sqladmin.user_principal_name
    object_id      = azuread_user.sqladmin.object_id
  }
}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "FirewallRule1"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = azurerm_public_ip.my_terraform_public_ip.ip_address
  end_ip_address   = azurerm_public_ip.my_terraform_public_ip.ip_address
}

resource "azurerm_mssql_database" "mssql_db" {
  name      = "testdb1"
  server_id = azurerm_mssql_server.mssql_server.id
}

output "mssql_server" {
  value = azurerm_mssql_server.mssql_server
  sensitive = true
}

output "mssql_db" {
  value = azurerm_mssql_database.mssql_db
  sensitive = true
}