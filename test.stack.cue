package main

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

stack: v1.#Stack & {
    components: {
        // EKS Cluster Configuration
        cluster: {
            traits.#KubernetesCluster
            k8s: {
                name: "demo"
                version: {
                    minor: 28
                }
            }
		},
        // policyFirewall: traits.#AzureAKSPolicyFirewall & {
        policy: {
            traits.#AzureAKSPolicyFirewall
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
	    }
    }
// }