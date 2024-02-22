resource "azurerm_public_ip" "this" {
  for_each            = { for k, v in var.virtual_machines : k => v if v.expose != null }
  name                = "ip-public-${each.key}-${var.postfix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_rule" "this" {
  for_each                     = { for k, v in local.needed_rules_for_security_rules : k => v if length(v) > 0 }
  name                         = each.key
  priority                     = lookup(var.nsg_ruleset, each.key).priority
  direction                    = lookup(var.nsg_ruleset, each.key).direction
  resource_group_name          = var.resource_group_name
  protocol                     = lookup(var.nsg_ruleset, each.key).protocol
  access                       = lookup(var.nsg_ruleset, each.key).access
  network_security_group_name  = var.nsg_name
  destination_address_prefixes = each.value
  destination_port_range       = lookup(var.nsg_ruleset, each.key).destination_port_range
  source_port_range            = "*"
  source_address_prefix        = "*"
}