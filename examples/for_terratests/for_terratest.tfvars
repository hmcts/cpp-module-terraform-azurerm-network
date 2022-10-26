environment                    = "dev"
role                           = "terratests"
location                       = "uksouth"
create_dns_zone                = true
dns_zone_soa_record            = { ttl = 3000 }
vnet_address_space             = ["10.1.0.0/16"]
gateway_subnet_address_prefix  = ["10.1.1.0/27"]
firewall_subnet_address_prefix = ["10.1.0.0/26"]
tags                           = { environment = "dev", role = "terratests", location = "uksouth", platform = "nl", tier = "testing" }
