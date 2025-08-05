base_name = "rparters5"
location  = "Australia East"
packageUri = "https://cssa85ca20741cd99f16896d.blob.core.windows.net/custom-scripts/site.zip?sp=r&st=2025-07-01T13:22:53Z&se=2025-08-05T21:22:53Z&spr=https&sv=2024-11-04&sr=b&sig=6KDqwGH39ZrYar37h0Dsqg0KSn2wR%2FdIgaHqegabsnc%3D"

vnet_address_space = ["10.15.0.0/16"]

allow_public_access = true

webapp_sku = "B3"
sql_sku    = "S1"

allow_delegated_write_permissions = true

nerdio_tag_prefix = "NMW"

desktop_admins = {
  "admin1" = "DesktopAdmin@domain.onmicrosoft.com"
 
}

desktop_users = {
  "user1" = "DesktopUser@domain.onmicrosoft.com"
 
}

helpdesk_users = {
  "helpdesk1" = "helpdesk_User@domain.onmicrosoft.com"
}

reviewers = {
  "reviewer1" = "reviewer@domain.onmicrosoft.com"
}

nerdio_admins = {
  "nerdioAdmin1" = "NerdioAdmin@domain.com"
  
}

tags = {
  Environment = "Production"
  Project     = "Nerdio"
}