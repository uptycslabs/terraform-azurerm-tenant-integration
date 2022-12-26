locals {
  all_subscription_ids = toset([for each in data.azurerm_subscriptions.all_subscriptions.subscriptions : each.id if each.state == "Enabled"])
}
resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.app_ids.result.MicrosoftGraph
  use_existing   = true
}


resource "azuread_application" "application" {
  display_name = var.resource_name

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.app_ids.result.MicrosoftGraph
    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
      type = "Role"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["Organization.Read.All"]
      type = "Role"
    }
    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["Group.Read.All"]
      type = "Role"
    }

    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
      type = "Role"
    }

    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["OnPremisesPublishingProfiles.ReadWrite.All"]
      type = "Role"
    }

    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["Application.Read.All"]
      type = "Role"
    }

  }

}

resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.application.application_id
}


resource "azuread_app_role_assignment" "DirectoryReadAll" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "UserReadAll" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "GroupReadAll" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Group.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}


resource "azuread_app_role_assignment" "OrganizationReadAll" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Organization.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "OnPremisesPublishingProfilesReadWriteAll" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["OnPremisesPublishingProfiles.ReadWrite.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}

resource "azuread_app_role_assignment" "ApplicationReadAll" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Application.Read.All"]
  principal_object_id = azuread_service_principal.service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}


resource "azuread_application_password" "password_generation" {
  application_object_id = azuread_application.application.object_id
  end_date_relative     = "86400h"
  display_name          = var.resource_name
}

resource "azurerm_role_assignment" "Attach_Readerrole" {
  scope                = data.azurerm_management_group.parent_management_group.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.service_principal.id
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
  storage_permissions = []
}


resource "local_file" "Credentails" {
  content = jsonencode({
    "clientId"                       = "${azuread_application.application.application_id}",
    "clientSecret"                   = "${azuread_application_password.password_generation.value}",
    "tenantId"                       = "${data.azurerm_client_config.current.tenant_id}",
    "activeDirectoryEndpointUrl"     = "https://login.microsoftonline.com",
    "activeDirectoryGraphResourceId" = "https://graph.windows.net/",
    "galleryEndpointUrl"             = "https://gallery.azure.com/",
    "managementEndpointUrl"          = "https://management.core.windows.net/",
    "resourceManagerEndpointUrl"     = "https://management.azure.com/",
    "sqlManagementEndpointUrl"       = "https://management.core.windows.net:8443/"

  })
  filename = "credentials.json"
}
