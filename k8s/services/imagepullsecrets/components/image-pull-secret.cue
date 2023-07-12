package components

import (
	"stakpak.dev/devx/v1"
	k8sr "stakpak.dev/devx/k8s"
	"stakpak.dev/devx/v1/traits"
)

#ECRImagePullSecret: {
	traits.#KubernetesResources

	k8s: {
		namespace: string
		...
	}
	ecrImps: {
		name:            string
		target:          string | *"\(name)-image-pull-secret"
		accessKeySecret: v1.#Secret
	}

	k8sResources: "image-pull-secret-\(ecrImps.name)": {
		k8sr.#KubernetesResource
		apiVersion: "images.banzaicloud.io/v1alpha1"
		kind:       "ImagePullSecret"
		metadata: name: ecrImps.name
		spec: {
			registry: "credentials": [{
				namespace: k8s.namespace
				name:      ecrImps.accessKeySecret.name
			}]
			"target": {
				namespaces: labels: [{
					matchExpressions: [{
						key:      "ignore-imps"
						operator: "DoesNotExist"
						values: []
					}]
				}]
				secret: name: ecrImps.target
			}
		}
	}
}
