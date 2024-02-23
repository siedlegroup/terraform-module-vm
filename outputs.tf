output "virtual_machines" {
  value = { for vm in azurerm_linux_virtual_machine.this :
    vm.computer_name => vm.private_ip_address
  }
}
