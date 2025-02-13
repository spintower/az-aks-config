resource "azurerm_user_assigned_identity" "uai1" {
  location            = azurerm_resource_group.sqlresourcegroup.location
  name                = "${random_pet.prefix.id}-uai1"
  resource_group_name = azurerm_resource_group.sqlresourcegroup.name
}

# resource "azurerm_user_assigned_identity" "uai2" {
#   location            = azurerm_resource_group.sqlresourcegroup.location
#   name                = "${random_pet.prefix.id}-uai2"
#   resource_group_name = azurerm_resource_group.sqlresourcegroup.name
# }

# assign role on SQL server to UMI - turns out this is not necessary
# resource "azurerm_role_assignment" "uai1_sql_db_cont" {
#   scope                = azurerm_mssql_server.mssql_server.id
#   role_definition_name = "SQL DB Contributor"
#   principal_id         = azurerm_user_assigned_identity.uai1.principal_id
# }

# assign one more role on SQL server to UMI - turns out this is not necessary
# resource "azurerm_role_assignment" "uai1_sql_mg_inst_cont" {
#   scope                = azurerm_mssql_server.mssql_server.id
#   role_definition_name = "SQL Managed Instance Contributor"
#   principal_id         = azurerm_user_assigned_identity.uai1.principal_id
# }

# assign role on SQL logical DB to UMI - turns out this is not necessary
# resource "azurerm_role_assignment" "uai1_sql_db_cont_testdb1" {
#   scope                = azurerm_mssql_database.mssql_db.id
#   role_definition_name = "SQL DB Contributor"
#   principal_id         = azurerm_user_assigned_identity.uai1.principal_id
# }

# assign another role on SQL logical DB to UMI - turns out this is not necessary
# resource "azurerm_role_assignment" "uai1_sql_mg_inst_cont_testdb1" {
#   scope                = azurerm_mssql_database.mssql_db.id
#   role_definition_name = "SQL Managed Instance Contributor"
#   principal_id         = azurerm_user_assigned_identity.uai1.principal_id
# }

output "uai1" {
  value = azurerm_user_assigned_identity.uai1
}

# output "uai2" {
#   value = azurerm_user_assigned_identity.uai2
# }
