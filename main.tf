
resource "azurerm_windows_web_app" "nerdio" {
  name                      = "${lower(var.base_name)}-app"
  location                  = azurerm_resource_group.nerdio.location
  resource_group_name       = azurerm_resource_group.nerdio.name
  service_plan_id           = azurerm_service_plan.nerdio.id
  https_only                = true
  virtual_network_subnet_id = azurerm_subnet.appsvc.id

  site_config {
    always_on = true
    # health_check_path      = "/public/health/status" # Can't use this as it has a 5 min threshold internally
    http2_enabled          = true
    minimum_tls_version    = 1.2
    ftps_state             = "Disabled"
    use_32_bit_worker      = false
    vnet_route_all_enabled = true

    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
  }

  app_settings = {
    "ApplicationInsights:ConnectionString"   = azurerm_application_insights.nerdio.connection_string
    "ApplicationInsights:InstrumentationKey" = azurerm_application_insights.nerdio.instrumentation_key
    "AzureAd:Instance"                       = "https://login.microsoftonline.com/"
    "AzureAd:ClientId"                       = azuread_application.nerdio_manager.application_id
    "AzureAd:TenantId"                       = data.azurerm_subscription.current.tenant_id
    "Billing:Mode"                           = "MAU"
    "Deployment:AutomationAccountName"       = azurerm_automation_account.nerdio.name
    "Deployment:AutomationEnabled"           = "True"
    "Deployment:AzureTagPrefix"              = var.nerdio_tag_prefix
    "Deployment:AzureType"                   = "AzureCloud"
    "Deployment:KeyVaultName"                = azurerm_key_vault.nerdio.name
    "Deployment:LogAnalyticsWorkspace"       = azurerm_log_analytics_workspace.nerdio.id
    "Deployment:Region"                      = azurerm_resource_group.nerdio.location
    "Deployment:ResourceGroupName"           = azurerm_resource_group.nerdio.name
    "Deployment:ScriptedActionAccount"       = azurerm_automation_account.nerdio.id
    "Deployment:SubscriptionId"              = data.azurerm_subscription.current.subscription_id
    "Deployment:SubscriptionDisplayName"     = data.azurerm_subscription.current.display_name
    "Deployment:TenantId"                    = data.azurerm_subscription.current.tenant_id
    "Deployment:UpdaterRunbookRunAs"         = "nmwUpdateRunAs"
    "Deployment:WebAppName"                  = "${lower(var.base_name)}-app"
    "RoleAuthorization:Enabled"              = "True"
    "WVD:AadTenantId"                        = data.azurerm_subscription.current.tenant_id
    "WVD:SubscriptionId"                     = data.azurerm_subscription.current.subscription_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_service_plan" "nerdio" {
  name                = "${lower(var.base_name)}-plan"
  resource_group_name = azurerm_resource_group.nerdio.name
  location            = azurerm_resource_group.nerdio.location
  sku_name            = var.webapp_sku
  os_type             = "Windows"

  tags = var.tags
}

resource "azurerm_private_endpoint" "webapp" {
  name                = "${azurerm_windows_web_app.nerdio.name}-ple"
  resource_group_name = azurerm_windows_web_app.nerdio.resource_group_name
  location            = azurerm_windows_web_app.nerdio.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_dns_zone_group {
    name = azurerm_windows_web_app.nerdio.name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.private_link["website"].id
    ]
    
  }

  private_service_connection {
    name                           = "Nerdio"
    private_connection_resource_id = azurerm_windows_web_app.nerdio.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

depends_on = [ azapi_resource.msdeploy,azurerm_key_vault_access_policy.nerdio_service_principal,azurerm_key_vault_access_policy.nerdio_webapp,azurerm_key_vault_certificate.nerdio,azurerm_key_vault_secret.azuread_client_secret,azurerm_key_vault_secret.sql_connection ]
  tags = var.tags
}

resource "azapi_resource" "msdeploy" {
  type = "Microsoft.Web/sites/extensions@2022-03-01"
  name = "MSDeploy"
  parent_id = azurerm_windows_web_app.nerdio.id
  body = jsonencode({
    properties = {
     //This is the sitep.zip or the zip deploy package that Nerdio team needs to provide
         packageUri = var.packageUri
     }
#    kind = "string"
  })

  depends_on = [ azurerm_service_plan.nerdio,azurerm_windows_web_app.nerdio,azurerm_mssql_database.nerdio,azurerm_key_vault.nerdio,azurerm_mssql_server.nerdio]
}

