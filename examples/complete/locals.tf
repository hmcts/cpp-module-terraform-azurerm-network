#------------------------
# Local declarations
#------------------------
locals {
  environment                    = "dev"
  role                           = "completeeg"
  delimiter                      = "-"
  resource_group_name            = join(local.delimiter, ["rg", local.environment, local.role, "01"])
  nw_resource_group_name         = join(local.delimiter, ["rg", local.environment, local.role, "nw"])
  vnetwork_name                  = join(local.delimiter, ["vn", local.environment, local.role, "01"])
  gateway_subnet_name            = join(local.delimiter, ["gws", local.environment, local.role, "01"])
  firewall_subnet_name           = join(local.delimiter, ["fws", local.environment, local.role, "01"])
  gateway_subnet_address_prefix  = ["10.1.1.0/27"]
  firewall_subnet_address_prefix = ["10.1.0.0/26"]
  location                       = "uksouth"
  mgnt_subnet_name               = join(local.delimiter, ["sn", local.environment, local.role, "mngt"])
  dmz_subnet_name                = join(local.delimiter, ["sn", local.environment, local.role, "dmz"])
  ddos_plan_name                 = join(local.delimiter, ["dpp", local.environment, local.role, "01"])

  tags = { environment = "dev", role = "completeeg", location = "uksouth", platform = "nl", tier = "testing" }
}



