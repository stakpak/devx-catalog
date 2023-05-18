package traits

import (
	"guku.io/devx/v1"
	"guku.io/devx/k8s"
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
	k8sResources!: [string]: k8s.#KubernetesResource
}
