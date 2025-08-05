resource "azurerm_shared_image_gallery" "nerdio" {
  name                = "${lower(replace(var.base_name, "-", ""))}sig"
  resource_group_name = azurerm_resource_group.nerdio.name
  location            = azurerm_resource_group.nerdio.location
  description         = "Images for Virtual Desktops"

  tags = var.tags
}
