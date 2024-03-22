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

  //TO DO: create working dependency inclusion by adding required modules to this test
}

module "vm" {
  source = "../."
  tags = {
    owner       = "siedle-group-cloud"
    environment = "test"
    project     = "SUS"
    location    = "Germany West Central"
    managed     = path.root
  }
  environment             = "test1"
  location                = "germanywestcentral"
  postfix                 = "sgc-platform-test"
  dns_region              = "de"
  private_dns_zone_name   = "test.cloud.siedle.com"
  public_dns_zone_name    = "test.cloud.siedle.com"
  dns_zone_resource_group = "sgc-dns"
  resource_group_name     = "rg-test.cloud.siedle.com"
  nsg_ruleset = {
    "HTTPS" : {
      priority : 1000,
      direction : "Inbound",
      protocol : "Tcp",
      access : "Allow",
      destination_port_range = "443",
    }
  }
  vnet_subnets_name_id = dependency.vnet.outputs.vnet_subnets_name_id
  vmsto_account_uri    = dependency.storage.outputs.storage_account_uri
  nsg_name             = dependency.nsg.outputs.network_security_group_name
  virtual_machines = {
    "appl01" = {
      size                 = "Standard_B2ls_v2",
      disk_size            = 30,
      subnet_id            = "subnet1-${include.envcommon.locals.project}"
      storage_account_type = "Standard_LRS"
    }
  }
  bootstrapping_ssh_key = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBACAySnnsRm3Mze6xYo3cSsOyGCv5L+LB54hCmGrTbxJTAlPtKvk3DMEBC1O+3GmT4IvJWvrmrCNwLFGsDD6WvRg9wGOJU8c0Xa5POjpg5vYL0QcTMs+YBany6ljjA42UdgY0nixN10tCkmPrVxrmEI9zv+GSGRlbfqeorZOKgU1yQjSHQ== hw@gilawa.com"
  ssh_key_public        = "aa"
  ssh_key_private       = "aa"
}
