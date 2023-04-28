locals {
  all_subscription_ids = toset([for each in data.azurerm_subscriptions.all_subscriptions.subscriptions : each.id if each.state == "Enabled"])
}

# Get MSGraph App
resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

# Create a service principal for the Uptycs App 
resource "azuread_service_principal" "service_principal" {
  application_id = var.uptycs_app_client_id
}

# Create Graph API related permissions to the service principal
resource "azuread_app_role_assignment" "application_reader_role" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Application.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "user_reader_role" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "directory_reader_role" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "organization_reader_role" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Organization.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "group_reader_role" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Group.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "on_premises_publishing_profiles_reader_role" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["OnPremisesPublishingProfiles.ReadWrite.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "audit_log_reader_role" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["AuditLog.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

# Give the service principal a Reader role in the Management Group
resource "azurerm_role_assignment" "attach_reader_role" {
  principal_id         = azuread_service_principal.service_principal.id
  scope                = data.azurerm_management_group.parent_management_group.id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "Attach_Key_Vault_Readerrole" {
  count                = var.set_tenant_level_permissions == true ? 1 : 0
  scope                = data.azurerm_management_group.parent_management_group.id
  role_definition_name = "Key Vault Reader"
  principal_id         = azuread_service_principal.service_principal.id
}

resource "azurerm_role_assignment" "Attach_StorageAccountKeyOperatorServicerole" {
  count                = var.set_tenant_level_permissions == true ? 1 : 0
  scope                = data.azurerm_management_group.parent_management_group.id
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = azuread_service_principal.service_principal.id
}

resource "azurerm_role_definition" "Define_App_Service_Auth_Reader" {
  name        = "${var.resource_name}-AppServiceAuthReader"
  scope       = data.azurerm_management_group.parent_management_group.id
  description = "Read permissions for authentication/authorization data related to Azure App Service"

  permissions {
    actions = ["Microsoft.Web/sites/config/list/Action"
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_management_group.parent_management_group.id,
  ]
}

resource "azurerm_role_assignment" "Attach_App_Service_Auth_Reader" {
  count              = var.set_tenant_level_permissions == true ? 1 : 0
  scope              = data.azurerm_management_group.parent_management_group.id
  role_definition_id = azurerm_role_definition.Define_App_Service_Auth_Reader.role_definition_resource_id
  principal_id       = azuread_service_principal.service_principal.id
}


resource "azurerm_role_assignment" "Attach_Key_Vault_Readerrole_to_subscriptions" {
  for_each             = var.set_tenant_level_permissions == true ? [] : local.all_subscription_ids
  scope                = each.key
  role_definition_name = "Key Vault Reader"
  principal_id         = azuread_service_principal.service_principal.id
}

resource "azurerm_role_assignment" "Attach_StorageAccountKeyOperatorServicerole_to_subscriptions" {
  for_each             = var.set_tenant_level_permissions == true ? [] : local.all_subscription_ids
  scope                = each.key
  role_definition_name = "Storage Account Key Operator Service Role"
  principal_id         = azuread_service_principal.service_principal.id
}


resource "azurerm_role_assignment" "Attach_App_Service_Auth_Reader_to_subscriptions" {
  for_each           = var.set_tenant_level_permissions == true ? [] : local.all_subscription_ids
  scope              = each.key
  role_definition_id = azurerm_role_definition.Define_App_Service_Auth_Reader.role_definition_resource_id
  principal_id       = azuread_service_principal.service_principal.id
}

resource "azurerm_key_vault_access_policy" "attach_keyvalut_policy" {
  count        = length(data.azurerm_resources.Fetch_keyvalutids.resources)
  key_vault_id = data.azurerm_resources.Fetch_keyvalutids.resources[count.index].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.service_principal.object_id

  key_permissions = []

  secret_permissions = [
    "List",
  ]
  certificate_permissions = [
    "List",
  ]
  storage_permissions = []
}
