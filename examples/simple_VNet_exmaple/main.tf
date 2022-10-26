# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "vnet" {
  source = "../../"

  environment = local.environment
  role        = local.role
  tags        = local.tags
  # By default, this module will not create a resource group, proivde the name here
  # to use an existing resource group, specify the existing resource group name,
  # and set the argument to `create_resource_group = true`. Location will be same as existing RG.
  create_resource_group         = true
  resource_group_name           = local.resource_group_name
  vnetwork_name                 = local.vnetwork_name
  ddos_plan_name                = local.ddos_plan_name
  nw_resource_group_name        = local.nw_resource_group_name
  location                      = local.location
  create_dns_zone               = local.create_dns_zone
  dns_zone_name                 = local.dns_zone_name
  dns_zone_soa_record           = local.dns_zone_soa_record
  gateway_subnet_name           = local.gateway_subnet_name
  firewall_subnet_name          = local.firewall_subnet_name
  vnet_address_space            = ["10.1.0.0/16"]
  gateway_subnet_address_prefix = ["10.1.1.0/27"]

  # Adding Standard DDoS Plan, and custom DNS servers (Optional)
  # Setting to false due to limitation (DdosProtectionPlanCountLimitReached)
  create_ddos_plan = false

  # Setting to false due to limitation (NetworkWatcherCountLimitReached)
  create_network_watcher = false

  # Multiple Subnets, Service delegation, Service Endpoints, Network security groups
  # These are default subnets with required configuration, check README.md for more details
  # NSG association to be added automatically for all subnets listed here.
  # First two address ranges from VNet Address space reserved for Gateway And Firewall Subnets.
  # ex.: For 10.1.0.0/16 address space, usable address range start from 10.1.2.0/24 for all subnets.
  # subnet name will be set as per Azure naming convention by defaut. expected value here is: <App or project name>
  subnets = {
    mgnt_subnet = {
      subnet_name           = local.mgnt_subnet_name
      subnet_address_prefix = ["10.1.2.0/24"]
      service_endpoints     = ["Microsoft.Storage"]
    }

    dmz_subnet = {
      subnet_name           = local.dmz_subnet_name
      subnet_address_prefix = ["10.1.3.0/24"]
      service_endpoints     = ["Microsoft.Storage"]
    }
  }

}
