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
		}
	}