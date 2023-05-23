package components

import (
	"guku.io/devx/v1"
	k8sr "guku.io/devx/k8s"
	"guku.io/devx/v1/traits"
)

#ECRImagePullSecret: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}
	ecrImps: {
		name:             string
		accessKeySecret?: string | v1.#Secret
	}

	k8sResources: "image-pull-secret-\(ecrImps.name)": {
		k8sr.#KubernetesResource
		apiVersion: "images.banzaicloud.io/v1alpha1"
		kind:       "ImagePullSecret"
		metadata: name: ecrImps.name
		spec: {
			registry: credentials: [{
				namespace: k8s.namespace
				name:      ecrImps.name
			}]
			target: secret: name: "\(ecrImps.name)-image-pull-secret"
		}
	}
}
