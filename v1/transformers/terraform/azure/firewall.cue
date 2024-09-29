package azure

import (
	"net"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	helpers "stakpak.dev/devx/v1/transformers/terraform/azure/helpers"
)

#AddAzureAKSFirewall: v1.#Transformer & {
	traits.#FirewallPolicy
	k8s:    _
	policy: _

	// Define Azure-related variables such as location, resource group, and virtual network name.
	azure: {
		location:          helpers.#Location
		resourceGroupName: string
		addressFirewall: [... string & net.IPCIDR]
		addressSourceFW: [...net.IP] // Add Source Ips for Firewall
		... // added three dots to firwall transformer to which allow fields not defined
	}

	// Define the resources section, which generates the necessary Terraform resources.
	$resources: terraform: schema.#Terraform & {
		resource: {
			// Define the Azure subnet for the firewall.
			azurerm_subnet: "\(k8s.name)_firewall_subnet": {
				name:                 "AzureFirewallSubnet"
				resource_group_name:  azure.resourceGroupName
				virtual_network_name: azure.vnetName
				address_prefixes:     azure.addressFirewall
			}

			// Define the public IP address resource for the firewall.
			azurerm_public_ip: "\(k8s.name)_firewall_public_ip": {
				name:                "\(k8s.name)-firewall-public-ip"
				location:            azure.location
				resource_group_name: azure.resourceGroupName
				allocation_method:   "Static"
				sku:                 "Standard"
			}

			// Define the Azure firewall resource.
			azurerm_firewall: "\(k8s.name)_firewall": {
				name:                "\(k8s.name)-firewall"
				location:            azure.location
				resource_group_name: azure.resourceGroupName
				sku_name:            "AZFW_VNet"
				sku_tier:            "Standard"
				ip_configuration: {
					name:                 "firewall-ip-config"
					public_ip_address_id: "azurerm_public_ip.\(k8s.name)_firewall_public_ip.id"
					subnet_id:            "azurerm_subnet.\(k8s.name)_firewall_subnet.id"
				}
			}

			// Define the Azure firewall policy resource.
			azurerm_firewall_policy: "\(k8s.name)_firewall_policy": {
				name:                "\(k8s.name)-firewall-policy"
				resource_group_name: azure.resourceGroupName
				location:            azure.location
			}

			// Define the Azure firewall policy rule collection group.
			azurerm_firewall_policy_rule_collection_group: "\(k8s.name)_firewall_rule_collection": {
				name:               "\(k8s.name)-firewall-rule-collection"
				firewall_policy_id: "azurerm_firewall_policy.\(k8s.name)_firewall_policy.id"
				priority:           policy.priority
				network_rule_collection: {
					name:     policy.collection.name
					priority: policy.collection.priority
					action:   policy.collection.action

					// Define individual rules for the firewall network rule collection.
					rule: {
						name:                  policy.rule.name
						description:           policy.rule.description
						source_addresses:      policy.rule.source_addresses
						destination_addresses: policy.rule.destination_addresses
						destination_ports:     policy.rule.destination_ports
						protocols:             policy.rule.protocols
					}
				}
			}
			// 
			data: azurerm_subnet: "\(k8s.name)_aks_subnet": {
				name:                "\(k8s.name)-aks-subnet"
				resource_group_name: azure.resourceGroupName
			}
			data: azurerm_route_table: "\(k8s.name)_aks_route_table": {
				name:                "\(k8s.name)-aks-route-table"
				resource_group_name: azure.resourceGroupName
			}
			// Associate Route Table with AKS Subnet
			azurerm_subnet_route_table_association: "\(k8s.name)_aks_route_table_assoc": {
				subnet_id:      "${data.azurerm_subnet.\(k8s.name)_aks_subnet.id}"
				route_table_id: "${data.azurerm_route_table.\(k8s.name)_aks_route_table.id}"
			}
			// Route through Azure Firewall
			azurerm_route: "\(k8s.name)_route_through_firewall": {
				name: "\(k8s.name)_firewall-route"
				//   address_prefix         : "0.0.0.0/0"
				address_prefix:         azure.addressSourceFW
				next_hop_type:          "VirtualAppliance"
				next_hop_in_ip_address: "azurerm_firewall.\(k8s.name)_firewall.ip_configuration[0].private_ip_address"
				route_table_name:       "${data.azurerm_route_table.\(k8s.name)_aks_route_table.name}"
				resource_group_name:    azure.resourceGroupName
			}

		}
	}
}
