# Declare the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg2" {
  name     = "rg-12"
  location = "East US"
}

# Create a virtual network
resource "azurerm_virtual_network" "az-vn" {
  name                = "Az-vn1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
}

# Create a subnet
resource "azurerm_subnet" "az-sub" {
  name                 = "Az-sub1"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.az-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP address
resource "azurerm_public_ip" "Az_ip" {
  name                = "Az-ip1"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  allocation_method   = "Static"
}

# Create a network interface
resource "azurerm_network_interface" "Az_ni" {
  name                = "Az-ni1"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

  ip_configuration {
    name                          = "example-ip-config"
    subnet_id                     = azurerm_subnet.az-sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Az_ip.id
  }
}

# Create a virtual machine
resource "azurerm_virtual_machine" "VM" {
  name                  = "Vm_01"
  location              = azurerm_resource_group.rg2.location
  resource_group_name   = azurerm_resource_group.rg2.name
  network_interface_ids = [azurerm_network_interface.Az_ni.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "examplevm"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}
#creat ne