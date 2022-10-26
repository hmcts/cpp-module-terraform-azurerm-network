#------------------------
# Local declarations
#------------------------
locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  if_ddos_enabled     = var.create_ddos_plan ? [{}] : []
  # Constructing standardised name for Network Watcher
  ntk_watcher_name = join("-", ["nw", var.environment, var.role, "01"])

  create_dns_zone = var.create_dns_zone && length(var.dns_zone_name) > 0
}
