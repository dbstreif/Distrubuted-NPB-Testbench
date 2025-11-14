provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "npbTest-RG" {
  name = "NpbTestbench"
}

resource "azurerm_virtual_network" "npb-VNet" {
  name                = "npbTest-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westus2"
  resource_group_name = data.azurerm_resource_group.npbTest-RG.name
}

resource "azurerm_subnet" "npbTest-Sub" {
  name                 = "npbTest-subnet"
  resource_group_name  = data.azurerm_resource_group.npbTest-RG.name
  virtual_network_name = azurerm_virtual_network.npb-VNet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "npb-SG" {
  name                = "npb-sg"
  location            = data.azurerm_resource_group.npbTest-RG.location
  resource_group_name = data.azurerm_resource_group.npbTest-RG.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowPing"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

data "azurerm_ssh_public_key" "npb-PubKey" {
  name                = var.ssh_key_name
  resource_group_name = var.ssh_key_rg_name
}


resource "azurerm_public_ip" "npb-PubIp" {
  count               = 3
  name                = "npbTest-pip-${count.index + 1}"
  location            = data.azurerm_resource_group.npbTest-RG.location
  resource_group_name = data.azurerm_resource_group.npbTest-RG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "npb-Nic" {
  count               = 3
  name                = "npbTest-nic-${count.index + 1}"
  location            = data.azurerm_resource_group.npbTest-RG.location
  resource_group_name = data.azurerm_resource_group.npbTest-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.npbTest-Sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.npb-PubIp[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "npb-Nic-Sg" {
  count                     = 3
  network_interface_id      = azurerm_network_interface.npb-Nic[count.index].id
  network_security_group_id = azurerm_network_security_group.npb-SG.id
}

resource "azurerm_linux_virtual_machine" "Node" {
  count                 = 3
  name                  = "NPBTest${count.index + 1}"
  location              = data.azurerm_resource_group.npbTest-RG.location
  resource_group_name   = data.azurerm_resource_group.npbTest-RG.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.npb-Nic[count.index].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = data.azurerm_ssh_public_key.npb-PubKey.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  disable_password_authentication = true
}
