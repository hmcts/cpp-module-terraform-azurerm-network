#------------------------
# Local declarations
#------------------------
locals {
  environment = var.environment
  role        = var.role
  tier        = "testing"

  delimiter              = "-"
  resource_group_name    = join(local.delimiter, ["rg", local.environment, local.role, "01"])
  nw_resource_group_name = join(local.delimiter, ["rg", local.environment, local.role, "nw"])
  vnetwork_name          = join(local.delimiter, ["vn", local.environment, local.role, "01"])
  vnet_address_space     = var.vnet_address_space
  location               = var.location
  mgnt_subnet_name       = join(local.delimiter, ["sn", local.environment, local.role, "mngt"])
  dmz_subnet_name        = join(local.delimiter, ["sn", local.environment, local.role, "dmz"])
  ddos_plan_name         = join(local.delimiter, ["dpp", local.environment, local.role, "01"])

  gateway_subnet_name            = join(local.delimiter, ["gws", local.environment, local.role, "01"])
  gateway_subnet_address_prefix  = var.gateway_subnet_address_prefix
  firewall_subnet_name           = join(local.delimiter, ["fws", local.environment, local.role, "01"])
  firewall_subnet_address_prefix = var.firewall_subnet_address_prefix
  create_dns_zone                = var.create_dns_zone
  dns_zone_name                  = join(local.delimiter, ["dz", local.environment, local.role, "01.local"])
  dns_zone_soa_record            = var.dns_zone_soa_record
  tags                           = var.tags

}

