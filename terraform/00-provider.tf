terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.13"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
  }
}

# subscription_id vem do `az login` (assinatura padrão)
provider "azurerm" {
  features {}
}

locals {
  name     = "gs02-devops"
  location = "brazilsouth"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name}"
  location = local.location
}
