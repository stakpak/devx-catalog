package traits

import (
	"guku.io/devx/v1"
)

#KubernetesCluster: v1.#Trait & {
	$metadata: traits: KubernetesCluster: null
	k8s!: {
		name!: string
		version!: {
			major!: uint | *1
			minor!: uint
			patch?: uint
		}
	}
}
