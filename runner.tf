resource "azurerm_virtual_machine_extension" "this" {
  for_each             = { for k, v in var.virtual_machines : k => v if v.configure_as_runner == true }
  name                 = "vm-${each.key}-${var.postfix}"
  virtual_machine_id   = azurerm_linux_virtual_machine.this[each.key].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  settings             = <<SETTINGS
 {
  "script": "${base64encode(templatefile("files/github-runner.tftpl", { key = var.github_app_private_key }))}"
 }
SETTINGS
  lifecycle {
    ignore_changes = [settings]
  }
  tags = var.tags
}
