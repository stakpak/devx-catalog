package traits

import (
	"stakpak.dev/devx/v1"
	k8sr "stakpak.dev/devx/k8s"
)

#KubernetesCluster: v1.#Trait & {
	$metadata: traits: KubernetesCluster: null
	k8s!: {
		name!: string
		version: {
			major:  uint | *1
			minor!: uint
			patch?: uint
		}
	}
}

#KubernetesResources: v1.#Trait & {
	$metadata: traits: KubernetesResources: null
	k8s!: {
		name!:      string
		namespace?: string
		version: {
			major:  uint | *1
			minor!: uint
			patch?: uint
		}
	}
	k8sResources!: [string]: k8sr.#KubernetesResource
}
