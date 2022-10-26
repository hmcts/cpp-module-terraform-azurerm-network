resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge(var.tags, { "Name" = format("%s", var.resource_group_name) }, { "role" = var.role }, )

  lifecycle {
    ignore_changes = [
      # Ignore changes to creation related tags
      tags["created_time"], tags["created_by"], tags["creator"],
    ]
  }
}


#-------------------------------------
# VNET Creation - Default is "true"
#-------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetwork_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
  tags                = merge(var.tags, { "Name" = format("%s", var.vnetwork_name) }, { "role" = var.role }, )

  dynamic "ddos_protection_plan" {
    for_each = local.if_ddos_enabled

    content {
      id     = azurerm_network_ddos_protection_plan.ddos[0].id
      enable = true
    }
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to creation related tags
      tags["created_time"], tags["created_by"], tags["creator"],
    ]
  }
}

#--------------------------------------------
# Ddos protection plan - Default is "false"
#--------------------------------------------

resource "azurerm_network_ddos_protection_plan" "ddos" {
  count               = var.create_ddos_plan ? 1 : 0
  name                = var.ddos_plan_name
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = merge(var.tags, { "Name" = format("%s", var.ddos_plan_name) }, { "role" = var.role }, )
  lifecycle {
    ignore_changes = [
      # Ignore changes to creation related tags
      tags["created_time"], tags["created_by"], tags["creator"],
    ]
  }
}

#-------------------------------------
# Network Watcher - Default is "true"
#-------------------------------------
resource "azurerm_resource_group" "nwatcher" {
  count    = var.create_network_watcher != false ? 1 : 0
  name     = var.nw_resource_group_name
  location = local.location
  tags     = merge(var.tags, { "Name" = var.nw_resource_group_name }, { "role" = var.role }, )
  lifecycle {
    ignore_changes = [
      # Ignore changes to creation related tags
      tags["created_time"], tags["created_by"], tags["creator"],
    ]
  }
}

resource "azurerm_network_watcher" "nwatcher" {
  count               = var.create_network_watcher != false ? 1 : 0
  name                = "${local.ntk_watcher_name}_${local.location}"
  location            = local.location
  resource_group_name = azurerm_resource_group.nwatcher.0.name
  tags                = merge(var.tags, { "Name" = format("%s", "${local.ntk_watcher_name}-${local.location}") }, { "role" = var.role }, )
  lifecycle {
    ignore_changes = [
      # Ignore changes to creation related tags
      tags["created_time"], tags["created_by"], tags["creator"],
    ]
  }
}

#--------------------------------------------------------------------------------------------------------
# Subnets Creation with, private link endpoint/servie network policies, service endpoints and Delegation.
#--------------------------------------------------------------------------------------------------------

resource "azurerm_subnet" "fw-snet" {
  count                = var.firewall_subnet_address_prefix != null ? 1 : 0
  name                 = var.firewall_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.firewall_subnet_address_prefix #[cidrsubnet(element(var.vnet_address_space, 0), 10, 0)]
  service_endpoints    = var.firewall_service_endpoints
}

resource "azurerm_subnet" "gw_snet" {
  count                = var.gateway_subnet_address_prefix != null ? 1 : 0
  name                 = var.gateway_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.gateway_subnet_address_prefix #[cidrsubnet(element(var.vnet_address_space, 0), 8, 1)]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "snet" {
  for_each                                      = var.subnets
  name                                          = each.value.subnet_name
  resource_group_name                           = local.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.subnet_address_prefix
  service_endpoints                             = lookup(each.value, "service_endpoints", [])
  private_endpoint_network_policies_enabled     = lookup(each.value, "private_endpoint_network_policies_enabled", null)
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", null)
  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}

#-----------------------------------------------
# Network security group - Default is "false"
#-----------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = lower("ng_${each.key}_in")
  resource_group_name = local.resource_group_name
  location            = local.location
  tags                = merge(var.tags, { "Name" = lower("ng_${each.key}_in") }, { "role" = var.role }, )
  dynamic "security_rule" {
    for_each = concat(lookup(each.value, "nsg_inbound_rules", []), lookup(each.value, "nsg_outbound_rules", []))
    content {
      name                       = security_rule.value[0] == "" ? "Default_Rule" : security_rule.value[0]
      priority                   = security_rule.value[1]
      direction                  = security_rule.value[2] == "" ? "Inbound" : security_rule.value[2]
      access                     = security_rule.value[3] == "" ? "Allow" : security_rule.value[3]
      protocol                   = security_rule.value[4] == "" ? "Tcp" : security_rule.value[4]
      source_port_range          = "*"
      destination_port_range     = security_rule.value[5] == "" ? "*" : security_rule.value[5]
      source_address_prefix      = security_rule.value[6] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[6]
      destination_address_prefix = security_rule.value[7] == "" ? element(each.value.subnet_address_prefix, 0) : security_rule.value[7]
      description                = "${security_rule.value[2]}_Port_${security_rule.value[5]}"
    }
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to creation related tags
      tags["created_time"], tags["created_by"], tags["creator"],
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}


#-----------------------------------------------
# DNS Zone - Default is "false"
#-----------------------------------------------
resource "azurerm_dns_zone" "dns-zone" {
  count               = local.create_dns_zone ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = local.resource_group_name
  # Hit limitation of "A maximum of 15 tags are allowed with keys no longer than 512 and values no longer than 256 characters"  
  # tags                = merge(var.tags, { "Name" = format("%s", var.dns_zone_name) }, { "role" = var.role }, )
  lifecycle {
    ignore_changes = [
      # Ignore changes to creation related tags
      tags["created_time"], tags["created_by"], tags["creator"],
    ]
  }
}