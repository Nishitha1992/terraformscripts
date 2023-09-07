# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}

    subscription_id = "9cf7d5a5-d86d-42c7-a771-9552939ab171"
    client_id       = "9beac7cd-60c5-485a-a3c9-8e5786f0267f"
    client_secret   = "XA28Q~XYh~ionXOSDMMAj_LXewG3W4GWC1uebdBg"
    tenant_id       = "6a1fb993-1866-44b7-ae78-883af9b9ad42"
}

terraform {
  backend "azurerm" {
    storage_account_name = "tfpractice"
    container_name       = "practice1"
    key                  = "nishitha"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    access_key = "tQoaF1HAeBcU+ChD3fzQ8Ud0N3zesGjnIj79mdxRi4xAHlHzGNH1tolFAGiu2MSU04LWWfCoWDIT+ASt84Te9g=="
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = "${var.rgname}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.prefix}-1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["${var.vnet_cidr_prefix}"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-10"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["${var.subnet1_cidr_prefix}"]
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "${var.prefix}-nsg1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_network_security_rule" "nsr1" {
  name                        = "practice6"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg1.name
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

resource "azurerm_subnet_network_security_group_association" "nsga1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_interface" "ni1" {
  name                = "${var.prefix}-ninter"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "wvm1" {
  name                = "${var.prefix}-vmac"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.ni1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}