resource "azurerm_application_insights" "nerdio" {
  name                = "${lower(var.base_name)}-appi"
  location            = azurerm_resource_group.nerdio.location
  resource_group_name = azurerm_resource_group.nerdio.name
  workspace_id        = azurerm_log_analytics_workspace.nerdio.id
  application_type    = "web"

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "nerdio" {
  name                = "${lower(var.base_name)}-log"
  location            = azurerm_resource_group.nerdio.location
  resource_group_name = azurerm_resource_group.nerdio.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(var.tags, { "${var.nerdio_tag_prefix}_OBJECT_TYPE" = "LOG_ANALYTICS_WORKSPACE" })
}

#
# Solutions to enable Azure Defender
#
resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = azurerm_resource_group.nerdio.location
  resource_group_name   = azurerm_resource_group.nerdio.name
  workspace_resource_id = azurerm_log_analytics_workspace.nerdio.id
  workspace_name        = azurerm_log_analytics_workspace.nerdio.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "security_center" {
  solution_name         = "SecurityCenterFree"
  location              = azurerm_resource_group.nerdio.location
  resource_group_name   = azurerm_resource_group.nerdio.name
  workspace_resource_id = azurerm_log_analytics_workspace.nerdio.id
  workspace_name        = azurerm_log_analytics_workspace.nerdio.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityCenterFree"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "sql_advanced_threat_protection" {
  solution_name         = "SQLAdvancedThreatProtection"
  location              = azurerm_resource_group.nerdio.location
  resource_group_name   = azurerm_resource_group.nerdio.name
  workspace_resource_id = azurerm_log_analytics_workspace.nerdio.id
  workspace_name        = azurerm_log_analytics_workspace.nerdio.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SQLAdvancedThreatProtection"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "sql_vulnerability_assessment" {
  solution_name         = "SQLVulnerabilityAssessment"
  location              = azurerm_resource_group.nerdio.location
  resource_group_name   = azurerm_resource_group.nerdio.name
  workspace_resource_id = azurerm_log_analytics_workspace.nerdio.id
  workspace_name        = azurerm_log_analytics_workspace.nerdio.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SQLVulnerabilityAssessment"
  }

  tags = var.tags
}
