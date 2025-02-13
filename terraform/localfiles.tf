resource "local_file" "private_key" {
    content  = azapi_resource_action.ssh_public_key_gen.output.privateKey
    filename = "localfiles/private_key.pem"
    file_permission = "0400"
}

resource "local_file" "public_key" {
    content  = azapi_resource_action.ssh_public_key_gen.output.publicKey
    filename = "localfiles/public_key.pem"
    file_permission = "0400"
}

resource "local_file" "admin_login" {
    content  = "${replace(random_pet.prefix.id, "-", "")}admin"
    filename = "localfiles/admin_login"
}

resource "local_file" "admin_password" {
    content  = random_password.sqlpassword.result
    filename = "localfiles/admin_password"
}

resource "local_file" "public_ip_address" {
    content  = azurerm_linux_virtual_machine.sql_terraform_vm.public_ip_address
    filename = "localfiles/public_ip_address"
}

resource "local_file" "resource_group_name" {
    content  = azurerm_resource_group.sqlresourcegroup.name
    filename = "localfiles/resource_group_name"
}

resource "local_file" "dbserver" {
    content  = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
    filename = "localfiles/dbserver"
}

resource "local_file" "dbname" {
    content  = "testdb1"
    filename = "localfiles/dbname"
}

resource "local_file" "miname" {
    content  = azurerm_user_assigned_identity.uai1.name
    filename = "localfiles/miname"
}

resource "local_file" "sqladmin_name" {
    content  = azuread_user.sqladmin.user_principal_name
    filename = "localfiles/sqladmin_name"
}

resource "local_file" "sqladmin_password" {
    content  = azuread_user.sqladmin.password
    filename = "localfiles/sqladmin_password"
}

resource "local_file" "sql_create_user" {
    content = <<EOT
CREATE USER [${azurerm_user_assigned_identity.uai1.name}] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [${azurerm_user_assigned_identity.uai1.name}];
ALTER ROLE db_datawriter ADD MEMBER [${azurerm_user_assigned_identity.uai1.name}];
ALTER ROLE db_ddladmin ADD MEMBER [${azurerm_user_assigned_identity.uai1.name}];
GO
EOT
    filename = "localfiles/create_user.sql"
}