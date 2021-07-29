resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.app_dev_rg_test_01.location
  resource_group_name = azurerm_resource_group.app_dev_rg_test_01.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.app_dev_rg_test_01.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.app_dev_rg_test_01.location
  resource_group_name = azurerm_resource_group.app_dev_rg_test_01.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine-${count.index}"
  resource_group_name = azurerm_resource_group.app_dev_rg_test_01.name
  location            = azurerm_resource_group.app_dev_rg_test_01.location
  count               = 1
  size                = "Standard_A3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
   ]
  

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./pubkey/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
