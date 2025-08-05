resource "azurerm_resource_group" "nerdio" {
  name     = "${lower(var.base_name)}-rg"
  location = var.location
  tags     = var.tags
}
