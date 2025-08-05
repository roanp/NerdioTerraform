resource "azurerm_virtual_network" "nerdio" {
  name                = "${lower(var.base_name)}-vnet"
  location            = azurerm_resource_group.nerdio.location
  resource_group_name = azurerm_resource_group.nerdio.name

  address_space = var.vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  virtual_network_name = azurerm_virtual_network.nerdio.name
  resource_group_name  = azurerm_virtual_network.nerdio.resource_group_name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.nerdio.address_space[0], 1, 0)]

  #private_endpoint_network_policies_enabled = true
}

resource "azurerm_subnet" "appsvc" {
  name                 = "appsvc"
  virtual_network_name = azurerm_virtual_network.nerdio.name
  resource_group_name  = azurerm_virtual_network.nerdio.resource_group_name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.nerdio.address_space[0], 1, 1)]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_security_group" "nerdio" {
  name                = "${lower(var.base_name)}-nsg"
  location            = azurerm_resource_group.nerdio.location
  resource_group_name = azurerm_resource_group.nerdio.name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.nerdio.id
}

resource "azurerm_subnet_network_security_group_association" "appsvc" {
  subnet_id                 = azurerm_subnet.appsvc.id
  network_security_group_id = azurerm_network_security_group.nerdio.id
}
