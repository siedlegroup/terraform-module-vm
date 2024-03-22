resource "random_string" "id" {
  for_each         = var.virtual_machines
  length           = 5
  numeric          = true
  special          = false
  override_special = "/@£$"
}

resource "random_password" "pw" {
  length           = 16
  numeric          = true
  special          = true
  override_special = "+#*$%&§!.-?"
}

resource "azurerm_network_interface" "private" {
  # checkov:skip=CKV_AZURE_119: we do want public ip addresses for the network interface
  for_each            = var.virtual_machines
  name                = "nic-private-${each.key}-${var.postfix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ip-${random_string.id[each.key].result}-${var.postfix}"
    subnet_id                     = lookup(var.vnet_subnets_name_id, each.value.private_subnet_id, "")
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.expose != null ? azurerm_public_ip.this[each.key].id : null

  }
  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  # checkov:skip=CKV_AZURE_1: we do not use basic auth - only ssh auth allowed
  # checkov:skip=CKV_AZURE_50: extension needed for vm bootstrapping
  for_each                   = var.virtual_machines
  name                       = "vm-${each.key}-${var.postfix}"
  computer_name              = coalesce(each.value.vm_name, "${each.key}.${var.dns_region}.${var.environment}")
  network_interface_ids      = [azurerm_network_interface.private[each.key].id]
  allow_extension_operations = each.value.configure_as_runner != null ? "true" : "false"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  size                       = each.value.size
  admin_username             = "ubuntu"

  admin_ssh_key {
    public_key = var.ssh_key_public
    username   = "ubuntu"
  }
  provisioner "file" {
    content     = join("\n", [var.bootstrapping_ssh_key, var.ssh_key_public])
    destination = "/home/ubuntu/.ssh/authorized_keys"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ssh_key_private
      host        = azurerm_network_interface.private[each.key].private_ip_address
    }
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value.storage_account_type
    disk_size_gb         = each.value.disk_size
  }

  boot_diagnostics {
    storage_account_uri = var.vmsto_account_uri
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_private_dns_a_record" "this" {
  for_each            = var.virtual_machines
  name                = "${each.key}.${var.dns_region}.${var.environment}"
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.dns_zone_resource_group
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.this[each.key].private_ip_address]
  tags                = var.tags
}

