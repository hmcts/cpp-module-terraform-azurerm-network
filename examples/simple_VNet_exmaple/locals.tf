#------------------------
# Local declarations
#------------------------
locals {
  environment            = "dev"
  role                   = "simpleeg"
  delimiter              = "-"
  resource_group_name    = join(local.delimiter, ["rg", local.environment, local.role, "01"])
  nw_resource_group_name = join(local.delimiter, ["rg", local.environment, local.role, "nw"])
  vnetwork_name          = join(local.delimiter, ["vn", local.environment, local.role, "01"])
  location               = "uksouth"
  mgnt_subnet_name       = join(local.delimiter, ["sn", local.environment, local.role, "mngt"])
  dmz_subnet_name        = join(local.delimiter, ["sn", local.environment, local.role, "dmz"])
  ddos_plan_name         = join(local.delimiter, ["dpp", local.environment, local.role, "01"])

  gateway_subnet_name  = join(local.delimiter, ["gws", local.environment, local.role, "01"])
  firewall_subnet_name = join(local.delimiter, ["fws", local.environment, local.role, "01"])

  create_dns_zone     = true
  dns_zone_name       = join(local.delimiter, ["dz", local.environment, local.role, "01.local"])
  dns_zone_soa_record = { ttl = 3000 }
  tags                = { environment = "dev", role = "simpleeg", location = "uksouth", platform = "nl", tier = "testing" }

}



