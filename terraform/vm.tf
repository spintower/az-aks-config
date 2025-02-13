# Create virtual machine
resource "azurerm_linux_virtual_machine" "sql_terraform_vm" {
  name                  = "myVM"
  location              = azurerm_resource_group.sqlresourcegroup.location
  resource_group_name   = azurerm_resource_group.sqlresourcegroup.name
  network_interface_ids = [azurerm_network_interface.sql_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    # offer     = "0001-com-ubuntu-server-jammy"
    # sku       = "22_04-lts-gen2"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # computer_name  = "hostname"
  computer_name  = "${random_pet.prefix.id}-linux-vm"
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.sql_storage_account.primary_blob_endpoint
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.uai1.id,
      # azurerm_user_assigned_identity.uai2.id,
      ]
  }
}

#resource "azurerm_virtual_machine_extension" "example" {
#  name                 = "hostname"
#  virtual_machine_id   = azurerm_linux_virtual_machine.sql_terraform_vm.id
#  publisher            = "Microsoft.Azure.Extensions"
#  type                 = "CustomScript"
#  type_handler_version = "2.0"
#
#  settings = <<SETTINGS
# {
#  "commandToExecute": "hostname",
#  "commandToExecute": "uptime",
#  "commandToExecute": "sudo apt-get -y install bzip2",
#  "commandToExecute": "wget -O /tmp/sqlcmd-linux-amd64.tar.bz2 wget https://github.com/microsoft/go-sqlcmd/releases/download/v1.8.2/sqlcmd-linux-amd64.tar.bz2"
# }
#SETTINGS
#}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.sql_terraform_vm.public_ip_address
}

output "vmidentity" {
    value = azurerm_linux_virtual_machine.sql_terraform_vm.identity
}
