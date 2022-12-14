terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.29.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
