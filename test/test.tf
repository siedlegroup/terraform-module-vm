terraform {
  required_version = "> 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.89.0, < 4.0.0"
    }
    # add azuread or other providers as required for testing purposes
    //azuread = {
    //  source  = "hashicorp/azuread"
    //  version = "~> 2.47.0"
    //}
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
  use_msi = true
}

//provider "azuread" {}

# add requierd input parameters in local object and call module in repository root from here:

locals {
  # add inputs here
}

//module "changeme" {
//  source = "../."
//}
