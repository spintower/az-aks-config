# Generate random text for a unique storage account name
resource "random_id" "storage_account_random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.sqlresourcegroup.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "sql_storage_account" {
  name                     = "diag${random_id.storage_account_random_id.hex}"
  location                 = azurerm_resource_group.sqlresourcegroup.location
  resource_group_name      = azurerm_resource_group.sqlresourcegroup.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}