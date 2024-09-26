package main

import (
	"stakpak.dev/devx/v2alpha1"
	azure "stakpak.dev/devx/v1/transformers/terraform/azure"
)


builders: v2alpha1.#Environments & {
	prod: {
		let azureConfig = {
					resourceGroupName: "resource"
					location:          "East US"
		}
		flows: {
			// Create aks
			"terraform/azure-k8s": pipeline: [
				azure.#AddKubernetesCluster & {
					"azure": azureConfig &  {
						aks: {
							nodeSize: "Standard_D8s_v3"
							minCount: 3
							maxCount: 8
						}
					}
				},
			]
			// Create Firewall
			"azure/add-firewall": pipeline: [
				azure.#AddAzureAKSFirewall & {
					"azure": azureConfig & {
						vnetName:  "fwvnet"
					},
					policy: {
						priority: 100
						collection: {
							priority: 100
							name:     "fwtesting"
							action:   "Allow"
						}
						rule: {
							name: "fwtesting"
							source_addresses: ["*"]
							destination_addresses: ["*"]
							destination_ports: [8080, 9090]

						}
					}
				},
			]
		}
	}
}