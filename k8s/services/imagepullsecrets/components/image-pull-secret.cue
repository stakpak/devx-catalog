package components

import (
	"guku.io/devx/v1"
	"guku.io/devx/k8s"
	"guku.io/devx/v1/traits"
)

#ECRImagePullSecret: {
	traits.#KubernetesResources

	ecr: {
		name:             string
		namespace:        string
		accessKeySecret?: string | v1.#Secret
	}

	k8sResources: "image-pull-secret-\(ecr.name)": {
		k8s.#KubernetesResource
		apiVersion: "images.banzaicloud.io/v1alpha1"
		kind:       "ImagePullSecret"
		metadata: name: ecr.name
		spec: {
			registry: credentials: [{
				namespace: ecr.namespace
				name:      ecr.name
			}]
			target: secret: name: ecr.name
		}
	}
}
