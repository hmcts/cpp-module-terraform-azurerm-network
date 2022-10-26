variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "uksouth"
}

variable "role" {
  type        = string
  description = "Name of role/purpose of this resource"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment into which resource is deployed"
  default     = ""
}

variable "create_dns_zone" {
  description = "Create a DNS Zone to Create alongside the VNET. Default is false"
  default     = false
}

variable "dns_zone_soa_record" {
  description = "SOA Record to be used when creating DNS Zone"
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = ["10.0.0.0/16"]
}

variable "gateway_subnet_address_prefix" {
  description = "The address prefix to use for the gateway subnet"
  default     = null
}

variable "firewall_subnet_address_prefix" {
  description = "The address prefix to use for the firewall subnet"
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
