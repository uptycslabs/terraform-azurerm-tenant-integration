data "azuread_application_published_app_ids" "app_ids" {}

data "azurerm_client_config" "current" {}

data "azurerm_management_group" "parent_management_group" {
  name = var.parent_management_group_id
}

data "azurerm_subscriptions" "all_subscriptions" {
}

data "azurerm_resources" "Fetch_keyvalutids" {
  type = "Microsoft.KeyVault/vaults"
}
