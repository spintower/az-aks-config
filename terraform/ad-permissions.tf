# removing - this should not be necessary
# data "azuread_application_published_app_ids" "well_known" {}

# resource "azuread_service_principal" "msgraph" {
#   client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
#   use_existing = true
# }

# assign the following MSGraph permissions to UAI
#   "User.Read.All"
#   "GroupMember.Read.All"
#   "Application.Read.All"

# resource "azuread_app_role_assignment" "user_read_all" {
#   app_role_id         = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
#   principal_object_id = azurerm_user_assigned_identity.uai1.principal_id
#   resource_object_id  = azuread_service_principal.msgraph.object_id
# }
# resource "azuread_app_role_assignment" "gm_read_all" {
#   app_role_id         = azuread_service_principal.msgraph.app_role_ids["GroupMember.Read.All"]
#   principal_object_id = azurerm_user_assigned_identity.uai1.principal_id
#   resource_object_id  = azuread_service_principal.msgraph.object_id
# }
# resource "azuread_app_role_assignment" "app_read_all" {
#   app_role_id         = azuread_service_principal.msgraph.app_role_ids["Application.Read.All"]
#   principal_object_id = azurerm_user_assigned_identity.uai1.principal_id
#   resource_object_id  = azuread_service_principal.msgraph.object_id
# }
