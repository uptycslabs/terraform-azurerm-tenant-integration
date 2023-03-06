data "azuread_application_published_app_ids" "well_known" {}

data "azurerm_client_config" "current" {}

# Get the Management Group
data "azurerm_management_group" "parent_management_group" {
  name = var.root_management_group_id
}

data "azurerm_subscriptions" "all_subscriptions" {
}

data "azurerm_resources" "Fetch_keyvalutids" {
  type = "Microsoft.KeyVault/vaults"
}
