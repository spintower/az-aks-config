output "resource_group_name" {
  value = azurerm_resource_group.sqlresourcegroup.name
}

output "admin_login" {
    value = "${replace(random_pet.prefix.id, "-", "")}admin"
}

output "admin_password" {
  sensitive = true
  value     = random_password.sqlpassword.result
}

