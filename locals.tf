locals {
  needed_rules_for_security_rules = {
    for k_rule, v_rule in var.nsg_ruleset : k_rule => flatten([
      for k_vm, v_vm in var.virtual_machines : [
        for rule in v_vm.expose : azurerm_network_interface.private[k_vm].private_ip_address if rule == k_rule && contains(keys(azurerm_network_interface.private), k_vm)
      ] if v_vm.expose != null
    ])
  }
}

//TO DO: can be used for switching to Load Balancer implementation
/*
locals {
  lb_rule_probes = {
    HTTP    = "80"
    HTTPS   = "443"
    MQTT    = "8883"
    SIP-UDP = "5060"
    SIP-TCP = "5060"
  }
}

locals {
  combined_exposures = flatten([
    for vm_name, vm_details in var.virtual_machines != null ? var.virtual_machines : {} : [
      for protocol in lookup(vm_details, "expose", []) != null ? lookup(vm_details, "expose", []) : [] : {
        vm_name     = vm_name
        protocol    = protocol
        rule_config = lookup(var.nsg_ruleset, protocol, null)
      }
    ]
  ])
}
*/
