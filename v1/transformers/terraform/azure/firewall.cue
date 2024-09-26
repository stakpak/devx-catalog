package azure

import (
    "net"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	schema "stakpak.dev/devx/v1/transformers/terraform"
	helpers "stakpak.dev/devx/v1/transformers/terraform/azure/helpers"
)

#AddAzureAKSFirewall: v1.#Transformer & {
    // This transformer accepts traits or values.
    // The #KubernetesCluster trait fetches cluster information such as the cluster name "\(k8s.name)"
	traits.#KubernetesCluster
    
    // Declare the `k8s` field. The value is left open (underscore `_`),
    // and it will be specified later.
	k8s: _

    // Define version constraints for the Kubernetes cluster.
	k8s: version: {
        major: 1                    // Major version must be 1.
        minor: <=29 & >=27          // Minor version must be between 27 and 29 (inclusive).
    }

    // Define Azure-related variables such as location, resource group, and virtual network name.
	azure: {
		location:          helpers.#Location  // Fetch the location using a helper transformer.
		resourceGroupName: string             // The name of the Azure resource group (provided as input).
        vnetName: string                      // The name of the Azure virtual network (provided as input).
		... 			// added three dots to firwall transformer to which allow fields not defined
	}

    // Define firewall policy structure (removing the previously open field `policy: _`).
 	policy: {
		priority: uint                       // Priority for the firewall policy (unsigned integer).
		collection: {
			priority: uint                   // Priority for the rule collection.
			name:     string                 // Name of the rule collection (string).
			action:   "Allow" | "Deny"       // Action: Either "Allow" or "Deny".
		}
		rule: {
			name:        string               // Name of the rule (string).
			description: string | *""          // Optional description with a default value of an empty string.
			source_addresses: [...net.IP] | ["*"]  // List of source IPs or wildcard "*" for all IPs.
			destination_addresses:  [...net.IP] | ["*"]  // List of destination IPs or wildcard "*".
			destination_ports: [...uint]       // List of destination ports (unsigned integers).
			protocols: ["UDP", "TCP"]          // Protocols allowed: UDP and TCP.
		}
	}
	addressFirewall: [... string & net.IPCIDR]  

    // Define the resources section, which generates the necessary Terraform resources.
	$resources: terraform: schema.#Terraform & {
		resource: {
			// Define the Azure subnet for the firewall.
			azurerm_subnet: "\(k8s.name)_firewall_subnet": {
				name:                 "AzureFirewallSubnet"        // Name of the subnet.
				resource_group_name:  azure.resourceGroupName      // Resource group name for the subnet.
				virtual_network_name: azure.vnetName               // Virtual network name where the subnet resides.
				address_prefixes: addressFirewall                  // CIDR block for the subnet.
			}
			
			// Define the public IP address resource for the firewall.
			azurerm_public_ip: "\(k8s.name)_firewall_public_ip": {
				name:                "\(k8s.name)-firewall-public-ip"  // Name of the public IP.
				location:            azure.location                   // Location (from input).
				resource_group_name: azure.resourceGroupName          // Resource group name for the public IP.
				allocation_method:   "Static"                         // Static IP allocation method.
				sku:                 "Standard"                       // IP SKU (Standard tier).
			}
			
			// Define the Azure firewall resource.
			azurerm_firewall: "\(k8s.name)_firewall": {
				name:                "\(k8s.name)-firewall"           // Name of the firewall.
				location:            azure.location                   // Location (from input).
				resource_group_name: azure.resourceGroupName          // Resource group name for the firewall.
				sku_name:            "AZFW_VNet"                      // Firewall SKU name (Virtual Network SKU).
				sku_tier:            "Standard"                       // Firewall SKU tier (Standard tier).
				ip_configuration: {
					name:                 "firewall-ip-config"          // IP configuration name.
					public_ip_address_id: "azurerm_public_ip.\(k8s.name)_firewall_public_ip.id" // Reference to public IP.
					subnet_id:            "azurerm_subnet.\(k8s.name)_firewall_subnet.id"      // Reference to subnet.
				}
			}
			
			// Define the Azure firewall policy resource.
			azurerm_firewall_policy: "\(k8s.name)_firewall_policy": {
				name:                "\(k8s.name)-firewall-policy"    // Name of the firewall policy.
				resource_group_name: azure.resourceGroupName          // Resource group name for the firewall policy.
				location:            azure.location                   // Location (from input).
			}
			
			// Define the Azure firewall policy rule collection group.
			azurerm_firewall_policy_rule_collection_group: "\(k8s.name)_firewall_rule_collection": {
				name:               "\(k8s.name)-firewall-rule-collection" // Name of the rule collection group.
				firewall_policy_id: "azurerm_firewall_policy.\(k8s.name)_firewall_policy.id" // Reference to firewall policy.
				priority:           policy.priority                      // Priority for the rule collection group.
				network_rule_collection: {
					name:     policy.collection.name                     // Name of the network rule collection.
					priority: policy.collection.priority                 // Priority of the network rule collection.
					action:   policy.collection.action                   // Action for the rule collection ("Allow" or "Deny").
					
					// Define individual rules for the firewall network rule collection.
					rule: {
						name:         policy.rule.name                   // Name of the rule.
						description:  policy.rule.description            // Description of the rule.
						source_addresses: policy.rule.source_addresses   // Source addresses for the rule.
						destination_addresses:  policy.rule.destination_addresses // Destination addresses for the rule.
						destination_ports:  policy.rule.destination_ports // Destination ports for the rule.
						protocols:  policy.rule.protocols                // Allowed protocols for the rule (TCP, UDP).
					}
				}
			}
		}
	}
}