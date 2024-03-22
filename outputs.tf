output "virtual_machines" {
  value = { for vm in azurerm_linux_virtual_machine.this :
    vm.computer_name => vm.private_ip_address
  }
}

output "public_ips" {
  value = { for k, v in azurerm_public_ip.this : k => v.ip_address }
}

output "needed_rules_for_security_rules" {
  value = local.needed_rules_for_security_rules
}

output "authorized_keys" {
  value     = join("\n", [var.bootstrapping_ssh_key, var.ssh_key_public])
  sensitive = false
}
