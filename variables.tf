variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "uksouth"
}

variable "create_resource_group" {
  description = "Whether to create resource group and use it for all networking resources"
  default     = true
}

variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "rg-demo-uksouth-01"
}

variable "nw_resource_group_name" {
  description = "A container that holds related resources for an Azure Network Watcher"
  default     = "rg-demo-uksouth-nw"
}

variable "vnetwork_name" {
  description = "Name of your Azure Virtual Network"
  default     = "vnet-azure-uksouth-001"
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = ["10.0.0.0/16"]
}

variable "create_ddos_plan" {
  description = "Create an ddos plan - Default is false"
  default     = false
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = []
}

variable "ddos_plan_name" {
  description = "The name of AzureNetwork DDoS Protection Plan"
  default     = "azureddosplan01"
}

variable "create_network_watcher" {
  description = "Controls if Network Watcher resources should be created for the Azure subscription"
  default     = true
}

variable "subnets" {
  description = "For each subnet, create an object that contain fields"
  default     = {}
}


variable "gateway_subnet_name" {
  description = "The gateway subnet name"
  default     = null
}

variable "gateway_subnet_address_prefix" {
  description = "The address prefix to use for the gateway subnet"
  default     = null
}

variable "firewall_subnet_name" {
  description = "The firewall subnet name"
  default     = null
}

variable "firewall_subnet_address_prefix" {
  description = "The address prefix to use for the Firewall subnet"
  default     = null
}

variable "firewall_service_endpoints" {
  description = "Service endpoints to add to the firewall subnet"
  type        = list(string)
  default = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureCosmosDB",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

#####################
# DNS Zone Creation #
#####################
variable "create_dns_zone" {
  description = "Create a DNS Zone to Create alongside the VNET. Default is false"
  default     = false
}

variable "dns_zone_name" {
  description = "The name of AzureNetwork DNS Zone"
  default     = ""
}

# Add some validation later to ensure that it contans only expected entries
# email, host_name, expire_time, fqdn, minimum_ttl, refresh_time, retry_time, serial_number, ttl & tags
variable "dns_zone_soa_record" {
  description = "SOA Record to be used when creating DNS Zone"
  type        = map(string)
  default     = {}
}

############
# TAGGING  #
############

variable "environment" {
  type        = string
  description = "Environment into which resource is deployed"
  default     = ""
}

variable "role" {
  type        = string
  description = "Name of role/purpose of this resource"
  default     = ""
}

variable "platform" {
  type        = string
  description = "Live or Non-Live"
  default     = "nl"
}

variable "tier" {
  type        = string
  description = "Tier for resource? eg DMZ, IMZ."
  default     = null
}


/*
variable "tag_created_by" {
  type        = string
  description = "User who run the job when resource was created"
}

variable "tag_git_url" {
  type        = string
  description = "GIT URL of the project"
}

variable "tag_git_branch" {
  type        = string
  description = "GIT Branch from where changes being applied"
}

variable "tag_last_apply" {
  type        = string
  description = "Current timestamp when changes applied"
}

variable "tag_last_apply_by" {
  type        = string
  description = "USER ID of the person who is applying the changes"
}
*/
