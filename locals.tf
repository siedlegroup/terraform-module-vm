locals {
  needed_rules_for_security_rules = {
    for k_rule, v_rule in var.nsg_ruleset : k_rule => flatten([
      for k_vm, v_vm in var.virtual_machines : [
        for rule in v_vm.expose : azurerm_network_interface.this[k_vm].private_ip_address if rule == k_rule
      ] if v_vm.expose != null
    ])
  }
}
