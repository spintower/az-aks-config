# create a user in AD that will be the admin for Azure SQL instance
resource "azuread_user" "sqladmin" {
  user_principal_name = "sqladmin@alexkotovoutlook.onmicrosoft.com"
  display_name        = "SQL Admin"
  mail_nickname       = "sqladmin"
  password            = ""
}
