// TO DO: currently not in use, but can be activated for switching to Load Balancer implementation
/*
resource "azurerm_lb" "this" {
  name                = "lb-public-${var.postfix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"

  dynamic "frontend_ip_configuration" {
    for_each = { for vm_key, vm in var.virtual_machines : vm_key => vm if vm.expose != null && vm.public_subnet_id != null }
    content {
      name                 = "frontend-${frontend_ip_configuration.key}-${var.postfix}"
      public_ip_address_id = lookup(azurerm_public_ip.this, frontend_ip_configuration.key, null).id
      #subnet_id            = frontend_ip_configuration.value.public_subnet_id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  for_each = { for k, v in var.virtual_machines : k => v if v.expose != null }

  loadbalancer_id = azurerm_lb.this.id
  name            = "lb-backend-${each.key}-${var.postfix}"
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  for_each = { for k, v in var.virtual_machines : k => v if v.expose != null }

  backend_address_pool_id = azurerm_lb_backend_address_pool.this[each.key].id
  name                    = "lb-backend-addr-${each.key}-${var.postfix}"
  ip_address              = azurerm_network_interface.public[each.key].private_ip_address
  virtual_network_id      = var.vnet_id
  depends_on              = [azurerm_lb_backend_address_pool.this]
}

resource "azurerm_lb_probe" "this" {
  for_each        = local.lb_rule_probes
  loadbalancer_id = azurerm_lb.this.id
  name            = each.key
  port            = each.value
}

resource "azurerm_lb_rule" "this" {
  for_each = { for idx, val in local.combined_exposures : "${val.vm_name}-${val.protocol}" => val if val.rule_config != null }

  loadbalancer_id                = azurerm_lb.this.id
  name                           = "rule-${each.value.vm_name}-${each.value.protocol}-${var.postfix}"
  protocol                       = each.value.rule_config.protocol
  frontend_port                  = element(each.value.rule_config.destination_port_ranges, 0)
  backend_port                   = element(each.value.rule_config.destination_port_ranges, 0)
  frontend_ip_configuration_name = "frontend-${each.value.vm_name}-${var.postfix}"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.value.vm_name].id]
  probe_id                       = azurerm_lb_probe.this[each.value.protocol].id
  idle_timeout_in_minutes        = 5
  enable_floating_ip             = false
}
*/
