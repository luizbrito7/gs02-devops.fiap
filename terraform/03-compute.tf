resource "azurerm_public_ip" "this" {
  name                = "pip-${local.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${local.name}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# 2 vCPU / 8 GB: SonarQube pede 4 GB, o resto fica para Jenkins e app
resource "azurerm_linux_virtual_machine" "this" {
  name                  = "vm-${local.name}"
  resource_group_name   = azurerm_resource_group.this.name
  location              = azurerm_resource_group.this.location
  size                  = "Standard_B2ms"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.this.id]
  custom_data           = filebase64("${path.module}/cloud-init.sh")

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/gs02_devops.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

output "ssh" {
  value = "ssh -i ~/.ssh/gs02_devops azureuser@${azurerm_public_ip.this.ip_address}"
}

output "ip" {
  value = azurerm_public_ip.this.ip_address
}
