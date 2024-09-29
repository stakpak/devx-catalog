package traits

import (
	"net"
	"stakpak.dev/devx/v1"
)

// a virtual private cloud network
#AzureAKSPolicyFirewall: v1.#Trait & {
	$metadata: traits: AzureAKSPolicyFirewall: null
	policyFirewall: {
		policy: {
			priority: uint                     
			collection: {
				priority: uint                  
				name:     string                
				action:   "Allow" | "Deny"    
		}
			rule: {
				name:        string               
				description: string | *""          
				source_addresses: [...net.IP] | ["*"]  
				destination_addresses:  [...net.IP] | ["*"]  
				destination_ports: [...uint]      
				protocols: ["UDP", "TCP"]   
				}
		}
	}
}	
