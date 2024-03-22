resource "azurerm_public_ip" "this" {
  for_each            = { for k, v in var.virtual_machines : k => v if v.expose != null }
  name                = "ip-public-${random_string.id[each.key].result}-${var.postfix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    create_before_destroy = true
  }
}
//TO DO: can be used for switching to Load Balancer implementation
/*
resource "azurerm_network_interface" "public" {
  # checkov:skip=CKV_AZURE_119: "Ensure that Network Interfaces don't use public IPs" - only created if wanted
  for_each            = { for k, v in var.virtual_machines : k => v if v.expose != null }
  location            = var.location
  name                = "nic-public-${each.key}-${var.postfix}"
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ip-${random_string.id[each.key].result}-${var.postfix}"
    subnet_id                     = lookup(var.vnet_subnets_name_id, each.value.public_subnet_id, "")
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.this[each.key].id
  }
  tags = var.tags
}
*/

resource "azurerm_network_security_rule" "this" {
  for_each                     = { for k, v in local.needed_rules_for_security_rules : k => v if length(v) > 0 }
  name                         = "Public-${each.key}"
  priority                     = lookup(var.nsg_ruleset, each.key).priority
  direction                    = lookup(var.nsg_ruleset, each.key).direction
  resource_group_name          = var.resource_group_name
  protocol                     = lookup(var.nsg_ruleset, each.key).protocol
  access                       = lookup(var.nsg_ruleset, each.key).access
  network_security_group_name  = var.nsg_name
  destination_address_prefixes = each.value
  destination_port_ranges      = lookup(var.nsg_ruleset, each.key).destination_port_ranges
  source_port_range            = "*"
  source_address_prefix        = "*"
  depends_on                   = [azurerm_linux_virtual_machine.this, azurerm_public_ip.this]
}

resource "azurerm_dns_a_record" "this" {
  for_each            = { for k, v in var.virtual_machines : k => v if v.expose != null }
  name                = "${each.key}.${var.dns_region}.${var.environment}"
  zone_name           = var.public_dns_zone_name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300
  records             = [azurerm_public_ip.this[each.key].ip_address]
  tags                = var.tags
  depends_on          = [azurerm_public_ip.this]
}
