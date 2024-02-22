variable "environment" {
  type        = string
  description = "Environment (stage) name for this Key Vault"
}

variable "postfix" {
  type        = string
  description = "Suffix definition providing predictable resource names"
}

variable "resource_group_name" {
  type        = string
  description = "A logical container that holds related resources for an Azure solution"
}

variable "dns_zone_resource_group" {
  type        = string
  description = "Resource group name of DNS zone to create record in (usually in shared env)"
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name of the existing private DNS zone, usually in a shared environment"
}

variable "location" {
  type        = string
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "dns_region" {
  type        = string
  description = "The region part of the DNS name, example: resources in locations germanywestcentral and germanynort will have a DNS name with .de."
}

variable "vnet_subnets_name_id" {
  type        = map(string)
  description = "Subnet names and IDs created in the current vnet"
}

variable "ssh_key" {
  type        = string
  description = "SSH key to add to each vm for secure access"
}

variable "vmsto_account_uri" {
  type        = string
  description = "Endpoint for storage account to store diagnostics and os_disk"
}

variable "virtual_machines" {
  type = map(object({
    vm_name              = optional(string)
    size                 = string
    disk_size            = number
    subnet_id            = string
    configure_as_runner  = optional(bool)
    expose               = optional(list(string))
    storage_account_type = optional(string)
  }))
  description = "Map of VM instances and their configuration parameters"
}

variable "github_app_private_key" {
  type        = string
  description = "SGC Github app private key"
  sensitive   = true
  default     = ""
}

variable "nsg_name" {
  type        = string
  description = "Name of the Network Security Group where the security group rules will be applied"
}

variable "nsg_ruleset" {
  type = map(object({
    priority               = number,
    direction              = string,
    protocol               = string,
    access                 = string,
    destination_port_range = string,
  }))
}
